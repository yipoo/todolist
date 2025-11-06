/**
 * View 扩展
 *
 * 为所有 SwiftUI 视图添加便捷方法
 */

import SwiftUI

extension View {
    // MARK: - 条件修饰符

    /// 根据条件应用修饰符
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// 根据可选值应用修饰符
    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }

    // MARK: - 圆角

    /// 指定边的圆角
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    // MARK: - 隐藏

    /// 根据条件隐藏视图
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }

    // MARK: - 卡片样式

    /// 应用卡片样式
    func cardStyle(
        padding: CGFloat = Layout.mediumPadding,
        cornerRadius: CGFloat = Layout.mediumCornerRadius
    ) -> some View {
        self
            .padding(padding)
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - 键盘

    /// 点击隐藏键盘
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }

    // MARK: - 加载状态

    /// 显示加载指示器
    func loading(_ isLoading: Bool) -> some View {
        ZStack {
            self.disabled(isLoading)

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
        }
    }

    // MARK: - Toast 提示

    /// 显示 Toast 提示
    func toast(
        isPresented: Binding<Bool>,
        message: String,
        type: ToastType = .info
    ) -> some View {
        self.overlay(
            ToastView(
                isPresented: isPresented,
                message: message,
                type: type
            )
        )
    }
}

// MARK: - 辅助视图

/// 自定义圆角形状
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

/// Toast 视图
struct ToastView: View {
    @Binding var isPresented: Bool
    let message: String
    let type: ToastType
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            if isPresented {
                HStack(spacing: 12) {
                    Image(systemName: type.icon)
                        .font(.title3)

                    Text(message)
                        .font(.subheadline)
                }
                .foregroundColor(type.foregroundColor(for: colorScheme))
                .padding()
                .background(type.backgroundColor(for: colorScheme))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.2), radius: 8, x: 0, y: 2)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 50)
        .animation(.spring(), value: isPresented)
    }
}

enum ToastType {
    case success
    case error
    case warning
    case info

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }

    /// 背景颜色（适配浅色/深色模式）
    func backgroundColor(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .success:
            return colorScheme == .dark ? Color.green.opacity(0.3) : Color.green
        case .error:
            return colorScheme == .dark ? Color.red.opacity(0.3) : Color.red
        case .warning:
            return colorScheme == .dark ? Color.orange.opacity(0.3) : Color.orange
        case .info:
            return colorScheme == .dark ? Color.blue.opacity(0.3) : Color.blue
        }
    }

    /// 前景颜色（适配浅色/深色模式）
    func foregroundColor(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .success:
            return colorScheme == .dark ? Color.green.opacity(0.9) : .white
        case .error:
            return colorScheme == .dark ? Color.red.opacity(0.9) : .white
        case .warning:
            return colorScheme == .dark ? Color.orange.opacity(0.9) : .white
        case .info:
            return colorScheme == .dark ? Color.blue.opacity(0.9) : .white
        }
    }
}
