/**
 * 折线图组件
 *
 * 用于显示趋势数据
 */

import SwiftUI

struct LineChartView: View {
    // MARK: - 参数

    let data: [ChartDataPoint]
    let color: Color
    let height: CGFloat

    // MARK: - 计算属性

    private var maxValue: Double {
        data.map { $0.value }.max() ?? 1
    }

    private var minValue: Double {
        data.map { $0.value }.min() ?? 0
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack(alignment: .bottomLeading) {
                // 背景网格线
                backgroundGrid(width: width, height: height)

                // 折线路径
                linePath(width: width, height: height)
                    .stroke(color, lineWidth: 2)

                // 渐变填充
                gradientPath(width: width, height: height)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.3), color.opacity(0.0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // 数据点
                dataPoints(width: width, height: height)
            }
        }
        .frame(height: height)
    }

    // MARK: - 子视图

    /// 背景网格
    private func backgroundGrid(width: CGFloat, height: CGFloat) -> some View {
        Path { path in
            let horizontalLines = 4
            for i in 0...horizontalLines {
                let y = height * CGFloat(i) / CGFloat(horizontalLines)
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: width, y: y))
            }
        }
        .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 0.5, dash: [5]))
    }

    /// 折线路径
    private func linePath(width: CGFloat, height: CGFloat) -> Path {
        var path = Path()

        guard !data.isEmpty else { return path }

        let stepX = width / CGFloat(max(data.count - 1, 1))
        let range = maxValue - minValue

        for (index, point) in data.enumerated() {
            let x = stepX * CGFloat(index)
            let normalizedValue = range > 0 ? (point.value - minValue) / range : 0
            let y = height - (CGFloat(normalizedValue) * height)

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }

    /// 渐变填充路径
    private func gradientPath(width: CGFloat, height: CGFloat) -> Path {
        var path = linePath(width: width, height: height)

        guard !data.isEmpty else { return path }

        let stepX = width / CGFloat(max(data.count - 1, 1))
        let lastX = stepX * CGFloat(data.count - 1)

        path.addLine(to: CGPoint(x: lastX, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }

    /// 数据点
    private func dataPoints(width: CGFloat, height: CGFloat) -> some View {
        let stepX = width / CGFloat(max(data.count - 1, 1))
        let range = maxValue - minValue

        return ForEach(Array(data.enumerated()), id: \.offset) { index, point in
            let x = stepX * CGFloat(index)
            let normalizedValue = range > 0 ? (point.value - minValue) / range : 0
            let y = height - (CGFloat(normalizedValue) * height)

            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .offset(x: x - 3, y: y - 3)
        }
    }
}

// MARK: - 图表数据点

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

// MARK: - 预览

#Preview {
    VStack(spacing: 20) {
        Text("完成趋势")
            .font(.headline)

        LineChartView(
            data: [
                ChartDataPoint(label: "周一", value: 3),
                ChartDataPoint(label: "周二", value: 5),
                ChartDataPoint(label: "周三", value: 4),
                ChartDataPoint(label: "周四", value: 8),
                ChartDataPoint(label: "周五", value: 6),
                ChartDataPoint(label: "周六", value: 7),
                ChartDataPoint(label: "周日", value: 9)
            ],
            color: .blue,
            height: 200
        )

        // X 轴标签
        HStack {
            ForEach(["周一", "周二", "周三", "周四", "周五", "周六", "周日"], id: \.self) { day in
                Text(day)
                    .font(.caption2)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    .padding()
}
