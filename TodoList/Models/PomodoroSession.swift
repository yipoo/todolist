/**
 * 番茄钟会话数据模型
 *
 * 记录每次番茄钟的使用情况
 */

import Foundation
import SwiftData

@Model
final class PomodoroSession {
    // MARK: - 属性

    /// 唯一标识符
    @Attribute(.unique) var id: UUID

    /// 开始时间
    var startTime: Date

    /// 结束时间（可选，进行中时为 nil）
    var endTime: Date?

    /// 计划时长（分钟）
    var plannedDuration: Int

    /// 实际时长（分钟，完成后计算）
    var actualDuration: Int?

    /// 会话类型
    var sessionType: SessionType

    /// 是否完成（中途放弃则为 false）
    var isCompleted: Bool

    /// 创建时间
    var createdAt: Date

    // MARK: - 关系

    /// 关联的待办事项（可选）
    var todo: TodoItem?

    /// 所属用户
    var user: User?

    // MARK: - 初始化

    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        plannedDuration: Int,
        sessionType: SessionType,
        todo: TodoItem? = nil,
        user: User? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.plannedDuration = plannedDuration
        self.sessionType = sessionType
        self.isCompleted = false
        self.createdAt = Date()
        self.todo = todo
        self.user = user
    }

    // MARK: - 便捷方法

    /// 完成会话
    func complete() {
        endTime = Date()
        isCompleted = true
        actualDuration = Int(Date().timeIntervalSince(startTime) / 60)

        // 如果关联了待办且是工作会话，增加番茄钟计数
        if sessionType == .work, let todo = todo {
            todo.addPomodoro()
        }
    }

    /// 放弃会话
    func abandon() {
        endTime = Date()
        isCompleted = false
        actualDuration = Int(Date().timeIntervalSince(startTime) / 60)
    }

    /// 是否正在进行中
    func isActive() -> Bool {
        return endTime == nil
    }

    /// 剩余时间（秒）
    func remainingSeconds() -> Int {
        guard endTime == nil else { return 0 }
        let elapsed = Date().timeIntervalSince(startTime)
        let planned = TimeInterval(plannedDuration * 60)
        let remaining = planned - elapsed
        return max(0, Int(remaining))
    }

    /// 进度（0.0 - 1.0）
    func progress() -> Double {
        guard endTime == nil else { return 1.0 }
        let elapsed = Date().timeIntervalSince(startTime)
        let planned = TimeInterval(plannedDuration * 60)
        return min(1.0, elapsed / planned)
    }
}

// MARK: - 会话类型枚举

enum SessionType: String, Codable, CaseIterable {
    case work = "工作"
    case shortBreak = "短休息"
    case longBreak = "长休息"

    /// 类型对应的颜色
    var colorHex: String {
        switch self {
        case .work: return "#FF3B30"        // 红色
        case .shortBreak: return "#34C759"  // 绿色
        case .longBreak: return "#007AFF"   // 蓝色
        }
    }

    /// 类型对应的图标
    var icon: String {
        switch self {
        case .work: return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer"
        case .longBreak: return "bed.double"
        }
    }

    /// 类型对应的 Emoji
    var emoji: String {
        switch self {
        case .work: return "🍅"
        case .shortBreak: return "☕️"
        case .longBreak: return "🏖️"
        }
    }
}
