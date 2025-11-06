/**
 * 番茄钟设置
 *
 * 存储用户的番茄钟偏好设置（UserDefaults）
 */

import Foundation

struct PomodoroSettings: Codable {
    // MARK: - 时长设置（分钟）

    /// 工作时长
    var workDuration: Int = 25

    /// 短休息时长
    var shortBreakDuration: Int = 5

    /// 长休息时长
    var longBreakDuration: Int = 15

    /// 几个番茄钟后进行长休息
    var sessionsBeforeLongBreak: Int = 4

    // MARK: - 行为设置

    /// 自动开始休息
    var autoStartBreaks: Bool = false

    /// 自动开始下一个番茄钟
    var autoStartPomodoros: Bool = false

    /// 启用提醒通知
    var notificationsEnabled: Bool = true

    /// 启用声音提醒
    var soundEnabled: Bool = true

    /// 启用触觉反馈
    var hapticEnabled: Bool = true

    // MARK: - 统计设置

    /// 每日目标番茄钟数量
    var dailyGoal: Int = 8

    /// 是否统计放弃的会话
    var trackAbandonedSessions: Bool = true

    // MARK: - UserDefaults 键
    static let userDefaultsKey = "pomodoroSettings"

    // MARK: - 持久化

    /// 保存到 UserDefaults
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: Self.userDefaultsKey)
        }
    }

    /// 从 UserDefaults 加载
    static func load() -> PomodoroSettings {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let settings = try? JSONDecoder().decode(PomodoroSettings.self, from: data)
        else {
            return PomodoroSettings() // 返回默认设置
        }
        return settings
    }

    // MARK: - 预设方案

    /// 经典番茄钟方案
    static let classic = PomodoroSettings(
        workDuration: 25,
        shortBreakDuration: 5,
        longBreakDuration: 15,
        sessionsBeforeLongBreak: 4
    )

    /// 短时方案（适合初学者）
    static let short = PomodoroSettings(
        workDuration: 15,
        shortBreakDuration: 3,
        longBreakDuration: 10,
        sessionsBeforeLongBreak: 4
    )

    /// 长时方案（适合深度工作）
    static let long = PomodoroSettings(
        workDuration: 50,
        shortBreakDuration: 10,
        longBreakDuration: 30,
        sessionsBeforeLongBreak: 2
    )
}

// MARK: - 快速时长预设

/// 快速时长预设（用于左右滑动选择）
struct PomodoroPreset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let duration: Int // 分钟
    let emoji: String

    static let presets: [PomodoroPreset] = [
        PomodoroPreset(name: "短时专注", duration: 15, emoji: "⚡️"),
        PomodoroPreset(name: "经典番茄", duration: 25, emoji: "🍅"),
        PomodoroPreset(name: "深度工作", duration: 45, emoji: "🎯"),
        PomodoroPreset(name: "超长专注", duration: 60, emoji: "🚀")
    ]

    static let defaultPreset = presets[1] // 25分钟
}

// MARK: - 番茄钟统计

/// 番茄钟统计数据（用于展示）
struct PomodoroStatistics {
    /// 总完成的番茄钟数
    var totalCompleted: Int

    /// 今天完成的番茄钟数
    var todayCompleted: Int

    /// 本周完成的番茄钟数
    var weekCompleted: Int

    /// 本月完成的番茄钟数
    var monthCompleted: Int

    /// 总工作时长（分钟）
    var totalWorkMinutes: Int

    /// 今天工作时长（分钟）
    var todayWorkMinutes: Int

    /// 平均每天完成数
    var averagePerDay: Double

    /// 连续打卡天数
    var consecutiveDays: Int

    /// 最长连续打卡天数
    var longestStreak: Int

    /// 今日目标达成率（0.0 - 1.0）
    func todayGoalProgress(goal: Int) -> Double {
        guard goal > 0 else { return 0 }
        return min(1.0, Double(todayCompleted) / Double(goal))
    }

    /// 格式化工作时长
    func formattedWorkTime(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)小时\(mins)分钟"
        } else {
            return "\(mins)分钟"
        }
    }
}
