/**
 * 认证视图模型
 *
 * 处理登录、注册、登出等认证逻辑
 * 使用 @Observable 替代传统的 ObservableObject（iOS 17+）
 *
 * 与 React 对比：
 * - @Observable ≈ Context API / Zustand
 * - 自动追踪状态变化，无需手动 @Published
 */

import Foundation
import SwiftUI
import Observation

@Observable
@MainActor
final class AuthViewModel {
    // MARK: - 状态属性

    /// 当前登录的用户
    var currentUser: User?

    /// 是否已登录
    var isAuthenticated: Bool {
        currentUser != nil
    }

    /// 是否正在加载
    var isLoading = false

    /// 错误消息
    var errorMessage: String?

    /// 成功消息
    var successMessage: String?

    // MARK: - 依赖

    private let dataManager = DataManager.shared
    private let keychainManager = KeychainManager.shared

    // MARK: - 初始化

    init() {
        // 尝试从缓存恢复登录状态
        restoreLoginState()
    }

    // MARK: - 登录

    /// 登录
    /// - Parameters:
    ///   - email: 邮箱或用户名
    ///   - password: 密码
    ///   - rememberMe: 是否记住登录状态
    func login(email: String, password: String, rememberMe: Bool = false) async {
        // 清空之前的消息
        clearMessages()

        // 验证输入
        let validation = FormValidation.validateLoginForm(email: email, password: password)
        guard validation.isValid else {
            errorMessage = validation.errorMessage
            return
        }

        // 开始加载
        isLoading = true

        // 模拟网络延迟（实际项目中会调用 API）
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 查找用户
        let user = dataManager.findUser(byEmail: email.trimmed) ??
                   dataManager.findUser(byUsername: email.trimmed)

        guard let user = user else {
            isLoading = false
            errorMessage = "用户不存在"
            return
        }

        // 验证密码
        let hashedPassword = KeychainManager.hashPassword(password)
        guard user.passwordHash == hashedPassword else {
            isLoading = false
            errorMessage = "密码错误"
            return
        }

        // 登录成功
        currentUser = user
        dataManager.updateUserLastLogin(user)

        // 保存登录状态
        if rememberMe {
            saveLoginState(userId: user.id)
        }

        // 保存密码到 Keychain（可选）
        if rememberMe {
            _ = keychainManager.savePassword(password, for: user.username)
        }

        isLoading = false
        successMessage = "登录成功"

        // 发送登录通知
        NotificationCenter.default.post(name: NotificationNames.userDidLogin, object: user)
    }

    // MARK: - 注册

    /// 注册新用户
    func register(
        username: String,
        email: String,
        password: String,
        confirmPassword: String
    ) async {
        // 清空之前的消息
        clearMessages()

        // 验证输入
        let validation = FormValidation.validateRegistrationForm(
            username: username,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )

        guard validation.isValid else {
            errorMessage = validation.errorMessage
            return
        }

        // 开始加载
        isLoading = true

        // 模拟网络延迟
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 检查用户名是否已存在
        if dataManager.findUser(byUsername: username.trimmed) != nil {
            isLoading = false
            errorMessage = "用户名已被占用"
            return
        }

        // 检查邮箱是否已存在
        if dataManager.findUser(byEmail: email.trimmed) != nil {
            isLoading = false
            errorMessage = "邮箱已被注册"
            return
        }

        // 创建用户
        let hashedPassword = KeychainManager.hashPassword(password)

        do {
            let user = try dataManager.createUser(
                username: username.trimmed,
                phoneNumber: "",  // 老版本注册，使用空手机号
                email: email.trimmed,
                passwordHash: hashedPassword
            )

            // 自动登录
            currentUser = user
            saveLoginState(userId: user.id)

            // 保存密码到 Keychain
            _ = keychainManager.savePassword(password, for: user.username)

            isLoading = false
            successMessage = "注册成功"

            // 发送登录通知
            NotificationCenter.default.post(name: NotificationNames.userDidLogin, object: user)

        } catch {
            isLoading = false
            errorMessage = "注册失败：\(error.localizedDescription)"
        }
    }

