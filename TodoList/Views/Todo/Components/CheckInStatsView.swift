/**
 * 打卡统计组件
 *
 * 展示打卡的各项统计数据
 */

import SwiftUI

struct CheckInStatsView: View {
    let todo: TodoItem
    let baseColor: Color

    init(todo: TodoItem) {
        self.todo = todo
        self.baseColor = Color(hex: todo.recurringColor ?? "#4A90E2")
    }

    var body: some View {
        VStack(spacing: 12) {
            // 统计卡片网格
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 12
            ) {
                // 连续打卡天数
                SelfDisciplineStatsCard(
                    icon: "flame.fill",
                    title: "连续打卡",
                    value: "\(todo.streakDays)",
                    unit: "天",
                    color: .orange
                )

                // 总打卡次数
                SelfDisciplineStatsCard(
                    icon: "checkmark.circle.fill",
                    title: "总打卡",
                    value: "\(todo.checkInDates.count)",
                    unit: "次",
                    color: .green
                )

                // 本周打卡
                SelfDisciplineStatsCard(
                    icon: "calendar",
                    title: "本周打卡",
                    value: "\(todo.thisWeekCheckInCount())",
                    unit: "次",
                    color: .blue
                )

                // 本月打卡
                SelfDisciplineStatsCard(
                    icon: "calendar.badge.clock",
                    title: "本月打卡",
                    value: "\(thisMonthCheckInCount())",
                    unit: "次",
                    color: .purple
                )
            }

            // 完成率统计
            completionRateView
        }
    }

    // 本月打卡次数
    private func thisMonthCheckInCount() -> Int {
        let calendar = Calendar.current
        let today = Date()
        guard let monthStart = calendar.dateInterval(of: .month, for: today)?.start else {
            return 0
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return todo.checkInDates.filter { dateString in
            guard let date = dateFormatter.date(from: dateString) else { return false }
            return date >= monthStart && date <= today
        }.count
    }

    // 完成率视图
    private var completionRateView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(baseColor)
                Text("本月完成率")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(monthCompletionRate() * 100))%")
                    .font(.headline)
                    .foregroundColor(baseColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 4)
                        .fill(baseColor.opacity(0.2))
                        .frame(height: 8)

                    // 进度
                    RoundedRectangle(cornerRadius: 4)
                        .fill(baseColor)
                        .frame(
                            width: geometry.size.width * monthCompletionRate(),
                            height: 8
                        )
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // 本月完成率
    private func monthCompletionRate() -> Double {
        let calendar = Calendar.current
        let today = Date()
        guard let monthStart = calendar.dateInterval(of: .month, for: today)?.start else {
            return 0
        }

        // 计算本月应该打卡的天数
        var expectedDays = 0
        var currentDate = monthStart

        while currentDate <= today {
            // 根据循环类型判断今天是否应该打卡
            let weekday = calendar.component(.weekday, from: currentDate)

            let shouldCheckIn: Bool
            switch todo.recurringType {
            case .none:
                shouldCheckIn = false
            case .daily:
                shouldCheckIn = true
            case .weekdays:
                shouldCheckIn = weekday >= 2 && weekday <= 6
            case .custom:
                let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
                shouldCheckIn = todo.customWeekdays.contains(adjustedWeekday)
            }

            if shouldCheckIn {
                expectedDays += 1
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        guard expectedDays > 0 else { return 0 }

        let actualDays = thisMonthCheckInCount()
        return Double(actualDays) / Double(expectedDays)
    }
}

// MARK: - 自律打卡统计卡片

struct SelfDisciplineStatsCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            HStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if !unit.isEmpty {
                    Text("(\(unit))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - 预览

#Preview {
    let todo = TodoItem(title: "早起打卡")
    todo.isRecurring = true
    todo.recurringType = .daily
    todo.recurringColor = "#FF6B6B"
    todo.recurringIcon = "sun.max.fill"
    todo.streakDays = 15

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    var dates: [String] = []
    for day in 0..<30 {
        if day % 3 != 0 {
            if let date = Calendar.current.date(byAdding: .day, value: -day, to: Date()) {
                dates.append(dateFormatter.string(from: date))
            }
        }
    }
    todo.checkInDates = dates

    return ScrollView {
        CheckInStatsView(todo: todo)
            .padding()
    }
}
