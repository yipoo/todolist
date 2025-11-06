/**
 * 数据管理器
 *
 * 统一管理 SwiftData 的数据操作
 * 类似 Next.js 中的数据访问层（DAL）
 */

import Foundation
import SwiftData

@MainActor
final class DataManager {
    // MARK: - 单例

    static let shared = DataManager()

    // MARK: - 属性

    /// SwiftData 模型容器
    private(set) var container: ModelContainer

    /// 主上下文
    var context: ModelContext {
        container.mainContext
    }

    // MARK: - App Group 配置

    /// App Group 标识符（与 Widget 共享）
    private static let appGroupIdentifier = "group.com.yipoo.todolist"

    // MARK: - 初始化

    private init() {
        // 获取 App Group 共享容器 URL
        guard let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: DataManager.appGroupIdentifier
        ) else {
            fatalError("❌ 无法获取 App Group 容器: \(DataManager.appGroupIdentifier)")
        }

        print("📂 App Group 容器路径: \(appGroupURL.path())")

        // 开发模式：删除旧数据库以支持模型变更（可选）
        #if DEBUG
        // 取消注释下面的代码可以在每次启动时清空数据库
        // let defaultStoreURL = appGroupURL.appendingPathComponent("default.store")
        // if FileManager.default.fileExists(atPath: defaultStoreURL.path()) {
        //     try? FileManager.default.removeItem(at: defaultStoreURL)
        //     print("🗑️ 已删除旧数据库，将创建新数据库")
        // }
        #endif

        // 配置模型容器
        let schema = Schema([
            User.self,
            TodoItem.self,
            Category.self,
            Subtask.self,
            PomodoroSession.self
        ])

