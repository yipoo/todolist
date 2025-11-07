/**
 * View 扩展
 *
 * 为所有 SwiftUI 视图添加便捷方法
 */

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

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

    /// 指定边的圆角（使用 SwiftUI 原生 API）
    func cornerRadius(_ radius: CGFloat, corners: RectangleCorner) -> some View {
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
//            .background(.systemBackground)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // MARK: - 键盘

    /// 点击隐藏键盘（使用 SwiftUI focused 状态）
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            #if canImport(UIKit) && !os(watchOS)
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
            #endif
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

// MARK: - 辅助类型

/// 矩形角的枚举（SwiftUI 版本）
struct RectangleCorner: OptionSet {
    let rawValue: Int
    
    static let topLeft = RectangleCorner(rawValue: 1 << 0)
    static let topRight = RectangleCorner(rawValue: 1 << 1)
    static let bottomLeft = RectangleCorner(rawValue: 1 << 2)
    static let bottomRight = RectangleCorner(rawValue: 1 << 3)
    
    static let allCorners: RectangleCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    static let topCorners: RectangleCorner = [.topLeft, .topRight]
    static let bottomCorners: RectangleCorner = [.bottomLeft, .bottomRight]
    static let leftCorners: RectangleCorner = [.topLeft, .bottomLeft]
    static let rightCorners: RectangleCorner = [.topRight, .bottomRight]
}

// MARK: - 辅助视图

/// 自定义圆角形状（纯 SwiftUI 实现）
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: RectangleCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topLeft = corners.contains(.topLeft) ? radius : 0
        let topRight = corners.contains(.topRight) ? radius : 0
        let bottomLeft = corners.contains(.bottomLeft) ? radius : 0
        let bottomRight = corners.contains(.bottomRight) ? radius : 0
        
        path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
        
        // 顶部边
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        
        // 右上角
        if topRight > 0 {
            path.addArc(
                center: CGPoint(x: rect.maxX - topRight, y: rect.minY + topRight),
                radius: topRight,
                startAngle: .degrees(-90),
                endAngle: .degrees(0),
                clockwise: false
            )
        }
        
        // 右侧边
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        
        // 右下角
        if bottomRight > 0 {
            path.addArc(
                center: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY - bottomRight),
                radius: bottomRight,
                startAngle: .degrees(0),
                endAngle: .degrees(90),
                clockwise: false
            )
        }
        
        // 底部边
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        
        // 左下角
        if bottomLeft > 0 {
            path.addArc(
                center: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY - bottomLeft),
                radius: bottomLeft,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
        }
        
        // 左侧边
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        
        // 左上角
        if topLeft > 0 {
            path.addArc(
                center: CGPoint(x: rect.minX + topLeft, y: rect.minY + topLeft),
                radius: topLeft,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )
        }
        
        path.closeSubpath()
        return path
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
