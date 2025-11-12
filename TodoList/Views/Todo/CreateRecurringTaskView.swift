/**
 * 创建循环任务视图
 *
 * 用于创建自律打卡类的循环任务
 */

import SwiftUI

struct CreateRecurringTaskView: View {
    let todoViewModel: TodoViewModel
    let onDismiss: () -> Void

    // MARK: - 状态

    @State private var title = ""
    @State private var selectedColor = "#FF6B6B"
    @State private var selectedIcon = "star.fill"
    @State private var recurringType: RecurringType = .daily
    @State private var customWeekdays: Set<Int> = []
    @State private var isSaving = false

    // MARK: - 常量

    private let colorOptions = [
        "#FF6B6B", // 红色
        "#4ECDC4", // 青色
        "#45B7D1", // 蓝色
        "#96CEB4", // 绿色
        "#FFEAA7", // 黄色
        "#DFE6E9", // 灰色
        "#FD79A8", // 粉色
        "#FDCB6E", // 橙色
        "#6C5CE7", // 紫色
        "#00B894"  // 深绿
    ]

    private let iconOptions = [
        "star.fill",
        "sun.max.fill",
        "moon.stars.fill",
        "figure.run",
        "dumbbell.fill",
        "book.fill",
        "pencil",
        "music.note",
        "heart.fill",
        "leaf.fill",
        "drop.fill",
        "flame.fill",
        "bolt.fill",
        "sparkles"
    ]

    private let weekdayNames = ["一", "二", "三", "四", "五", "六", "日"]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // 任务名称
                Section("任务名称") {
                    TextField("例如: 早起打卡", text: $title)
                }

                // 颜色选择
                Section("选择颜色") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            ColorButton(
                                color: color,
                                isSelected: selectedColor == color,
                                action: {
                                    selectedColor = color
                                }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }

                // 图标选择
                Section("选择图标") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { icon in
                            IconButton(
                                icon: icon,
                                color: selectedColor,
                                isSelected: selectedIcon == icon,
                                action: {
                                    selectedIcon = icon
                                }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }

                // 循环设置
                Section("循环设置") {
                    Picker("循环方式", selection: $recurringType) {
                        ForEach(RecurringType.allCases.filter { $0 != .none }, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }

                    // 自定义星期选择
                    if recurringType == .custom {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("选择星期")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            HStack(spacing: 8) {
                                ForEach(1...7, id: \.self) { weekday in
                                    WeekdayButton(
                                        weekday: weekday,
                                        label: weekdayNames[weekday - 1],
                                        isSelected: customWeekdays.contains(weekday),
                                        action: {
                                            if customWeekdays.contains(weekday) {
                                                customWeekdays.remove(weekday)
                                            } else {
                                                customWeekdays.insert(weekday)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                // 预览
                Section {
                    VStack(spacing: 16) {
                        // 未完成状态预览
                        VStack(alignment: .leading, spacing: 8) {
                            Text("未完成")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)

                            let uncompletedTodo = createPreviewTodo(isCompleted: false)
                            RecurringTaskCard(todo: uncompletedTodo) {}
                                .frame(height: 120)
                        }

                        // 已完成状态预览
                        VStack(alignment: .leading, spacing: 8) {
                            Text("已完成")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)

                            let completedTodo = createPreviewTodo(isCompleted: true)
                            RecurringTaskCard(todo: completedTodo) {}
                                .frame(height: 120)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("预览效果")
                } footer: {
                    Text("展示未完成和已完成两种状态的卡片效果")
                        .font(.caption)
                }
            }
            .navigationTitle("添加自律打卡")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        onDismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveRecurringTask()
                    }
                    .disabled(!isValid || isSaving)
                }
            }
            .disabled(isSaving)
        }
    }

    // MARK: - 方法

    /// 验证表单
    private var isValid: Bool {
        let titleValid = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let weekdaysValid = recurringType != .custom || !customWeekdays.isEmpty
        return titleValid && weekdaysValid
    }

    /// 创建预览用的 TodoItem
    private func createPreviewTodo(isCompleted: Bool = false) -> TodoItem {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())

        let todo = TodoItem(title: title.isEmpty ? "预览任务" : title)
        todo.isRecurring = true
        todo.recurringType = recurringType
        todo.recurringColor = selectedColor
        todo.recurringIcon = selectedIcon
        todo.customWeekdays = Array(customWeekdays).sorted()

        if isCompleted {
            // 已完成状态：模拟打卡数据
            todo.streakDays = 7
            todo.checkInDates = [
                todayString,
                dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
                dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -2, to: Date())!),
                dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -3, to: Date())!),
                dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -4, to: Date())!),
                dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -5, to: Date())!),
                dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -6, to: Date())!)
            ]
        } else {
            // 未完成状态：有历史打卡但今天未完成
            todo.streakDays = 3
            todo.checkInDates = [
                dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
                dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -2, to: Date())!),
                dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -3, to: Date())!)
            ]
        }

        return todo
    }

    /// 保存循环任务
    private func saveRecurringTask() {
        guard isValid else { return }

        isSaving = true

        Task {
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

            // 创建 TodoItem
            let todo = TodoItem(title: trimmedTitle)
            todo.isRecurring = true
            todo.recurringType = recurringType
            todo.recurringColor = selectedColor
            todo.recurringIcon = selectedIcon
            todo.customWeekdays = Array(customWeekdays).sorted()
            todo.streakDays = 0
            todo.checkInDates = []

            // 添加到 ViewModel
            await todoViewModel.addTodo(todo)

            isSaving = false
            onDismiss()
        }
    }
}

// MARK: - 辅助组件

/// 颜色选择按钮
struct ColorButton: View {
    let color: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(hex: color))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .strokeBorder(isSelected ? Color.white : Color.clear, lineWidth: isSelected ? 3 : 0)
                    )
                    .shadow(color: isSelected ? Color.black.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

/// 图标选择按钮
struct IconButton: View {
    let icon: String
    let color: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color(hex: color) : Color(.systemGray5))
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isSelected ? Color.white : Color.clear, lineWidth: isSelected ? 2 : 0)
                    )
                    .shadow(color: isSelected ? Color.black.opacity(0.2) : Color.clear, radius: 3, x: 0, y: 2)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .primary)
            }
        }
        .buttonStyle(.plain)
    }
}

/// 星期选择按钮
struct WeekdayButton: View {
    let weekday: Int
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .clipShape(Circle())
        }
    }
}

// MARK: - 预览

#Preview {
    let authViewModel = AuthViewModel()
    let todoViewModel = TodoViewModel(authViewModel: authViewModel)

    return CreateRecurringTaskView(
        todoViewModel: todoViewModel,
        onDismiss: {}
    )
}
