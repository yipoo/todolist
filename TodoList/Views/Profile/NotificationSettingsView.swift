/**
 * 通知设置视图
 *
 * 管理通知相关设置
 */

import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var preferences = UserPreferencesManager.shared
    @State private var notificationsEnabled = true
    @State private var dueReminder = true
    @State private var dailyReminder = false
    @State private var reminderTime = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("开启通知", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            preferences.notificationsEnabled = newValue
                        }
                } footer: {
                    Text("关闭后将不会收到任何通知")
                }

                if notificationsEnabled {
                    Section {
                        Toggle("截止日期提醒", isOn: $dueReminder)
                            .onChange(of: dueReminder) { _, newValue in
                                preferences.dueReminder = newValue
                            }

                        Toggle("每日总结", isOn: $dailyReminder)
                            .onChange(of: dailyReminder) { _, newValue in
                                preferences.dailyReminder = newValue
                            }

                        if dailyReminder {
                            DatePicker(
                                "提醒时间",
                                selection: $reminderTime,
                                displayedComponents: .hourAndMinute
                            )
                            .onChange(of: reminderTime) { _, newValue in
                                preferences.reminderTime = newValue
                            }
                        }
                    } header: {
                        Text("提醒设置")
                    }
                }
            }
            .navigationTitle("通知设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadSettings()
            }
        }
    }

    // MARK: - 方法

    private func loadSettings() {
        notificationsEnabled = preferences.notificationsEnabled
        dueReminder = preferences.dueReminder
        dailyReminder = preferences.dailyReminder
        reminderTime = preferences.reminderTime
    }
}

#Preview {
    NotificationSettingsView()
}
