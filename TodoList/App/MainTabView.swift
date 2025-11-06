/**
 * 主标签栏视图
 *
 * 包含 5 个主要功能模块：
 * 1. 待办事项（TodoList）
 * 2. 日历（Calendar）
 * 3. 番茄钟（Pomodoro）
 * 4. 统计（Statistics）
 * 5. 个人中心（Profile）
 *
 * 与 React 对比：类似于底部导航栏 TabBar 组件
 */

import SwiftUI
import SwiftData

struct MainTabView: View {
    // MARK: - 环境

    @Environment(AuthViewModel.self) private var authViewModel

    // MARK: - 状态

    @State private var selectedTab = 0

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // 待办事项
            TodoListView(authViewModel: authViewModel)
                .tabItem {
                    Label("待办", systemImage: selectedTab == 0 ? "checkmark.circle.fill" : "checkmark.circle")
                }
                .tag(0)

            // 日历
            // CalendarPlaceholderView()
            //     .tabItem {
            //         Label("日历", systemImage: selectedTab == 1 ? "calendar.circle.fill" : "calendar.circle")
            //     }
            //     .tag(1)

            // 番茄钟
            PomodoroTimerView(authViewModel: authViewModel, todo: nil)
                .tabItem {
                    Label("番茄钟", systemImage: selectedTab == 2 ? "timer.circle.fill" : "timer.circle")
                }
                .tag(2)

            // 统计
            StatisticsView(authViewModel: authViewModel)
                .tabItem {
                    Label("统计", systemImage: selectedTab == 3 ? "chart.bar.fill" : "chart.bar")
                }
                .tag(3)

            // 个人中心
            ProfileView(authViewModel: authViewModel)
                .tabItem {
                    Label("我的", systemImage: selectedTab == 4 ? "person.circle.fill" : "person.circle")
                }
                .tag(4)
        }
        .tint(.blue) // 设置选中颜色
    }
}

// MARK: - 预览

#Preview {
    MainTabView()
        .environment(AuthViewModel())
        .modelContainer(DataManager.shared.container)
}
