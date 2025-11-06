/**
 * 用户数据模型
 *
 * SwiftData 是 iOS 17+ 的原生数据持久化框架
 * @Model 宏自动生成数据库相关代码
 */

import Foundation
import SwiftData

@Model
final class User {
    // MARK: - 属性

    /// 唯一标识符
    @Attribute(.unique) var id: UUID

    /// 用户名（用于显示）
    var username: String

    /// 手机号码（唯一，主要登录方式）
    @Attribute(.unique) var phoneNumber: String

    /// 邮箱地址（可选）
    var email: String?

    /// 密码哈希值（可选，不存储明文密码）
    var passwordHash: String?

    /// 用户头像 URL（可选）
    var avatarURL: String?

    /// 用户头像图片数据（本地存储）
    @Attribute(.externalStorage) var avatarImageData: Data?

    /// 创建时间
    var createdAt: Date

    /// 最后登录时间
    var lastLoginAt: Date

    // MARK: - 关系

    /// 用户的所有待办事项（一对多关系）
    /// deleteRule: .cascade 表示删除用户时自动删除所有待办
    @Relationship(deleteRule: .cascade, inverse: \TodoItem.user)
    var todos: [TodoItem] = []

    /// 用户的自定义分类（一对多关系）
    @Relationship(deleteRule: .cascade, inverse: \Category.user)
    var categories: [Category] = []

    /// 用户的番茄钟记录（一对多关系）
    @Relationship(deleteRule: .cascade, inverse: \PomodoroSession.user)
    var pomodoroSessions: [PomodoroSession] = []

    // MARK: - 初始化

    init(
        id: UUID = UUID(),
        username: String,
        phoneNumber: String,
        email: String? = nil,
        passwordHash: String? = nil,
        avatarURL: String? = nil
    ) {
        self.id = id
        self.username = username
        self.phoneNumber = phoneNumber
        self.email = email
        self.passwordHash = passwordHash
        self.avatarURL = avatarURL
        self.createdAt = Date()
        self.lastLoginAt = Date()
    }

    // MARK: - 便捷方法

    /// 更新最后登录时间
    func updateLastLogin() {
        self.lastLoginAt = Date()
    }

    /// 获取今天的待办数量
    func todayTodoCount() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: today)
        }.count
    }

    /// 获取今天已完成的待办数量
    func todayCompletedCount() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: today) && todo.isCompleted
        }.count
    }
}

// MARK: - 用户设置

/// 用户设置（存储为 UserDefaults）
struct UserSettings: Codable {
    var userId: UUID

    // 通知设置
    var notificationsEnabled: Bool = true
    var dueReminder: Bool = true
    var reminderTime: Int = 9 // 提前提醒时间（小时）

    // 番茄钟设置
    var pomodoroSettings: PomodoroSettings = PomodoroSettings()

    // 界面设置
    var theme: AppTheme = .system
    var defaultView: DefaultView = .list

    enum AppTheme: String, Codable {
        case light = "浅色"
        case dark = "深色"
        case system = "跟随系统"
    }

    enum DefaultView: String, Codable {
        case list = "列表"
        case calendar = "日历"
    }
}
