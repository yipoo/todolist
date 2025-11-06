/**
 * 待办详情视图
 *
 * 显示待办的完整信息
 * 支持：
 * - 查看所有信息
 * - 编辑
 * - 完成/取消完成
 * - 管理子任务
 * - 查看番茄钟记录
 */

import SwiftUI

struct TodoDetailView: View {
    // MARK: - 环境

    @Environment(\.dismiss) private var dismiss
    let todo: TodoItem
    let todoViewModel: TodoViewModel
    let initialIndex: Int // 初始索引

    // MARK: - 状态

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var newSubtaskTitle = ""
    @State private var showToast = false
    @State private var currentTodo: TodoItem
    @State private var currentIdx: Int

    // MARK: - 计算属性

    /// 实时获取所有待办(从 ViewModel)
    private var allTodos: [TodoItem] {
        todoViewModel.filteredTodos
    }

    // MARK: - 初始化

    init(todo: TodoItem, todoViewModel: TodoViewModel, currentIndex: Int) {
        self.todo = todo
        self.todoViewModel = todoViewModel
        self.initialIndex = currentIndex
        _currentTodo = State(initialValue: todo)
        _currentIdx = State(initialValue: currentIndex)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.largeSpacing) {
                    // 标题卡片
                    titleCard

                    // 信息卡片
                    infoCard

                    // 子任务卡片（始终显示）
                    subtasksCard

                    // 描述
                    if let description = currentTodo.itemDescription, !description.isEmpty {
                        descriptionCard(description)
                    }

                    // 标签
                    if !currentTodo.tags.isEmpty {
                        tagsCard
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("待办详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                navigationBar
            }
            // Toast 提示
            .toast(
                isPresented: $showToast,
                message: todoViewModel.errorMessage ?? todoViewModel.successMessage ?? "",
                type: todoViewModel.errorMessage != nil ? .error : .success
            )
            .onChange(of: todoViewModel.errorMessage) { _, newValue in
                if newValue != nil {
                    showToast = true
                }
            }
            .onChange(of: todoViewModel.successMessage) { _, newValue in
                if newValue != nil {
                    showToast = true
                }
            }
            // 监听 ViewModel 的数据变化，实时更新当前 todo
            .onChange(of: todoViewModel.filteredTodos) { _, newTodos in
                // 当数据更新时，刷新当前显示的 todo
                if currentIdx < newTodos.count {
                    currentTodo = newTodos[currentIdx]
                }
            }
            .onAppear {
                // 视图出现时，确保使用最新数据
                if currentIdx < allTodos.count {
                    currentTodo = allTodos[currentIdx]
                }
            }
            // 删除确认
            .alert("确定删除？", isPresented: $showDeleteAlert) {
                Button("删除", role: .destructive) {
                    Task {
                        await todoViewModel.deleteTodo(currentTodo)
                        dismiss()
                    }
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("删除后无法恢复")
            }
        }
    }

    // MARK: - 子视图

    /// 标题卡片
    private var titleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // 完成按钮
                Button(action: {
                    Task {
                        await todoViewModel.toggleCompletion(currentTodo)
                    }
                }) {
                    Image(systemName: currentTodo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.largeTitle)
                        .foregroundColor(currentTodo.isCompleted ? .green : .gray)
                }

                // 标题
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentTodo.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .strikethrough(currentTodo.isCompleted)

                    // 优先级标签
                    HStack(spacing: 4) {
                        Image(systemName: currentTodo.priority.icon)
                            .font(.caption)

                        Text(currentTodo.priority.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.priorityColor(currentTodo.priority).opacity(0.2))
                    .foregroundColor(Color.priorityColor(currentTodo.priority))
                    .cornerRadius(6)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    /// 信息卡片
    private var infoCard: some View {
        VStack(spacing: 16) {
            // 截止日期
            if let dueDate = todo.dueDate {
                InfoRow(
                    icon: "calendar",
                    title: "截止日期",
                    value: dueDate.friendlyString,
                    valueColor: todo.isOverdue() ? .red : .primary
                )
            }

            // 分类
            if let category = todo.category {
                InfoRow(
                    icon: category.icon,
                    title: "分类",
                    value: category.name,
                    valueColor: Color(hex: category.colorHex)
                )
            }

            // 创建时间
            InfoRow(
                icon: "clock",
                title: "创建时间",
                value: todo.createdAt.relativeString
            )

            // 完成时间
            if let completedAt = todo.completedAt {
                InfoRow(
                    icon: "checkmark.circle",
                    title: "完成时间",
                    value: completedAt.relativeString
                )
            }

            // 番茄钟
            if todo.pomodoroCount > 0 {
                InfoRow(
                    icon: "timer",
                    title: "番茄钟",
                    value: "\(todo.pomodoroCount) 个",
                    valueColor: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    /// 子任务卡片
    private var subtasksCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Label("子任务", systemImage: "checklist")
                    .font(.headline)

                Spacer()

                if !currentTodo.subtasks.isEmpty {
                    let completedCount = currentTodo.subtasks.filter { $0.isCompleted }.count
                    Text("\(completedCount)/\(currentTodo.subtasks.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // 子任务列表
            if !currentTodo.subtasks.isEmpty {
                ForEach(currentTodo.subtasks) { subtask in
                    HStack {
                        Button(action: {
                            Task {
                                await todoViewModel.toggleSubtask(subtask, in: currentTodo)
                            }
                        }) {
                            Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                                .foregroundColor(subtask.isCompleted ? .green : .gray)
                        }

                        Text(subtask.title)
                            .strikethrough(subtask.isCompleted)

                        Spacer()

                        Button(action: {
                            Task {
                                await todoViewModel.deleteSubtask(subtask, from: currentTodo)
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Divider()
                    .padding(.vertical, 4)
            } else {
                // 空状态提示
                Text("还没有子任务，点击下方按钮添加")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            }

            // 添加子任务区域
            VStack(spacing: 8) {
                HStack {
                    TextField("输入子任务标题", text: $newSubtaskTitle)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(8)
                        .onSubmit {
                            addSubtask()
                        }

                    Button(action: addSubtask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(newSubtaskTitle.trimmed.isEmpty ? .gray : .blue)
                    }
                    .disabled(newSubtaskTitle.trimmed.isEmpty)
                }

                // 或者使用按钮方式添加
                if newSubtaskTitle.isEmpty {
                    Button(action: {
                        // 聚焦到输入框（通过设置一个占位文本）
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("添加子任务")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    /// 描述卡片
    private func descriptionCard(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("描述", systemImage: "text.quote")
                .font(.headline)

            Text(description)
                .font(.body)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    /// 标签卡片
    private var tagsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("标签", systemImage: "tag")
                .font(.headline)

            // 使用 HStack + Wrap 来显示标签
            let rows = createTagRows(tags: currentTodo.tags)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(row, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(16)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    /// 创建标签行（简单实现，每行最多3个）
    private func createTagRows(tags: [String]) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []

        for tag in tags {
            currentRow.append(tag)
            if currentRow.count >= 3 {
                rows.append(currentRow)
                currentRow = []
            }
        }

        if !currentRow.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }

    /// 操作按钮
    /// 底部导航按钮
    private var navigationBar: some View {
        HStack(spacing: 20) {
            Spacer()
            // 上一个按钮
            Button(action: navigateToPrevious) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(hasPrevious ? .white : .gray)
                    .frame(width: 56, height: 56)
                    .background(hasPrevious ? Color.blue : Color(.systemGray5))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .disabled(!hasPrevious)
            Spacer()

            // 下一个按钮
            Button(action: navigateToNext) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(hasNext ? .white : .gray)
                    .frame(width: 56, height: 56)
                    .background(hasNext ? Color.blue : Color(.systemGray5))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .disabled(!hasNext)
            Spacer()
        }
        .padding(.bottom, 20)
    }

    /// 是否有上一个
    private var hasPrevious: Bool {
        currentIdx > 0 && !allTodos.isEmpty
    }

    /// 是否有下一个
    private var hasNext: Bool {
        currentIdx < allTodos.count - 1 && !allTodos.isEmpty
    }

    // MARK: - 方法

    /// 添加子任务
    private func addSubtask() {
        let trimmed = newSubtaskTitle.trimmed
        guard !trimmed.isEmpty else { return }

        Task {
            await todoViewModel.addSubtask(to: currentTodo, title: trimmed)
            newSubtaskTitle = ""
        }
    }

    /// 导航到上一个
    private func navigateToPrevious() {
        guard hasPrevious else { return }
        currentIdx -= 1
        // 边界检查
        if currentIdx < allTodos.count {
            currentTodo = allTodos[currentIdx]
        }
        newSubtaskTitle = ""
    }

    /// 导航到下一个
    private func navigateToNext() {
        guard hasNext else { return }
        currentIdx += 1
        // 边界检查
        if currentIdx < allTodos.count {
            currentTodo = allTodos[currentIdx]
        }
        newSubtaskTitle = ""
    }
}

// MARK: - 辅助组件

/// 信息行
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - 预览

#Preview {
    let todo = TodoItem(
        title: "完成 SwiftUI 学习",
        itemDescription: "学习 MVVM 架构、SwiftData 的使用，以及各种高级组件的实现",
        priority: .high,
        tags: ["学习", "iOS", "SwiftUI"],
        dueDate: Date().addingTimeInterval(86400),
        category: nil,
        user: nil
    )

    TodoDetailView(
        todo: todo,
        todoViewModel: TodoViewModel(authViewModel: AuthViewModel()),
        currentIndex: 0
    )
}
