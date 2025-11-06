/**
 * 个人中心视图模型
 *
 * 管理个人中心的数据和业务逻辑
 */

import Foundation
import SwiftUI
import SwiftData

@Observable
@MainActor
final class ProfileViewModel {
    // MARK: - 属性
    
    private let dataManager = DataManager.shared
    private let authViewModel: AuthViewModel
    
    var todos: [TodoItem] = []
    var categories: [Category] = []
    var isDataLoaded = false

    var isLoading = false
    var errorMessage: String?
    var successMessage: String?

    // MARK: - ViewModels

    var categoryViewModel: CategoryViewModel
    
    // MARK: - 初始化
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        self.categoryViewModel = CategoryViewModel(authViewModel: authViewModel)
    }
    
    // MARK: - 数据加载
    
    func loadData() {
        guard let user = authViewModel.currentUser else { return }
        todos = dataManager.fetchTodos(for: user)
        categoryViewModel.loadCategories()
        categories = categoryViewModel.categories
        isDataLoaded = true
    }
    
    // MARK: - 统计数据
    
    /// 已完成任务数
    var completedTaskCount: Int {
        todos.filter { $0.isCompleted }.count
    }
    
    /// 进行中任务数
    var activeTaskCount: Int {
        todos.filter { !$0.isCompleted }.count
    }
    
    /// 总番茄钟数
    var totalPomodoroCount: Int {
        todos.reduce(0) { $0 + $1.pomodoroCount }
    }
    
    /// 完成率
    var completionRate: Double {
        guard todos.count > 0 else { return 0 }
        return Double(completedTaskCount) / Double(todos.count)
    }
    
    /// 分类数量
    var categoryCount: Int {
        categories.count
    }

    // MARK: - 头像管理

    /// 获取用户头像
    func getAvatarImage() -> UIImage? {
        guard let user = authViewModel.currentUser,
              let data = user.avatarImageData else {
            return nil
        }

        return UIImage(data: data)
    }

    /// 更新用户头像
    func updateAvatar(_ image: UIImage) async {
        guard let user = authViewModel.currentUser else {
            errorMessage = "用户未登录"
            return
        }

        isLoading = true
        errorMessage = nil

        // 压缩图片
        guard let imageData = compressImage(image) else {
            errorMessage = "图片处理失败"
            isLoading = false
            return
        }

        // 保存到用户模型
        user.avatarImageData = imageData

        do {
            try dataManager.context.save()
            successMessage = "头像更新成功"
        } catch {
            errorMessage = "保存失败: \(error.localizedDescription)"
        }

        isLoading = false

        // 清除消息
        clearMessagesAfterDelay()
    }

    /// 删除用户头像
    func deleteAvatar() async {
        guard let user = authViewModel.currentUser else { return }

        user.avatarImageData = nil

        do {
            try dataManager.context.save()
            successMessage = "头像已删除"
        } catch {
            errorMessage = "删除失败: \(error.localizedDescription)"
        }

        clearMessagesAfterDelay()
    }

    // MARK: - 个人信息更新

    /// 更新用户名
    func updateUsername(_ newUsername: String) async {
        guard let user = authViewModel.currentUser else { return }

        let trimmed = newUsername.trimmed
        guard !trimmed.isEmpty else {
            errorMessage = "用户名不能为空"
            return
        }

        isLoading = true
        user.username = trimmed

        do {
            try dataManager.context.save()
            successMessage = "用户名更新成功"
        } catch {
            errorMessage = "保存失败: \(error.localizedDescription)"
        }

        isLoading = false
        clearMessagesAfterDelay()
    }

    /// 更新邮箱
    func updateEmail(_ newEmail: String) async {
        guard let user = authViewModel.currentUser else { return }

        let trimmed = newEmail.trimmed
        guard !trimmed.isEmpty else {
            user.email = nil
            try? dataManager.context.save()
            return
        }

        guard Validators.isValidEmail(trimmed) else {
            errorMessage = "邮箱格式不正确"
            return
        }

        isLoading = true
        user.email = trimmed

        do {
            try dataManager.context.save()
            successMessage = "邮箱更新成功"
        } catch {
            errorMessage = "保存失败: \(error.localizedDescription)"
        }

        isLoading = false
        clearMessagesAfterDelay()
    }

    // MARK: - 辅助方法

    /// 压缩图片
    private func compressImage(_ image: UIImage) -> Data? {
        // 调整图片大小到合适的尺寸（300x300）
        let size = CGSize(width: 300, height: 300)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: CGRect(origin: .zero, size: size))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        // 压缩为 JPEG，质量 0.7
        return resizedImage.jpegData(compressionQuality: 0.7)
    }

    /// 清除消息
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }

    /// 延迟清除消息
    private func clearMessagesAfterDelay() {
        Task {
            try? await Task.sleep(for: .seconds(2))
            clearMessages()
        }
    }
}

