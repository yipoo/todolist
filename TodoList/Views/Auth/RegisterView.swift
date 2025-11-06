/**
 * 注册界面
 *
 * 用户注册页面
 * 包含表单验证和密码强度提示
 */

import SwiftUI

struct RegisterView: View {
    // MARK: - 环境

    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - 状态

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreeToTerms = false
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var showToast = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: Layout.largeSpacing) {
                // 标题
                headerView

                // 注册表单
                registerForm

                // 密码强度指示器
                passwordStrengthIndicator

                // 服务条款
                termsToggle

                // 注册按钮
                registerButton

                // 登录链接
                loginLink
            }
            .padding(Layout.largePadding)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("创建账号")
        .navigationBarTitleDisplayMode(.inline)
        // Toast 提示
        .toast(
            isPresented: $showToast,
            message: authViewModel.errorMessage ?? authViewModel.successMessage ?? "",
            type: authViewModel.errorMessage != nil ? .error : .success
        )
        .onChange(of: authViewModel.errorMessage) { _, newValue in
            if newValue != nil {
                showToast = true
            }
        }
        .onChange(of: authViewModel.successMessage) { _, newValue in
            if newValue != nil {
                showToast = true
                // 注册成功后自动关闭
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if authViewModel.isAuthenticated {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - 子视图

    /// 头部视图
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("加入 TodoList")
                .font(.title)
                .fontWeight(.bold)

            Text("创建账号，开始高效管理任务")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }

    /// 注册表单
    private var registerForm: some View {
        VStack(spacing: Layout.mediumSpacing) {
            // 用户名
            FormField(
                icon: "person",
                placeholder: "用户名（3-20个字符）",
                text: $username
            )

            // 邮箱
            FormField(
                icon: "envelope",
                placeholder: "邮箱地址",
                text: $email,
                keyboardType: .emailAddress
            )

            // 密码
            PasswordField(
                icon: "lock",
                placeholder: "密码（至少8位，包含字母和数字）",
                text: $password,
                isVisible: $isPasswordVisible
            )

            // 确认密码
            PasswordField(
                icon: "lock.fill",
                placeholder: "确认密码",
                text: $confirmPassword,
                isVisible: $isConfirmPasswordVisible
            )
        }
    }

    /// 密码强度指示器
    @ViewBuilder
    private var passwordStrengthIndicator: some View {
        if !password.isEmpty {
            let strength = authViewModel.getPasswordStrength(password)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("密码强度：")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(strength.description)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: strength.color))
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)

                        // 进度
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: strength.color))
                            .frame(width: geometry.size.width * strength.progress, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
    }

    /// 服务条款
    private var termsToggle: some View {
        Toggle(isOn: $agreeToTerms) {
            HStack(spacing: 4) {
                Text("我已阅读并同意")
                    .font(.caption)

                Button(action: {
                    // TODO: 显示服务条款
                }) {
                    Text("《服务条款》")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
    }

    /// 注册按钮
    private var registerButton: some View {
        Button(action: handleRegister) {
            HStack {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("注册")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Layout.buttonHeight)
            .background(
                LinearGradient(
                    colors: [.purple, .pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(Layout.mediumCornerRadius)
        }
        .disabled(authViewModel.isLoading || !isFormValid)
        .opacity(isFormValid ? 1.0 : 0.6)
    }

    /// 登录链接
    private var loginLink: some View {
        HStack {
            Text("已有账号？")
                .foregroundColor(.secondary)

            Button(action: {
                dismiss()
            }) {
                Text("立即登录")
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .font(.subheadline)
    }

    // MARK: - 方法

    /// 处理注册
    private func handleRegister() {
        Task {
            await authViewModel.register(
                username: username,
                email: email,
                password: password,
                confirmPassword: confirmPassword
            )
        }
    }

    /// 表单验证
    private var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        agreeToTerms
    }
}

// MARK: - 辅助组件

/// 表单输入框
struct FormField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)

            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(keyboardType)
        }
        .padding()
        .frame(height: 50)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

/// 密码输入框
struct PasswordField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)

            if isVisible {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } else {
                SecureField(placeholder, text: $text)
            }

            Button(action: {
                isVisible.toggle()
            }) {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(height: 50)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

// MARK: - 预览

#Preview {
    NavigationStack {
        RegisterView()
            .environment(AuthViewModel())
    }
}
