/**
 * 饼图组件
 *
 * 用于显示百分比分布数据
 */

import SwiftUI

struct PieChartView: View {
    // MARK: - 参数

    let data: [PieSliceData]
    let size: CGFloat

    // MARK: - Body

    var body: some View {
        ZStack {
            // 绘制饼图
            ForEach(Array(data.enumerated()), id: \.offset) { index, slice in
                PieSlice(
                    startAngle: startAngle(for: index),
                    endAngle: endAngle(for: index),
                    color: slice.color
                )
            }

            // 中心白色圆（环形图效果）
            Circle()
                .fill(Color(.systemBackground))
                .frame(width: size * 0.5, height: size * 0.5)
        }
        .frame(width: size, height: size)
    }

    // MARK: - 辅助方法

    /// 计算起始角度
    private func startAngle(for index: Int) -> Angle {
        let previousTotal = data.prefix(index).reduce(0) { $0 + $1.value }
        let total = data.reduce(0) { $0 + $1.value }

        guard total > 0 else { return .degrees(0) }

        return .degrees(Double(previousTotal) / Double(total) * 360 - 90)
    }

    /// 计算结束角度
    private func endAngle(for index: Int) -> Angle {
        let currentTotal = data.prefix(index + 1).reduce(0) { $0 + $1.value }
        let total = data.reduce(0) { $0 + $1.value }

        guard total > 0 else { return .degrees(0) }

        return .degrees(Double(currentTotal) / Double(total) * 360 - 90)
    }
}

// MARK: - 饼图切片

struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = min(geometry.size.width, geometry.size.height)
                let height = width
                let center = CGPoint(x: width / 2, y: height / 2)

                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: width / 2,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
            }
            .fill(color)
        }
    }
}

// MARK: - 饼图数据

struct PieSliceData: Identifiable {
    let id = UUID()
    let value: Int
    let color: Color
    let label: String
}

// MARK: - 预览

#Preview {
    VStack(spacing: 20) {
        PieChartView(
            data: [
                PieSliceData(value: 40, color: .red, label: "高"),
                PieSliceData(value: 30, color: .orange, label: "中"),
                PieSliceData(value: 20, color: .blue, label: "低")
            ],
            size: 200
        )

        // 图例
        HStack(spacing: 20) {
            ForEach([
                (Color.red, "高 40%"),
                (Color.orange, "中 30%"),
                (Color.blue, "低 20%")
            ], id: \.1) { color, text in
                HStack(spacing: 4) {
                    Circle()
                        .fill(color)
                        .frame(width: 12, height: 12)
                    Text(text)
                        .font(.caption)
                }
            }
        }
    }
    .padding()
}
