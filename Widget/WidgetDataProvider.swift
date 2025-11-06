/**
 * Widget 数据提供者
 *
 * 从 App Group 共享容器中读取待办数据
 */

import Foundation
import SwiftData

@MainActor
final class WidgetDataProvider {
    // MARK: - App Group 配置

    /// App Group 标识符（与主应用相同）
    private static let appGroupIdentifier = "group.com.yipoo.todolist"

    // MARK: - SwiftData 容器

    /// 获取共享的 SwiftData 容器
    private static func createContainer() -> ModelContainer? {
        // 获取 App Group 共享容器 URL
        guard let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            print("❌ Widget: 无法获取 App Group 容器")
            return nil
        }

        print("📂 Widget App Group 容器路径: \(appGroupURL.path())")

        // 配置模型 Schema（需要包含所有使用的模型）
        let schema = Schema([
            User.self,
            TodoItem.self,
            Category.self,
            Subtask.self,
            PomodoroSession.self
        ])

        // 使用与主应用相同的配置（使用 groupContainer）
        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(appGroupIdentifier)
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            print("✅ Widget: SwiftData 容器初始化成功")
            return container
        } catch {
            print("❌ Widget: 无法创建 ModelContainer: \(error)")
            return nil
        }
    }

    // MARK: - 数据获取

    /// 获取今日待办事项
    static func getTodayTodos() -> [WidgetTodoItem] {
        guard let container = createContainer() else {
            return []
        }

        let context = ModelContext(container)

        // 获取今日日期范围
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        do {
            // 查询今日待办（不使用强制解包，而是使用可选绑定）
            let descriptor = FetchDescriptor<TodoItem>(
                sortBy: [
                    SortDescriptor(\.dueDate, order: .forward)
                ]
            )

            let allTodos = try context.fetch(descriptor)

            // 过滤出今日待办（在内存中过滤，避免 predicate 的强制解包问题）
            let todos = allTodos.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return dueDate >= today && dueDate < tomorrow
            }

            // 转换为 WidgetTodoItem（不展示优先级）
            return todos.map { todo in
                WidgetTodoItem(
                    id: todo.id,
                    title: todo.title,
                    isCompleted: todo.isCompleted,
                    priority: "low",  // Widget 中不展示优先级，使用默认值
                    dueDate: todo.dueDate,
                    categoryName: todo.category?.name,
                    categoryColor: todo.category?.colorHex
                )
            }
        } catch {
            print("❌ Widget: 获取今日待办失败: \(error)")
            return []
        }
    }

    /// 获取统计数据
    static func getStatistics() -> WidgetStatistics {
        guard let container = createContainer() else {
            return WidgetStatistics()
        }

        let context = ModelContext(container)

        do {
            // 获取所有待办
            let allDescriptor = FetchDescriptor<TodoItem>()
            let allTodos = try context.fetch(allDescriptor)

            // 获取今日待办（在内存中过滤，避免 predicate 的强制解包问题）
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

            let todayTodos = allTodos.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return dueDate >= today && dueDate < tomorrow
            }

            // 计算统计数据
            let totalCount = allTodos.count
            let completedCount = allTodos.filter { $0.isCompleted }.count
            let todayCompletedCount = todayTodos.filter { $0.isCompleted }.count

            return WidgetStatistics(
                totalTodos: totalCount,
                completedTodos: completedCount,
                todayCompletedTodos: todayCompletedCount
            )
        } catch {
            print("❌ Widget: 获取统计数据失败: \(error)")
            return WidgetStatistics()
        }
    }

}
