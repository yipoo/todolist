/**
 * 通知管理器
 *
 * 管理应用的本地通知功能
 * - 请求通知权限
 * - 调度待办提醒通知
 * - 取消和更新通知
 */

import Foundation
import UserNotifications
import SwiftUI
import Combine
import SwiftData

@MainActor
final class NotificationManager: NSObject {
    // MARK: - 单例

    static let shared = NotificationManager()

    // MARK: - 属性

    private let center = UNUserNotificationCenter.current()

    /// 通知权限状态
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - 初始化

    private override init() {
        super.init()
        center.delegate = self

        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - 权限管理

    /// 请求通知权限
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await checkAuthorizationStatus()

            if granted {
                print("✅ 通知权限已授予")
            } else {
                print("❌ 通知权限被拒绝")
            }

            return granted
        } catch {
            print("❌ 请求通知权限失败: \(error.localizedDescription)")
            return false
        }
    }

    /// 检查当前权限状态
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus

        print("📱 通知权限状态: \(authorizationStatus.description)")
    }

    /// 打开系统设置页面
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - 通知调度

    /// 为待办事项调度提醒通知
    func scheduleNotification(for todo: TodoItem) async {
        // 检查是否有截止日期
        guard let dueDate = todo.dueDate else {
            print("⚠️ Todo \(todo.title) 没有截止日期，跳过通知")
            return
        }

        // 检查截止日期是否在未来
        guard dueDate > Date() else {
            print("⚠️ Todo \(todo.title) 截止日期已过，跳过通知")
            return
        }

        // 检查权限
        guard authorizationStatus == .authorized else {
            print("⚠️ 没有通知权限，无法调度通知")
            return
        }

        // 先取消旧的通知
        await cancelNotification(for: todo)

        // 创建通知内容
        let content = UNMutableNotificationContent()
        content.title = "待办提醒"
        content.body = todo.title
        content.sound = .default
        content.badge = 1

        // 添加额外信息
        var subtitle = ""
        if let category = todo.category {
            subtitle = category.name
        }
        if todo.priority == .high {
            subtitle += subtitle.isEmpty ? "高优先级" : " • 高优先级"
        }
        if !subtitle.isEmpty {
            content.subtitle = subtitle
        }

        // 添加自定义数据
        content.userInfo = [
            "todoId": todo.id.uuidString,
            "todoTitle": todo.title
        ]

        // 设置提醒时间 - 在截止日期前1小时
        let reminderDate = Calendar.current.date(byAdding: .hour, value: -1, to: dueDate) ?? dueDate

        // 如果提醒时间已经过了，就在截止时间提醒
        let finalReminderDate = reminderDate > Date() ? reminderDate : dueDate

        // 创建触发器
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: finalReminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // 创建请求
        let request = UNNotificationRequest(
            identifier: notificationIdentifier(for: todo),
            content: content,
            trigger: trigger
        )

        // 添加通知
        do {
            try await center.add(request)
            print("✅ 已为 Todo '\(todo.title)' 设置通知，提醒时间: \(finalReminderDate)")
        } catch {
            print("❌ 设置通知失败: \(error.localizedDescription)")
        }
    }

    /// 取消待办的通知
    func cancelNotification(for todo: TodoItem) async {
        let identifier = notificationIdentifier(for: todo)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🔕 已取消 Todo '\(todo.title)' 的通知")
    }

    /// 批量取消通知
    func cancelNotifications(for todos: [TodoItem]) async {
        let identifiers = todos.map { notificationIdentifier(for: $0) }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🔕 已取消 \(todos.count) 个待办的通知")
    }

    /// 取消所有通知
    func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
        print("🔕 已取消所有通知")
    }

    /// 更新待办的通知（删除旧的，创建新的）
    func updateNotification(for todo: TodoItem) async {
        if todo.isCompleted {
            // 如果已完成，取消通知
            await cancelNotification(for: todo)
        } else {
            // 否则重新调度
            await scheduleNotification(for: todo)
        }
    }

    // MARK: - 查询

    /// 获取所有待处理的通知
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }

    /// 获取待办的通知请求
    func getNotificationRequest(for todo: TodoItem) async -> UNNotificationRequest? {
        let identifier = notificationIdentifier(for: todo)
        let pending = await getPendingNotifications()
        return pending.first { $0.identifier == identifier }
    }

    // MARK: - 辅助方法

    /// 生成通知标识符
    private func notificationIdentifier(for todo: TodoItem) -> String {
        "todo_reminder_\(todo.id.uuidString)"
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    /// 在前台收到通知时调用
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 即使应用在前台也显示通知
        completionHandler([.banner, .sound, .badge])
    }

    /// 用户点击通知时调用
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        // 处理通知点击
        if let todoIdString = userInfo["todoId"] as? String,
           let todoId = UUID(uuidString: todoIdString) {
            print("📱 用户点击了通知，Todo ID: \(todoId)")

            // TODO: 可以在这里打开对应的待办详情页
            // 可以通过 NotificationCenter 发送通知给 App
            Task { @MainActor in
                NotificationCenter.default.post(
                    name: .didTapTodoNotification,
                    object: nil,
                    userInfo: ["todoId": todoId]
                )
            }
        }

        completionHandler()
    }
}

// MARK: - 扩展

extension UNAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "未确定"
        case .denied: return "已拒绝"
        case .authorized: return "已授权"
        case .provisional: return "临时授权"
        case .ephemeral: return "临时"
        @unknown default: return "未知"
        }
    }
}

extension Notification.Name {
    /// 用户点击了待办通知
    static let didTapTodoNotification = Notification.Name("didTapTodoNotification")
}
