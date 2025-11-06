/**
 * 全局常量定义
 *
 * 集中管理应用中的所有常量
 */

import Foundation
import SwiftUI

// MARK: - 应用信息

enum AppInfo {
    static let name = "TodoList"
    static let version = "1.0.0"
    static let buildNumber = "1"
    static let author = "Your Name"
    static let website = "https://example.com"
    static let email = "support@example.com"
}

// MARK: - 用户默认值键

enum UserDefaultsKeys {
    static let isLoggedIn = "isLoggedIn"
    static let currentUserId = "currentUserId"
    static let pomodoroSettings = "pomodoroSettings"
    static let userSettings = "userSettings"
    static let lastSyncDate = "lastSyncDate"
    static let onboardingCompleted = "onboardingCompleted"
}

// MARK: - Keychain 键

enum KeychainKeys {
    static let userPassword = "com.todolist.password"
    static let loginToken = "com.todolist.token"
    static let wechatAuth = "com.todolist.wechat"
}

// MARK: - 通知名称

enum NotificationNames {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
    static let todoDidUpdate = Notification.Name("todoDidUpdate")
    static let pomodoroDidComplete = Notification.Name("pomodoroDidComplete")
}

// MARK: - 布局常量

enum Layout {
    // 间距
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
    static let extraLargeSpacing: CGFloat = 32

    // 圆角
    static let smallCornerRadius: CGFloat = 8
    static let mediumCornerRadius: CGFloat = 12
    static let largeCornerRadius: CGFloat = 16

    // 内边距
    static let smallPadding: CGFloat = 8
    static let mediumPadding: CGFloat = 16
    static let largePadding: CGFloat = 24

    // 图标大小
    static let smallIconSize: CGFloat = 20
    static let mediumIconSize: CGFloat = 24
    static let largeIconSize: CGFloat = 32
    static let extraLargeIconSize: CGFloat = 48

    // 按钮高度
    static let buttonHeight: CGFloat = 50
    static let smallButtonHeight: CGFloat = 36
}

// MARK: - 动画常量

enum AnimationConstants {
    static let standard: Animation = .spring(response: 0.3, dampingFraction: 0.7)
    static let quick: Animation = .easeInOut(duration: 0.2)
    static let slow: Animation = .easeInOut(duration: 0.5)
}

// MARK: - 时间常量

enum TimeConstants {
    // 番茄钟时长（分钟）
    static let pomodoroWork = 25
    static let pomodoroShortBreak = 5
    static let pomodoroLongBreak = 15

    // 通知提前时间（分钟）
    static let reminderAdvance = 10

    // 自动登出时间（秒）
    static let autoLogoutDelay = 3600
}

// MARK: - 验证规则

enum ValidationRules {
    static let minUsernameLength = 3
    static let maxUsernameLength = 20
    static let minPasswordLength = 8
    static let maxPasswordLength = 32

    // 正则表达式
    static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let usernameRegex = "^[a-zA-Z0-9_]{3,20}$"
}

// MARK: - 颜色主题

enum AppColors {
    // 主题色
    static let primary = Color("Primary")
    static let secondary = Color("Secondary")
    static let accent = Color("Accent")

    // 优先级颜色
    static let highPriority = Color.red
    static let mediumPriority = Color.orange
    static let lowPriority = Color.gray

    // 分类颜色（十六进制）
    static let categoryColors = [
        "#007AFF", // 蓝色
        "#34C759", // 绿色
        "#FF9500", // 橙色
        "#FF3B30", // 红色
        "#AF52DE", // 紫色
        "#FF2D55", // 粉色
        "#5856D6", // 靛蓝
        "#00C7BE", // 青色
    ]

    // 状态颜色
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
}

// MARK: - SF Symbols 图标

enum AppIcons {
    // Tab Bar
    static let todoList = "checklist"
    static let calendar = "calendar"
    static let pomodoro = "timer"
    static let statistics = "chart.bar"
    static let profile = "person.circle"

    // 操作
    static let add = "plus.circle.fill"
    static let edit = "pencil"
    static let delete = "trash"
    static let complete = "checkmark.circle.fill"
    static let uncomplete = "circle"
    static let filter = "line.3.horizontal.decrease.circle"
    static let sort = "arrow.up.arrow.down"
    static let search = "magnifyingglass"

    // 优先级
    static let highPriority = "arrow.up.circle.fill"
    static let mediumPriority = "equal.circle.fill"
    static let lowPriority = "arrow.down.circle.fill"

    // 其他
    static let notification = "bell"
    static let settings = "gearshape"
    static let category = "folder"
    static let tag = "tag"
    static let time = "clock"
    static let reminder = "alarm"
}

// MARK: - 错误消息

enum ErrorMessages {
    static let networkError = "网络连接失败，请检查网络设置"
    static let loginFailed = "登录失败，请检查用户名和密码"
    static let registrationFailed = "注册失败，请稍后再试"
    static let invalidEmail = "邮箱格式不正确"
    static let invalidPassword = "密码长度至少8位，包含字母和数字"
    static let passwordMismatch = "两次输入的密码不一致"
    static let usernameTaken = "用户名已被占用"
    static let emailTaken = "邮箱已被注册"
    static let emptyTitle = "标题不能为空"
    static let saveFailed = "保存失败，请重试"
    static let deleteFailed = "删除失败，请重试"
}

// MARK: - 成功消息

enum SuccessMessages {
    static let loginSuccess = "登录成功"
    static let registrationSuccess = "注册成功"
    static let saveSuccess = "保存成功"
    static let deleteSuccess = "删除成功"
    static let updateSuccess = "更新成功"
    static let pomodoroComplete = "番茄钟完成！休息一下吧"
    static let breakComplete = "休息结束，开始工作吧"
}
