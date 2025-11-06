/**
 * 根视图
 *
 * 根据认证状态显示登录界面或主界面
 * 与 React 对比：类似于根路由组件
 */

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - 环境

    @Environment(AuthViewModel.self) private var authViewModel

    // MARK: - Body

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                // 已登录：显示主界面
                MainTabView()
                    .transition(.opacity)
            } else {
                // 未登录：显示新版登录界面
                PhoneLoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}

// MARK: - 预览

#Preview {
    ContentView()
        .environment(AuthViewModel())
        .modelContainer(DataManager.shared.container)
}
