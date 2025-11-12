/**
 * 偏好设置视图
 *
 * 管理应用偏好设置
 */

import SwiftUI

struct PreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    @State private var preferences = UserPreferencesManager.shared
    @State private var selectedTheme: AppTheme = .system
    @State private var selectedView: DefaultView = .list
    @State private var autoArchive = false
    @State private var showRecurringTasks = true
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isInitialLoad = true  // 标记是否是初次加载

    var body: some View {
        NavigationStack {
            Form {
                // 界面设置
                Section {
                    // 主题选择
                    Picker("主题", selection: $selectedTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .onChange(of: selectedTheme) { _, newValue in
                        // 跳过初次加载时的触发
                        guard !isInitialLoad else { return }

                        themeManager.setTheme(newValue)
                        toastMessage = "主题已更改为\(newValue.rawValue)"
                        showToast = true
                    }

                    // 默认视图选择
                    Picker("默认视图", selection: $selectedView) {
                        ForEach(DefaultView.allCases, id: \.self) { view in
                            Text(view.rawValue).tag(view)
                        }
                    }
                    .onChange(of: selectedView) { _, newValue in
                        // 跳过初次加载时的触发
                        guard !isInitialLoad else { return }

                        preferences.defaultView = newValue
                        toastMessage = "默认视图已更改"
                        showToast = true
                    }
                } header: {
                    Text("界面设置")
                } footer: {
                    Text("主题设置将立即生效")
                }

                // 任务管理
                Section {
                    Toggle("自动归档已完成任务", isOn: $autoArchive)
                        .onChange(of: autoArchive) { _, newValue in
                            preferences.autoArchive = newValue
                        }

                    Toggle("显示自律打卡", isOn: $showRecurringTasks)
                        .onChange(of: showRecurringTasks) { _, newValue in
                            preferences.showRecurringTasks = newValue
                        }
                } header: {
                    Text("任务管理")
                } footer: {
                    Text("完成超过30天的任务将自动归档。自律打卡用于记录习惯养成任务")
                }

                // 重置设置
                Section {
                    Button(role: .destructive) {
                        resetToDefaults()
                    } label: {
                        HStack {
                            Spacer()
                            Text("恢复默认设置")
                            Spacer()
                        }
                    }
                } footer: {
                    Text("将所有偏好设置恢复为默认值")
                }
            }
            .navigationTitle("偏好设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadPreferences()
            }
            .toast(
                isPresented: $showToast,
                message: toastMessage,
                type: .success
            )
            .preferredColorScheme(themeManager.colorScheme)
        }
    }

    // MARK: - 方法

    /// 加载偏好设置
    private func loadPreferences() {
        selectedTheme = preferences.theme
        selectedView = preferences.defaultView
        autoArchive = preferences.autoArchive
        showRecurringTasks = preferences.showRecurringTasks

        // 使用 DispatchQueue 确保在下一个 runloop 中将标志位设为 false
        // 这样可以确保 onChange 不会在初次加载时触发
        DispatchQueue.main.async {
            isInitialLoad = false
        }
    }

    /// 重置为默认设置
    private func resetToDefaults() {
        preferences.resetToDefaults()
        loadPreferences()
        themeManager.setTheme(.system)
        toastMessage = "已恢复默认设置"
        showToast = true
    }
}

#Preview {
    PreferencesView()
}
