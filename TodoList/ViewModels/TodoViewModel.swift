/**
 * 待办事项视图模型
 *
 * 管理待办事项的所有业务逻辑
 * 与 React 对比：类似于 Context + Reducer 的组合
 */

import Foundation
import SwiftUI
import Observation

@Observable
@MainActor
final class TodoViewModel {
    // MARK: - 状态属性

    /// 所有待办事项
    var todos: [TodoItem] = []

    /// 当前筛选条件
    var currentFilter: TodoFilterOption = .all

    /// 当前排序方式
    var currentSort: TodoSortOption = .createdAt

    /// 搜索关键词
    var searchText = ""

    /// 是否正在加载
    var isLoading = false

    /// 错误消息
    var errorMessage: String?

    /// 成功消息
    var successMessage: String?

    /// 选中的分类
    var selectedCategory: Category?

    // MARK: - 计算属性

    /// 筛选后的待办列表
    var filteredTodos: [TodoItem] {
        var result = todos

        // 按分类筛选
        if let category = selectedCategory {
            result = result.filter { $0.category?.id == category.id }
        }

        // 搜索筛选
        if !searchText.isEmpty {
            result = result.filter { todo in
                todo.title.localizedCaseInsensitiveContains(searchText) ||
                (todo.itemDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        // 排序逻辑：
        // 1. 已完成的排到最后
        // 2. 未完成的按优先级排序（高 -> 中 -> 低）
        // 3. 相同优先级按截止日期倒序（最近的在前）
        result.sort { todo1, todo2 in
            // 第一优先级：未完成的排在前面
            if todo1.isCompleted != todo2.isCompleted {
                return !todo1.isCompleted
            }

            // 如果都是未完成的，按优先级和截止日期排序
            if !todo1.isCompleted {
                // 第二优先级：按优先级排序（high < medium < low，所以高优先级在前）
                if todo1.priority != todo2.priority {
                    return todo1.priority.rawValue < todo2.priority.rawValue
                }

                // 第三优先级：按截止日期排序（最近的在前）
                if let date1 = todo1.dueDate, let date2 = todo2.dueDate {
                    return date1 < date2
                }
                // 有截止日期的排在没有截止日期的前面
                if todo1.dueDate != nil {
                    return true
                }
                if todo2.dueDate != nil {
                    return false
                }
            }

            // 其他情况保持原顺序（都是已完成的，按完成时间）
            return false
        }

        return result
    }

    /// 统计信息
    var statistics: TodoStatistics {
        let total = todos.count
        let completed = todos.filter { $0.isCompleted }.count
        let pending = total - completed
        let today = todos.filter { $0.isToday() }.count
        let overdue = todos.filter { $0.isOverdue() }.count

        return TodoStatistics(
            total: total,
            completed: completed,
            pending: pending,
            today: today,
            overdue: overdue
        )
    }

    // MARK: - 依赖

    private let dataManager = DataManager.shared
    private let authViewModel: AuthViewModel

    // MARK: - 初始化

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }

    // MARK: - 数据加载

    /// 加载待办列表
    func loadTodos() {
        guard let user = authViewModel.currentUser else {
            errorMessage = "请先登录"
            return
        }

        isLoading = true

        // 获取待办列表
        todos = dataManager.fetchTodos(
            for: user,
            filter: currentFilter,
            sortBy: currentSort
        )

        isLoading = false
    }

    /// 刷新列表
    func refresh() async {
        loadTodos()
    }

    // MARK: - 创建和更新

    /// 创建待办
    func createTodo(
        title: String,
        description: String? = nil,
        priority: Priority = .medium,
        dueDate: Date? = nil,
        category: Category? = nil,
        tags: [String] = []
    ) async {
        guard let user = authViewModel.currentUser else {
            errorMessage = "请先登录"
            return
        }

        clearMessages()

        // 验证标题
        guard !title.trimmed.isEmpty else {
            errorMessage = "请输入待办标题"
            return
        }

        isLoading = true

        do {
            let todo = TodoItem(
                title: title.trimmed,
                itemDescription: description?.trimmed,
                priority: priority,
                tags: tags,
                dueDate: dueDate,
                category: category,
                user: user
            )

            try dataManager.createTodo(todo)

            // 重新加载列表
            loadTodos()

            successMessage = "创建成功"
            isLoading = false

        } catch {
            errorMessage = "创建失败：\(error.localizedDescription)"
            isLoading = false
        }
    }

    /// 更新待办
    func updateTodo(_ todo: TodoItem) async {
        clearMessages()
        isLoading = true

        do {
            try dataManager.updateTodo(todo)

            // 重新加载列表
            loadTodos()

            successMessage = "更新成功"
            isLoading = false

        } catch {
            errorMessage = "更新失败：\(error.localizedDescription)"
            isLoading = false
        }
    }

    /// 切换完成状态
    func toggleCompletion(_ todo: TodoItem) async {
        todo.toggleCompletion()
        await updateTodo(todo)
    }

    /// 删除待办
    func deleteTodo(_ todo: TodoItem) async {
        clearMessages()
        isLoading = true

        do {
            try dataManager.deleteTodo(todo)

            // 重新加载列表
            loadTodos()

            successMessage = "删除成功"
            isLoading = false

        } catch {
            errorMessage = "删除失败：\(error.localizedDescription)"
            isLoading = false
        }
    }

    /// 批量删除
    func deleteTodos(_ todos: [TodoItem]) async {
        clearMessages()
        isLoading = true

        var failCount = 0

        for todo in todos {
            do {
                try dataManager.deleteTodo(todo)
            } catch {
                failCount += 1
            }
        }

        // 重新加载列表
        loadTodos()

        if failCount == 0 {
            successMessage = "删除成功"
        } else {
            errorMessage = "删除失败 \(failCount) 项"
        }

        isLoading = false
    }

    // MARK: - 筛选和排序

    /// 更新筛选条件
    func updateFilter(_ filter: TodoFilterOption) {
        currentFilter = filter
        loadTodos()
    }

    /// 更新排序方式
    func updateSort(_ sort: TodoSortOption) {
        currentSort = sort
        loadTodos()
    }

    /// 按分类筛选
    func filterByCategory(_ category: Category?) {
        selectedCategory = category
    }

    // MARK: - 子任务管理

    /// 添加子任务
    func addSubtask(to todo: TodoItem, title: String) async {
        guard !title.trimmed.isEmpty else {
            errorMessage = "请输入子任务标题"
            return
        }

        let subtask = Subtask(
            title: title.trimmed,
            todo: todo
        )

        todo.subtasks.append(subtask)
        await updateTodo(todo)
    }

    /// 删除子任务
    func deleteSubtask(_ subtask: Subtask, from todo: TodoItem) async {
        todo.subtasks.removeAll { $0.id == subtask.id }
        await updateTodo(todo)
    }

    /// 切换子任务完成状态
    func toggleSubtask(_ subtask: Subtask, in todo: TodoItem) async {
        subtask.toggleCompletion()
        await updateTodo(todo)
    }

    // MARK: - 辅助方法

    /// 清空消息
    private func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }

    /// 公开的清空消息方法（供视图调用）
    func clearMessagesPublic() {
        clearMessages()
    }

    /// 获取今日待办数量
    func getTodayTodoCount() -> Int {
        return todos.filter { $0.isToday() && !$0.isCompleted }.count
    }

    /// 获取逾期待办数量
    func getOverdueTodoCount() -> Int {
        return todos.filter { $0.isOverdue() && !$0.isCompleted }.count
    }
}

// MARK: - 统计数据

struct TodoStatistics {
    let total: Int
    let completed: Int
    let pending: Int
    let today: Int
    let overdue: Int

    var completionRate: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }
}
