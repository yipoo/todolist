/**
 * 添加待办 App Intent
 *
 * iOS 17+ Interactive Widget 功能
 * 允许用户直接在 Widget 上添加待办事项
 */

import Foundation
import AppIntents
import SwiftData
import WidgetKit

/// 添加待办事项的 Intent
struct AddTodoIntent: AppIntent {
    // MARK: - Intent 配置

    static var title: LocalizedStringResource = "添加待办"
    static var description = IntentDescription("快速添加一个待办事项")

    // MARK: - 参数

    /// 待办标题
    @Parameter(title: "待办内容", requestValueDialog: "请输入待办事项")
    var todoTitle: String

    // MARK: - 执行

    @MainActor
    func perform() async throws -> some IntentResult {
        // 验证输入
        let trimmedTitle = todoTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw AddTodoError.emptyTitle
        }

        // 获取共享数据容器
        guard let container = createContainer() else {
            throw AddTodoError.containerError
        }

        let context = ModelContext(container)

        // 获取当前用户（简化版：使用第一个用户）
        let userDescriptor = FetchDescriptor<User>()
        guard let user = try? context.fetch(userDescriptor).first else {
            throw AddTodoError.noUser
        }

        // 获取默认分类（工作分类）
        let categoryDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate<Category> { category in
                category.isSystem == true
            },
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        let defaultCategory = try? context.fetch(categoryDescriptor).first

        // 创建待办事项
        let newTodo = TodoItem(
            title: trimmedTitle,
            itemDescription: nil,
            priority: .medium,
            dueDate: Date(), // 默认今天
            category: defaultCategory,
            user: user
        )

        context.insert(newTodo)

        do {
            try context.save()
            print("✅ Widget: 成功添加待办「\(trimmedTitle)」")

            // 刷新 Widget 显示
            await refreshWidgets()

            return .result(
                dialog: "已添加待办「\(trimmedTitle)」"
            )
        } catch {
            print("❌ Widget: 添加待办失败: \(error)")
            throw AddTodoError.saveFailed
        }
    }

    // MARK: - 辅助方法

    /// 创建共享数据容器
    @MainActor
    private func createContainer() -> ModelContainer? {
        let appGroupIdentifier = "group.com.yipoo.todolist"

        let schema = Schema([
            User.self,
            TodoItem.self,
            Category.self,
            Subtask.self,
            PomodoroSession.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(appGroupIdentifier)
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            return container
        } catch {
            print("❌ Widget: 无法创建 ModelContainer: \(error)")
            return nil
        }
    }

    /// 刷新所有 Widget
    private func refreshWidgets() async {
        await MainActor.run {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

// MARK: - 错误定义

enum AddTodoError: LocalizedError {
    case emptyTitle
    case containerError
    case noUser
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "待办内容不能为空"
        case .containerError:
            return "无法访问数据存储"
        case .noUser:
            return "未找到用户信息"
        case .saveFailed:
            return "保存失败"
        }
    }
}