    // MARK: - 登出

    /// 登出
    func logout() {
        currentUser = nil
        clearLoginState()
        keychainManager.clearAll()

        // 发送登出通知
        NotificationCenter.default.post(name: NotificationNames.userDidLogout, object: nil)

        successMessage = "已退出登录"
    }

    // MARK: - 密码管理

    /// 修改密码
    func changePassword(oldPassword: String, newPassword: String) async {
        guard let user = currentUser else {
            errorMessage = "请先登录"
            return
        }

        clearMessages()

        // 验证旧密码
        let oldHashedPassword = KeychainManager.hashPassword(oldPassword)
        guard user.passwordHash == oldHashedPassword else {
            errorMessage = "原密码错误"
            return
        }

        // 验证新密码
        let validation = Validators.validatePassword(newPassword)
        guard validation.isValid else {
            errorMessage = validation.errorMessage
            return
        }

        isLoading = true

        // 更新密码
        let newHashedPassword = KeychainManager.hashPassword(newPassword)
        user.passwordHash = newHashedPassword

        do {
            try dataManager.save()
            _ = keychainManager.savePassword(newPassword, for: user.username)

            isLoading = false
            successMessage = "密码修改成功"
        } catch {
            isLoading = false
            errorMessage = "密码修改失败"
        }
    }

    // MARK: - 第三方登录（预留）

    /// 微信登录（预留接口）
    func loginWithWechat() async {
        errorMessage = "微信登录功能即将推出"
        // TODO: 实现微信登录
    }

    /// Apple ID 登录（预留接口）
    func loginWithApple() async {
        errorMessage = "Apple ID 登录功能即将推出"
        // TODO: 实现 Apple ID 登录
    }

    // MARK: - 私有方法

