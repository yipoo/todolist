/**
 * 待办事项数据模型
 *
 * 核心业务模型，包含待办的所有信息
 */

import Foundation
import SwiftData

@Model
final class TodoItem {
    // MARK: - 属性

    /// 唯一标识符
    @Attribute(.unique) var id: UUID

    /// 标题（必填）
    var title: String

    /// 详细描述（可选）
    var itemDescription: String?

    /// 完成状态
    var isCompleted: Bool

    /// 优先级
    var priority: Priority

    /// 标签（多个标签用逗号分隔或数组）
    var tags: [String]

    /// 截止日期（可选）
    var dueDate: Date?

    /// 提醒时间（可选）
    var reminderTime: Date?

    /// 创建时间
    var createdAt: Date

    /// 最后更新时间
    var updatedAt: Date

    /// 完成时间（可选）
    var completedAt: Date?

    /// 已完成的番茄钟数量
    var pomodoroCount: Int = 0

    /// 预计需要的番茄钟数量
    var estimatedPomodoros: Int = 0

    // MARK: - 循环任务属性

    /// 是否是循环任务
    var isRecurring: Bool = false

    /// 循环任务的颜色(十六进制字符串,如 "#FF5733")
    var recurringColor: String?

    /// 循环任务的图标名称
    var recurringIcon: String?

    /// 循环类型(使用字符串存储)
    var recurringTypeRaw: String = "none"

    /// 自定义循环的星期(1-7,周一到周日)
    var customWeekdays: [Int] = []

    /// 循环任务的打卡记录(日期字符串数组,格式: yyyy-MM-dd)
    var checkInDates: [String] = []

    /// 循环任务的连续打卡天数
    var streakDays: Int = 0

    /// 循环类型(计算属性)
    var recurringType: RecurringType {
        get {
            RecurringType(rawValue: recurringTypeRaw) ?? .none
        }
        set {
            recurringTypeRaw = newValue.rawValue
        }
    }

    // MARK: - 关系

    /// 所属用户（多对一）
    var user: User?

    /// 所属分类（多对一）
    var category: Category?

    /// 子任务列表（一对多）
    @Relationship(deleteRule: .cascade, inverse: \Subtask.todo)
    var subtasks: [Subtask] = []

    /// 关联的番茄钟会话（一对多）
    @Relationship(deleteRule: .nullify, inverse: \PomodoroSession.todo)
    var pomodoroSessions: [PomodoroSession] = []

    // MARK: - 初始化

    init(
        id: UUID = UUID(),
        title: String,
        itemDescription: String? = nil,
        isCompleted: Bool = false,
        priority: Priority = .medium,
        tags: [String] = [],
        dueDate: Date? = nil,
        reminderTime: Date? = nil,
        category: Category? = nil,
        user: User? = nil
    ) {
        self.id = id
        self.title = title
        self.itemDescription = itemDescription
        self.isCompleted = isCompleted
        self.priority = priority
        self.tags = tags
        self.dueDate = dueDate
        self.reminderTime = reminderTime
        self.createdAt = Date()
        self.updatedAt = Date()
        self.category = category
        self.user = user
    }

    // MARK: - 便捷方法

    /// 切换完成状态
    func toggleCompletion() {
        isCompleted.toggle()
        updatedAt = Date()

        if isCompleted {
            completedAt = Date()
        } else {
            completedAt = nil
        }
    }

    /// 添加番茄钟
    func addPomodoro() {
        pomodoroCount += 1
        updatedAt = Date()
    }