        // 使用 App Group 容器的配置
        // 使用 groupContainer 参数指定 App Group
        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(DataManager.appGroupIdentifier)
        )

        do {
            container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            print("✅ SwiftData 初始化成功（使用 App Group 共享容器）")
        } catch {
            fatalError("❌ 无法创建 ModelContainer: \(error)")
        }
    }

    // MARK: - 用户操作

    /// 创建新用户（手机号版本）
    func createUser(username: String, phoneNumber: String, email: String? = nil, passwordHash: String? = nil) throws -> User {
        let user = User(
            username: username,
            phoneNumber: phoneNumber,
            email: email,
            passwordHash: passwordHash
        )

        context.insert(user)

        // 创建系统预设分类
        let categories = Category.createSystemCategories(for: user)
        categories.forEach { context.insert($0) }

        try context.save()
        return user
    }

    /// 根据邮箱查找用户
    func findUser(byEmail email: String) -> User? {
        let predicate = #Predicate<User> { user in
            user.email == email
        }

        let descriptor = FetchDescriptor<User>(predicate: predicate)

        return try? context.fetch(descriptor).first
    }

    /// 根据用户名查找用户
    func findUser(byUsername username: String) -> User? {
        let predicate = #Predicate<User> { user in
            user.username == username
        }

        let descriptor = FetchDescriptor<User>(predicate: predicate)

        return try? context.fetch(descriptor).first
    }

    /// 根据 ID 查找用户
    func findUser(byId id: UUID) -> User? {
        let predicate = #Predicate<User> { user in
            user.id == id
        }

        let descriptor = FetchDescriptor<User>(predicate: predicate)

        return try? context.fetch(descriptor).first
    }

    /// 根据手机号查找用户
    func findUser(byPhoneNumber phoneNumber: String) -> User? {
        let predicate = #Predicate<User> { user in
            user.phoneNumber == phoneNumber
        }

        let descriptor = FetchDescriptor<User>(predicate: predicate)

        return try? context.fetch(descriptor).first
    }

    /// 更新用户最后登录时间
    func updateUserLastLogin(_ user: User) {
        user.updateLastLogin()
        try? context.save()
    }

    // MARK: - 待办事项操作

    /// 创建待办事项
    func createTodo(_ todo: TodoItem) throws {
        context.insert(todo)
        try context.save()
    }

    /// 更新待办事项
    func updateTodo(_ todo: TodoItem) throws {
        todo.updatedAt = Date()
        try context.save()
    }

    /// 删除待办事项
    func deleteTodo(_ todo: TodoItem) throws {
        context.delete(todo)
        try context.save()
    }

    /// 获取用户的所有待办（带筛选）
    func fetchTodos(
        for user: User,
        filter: TodoFilterOption = .all,
        sortBy: TodoSortOption = .createdAt
    ) -> [TodoItem] {
        // 先获取用户的所有待办
        let descriptor = FetchDescriptor<TodoItem>(
            sortBy: sortBy.descriptor()
        )

        let allTodos = (try? context.fetch(descriptor)) ?? []

        // 过滤出属于当前用户的待办
        let userTodos = allTodos.filter { $0.user?.id == user.id }

        // 根据筛选条件进一步过滤
        switch filter {
        case .all:
            return userTodos

        case .today:
            let calendar = Calendar.current
            return userTodos.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return calendar.isDateInToday(dueDate)
            }

        case .week:
            let calendar = Calendar.current
            let now = Date()
            return userTodos.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return calendar.isDate(dueDate, equalTo: now, toGranularity: .weekOfYear)
            }

        case .completed:
            return userTodos.filter { $0.isCompleted }

        case .uncompleted:
            return userTodos.filter { !$0.isCompleted }

        case .overdue:
            let now = Date()
            return userTodos.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return !todo.isCompleted && dueDate < now
            }
        }
    }

    // MARK: - 分类操作

    /// 创建分类
    func createCategory(_ category: Category) throws {
        context.insert(category)
        try context.save()
    }

    /// 更新分类
    func updateCategory(_ category: Category) throws {
        try context.save()
    }

    /// 删除分类（系统分类不能删除）
    func deleteCategory(_ category: Category) throws {
        guard !category.isSystem else {
            throw DataError.cannotDeleteSystemCategory
        }
        context.delete(category)
        try context.save()
    }

    /// 获取用户的所有分类
    func fetchCategories(for user: User) -> [Category] {
        let descriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )

        let allCategories = (try? context.fetch(descriptor)) ?? []
        return allCategories.filter { $0.user?.id == user.id }
    }

    // MARK: - 番茄钟操作

    /// 创建番茄钟会话
    func createPomodoroSession(_ session: PomodoroSession) throws {
        context.insert(session)
        try context.save()
    }

    /// 更新番茄钟会话
    func updatePomodoroSession(_ session: PomodoroSession) throws {
        try context.save()
    }

    /// 获取用户的番茄钟统计
    func fetchPomodoroStatistics(for user: User) -> PomodoroStatistics {
        let descriptor = FetchDescriptor<PomodoroSession>()
        let allSessions = (try? context.fetch(descriptor)) ?? []
        let sessions = allSessions.filter { $0.user?.id == user.id && $0.isCompleted }

        let calendar = Calendar.current
        let now = Date()

        // 今天完成的
        let todaySessions = sessions.filter {
            calendar.isDateInToday($0.startTime)
        }

        // 本周完成的
        let weekSessions = sessions.filter {
            calendar.isDate($0.startTime, equalTo: now, toGranularity: .weekOfYear)
        }

        // 本月完成的
        let monthSessions = sessions.filter {
            calendar.isDate($0.startTime, equalTo: now, toGranularity: .month)
        }

        // 计算工作时长
        let totalWorkMinutes = sessions
            .filter { $0.sessionType == .work }
            .reduce(0) { $0 + ($1.actualDuration ?? 0) }

        let todayWorkMinutes = todaySessions
            .filter { $0.sessionType == .work }
            .reduce(0) { $0 + ($1.actualDuration ?? 0) }

        return PomodoroStatistics(
            totalCompleted: sessions.count,
            todayCompleted: todaySessions.count,
            weekCompleted: weekSessions.count,
            monthCompleted: monthSessions.count,
            totalWorkMinutes: totalWorkMinutes,
            todayWorkMinutes: todayWorkMinutes,
            averagePerDay: 0, // 需要更复杂的计算
            consecutiveDays: 0, // 需要更复杂的计算
            longestStreak: 0 // 需要更复杂的计算
        )
    }

    // MARK: - 通用操作

    /// 保存上下文
    func save() throws {
        try context.save()
    }

    /// 重置所有数据（用于测试或清空）
    func resetAllData() throws {
        try context.delete(model: User.self)
        try context.delete(model: TodoItem.self)
        try context.delete(model: Category.self)
        try context.delete(model: Subtask.self)
        try context.delete(model: PomodoroSession.self)
        try context.save()
    }
}

// MARK: - 错误定义

enum DataError: LocalizedError {
    case cannotDeleteSystemCategory
    case userNotFound
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .cannotDeleteSystemCategory:
            return "系统预设分类不能删除"
        case .userNotFound:
            return "用户不存在"
        case .saveFailed:
            return "保存失败"
        }
    }
}
