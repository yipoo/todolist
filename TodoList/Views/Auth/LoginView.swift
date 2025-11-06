/**
 * 登录界面
 *
 * 用户登录页面，支持邮箱/用户名登录
 * 包含"记住我"和第三方登录（预留）
 */

import SwiftUI

struct LoginView: View {
    // MARK: - 环境对象

    @Environment(AuthViewModel.self) private var authViewModel

    // MARK: - 状态

    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var isPasswordVisible = false
    @State private var showToast = false

    // MARK: - 导航

    @State private var showRegister = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.largeSpacing) {
                    // Logo 和标题
                    headerView

                    // 登录表单
                    loginForm

                    // 记住我
                    rememberMeToggle

                    // 登录按钮
                    loginButton

                    // 忘记密码（预留）
                    forgotPasswordButton

                    // 分割线
                    dividerView

                    // 第三方登录（预留）
                    socialLoginSection

                    // 注册链接
                    registerLink
                }
                .padding(Layout.largePadding)
            }
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            // Toast 提示
            .toast(
                isPresented: $showToast,
                message: authViewModel.errorMessage ?? authViewModel.successMessage ?? "",
                type: authViewModel.errorMessage != nil ? .error : .success
            )
            // 监听错误和成功消息
            .onChange(of: authViewModel.errorMessage) { _, newValue in
                if newValue != nil {
                    showToast = true
                }
            }
            .onChange(of: authViewModel.successMessage) { _, newValue in
                if newValue != nil {
                    showToast = true
                }
            }
        }
    }

    // MARK: - 子视图

    /// 头部视图
    private var headerView: some View {
        VStack(spacing: Layout.mediumSpacing) {
            // App 图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)

            // 标题
            VStack(spacing: 8) {
                Text("欢迎回来")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("登录以继续使用 TodoList")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, Layout.largePadding)
    }

    /// 登录表单
    private var loginForm: some View {
        VStack(spacing: Layout.mediumSpacing) {
            // 邮箱/用户名输入
            VStack(alignment: .leading, spacing: 8) {
                Label("邮箱或用户名", systemImage: "envelope")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextField("请输入邮箱或用户名", text: $email)
                    .padding()
                    .frame(height: 50)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
            }

            // 密码输入
            VStack(alignment: .leading, spacing: 8) {
                Label("密码", systemImage: "lock")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    if isPasswordVisible {
                        TextField("请输入密码", text: $password)
                    } else {
                        SecureField("请输入密码", text: $password)
                    }

                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(height: 50)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
            }
        }
    }

    /// 记住我选项
    private var rememberMeToggle: some View {
        Toggle(isOn: $rememberMe) {
            Text("记住我")
                .font(.subheadline)
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
    }

    /// 登录按钮
    private var loginButton: some View {
        Button(action: handleLogin) {
            HStack {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("登录")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Layout.buttonHeight)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
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

    /// 忘记密码按钮
    private var forgotPasswordButton: some View {
        Button(action: {
            // TODO: 实现忘记密码功能
        }) {
            Text("忘记密码？")
                .font(.subheadline)
                .foregroundColor(.blue)
        }
    }

    /// 分割线
    private var dividerView: some View {
        HStack {
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1)

            Text("或")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)

            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1)
        }
    }

    /// 第三方登录区域
    private var socialLoginSection: some View {
        VStack(spacing: Layout.mediumSpacing) {
            Text("第三方登录")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: Layout.mediumSpacing) {
                // 微信登录（预留）
                SocialLoginButton(
                    icon: "message.fill",
                    title: "微信",
                    color: .green
                ) {
                    Task {
                        await authViewModel.loginWithWechat()
                    }
                }

                // Apple ID 登录（预留）
                SocialLoginButton(
                    icon: "apple.logo",
                    title: "Apple",
                    color: .black
                ) {
                    Task {
                        await authViewModel.loginWithApple()
                    }
                }
            }
        }
    }

    /// 注册链接
    private var registerLink: some View {
        HStack {
            Text("还没有账号？")
                .foregroundColor(.secondary)

            Button(action: {
                showRegister = true
            }) {
                Text("立即注册")
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .font(.subheadline)
    }

    // MARK: - 方法

    /// 处理登录
    private func handleLogin() {
        Task {
            await authViewModel.login(
                email: email,
                password: password,
                rememberMe: rememberMe
            )
        }
    }

    /// 表单验证
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
}

// MARK: - 预览

#Preview {
    LoginView()
        .environment(AuthViewModel())
}
