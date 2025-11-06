/**
 * 第三方登录按钮组件
 *
 * 可复用的第三方登录按钮
 * 预留微信、Apple ID 等登录方式
 */

import SwiftUI

struct SocialLoginButton: View {
    // MARK: - 属性

    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // 图标
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }

                // 标题
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 预设按钮

extension SocialLoginButton {
    /// 微信登录按钮
    static func wechat(action: @escaping () -> Void) -> some View {
        SocialLoginButton(
            icon: "message.fill",
            title: "微信",
            color: .green,
            action: action
        )
    }

    /// Apple ID 登录按钮
    static func apple(action: @escaping () -> Void) -> some View {
        SocialLoginButton(
            icon: "apple.logo",
            title: "Apple",
            color: .black,
            action: action
        )
    }

    /// Google 登录按钮（预留）
    static func google(action: @escaping () -> Void) -> some View {
        SocialLoginButton(
            icon: "globe",
            title: "Google",
            color: .red,
            action: action
        )
    }
}

// MARK: - 预览

#Preview {
    HStack(spacing: 20) {
        SocialLoginButton.wechat {
            print("微信登录")
        }

        SocialLoginButton.apple {
            print("Apple 登录")
        }

        SocialLoginButton.google {
            print("Google 登录")
        }
    }
    .padding()
}
