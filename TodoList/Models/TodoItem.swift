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
