/**
 * 手机号登录界面（新版）
 *
 * 两步式登录流程：
 * 步骤1：输入手机号
 * 步骤2：输入密码或验证码（根据是否为新用户）
 */

import SwiftUI

struct PhoneLoginView: View {
    // MARK: - 环境

    @Environment(AuthViewModel.self) private var authViewModel

    // MARK: - 状态

    @State private var phoneNumber = ""
    @State private var showNextStep = false
    @State private var showToast = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: Layout.largeSpacing) {
                Spacer()

                // Logo 和标题
                headerView

                // 手机号输入
                phoneInputSection

                // 继续按钮
                continueButton

                Spacer()

                // 分割线
                dividerView

                // 第三方登录
                socialLoginSection

                // 底部提示
                bottomHint
            }
            .padding(Layout.largePadding)
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $showNextStep) {
                PasswordVerificationView(phoneNumber: phoneNumber)
            }
            // Toast 提示
            .toast(
                isPresented: $showToast,
                message: authViewModel.errorMessage ?? "",
                type: .error
            )
            .onChange(of: authViewModel.errorMessage) { _, newValue in
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
                Text("欢迎使用 TodoList")
                    .font(.largeTitle)
                    .fontWeight(.bold)

//                Text("使用手机号登录或注册")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, Layout.largePadding)
    }

    /// 手机号输入区域
    private var phoneInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 25) {
                // 国旗图标
//                Text("🇨🇳")
//                    .font(.title2)
//
//                // 区号
//                Text("+86")
//                    .font(.body)
//                    .foregroundColor(.primary)
//
//                // 分隔线
//                Rectangle()
//                    .fill(Color(.systemGray4))
//                    .frame(width: 1, height: 24)

                // 手机号输入框
                TextField("请输入手机号", text: $phoneNumber)
                    .keyboardType(.numberPad)
                    .font(.body)
            }
            .padding()
            .frame(height: 50)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)
        }
    }

    /// 继续按钮
    private var continueButton: some View {
        Button(action: handleContinue) {
            HStack {
                Text("继续")
                    .fontWeight(.semibold)

                Image(systemName: "arrow.right")
                    .font(.subheadline)
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
        .disabled(!isPhoneValid)
        .opacity(isPhoneValid ? 1.0 : 0.6)
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
        .padding(.vertical, Layout.mediumSpacing)
    }

    /// 第三方登录区域
    private var socialLoginSection: some View {
        VStack(spacing: Layout.mediumSpacing) {
            Text("第三方登录")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: Layout.mediumSpacing) {
                // 微信登录
                SocialLoginButton.wechat {
                    Task {
                        await authViewModel.loginWithWechat()
                    }
                }
                .disabled(true)

                // Apple ID 登录
                SocialLoginButton.apple {
                    Task {
                        await authViewModel.loginWithApple()
                    }
                }
                .disabled(true)
            }
        }
    }

    /// 底部提示
    private var bottomHint: some View {
        HStack(spacing: Layout.smallPadding) {
            Text("继续即表示同意")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("《用户协议》")
                .font(.caption)
                .foregroundColor(.blue)
            Text("和")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("《隐私政策》")
                .font(.caption)
                .foregroundColor(.blue)
        }
        
    }

    // MARK: - 方法

    /// 处理继续按钮点击
    private func handleContinue() {
        // 验证手机号
        let validation = Validators.validatePhoneNumber(phoneNumber)
        guard validation.isValid else {
            authViewModel.errorMessage = validation.errorMessage
            return
        }

        // 跳转到下一步
        showNextStep = true
    }

    /// 手机号是否有效
    private var isPhoneValid: Bool {
        phoneNumber.count == 11
    }
}

// MARK: - 预览

#Preview {
    PhoneLoginView()
        .environment(AuthViewModel())
}