    /// 保存登录状态到 UserDefaults
    private func saveLoginState(userId: UUID) {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isLoggedIn)
        UserDefaults.standard.set(userId.uuidString, forKey: UserDefaultsKeys.currentUserId)
    }

    /// 清除登录状态
    private func clearLoginState() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isLoggedIn)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.currentUserId)
    }

    /// 恢复登录状态
    private func restoreLoginState() {
        guard UserDefaults.standard.bool(forKey: UserDefaultsKeys.isLoggedIn),
              let userIdString = UserDefaults.standard.string(forKey: UserDefaultsKeys.currentUserId),
              let userId = UUID(uuidString: userIdString)
        else {
            return
        }

        // 从数据库恢复用户
        currentUser = dataManager.findUser(byId: userId)
    }

    /// 清空消息
    private func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }

    // MARK: - 手机号登录（新）

    /// 手机号密码登录
    func loginWithPassword(phoneNumber: String, password: String) async {
        clearMessages()

        // 验证手机号
        let phoneValidation = Validators.validatePhoneNumber(phoneNumber)
        guard phoneValidation.isValid else {
            errorMessage = phoneValidation.errorMessage
            return
        }

        // 验证密码
        guard !password.isEmpty else {
            errorMessage = "请输入密码"
            return
        }

        isLoading = true

        // 模拟网络延迟
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 查找用户
        guard let user = dataManager.findUser(byPhoneNumber: phoneNumber) else {
            isLoading = false
            errorMessage = "手机号未注册"
            return
        }

        // 验证密码
        let hashedPassword = KeychainManager.hashPassword(password)
        guard user.passwordHash == hashedPassword else {
            isLoading = false
            errorMessage = "密码错误"
            return
        }

        // 登录成功
        currentUser = user
        dataManager.updateUserLastLogin(user)
        saveLoginState(userId: user.id)

        isLoading = false
        successMessage = "登录成功"

        NotificationCenter.default.post(name: NotificationNames.userDidLogin, object: user)
    }

    /// 手机号验证码登录
    func loginWithVerificationCode(phoneNumber: String, code: String) async {
        clearMessages()

        // 验证手机号
        let phoneValidation = Validators.validatePhoneNumber(phoneNumber)
        guard phoneValidation.isValid else {
            errorMessage = phoneValidation.errorMessage
            return
        }

        // 验证验证码
        let codeValidation = Validators.validateVerificationCode(code)
        guard codeValidation.isValid else {
            errorMessage = codeValidation.errorMessage
            return
        }

        isLoading = true

        // 模拟网络延迟
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 验证验证码（实际项目中应该调用后端 API）
        // 这里模拟验证码为 "123456"
        guard code == "123456" else {
            isLoading = false
            errorMessage = "验证码错误"
            return
        }

        // 查找用户
        guard let user = dataManager.findUser(byPhoneNumber: phoneNumber) else {
            isLoading = false
            errorMessage = "手机号未注册"
            return
        }

        // 登录成功
        currentUser = user
        dataManager.updateUserLastLogin(user)
        saveLoginState(userId: user.id)

        isLoading = false
        successMessage = "登录成功"

        NotificationCenter.default.post(name: NotificationNames.userDidLogin, object: user)
    }

    /// 手机号注册
    func registerWithPhone(phoneNumber: String, username: String, password: String) async {
        clearMessages()

        // 验证手机号
        let phoneValidation = Validators.validatePhoneNumber(phoneNumber)
        guard phoneValidation.isValid else {
            errorMessage = phoneValidation.errorMessage
            return
        }

        // 验证用户名
        let usernameValidation = Validators.validateUsername(username)
        guard usernameValidation.isValid else {
            errorMessage = usernameValidation.errorMessage
            return
        }

        // 验证密码
        let passwordValidation = Validators.validatePassword(password)
        guard passwordValidation.isValid else {
            errorMessage = passwordValidation.errorMessage
            return
        }

        isLoading = true

        // 模拟网络延迟
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 检查手机号是否已注册
        if dataManager.findUser(byPhoneNumber: phoneNumber) != nil {
            isLoading = false
            errorMessage = "手机号已被注册"
            return
        }

        // 检查用户名是否已存在
        if dataManager.findUser(byUsername: username.trimmed) != nil {
            isLoading = false
            errorMessage = "用户名已被占用"
            return
        }

        // 创建用户
        let hashedPassword = KeychainManager.hashPassword(password)

        do {
            let user = try dataManager.createUser(
                username: username.trimmed,
                phoneNumber: phoneNumber,
                passwordHash: hashedPassword
            )

            // 自动登录
            currentUser = user
            saveLoginState(userId: user.id)

            isLoading = false
            successMessage = "注册成功"

            NotificationCenter.default.post(name: NotificationNames.userDidLogin, object: user)

        } catch {
            isLoading = false
            errorMessage = "注册失败：\(error.localizedDescription)"
        }
    }

    /// 发送验证码
    func sendVerificationCode(to phoneNumber: String) async {
        clearMessages()

        // 验证手机号
        let validation = Validators.validatePhoneNumber(phoneNumber)
        guard validation.isValid else {
            errorMessage = validation.errorMessage
            return
        }

        // 模拟发送验证码
        try? await Task.sleep(nanoseconds: 500_000_000)

        // 实际项目中这里应该调用后端 API 发送验证码
        // 这里仅作演示
        successMessage = "验证码已发送"
    }

    /// 检查手机号是否已注册
    func isPhoneNumberRegistered(_ phoneNumber: String) -> Bool {
        return dataManager.findUser(byPhoneNumber: phoneNumber) != nil
    }

    // MARK: - 辅助方法

    /// 获取密码强度
    func getPasswordStrength(_ password: String) -> PasswordStrength {
        return Validators.passwordStrength(password)
    }

    /// 检查用户名是否可用
    func isUsernameAvailable(_ username: String) -> Bool {
        return dataManager.findUser(byUsername: username.trimmed) == nil
    }

    /// 检查邮箱是否可用
    func isEmailAvailable(_ email: String) -> Bool {
        return dataManager.findUser(byEmail: email.trimmed) == nil
    }
}
