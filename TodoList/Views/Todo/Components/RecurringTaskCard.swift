/**
 * 循环任务卡片组件
 *
 * 用于展示自律打卡类的循环任务，以圆角矩形卡片的形式展示
 */

import SwiftUI

/// 循环边框动画视图
struct AnimatedBorderModifier: ViewModifier {
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let color: Color

    @State private var rotation: Double = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0),
                                color.opacity(0.3),
                                color.opacity(0.7),
                                color,
                                color,
                                color.opacity(0.7),
                                color.opacity(0.3),
                                color.opacity(0)
                            ]),
                            center: .center,
                            startAngle: .degrees(rotation),
                            endAngle: .degrees(rotation + 360)
                        ),
                        lineWidth: lineWidth
                    )
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 3)
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}

extension View {
    func animatedBorder(cornerRadius: CGFloat, lineWidth: CGFloat, color: Color) -> some View {
        self.modifier(AnimatedBorderModifier(cornerRadius: cornerRadius, lineWidth: lineWidth, color: color))
    }
}

/// 条件动画边框修饰符
struct ConditionalAnimatedBorder: ViewModifier {
    let isEnabled: Bool
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let color: Color

    func body(content: Content) -> some View {
        Group {
            if isEnabled {
                content.animatedBorder(cornerRadius: cornerRadius, lineWidth: lineWidth, color: color)
            } else {
                content
            }
        }
    }
}

struct RecurringTaskCard: View {
    let todo: TodoItem
    let onToggle: () -> Void
    let onEdit: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    init(todo: TodoItem, onToggle: @escaping () -> Void, onEdit: (() -> Void)? = nil) {
        self.todo = todo
        self.onToggle = onToggle
        self.onEdit = onEdit
    }

    // 计算文字颜色
    private var textColor: Color {
        let isChecked = todo.isCheckedInToday()

        if isChecked {
            // 已完成：使用背景色的对比色
            let baseColor = Color(hex: todo.recurringColor ?? "#4A90E2")
            return baseColor.contrastingTextColor
        } else {
            // 未完成（灰色背景）：根据系统主题选择
            return colorScheme == .dark ? .white : Color.black.opacity(0.8)
        }
    }

    // 计算次要文字颜色（统计信息）
    private var secondaryTextColor: Color {
        let isChecked = todo.isCheckedInToday()

        if isChecked {
            // 已完成：使用背景色的柔和对比色
            let baseColor = Color(hex: todo.recurringColor ?? "#4A90E2")
            return baseColor.softContrastingTextColor
        } else {
            // 未完成（灰色背景）：根据系统主题选择
            return colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.6)
        }
    }

    // 计算图标颜色
    private var iconColor: Color {
        return textColor
    }

    // 计算图标背景颜色
    private var iconBackgroundColor: Color {
        return textColor.opacity(0.2)
    }

    var body: some View {
        frontCard
            .contentShape(Rectangle()) // 确保整个区域都能响应手势
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        // 触觉反馈
                        #if os(iOS)
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        #endif

                        // 直接触发编辑回调，显示整合页面
                        onEdit?()
                    }
            )
    }

    // 正面卡片
    private var frontCard: some View {
        VStack(spacing: 8) {
            // 上方图标和打卡标记
            HStack {
                // 左上角图标
                iconView
                    .frame(maxWidth: .infinity, alignment: .leading)

                // 右上角打卡标记
                checkmarkView
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Spacer()

            // 底部任务标题
            Text(todo.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(textColor)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            // 统计信息
            HStack(spacing: 6) {
                // 连续打卡天数
                if todo.streakDays > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 9))
                        Text("\(todo.streakDays)")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(secondaryTextColor)
                }

                // 分隔符
                if todo.streakDays > 0 && todo.thisWeekCheckInCount() > 0 {
                    Text("·")
                        .foregroundColor(secondaryTextColor.opacity(0.7))
                        .font(.system(size: 10))
                }

                // 本周打卡次数
                let weekCount = todo.thisWeekCheckInCount()
                if weekCount > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "calendar")
                            .font(.system(size: 9))
                        Text("\(weekCount)次")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(secondaryTextColor)
                }
            }
        }
        .padding(12)
        .frame(width: 120, height: 120)
        .background(backgroundGradient)
        .cornerRadius(16)
        // 未完成时添加动态边框
        .modifier(
            ConditionalAnimatedBorder(
                isEnabled: !todo.isCheckedInToday(),
                cornerRadius: 16,
                lineWidth: 1,
                color: Color(hex: todo.recurringColor ?? "#4A90E2")
            )
        )
        .onTapGesture {
            onToggle()
        }
    }

    // 图标视图
    private var iconView: some View {
        Group {
            if let iconName = todo.recurringIcon {
                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 32, height: 32)
                    .background(iconBackgroundColor)
                    .clipShape(Circle())
            } else {
                Image(systemName: "star.fill")
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 32, height: 32)
                    .background(iconBackgroundColor)
                    .clipShape(Circle())
            }
        }
    }

    // 打卡标记视图
    private var checkmarkView: some View {
        Group {
            if todo.isCheckedInToday() {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(textColor)
            } else {
                Image(systemName: "circle")
                    .font(.system(size: 24))
                    .foregroundColor(textColor.opacity(0.4))
                    .overlay(
                        Circle()
                            .strokeBorder(textColor.opacity(0.6), lineWidth: 2)
                    )
            }
        }
    }

    // 背景渐变
    private var backgroundGradient: LinearGradient {
        let baseColor = Color(hex: todo.recurringColor ?? "#4A90E2")
        let isChecked = todo.isCheckedInToday()

        if isChecked {
            // 已完成：鲜艳的渐变色
            return LinearGradient(
                gradient: Gradient(colors: [baseColor, baseColor.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            // 未完成：灰暗的颜色
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.6),
                    Color.gray.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - 预览

#Preview("已打卡") {
    let todo = TodoItem(title: "早起打卡")
    todo.isRecurring = true
    todo.recurringType = .daily
    todo.recurringColor = "#FF6B6B"
    todo.recurringIcon = "sun.max.fill"
    todo.streakDays = 15
    todo.checkInDates = ["2025-01-10", "2025-01-11", "2025-01-12"]

    return RecurringTaskCard(todo: todo) {
        print("Toggle check-in")
    }
    .padding()
}

#Preview("未打卡") {
    let todo = TodoItem(title: "健身打卡")
    todo.isRecurring = true
    todo.recurringType = .daily
    todo.recurringColor = "#4ECDC4"
    todo.recurringIcon = "figure.run"
    todo.streakDays = 7

    return RecurringTaskCard(todo: todo) {
        print("Toggle check-in")
    }
    .padding()
}

#Preview("多个卡片") {
    let todo1 = TodoItem(title: "早起打卡")
    todo1.isRecurring = true
    todo1.recurringColor = "#FF6B6B"
    todo1.recurringIcon = "sun.max.fill"
    todo1.streakDays = 15

    let todo2 = TodoItem(title: "健身打卡")
    todo2.isRecurring = true
    todo2.recurringColor = "#4ECDC4"
    todo2.recurringIcon = "figure.run"
    todo2.streakDays = 7

    let todo3 = TodoItem(title: "阅读打卡")
    todo3.isRecurring = true
    todo3.recurringColor = "#95E1D3"
    todo3.recurringIcon = "book.fill"

    return HStack(spacing: 12) {
        RecurringTaskCard(todo: todo1) {}
        RecurringTaskCard(todo: todo2) {}
        RecurringTaskCard(todo: todo3) {}
    }
    .padding()
}
