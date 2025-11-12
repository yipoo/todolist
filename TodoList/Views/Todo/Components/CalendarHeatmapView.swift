/**
 * 日历样式打卡热力图组件
 *
 * 以日历形式展示打卡历史记录，显示日期
 */

import SwiftUI

struct CalendarHeatmapView: View {
    let checkInDates: [String]
    let baseColor: Color

    @State private var currentMonth = Date()

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 16) {
            // 月份导航
            monthNavigator

            // 星期标题
            weekdayHeaders

            // 日历网格
            calendarGrid
        }
    }

    // 月份导航器
    private var monthNavigator: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.primary)
            }

            Spacer()

            Text(monthYearString)
                .font(.headline)

            Spacer()

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            .disabled(isCurrentMonth)
        }
        .padding(.horizontal)
    }

    // 星期标题
    private var weekdayHeaders: some View {
        HStack(spacing: 4) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // 日历网格
    private var calendarGrid: some View {
        let days = generateDaysInMonth()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

        return LazyVGrid(columns: columns, spacing: 6) {
            ForEach(days, id: \.self) { date in
                if let date = date {
                    dayCell(for: date)
                } else {
                    // 空白占位
                    Color.clear
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
    }

    // 单个日期单元格
    private func dayCell(for date: Date) -> some View {
        let dateString = dateFormatter.string(from: date)
        let isCheckedIn = checkInDates.contains(dateString)
        let isToday = calendar.isDateInToday(date)
        let isFuture = date > Date()
        let day = calendar.component(.day, from: date)

        return VStack(spacing: 0) {
            Text("\(day)")
                .font(.system(size: 14, weight: isToday ? .bold : .regular))
                .foregroundColor(textColor(isCheckedIn: isCheckedIn, isToday: isToday, isFuture: isFuture))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(backgroundColor(isCheckedIn: isCheckedIn, isToday: isToday, isFuture: isFuture))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(isToday ? baseColor : Color.clear, lineWidth: 2)
        )
    }

    // 背景颜色
    private func backgroundColor(isCheckedIn: Bool, isToday: Bool, isFuture: Bool) -> Color {
        if isFuture {
            return Color(.systemGray6)
        } else if isCheckedIn {
            return baseColor.opacity(0.8)
        } else {
            return Color(.systemGray5)
        }
    }

    // 文字颜色
    private func textColor(isCheckedIn: Bool, isToday: Bool, isFuture: Bool) -> Color {
        if isFuture {
            return Color.gray.opacity(0.4)
        } else if isCheckedIn {
            return .white
        } else {
            return .primary
        }
    }

    // 生成月份中的所有日期
    private func generateDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var days: [Date?] = []

        // 从月份第一周的第一天开始（可能是上个月的日期）
        let startDate = monthFirstWeek.start
        var currentDate = startDate

        // 生成足够的日期来填充完整的日历网格
        while days.count < 42 { // 6周 × 7天
            if calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month) {
                days.append(currentDate)
            } else if currentDate < monthInterval.start {
                days.append(nil) // 前面的空白
            } else {
                days.append(nil) // 后面的空白
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!

            // 如果已经填充完当前月份且到达新的一周的开始，就停止
            if currentDate > monthInterval.end && calendar.component(.weekday, from: currentDate) == 1 {
                break
            }
        }

        return days
    }

    // 星期符号
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        // 调整为周一开始
        return Array(symbols[1...]) + [symbols[0]]
    }

    // 月份年份字符串
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        return formatter.string(from: currentMonth)
    }

    // 是否是当前月份
    private var isCurrentMonth: Bool {
        calendar.isDate(currentMonth, equalTo: Date(), toGranularity: .month)
    }

    // 上一个月
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    // 下一个月
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            if newMonth <= Date() {
                currentMonth = newMonth
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
            CalendarHeatmapView(checkInDates: sampleDates, baseColor: .blue)
            CalendarHeatmapView(checkInDates: sampleDates, baseColor: .green)
            CalendarHeatmapView(checkInDates: sampleDates, baseColor: .orange)
        }
        .padding()
    }
}
