/**
 * 用户偏好设置管理器
 *
 * 使用 UserDefaults 持久化存储用户偏好
 */

import Foundation

@Observable
final class UserPreferencesManager {
    // MARK: - 单例

    static let shared = UserPreferencesManager()

    // MARK: - 存储键

    private enum Keys {
        static let theme = "app.theme"
        static let defaultView = "app.defaultView"
        static let notificationsEnabled = "notifications.enabled"
        static let dueReminder = "notifications.dueReminder"
        static let dailyReminder = "notifications.dailyReminder"
        static let reminderTime = "notifications.reminderTime"
        static let autoArchive = "tasks.autoArchive"
    }

    // MARK: - 属性

    /// 主题设置
    var theme: AppTheme {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: Keys.theme)
        }
    }

    /// 默认视图
    var defaultView: DefaultView {
        didSet {
            UserDefaults.standard.set(defaultView.rawValue, forKey: Keys.defaultView)
        }
    }

    /// 通知开关
    var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }

    /// 截止日期提醒
    var dueReminder: Bool {
        didSet {
            UserDefaults.standard.set(dueReminder, forKey: Keys.dueReminder)
        }
    }

    /// 每日提醒
    var dailyReminder: Bool {
        didSet {
            UserDefaults.standard.set(dailyReminder, forKey: Keys.dailyReminder)
        }
    }

    /// 提醒时间
    var reminderTime: Date {
        didSet {
            UserDefaults.standard.set(reminderTime, forKey: Keys.reminderTime)
        }
    }

    /// 自动归档
    var autoArchive: Bool {
        didSet {
            UserDefaults.standard.set(autoArchive, forKey: Keys.autoArchive)
        }
    }

    // MARK: - 初始化

    private init() {
        // 加载保存的设置，如果没有则使用默认值
        if let themeValue = UserDefaults.standard.string(forKey: Keys.theme),
           let savedTheme = AppTheme(rawValue: themeValue) {
            self.theme = savedTheme
        } else {
            self.theme = .system
        }

        if let viewValue = UserDefaults.standard.string(forKey: Keys.defaultView),
           let savedView = DefaultView(rawValue: viewValue) {
            self.defaultView = savedView
        } else {
            self.defaultView = .list
        }

        self.notificationsEnabled = UserDefaults.standard.object(forKey: Keys.notificationsEnabled) as? Bool ?? true
        self.dueReminder = UserDefaults.standard.object(forKey: Keys.dueReminder) as? Bool ?? true
        self.dailyReminder = UserDefaults.standard.object(forKey: Keys.dailyReminder) as? Bool ?? false

        if let savedTime = UserDefaults.standard.object(forKey: Keys.reminderTime) as? Date {
            self.reminderTime = savedTime
        } else {
            // 默认时间：早上 9:00
            let calendar = Calendar.current
            let components = DateComponents(hour: 9, minute: 0)
            self.reminderTime = calendar.date(from: components) ?? Date()
        }

        self.autoArchive = UserDefaults.standard.object(forKey: Keys.autoArchive) as? Bool ?? false
    }

    // MARK: - 重置方法

    /// 重置所有设置为默认值
    func resetToDefaults() {
        theme = .system
        defaultView = .list
        notificationsEnabled = true
        dueReminder = true
        dailyReminder = false
        autoArchive = false

        let calendar = Calendar.current
        let components = DateComponents(hour: 9, minute: 0)
        reminderTime = calendar.date(from: components) ?? Date()
    }
}

// MARK: - 枚举定义

/// 主题设置
enum AppTheme: String, CaseIterable {
    case light = "浅色"
    case dark = "深色"
    case system = "跟随系统"

    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

/// 默认视图
enum DefaultView: String, CaseIterable {
    case list = "列表"
    case calendar = "日历"
}

// 为了兼容 SwiftUI 的 ColorScheme
import SwiftUI

extension AppTheme {
    var systemColorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}
