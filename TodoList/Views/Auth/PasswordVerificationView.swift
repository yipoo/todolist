/**
 * 密码/验证码验证界面
 *
 * 根据用户是否存在显示不同的界面：
 * - 老用户：显示密码输入 + 验证码登录切换
 * - 新用户：显示设置密码 + 用户名输入
 */

import SwiftUI

struct PasswordVerificationView: View {
    // MARK: - 环境

    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - 参数

    let phoneNumber: String

    // MARK: - 状态

    @State private var loginMode: LoginMode = .password
    @State private var password = ""
    @State private var verificationCode = ""
    @State private var username = ""
    @State private var isPasswordVisible = false
    @State private var showToast = false
    @State private var isNewUser = false
    @State private var countdown = 60
    @State private var isCountingDown = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: Layout.largeSpacing) {
                // 手机号显示
                phoneNumberDisplay

                // 根据用户类型显示不同内容
                if isNewUser {
                    newUserSection
                } else {
                    existingUserSection
                }

                // 登录/注册按钮
                actionButton

                Spacer()
            }
            .padding(Layout.largePadding)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(isNewUser ? "注册" : "登录")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
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
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { _, newValue in
            if newValue {
                // 登录成功，延迟后自动关闭
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            }
        }
        .onAppear {
            checkUserExists()
        }
    }

    // MARK: - 子视图

    /// 手机号显示
    private var phoneNumberDisplay: some View {
        HStack {
            Image(systemName: "phone.fill")
                .foregroundColor(.secondary)

            Text(formatPhoneNumber(phoneNumber))
                .font(.title3)
                .fontWeight(.medium)

            Spacer()

            Button(action: {
                dismiss()
            }) {
                Text("更换")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
    }

    /// 新用户注册区域
    private var newUserSection: some View {
        VStack(spacing: Layout.mediumSpacing) {
            Spacer()
            Text("欢迎注册 TodoList")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)

            // 用户名输入
            VStack(alignment: .leading, spacing: 8) {
                TextField("请输入用户名（3-20个字符）", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .frame(height: 50)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
            }

            // 密码输入
            VStack(alignment: .leading, spacing: 8) {
                Label("设置密码", systemImage: "lock")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    if isPasswordVisible {
                        TextField("至少8位，包含字母和数字", text: $password)
                    } else {
                        SecureField("至少8位，包含字母和数字", text: $password)
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

            // 密码强度指示器
            if !password.isEmpty {
                passwordStrengthIndicator
            }
        }
    }

    /// 老用户登录区域
    private var existingUserSection: some View {
        VStack(spacing: Layout.mediumSpacing) {
            Text("欢迎回来")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 登录方式切换
            Picker("登录方式", selection: $loginMode) {
                Text("密码登录").tag(LoginMode.password)
                Text("验证码登录").tag(LoginMode.verificationCode)
            }
            .pickerStyle(.segmented)

            // 根据登录方式显示不同输入框
            if loginMode == .password {
                passwordInputField
            } else {
                verificationCodeInputField
            }
        }
    }

    /// 密码输入框
    private var passwordInputField: some View {
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

    /// 验证码输入框
    private var verificationCodeInputField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("验证码", systemImage: "number")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                TextField("请输入验证码", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .frame(maxWidth: .infinity)

                // 获取验证码按钮
                Button(action: sendVerificationCode) {
                    if isCountingDown {
                        Text("\(countdown)s")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("获取验证码")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .disabled(isCountingDown)
            }
            .padding()
            .frame(height: 50)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)
        }
    }

    /// 密码强度指示器
    @ViewBuilder
    private var passwordStrengthIndicator: some View {
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

    /// 登录/注册按钮
    private var actionButton: some View {
        Button(action: handleAction) {
            HStack {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(isNewUser ? "注册" : "登录")
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

    // MARK: - 方法

    /// 检查用户是否存在
    private func checkUserExists() {
        isNewUser = !authViewModel.isPhoneNumberRegistered(phoneNumber)
    }

    /// 发送验证码
    private func sendVerificationCode() {
        // 开始倒计时
        isCountingDown = true
        countdown = 60

        // 模拟发送验证码
        Task {
            await authViewModel.sendVerificationCode(to: phoneNumber)
        }

        // 倒计时
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdown -= 1
            if countdown == 0 {
                timer.invalidate()
                isCountingDown = false
                countdown = 60
            }
        }
    }

    /// 处理登录/注册
    private func handleAction() {
        Task {
            if isNewUser {
                // 注册
                await authViewModel.registerWithPhone(
                    phoneNumber: phoneNumber,
                    username: username,
                    password: password
                )
            } else {
                // 登录
                if loginMode == .password {
                    await authViewModel.loginWithPassword(
                        phoneNumber: phoneNumber,
                        password: password
                    )
                } else {
                    await authViewModel.loginWithVerificationCode(
                        phoneNumber: phoneNumber,
                        code: verificationCode
                    )
                }
            }
        }
    }

    /// 格式化手机号显示
    private func formatPhoneNumber(_ phone: String) -> String {
        guard phone.count == 11 else { return phone }
        let index1 = phone.index(phone.startIndex, offsetBy: 3)
        let index2 = phone.index(phone.startIndex, offsetBy: 7)
        return "\(phone[..<index1]) \(phone[index1..<index2]) \(phone[index2...])"
    }

    /// 表单验证
    private var isFormValid: Bool {
        if isNewUser {
            return !username.isEmpty && !password.isEmpty
        } else {
            if loginMode == .password {
                return !password.isEmpty
            } else {
                return verificationCode.count == 6
            }
        }
    }
}

// MARK: - 登录方式枚举

enum LoginMode {
    case password
    case verificationCode
}

// MARK: - 预览

#Preview("新用户注册") {
    NavigationStack {
        PasswordVerificationView(phoneNumber: "13800138000")
            .environment(AuthViewModel())
    }
}

#Preview("老用户登录") {
    // 预览专用包装视图 - 模拟老用户场景
    struct OldUserPreviewView: View {
        @Environment(AuthViewModel.self) private var authViewModel
        @Environment(\.dismiss) private var dismiss

        let phoneNumber: String

        // 强制设置为老用户
        @State private var loginMode: LoginMode = .password
        @State private var password = ""
        @State private var verificationCode = ""
        @State private var isPasswordVisible = false
        @State private var showToast = false
        @State private var countdown = 60
        @State private var isCountingDown = false

        var body: some View {
            ScrollView {
                VStack(spacing: Layout.largeSpacing) {
                    // 手机号显示
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.secondary)

                        Text(formatPhoneNumber(phoneNumber))
                            .font(.title3)
                            .fontWeight(.medium)

                        Spacer()

                        Button(action: {}) {
                            Text("更换")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(Layout.mediumCornerRadius)

                    // 老用户登录区域
                    VStack(spacing: Layout.mediumSpacing) {
                        Text("欢迎回来")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // 登录方式切换
                        Picker("登录方式", selection: $loginMode) {
                            Text("密码登录").tag(LoginMode.password)
                            Text("验证码登录").tag(LoginMode.verificationCode)
                        }
                        .pickerStyle(.segmented)

                        // 根据登录方式显示不同输入框
                        if loginMode == .password {
                            passwordInputField
                        } else {
                            verificationCodeInputField
                        }
                    }

                    // 登录按钮
                    Button(action: {}) {
                        Text("登录")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: Layout.buttonHeight)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(Layout.mediumCornerRadius)
                    }

                    Spacer()
                }
                .padding(Layout.largePadding)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("登录")
            .navigationBarTitleDisplayMode(.inline)
        }

        private var passwordInputField: some View {
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

                    Button(action: { isPasswordVisible.toggle() }) {
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

        private var verificationCodeInputField: some View {
            VStack(alignment: .leading, spacing: 8) {
                Label("验证码", systemImage: "number")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    TextField("请输入验证码", text: $verificationCode)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: .infinity)

                    Button(action: {}) {
                        Text(isCountingDown ? "\(countdown)s" : "获取验证码")
                            .font(.subheadline)
                            .foregroundColor(isCountingDown ? .secondary : .blue)
                    }
                    .disabled(isCountingDown)
                }
                .padding()
                .frame(height: 50)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
            }
        }

        private func formatPhoneNumber(_ phone: String) -> String {
            guard phone.count == 11 else { return phone }
            let prefix = phone.prefix(3)
            let suffix = phone.suffix(4)
            return "\(prefix) **** \(suffix)"
        }
    }

    return NavigationStack {
        OldUserPreviewView(phoneNumber: "13800138000")
            .environment(AuthViewModel())
    }
}
