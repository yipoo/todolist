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

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .environment(themeManager)
                .modelContainer(DataManager.shared.container)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
