/**
 * 统计卡片组件
 *
 * 用于显示单个统计指标
 */

import SwiftUI

struct StatCard: View {
    // MARK: - 参数

    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String?

    init(
        title: String,
        value: String,
        icon: String,
        color: Color,
        trend: String? = nil
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.trend = trend
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 图标和趋势
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }

                Spacer()

                if let trend = trend {
                    Text(trend)
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }

            // 数值
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            // 标题
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(Layout.mediumCornerRadius)
    }
}

// MARK: - 预览

#Preview {
    VStack(spacing: 16) {
        StatCard(
            title: "总任务",
            value: "42",
            icon: "checkmark.circle.fill",
            color: .blue,
            trend: "+12%"
        )

        StatCard(
            title: "已完成",
            value: "28",
            icon: "checkmark.circle.fill",
            color: .green
        )

        StatCard(
            title: "进行中",
            value: "14",
            icon: "clock.fill",
            color: .orange
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
