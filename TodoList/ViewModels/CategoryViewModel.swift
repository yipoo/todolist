/**
 * 分类视图模型
 *
 * 管理分类的所有业务逻辑
 */

import Foundation
import SwiftUI
import Observation

@Observable
@MainActor
final class CategoryViewModel {
    // MARK: - 状态属性

    /// 所有分类
    var categories: [Category] = []

    /// 是否正在加载
    var isLoading = false

    /// 错误消息
    var errorMessage: String?

    /// 成功消息
    var successMessage: String?

    // MARK: - 依赖

    private let dataManager = DataManager.shared
    private let authViewModel: AuthViewModel

    // MARK: - 初始化

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }

    // MARK: - 数据加载

    /// 加载分类列表
    func loadCategories() {
        guard let user = authViewModel.currentUser else {
            errorMessage = "请先登录"
            return
        }

        isLoading = true

        // 获取分类列表
        categories = dataManager.fetchCategories(for: user)

        isLoading = false
    }

    /// 刷新列表
    func refresh() async {
        loadCategories()
    }

    // MARK: - 创建和更新

    /// 创建分类
    func createCategory(
        name: String,
        icon: String,
        colorHex: String
    ) async {
        guard let user = authViewModel.currentUser else {
            errorMessage = "请先登录"
            return
        }

        clearMessages()

        // 验证名称
        guard !name.trimmed.isEmpty else {
            errorMessage = "请输入分类名称"
            return
        }

        isLoading = true

        do {
            let category = Category(
                name: name.trimmed,
                icon: icon,
                colorHex: colorHex,
                sortOrder: categories.count + 1,
                user: user
            )

            try dataManager.createCategory(category)

            // 重新加载列表
            loadCategories()

            successMessage = "创建成功"
            isLoading = false

        } catch {
            errorMessage = "创建失败：\(error.localizedDescription)"
            isLoading = false
        }
    }

    /// 更新分类
    func updateCategory(_ category: Category) async {
        clearMessages()
        isLoading = true

        do {
            try dataManager.updateCategory(category)

            // 重新加载列表
            loadCategories()

            successMessage = "更新成功"
            isLoading = false

        } catch {
            errorMessage = "更新失败：\(error.localizedDescription)"
            isLoading = false
        }
    }

    /// 删除分类
    func deleteCategory(_ category: Category) async {
        clearMessages()

        // 检查是否为系统分类
        guard !category.isSystem else {
            errorMessage = "系统分类不能删除"
            return
        }

        isLoading = true

        do {
            try dataManager.deleteCategory(category)

            // 重新加载列表
            loadCategories()

            successMessage = "删除成功"
            isLoading = false

        } catch {
            errorMessage = "删除失败：\(error.localizedDescription)"
            isLoading = false
        }
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

    /// 获取分类的统计信息
    func getStatistics(for category: Category) -> CategoryStatistics {
        return CategoryStatistics(
            total: category.totalCount(),
            completed: category.completedCount(),
            uncompleted: category.uncompletedCount(),
            today: category.todayCount(),
            overdue: category.overdueCount(),
            progress: category.completionProgress()
        )
    }
}

// MARK: - 统计数据

struct CategoryStatistics {
    let total: Int
    let completed: Int
    let uncompleted: Int
    let today: Int
    let overdue: Int
    let progress: Double
}
