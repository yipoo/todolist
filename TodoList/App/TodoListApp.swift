/**
 * TodoList 应用主入口
 *
 * 配置 SwiftData 和环境对象
 * 管理应用生命周期
 */

import SwiftUI
import SwiftData

@main
struct TodoListApp: App {
    // MARK: - 状态

    /// 认证视图模型（全局单例）
    @State private var authViewModel = AuthViewModel()

    /// 主题管理器（全局单例）
    @State private var themeManager = ThemeManager.shared

    /// 通知管理器
    private let notificationManager = NotificationManager.shared

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .environment(themeManager)
                .modelContainer(DataManager.shared.container)
                .preferredColorScheme(themeManager.colorScheme)
                .onAppear {
                    // App 首次启动时请求通知权限
                    Task {
                        await requestNotificationPermission()
                    }
                }
        }
    }

    // MARK: - 方法

    /// 请求通知权限
    private func requestNotificationPermission() async {
        await notificationManager.checkAuthorizationStatus()

        // 如果权限未确定，请求授权
        if notificationManager.authorizationStatus == .notDetermined {
            let granted = await notificationManager.requestAuthorization()
            print(granted ? "✅ 用户授予通知权限" : "❌ 用户拒绝通知权限")
        }
    }
}
