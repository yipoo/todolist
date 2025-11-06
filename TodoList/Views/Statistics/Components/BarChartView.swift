/**
 * 柱状图组件
 *
 * 用于显示对比数据
 */

import SwiftUI

struct BarChartView: View {
    // MARK: - 参数

    let data: [BarChartData]
    let height: CGFloat

    // MARK: - 计算属性

    private var maxValue: Double {
        data.map { $0.value }.max() ?? 1
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let barWidth = (width - CGFloat(data.count + 1) * 8) / CGFloat(data.count)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 4) {
                        // 数值标签
                        Text("\(Int(item.value))")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        // 柱子
                        RoundedRectangle(cornerRadius: 4)
                            .fill(item.color)
                            .frame(
                                width: barWidth,
                                height: max(heightFor(value: item.value), 4)
                            )

                        // X 轴标签
                        Text(item.label)
                            .font(.caption2)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .frame(width: barWidth)
                    }
                }
            }
            .frame(height: height)
        }
        .frame(height: height + 40) // 额外空间给标签
    }

    // MARK: - 辅助方法

    /// 计算柱子高度
    private func heightFor(value: Double) -> CGFloat {
        guard maxValue > 0 else { return 0 }
        return CGFloat(value / maxValue) * height
    }
}

// MARK: - 柱状图数据

struct BarChartData: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
}

// MARK: - 预览

#Preview {
    VStack(spacing: 20) {
        Text("每日完成统计")
            .font(.headline)

        BarChartView(
            data: [
                BarChartData(label: "周一", value: 3, color: .blue),
                BarChartData(label: "周二", value: 5, color: .blue),
                BarChartData(label: "周三", value: 4, color: .blue),
                BarChartData(label: "周四", value: 8, color: .blue),
                BarChartData(label: "周五", value: 6, color: .blue),
                BarChartData(label: "周六", value: 7, color: .blue),
                BarChartData(label: "周日", value: 9, color: .blue)
            ],
            height: 150
        )
    }
    .padding()
}
