/**
 * 打卡热力图组件
 *
 * 以日历形式展示打卡历史记录
 */

import SwiftUI

struct CheckInHeatmapView: View {
    let checkInDates: [String]
    let baseColor: Color
    let weeksToShow: Int

    init(checkInDates: [String], baseColor: Color = .blue, weeksToShow: Int = 12) {
        self.checkInDates = checkInDates
        self.baseColor = baseColor
        self.weeksToShow = weeksToShow
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 标题
            HStack {
                Text("打卡历史")
                    .font(.headline)
                Spacer()
                Text("最近\(weeksToShow)周")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 热力图
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 4) {
                    ForEach(generateWeeks(), id: \.self) { week in
                        VStack(spacing: 4) {
                            ForEach(0..<7, id: \.self) { dayIndex in
                                let date = Calendar.current.date(
                                    byAdding: .day,
                                    value: dayIndex,
                                    to: week
                                )!
                                dayCell(for: date)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // 图例
            legend
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // 生成周列表（从最早到最近）
    private func generateWeeks() -> [Date] {
        let calendar = Calendar.current
        var weeks: [Date] = []

        // 从今天开始往前推
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromSunday = (weekday == 1) ? 0 : (weekday - 1)

        // 找到本周周日
        guard let thisSunday = calendar.date(
            byAdding: .day,
            value: -daysFromSunday,
            to: today
        ) else { return [] }

        // 生成过去N周的周日日期
        for weekOffset in (0..<weeksToShow).reversed() {
            if let weekStart = calendar.date(
                byAdding: .weekOfYear,
                value: -weekOffset,
                to: thisSunday
            ) {
                weeks.append(weekStart)
            }
        }

        return weeks
    }

    // 单个日期单元格
    private func dayCell(for date: Date) -> some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        let isCheckedIn = checkInDates.contains(dateString)
        let isFuture = date > Date()

        return RoundedRectangle(cornerRadius: 2)
            .fill(cellColor(isCheckedIn: isCheckedIn, isFuture: isFuture))
            .frame(width: 12, height: 12)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(Color.gray.opacity(0.2), lineWidth: 0.5)
            )
    }

    // 单元格颜色
    private func cellColor(isCheckedIn: Bool, isFuture: Bool) -> Color {
        if isFuture {
            return Color.gray.opacity(0.1)
        } else if isCheckedIn {
            return baseColor
        } else {
            return Color.gray.opacity(0.2)
        }
    }

    // 图例
    private var legend: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(baseColor)
                    .frame(width: 12, height: 12)
                Text("已打卡")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 12, height: 12)
                Text("未打卡")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 12, height: 12)
                Text("未来")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - 预览

#Preview {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    var sampleDates: [String] = []
    for day in 0..<60 {
        if day % 3 != 0 {  // 模拟打卡数据
            if let date = Calendar.current.date(byAdding: .day, value: -day, to: Date()) {
                sampleDates.append(dateFormatter.string(from: date))
            }
        }
    }

    return ScrollView {
        VStack(spacing: 16) {
            CheckInHeatmapView(checkInDates: sampleDates, baseColor: .blue)
            CheckInHeatmapView(checkInDates: sampleDates, baseColor: .green)
            CheckInHeatmapView(checkInDates: sampleDates, baseColor: .orange)
        }
        .padding()
    }
}