    /// 是否逾期
    func isOverdue() -> Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }

    /// 是否是今天的待办
    func isToday() -> Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    /// 是否是本周的待办
    func isThisWeek() -> Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDate(dueDate, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// 子任务完成进度（0.0 - 1.0）
    func subtaskProgress() -> Double {
        guard !subtasks.isEmpty else { return 0 }
        let completed = subtasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(subtasks.count)
    }

    /// 子任务完成状态文本
    func subtaskProgressText() -> String {
        let completed = subtasks.filter { $0.isCompleted }.count
        return "\(completed)/\(subtasks.count)"
    }

    // MARK: - 循环任务方法

    /// 判断今天是否需要打卡
    func shouldCheckInToday() -> Bool {
        guard isRecurring else { return false }

        let today = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: today) // 1=周日, 2=周一, ..., 7=周六

        switch recurringType {
        case .none:
            return false
        case .daily:
            return true
        case .weekdays:
            // 周一到周五 (2-6)
            return weekday >= 2 && weekday <= 6
        case .custom:
            // 转换为周一=1的格式
            let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
            return customWeekdays.contains(adjustedWeekday)
        }
    }

    /// 判断今天是否已打卡
    func isCheckedInToday() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        return checkInDates.contains(todayString)
    }

    /// 今日打卡
    func checkInToday() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())

        if !checkInDates.contains(todayString) {
            checkInDates.append(todayString)
            updateStreakDays()
            updatedAt = Date()
        }
    }

    /// 取消今日打卡
    func uncheckToday() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())

        if let index = checkInDates.firstIndex(of: todayString) {
            checkInDates.remove(at: index)
            updateStreakDays()
            updatedAt = Date()
        }
    }

    /// 更新连续打卡天数
    private func updateStreakDays() {
        guard !checkInDates.isEmpty else {
            streakDays = 0
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // 按日期排序
        let sortedDates = checkInDates.compactMap { dateFormatter.date(from: $0) }.sorted()

        guard !sortedDates.isEmpty else {
            streakDays = 0
            return
        }

        let calendar = Calendar.current
        var streak = 1
        var currentDate = sortedDates.last!

        // 从最后一天往前数
        for i in stride(from: sortedDates.count - 2, through: 0, by: -1) {
            let previousDate = sortedDates[i]
            let daysDifference = calendar.dateComponents([.day], from: previousDate, to: currentDate).day ?? 0

            if daysDifference == 1 {
                streak += 1
                currentDate = previousDate
            } else {
                break
            }
        }

        streakDays = streak
    }

    /// 获取本周打卡天数
    func thisWeekCheckInCount() -> Int {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return 0
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return checkInDates.filter { dateString in
            guard let date = dateFormatter.date(from: dateString) else { return false }
            return date >= weekStart && date <= today
        }.count
    }
}

// MARK: - 循环类型枚举

enum RecurringType: String, Codable, CaseIterable {
    case none = "none"
    case daily = "daily"
    case weekdays = "weekdays"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .none: return "不重复"
        case .daily: return "每天"
        case .weekdays: return "工作日"
        case .custom: return "自定义"
        }
    }

    var icon: String {
        switch self {
        case .none: return "minus.circle"
        case .daily: return "repeat"
        case .weekdays: return "briefcase"
        case .custom: return "calendar"
        }
    }
}

// MARK: - 优先级枚举

enum Priority: String, Codable, CaseIterable, Comparable {
    case low = "低"
    case medium = "中"
    case high = "高"

    // 实现 Comparable 协议，用于排序
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        let order: [Priority] = [.low, .medium, .high]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }

    /// 优先级对应的颜色
    var color: String {
        switch self {
        case .low: return "gray"
        case .medium: return "orange"
        case .high: return "red"
        }
    }

    /// 优先级对应的图标
    var icon: String {
        switch self {
        case .low: return "arrow.down.circle"
        case .medium: return "equal.circle"
        case .high: return "arrow.up.circle"
        }
    }

    /// 排序权重（用于排序）
    var weight: Int {
        switch self {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}

// MARK: - 排序选项

enum TodoSortOption: String, CaseIterable {
    case createdAt = "创建时间"
    case dueDate = "截止日期"
    case title = "标题"

    var displayName: String {
        return rawValue
    }

    /// 排序描述器
    func descriptor() -> [SortDescriptor<TodoItem>] {
        switch self {
        case .createdAt:
            return [SortDescriptor(\.createdAt, order: .reverse)]
        case .dueDate:
            return [SortDescriptor(\.dueDate, order: .forward)]
        case .title:
            return [SortDescriptor(\.title, order: .forward)]
        }
    }
}

// MARK: - 筛选选项

enum TodoFilterOption: String, CaseIterable {
    case all = "全部"
    case today = "今天"
    case week = "本周"
    case completed = "已完成"
    case uncompleted = "未完成"
    case overdue = "已逾期"

    var displayName: String {
        return rawValue
    }

    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .today: return "calendar"
        case .week: return "calendar.badge.clock"
        case .completed: return "checkmark.circle"
        case .uncompleted: return "circle"
        case .overdue: return "exclamationmark.triangle"
        }
    }
}
