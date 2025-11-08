/**
 * 待办列表视图
 *
 * 主要功能：
 * - 显示待办列表
 * - 筛选和排序
 * - 搜索
 * - 快速操作（完成、删除）
 */

import SwiftUI
import SwiftData

struct TodoListView: View {
    // MARK: - 环境

    @Environment(AuthViewModel.self) private var authViewModel
    @State private var todoViewModel: TodoViewModel
    @State private var categoryViewModel: CategoryViewModel

    // MARK: - 状态

    @State private var showCreateView = false
    @State private var showFilterSheet = false
    @State private var selectedTodoItem: SelectedTodoItem?
    @State private var showToast = false
    @State private var groupByCategory = false // 是否按分类分组
    @State private var speechRecognizer = SpeechRecognitionManager() // 语音识别管理器
    @State private var micButtonPosition: CGPoint? = nil // 麦克风按钮的位置（nil = 使用默认位置）
    @State private var isDraggingMic = false // 是否正在拖拽麦克风
    @FocusState private var isQuickAddFocused: Bool // QuickAdd输入框焦点状态
    
    // 左滑操作相关状态
    @State private var todoToDelete: TodoItem? = nil // 待删除的 todo
    @State private var showDeleteConfirm = false // 显示删除确认对话框
    @State private var todoForSubtask: TodoItem? = nil // 要添加子任务的 todo
    @State private var showAddSubtaskSheet = false // 显示添加子任务弹窗
    @State private var newSubtaskTitle = "" // 新子任务标题

    // MARK: - 初始化

    init(authViewModel: AuthViewModel) {
        _todoViewModel = State(initialValue: TodoViewModel(authViewModel: authViewModel))
        _categoryViewModel = State(initialValue: CategoryViewModel(authViewModel: authViewModel))
    }

    // MARK: - 计算属性

    /// 是否有激活的筛选或排序
    private var hasActiveFilterOrSort: Bool {
        todoViewModel.currentFilter != .all || todoViewModel.currentSort != .createdAt
    }

    /// 按分类分组的 todos
    private var groupedTodos: [(category: Category?, todos: [TodoItem])] {
        let todos = todoViewModel.filteredTodos

        if !groupByCategory {
            return [(category: nil, todos: todos)]
        }

        // 按分类分组
        var grouped: [UUID?: [TodoItem]] = [:]
        for todo in todos {
            let key = todo.category?.id
            if grouped[key] == nil {
                grouped[key] = []
            }
            grouped[key]?.append(todo)
        }

        // 转换为有序数组
        var result: [(category: Category?, todos: [TodoItem])] = []

        // 先添加有分类的
        let sortedCategories = categoryViewModel.categories.sorted { $0.sortOrder < $1.sortOrder }
        for category in sortedCategories {
            if let todos = grouped[category.id], !todos.isEmpty {
                result.append((category: category, todos: todos))
            }
        }

        // 最后添加无分类的
        if let uncategorizedTodos = grouped[nil], !uncategorizedTodos.isEmpty {
            result.append((category: nil, todos: uncategorizedTodos))
        }

        return result
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // 主内容区域
                    ZStack {
                        if todoViewModel.isLoading && todoViewModel.todos.isEmpty {
                            // 加载中
                            loadingView
                        } else if todoViewModel.filteredTodos.isEmpty {
                            // 空状态
                            emptyView
                        } else {
                            // 列表内容
                            listContent
                        }
                    }
                    .simultaneousGesture(
                        // 使用 simultaneousGesture 确保不会阻止列表滚动
                        TapGesture().onEnded { _ in
                            // 点击列表区域时隐藏键盘
                            isQuickAddFocused = false
                        }
                    )

                    // 底部快捷添加入口
                    QuickAddTodoView(
                        todoViewModel: todoViewModel,
                        authViewModel: authViewModel,
                        speechRecognizer: $speechRecognizer,
                        isTextFieldFocused: $isQuickAddFocused,
                        onSave: {
                            // 保存成功后的回调
                        }
                    )
                }

                // 悬浮麦克风按钮（可拖拽，默认右下角）
                GeometryReader { geometry in
                    let defaultPosition = CGPoint(
                        x: geometry.size.width - 40,
                        y: geometry.size.height - 160
                    )
                    let currentPosition = micButtonPosition ?? defaultPosition

                    floatingMicButton
                        .position(currentPosition)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    isDraggingMic = true
                                    // 实时更新位置
                                    let newPosition = CGPoint(
                                        x: clampPosition(
                                            value: value.location.x,
                                            min: 40,
                                            max: geometry.size.width - 40
                                        ),
                                        y: clampPosition(
                                            value: value.location.y,
                                            min: 60,
                                            max: geometry.size.height - 40
                                        )
                                    )
                                    micButtonPosition = newPosition
                                }
                                .onEnded { _ in
                                    isDraggingMic = false
                                    // 位置已经在 onChanged 中设置好了
                                }
                        )
                }
            }
            .navigationTitle("待办")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .searchable(text: $todoViewModel.searchText, prompt: "搜索待办")
            .sheet(isPresented: $showCreateView) {
                CreateTodoView(todoViewModel: todoViewModel)
            }
            .sheet(item: $selectedTodoItem) { item in
                TodoDetailView(
                    todo: item.todo,
                    todoViewModel: todoViewModel,
                    currentIndex: item.index
                )
            }
            .sheet(isPresented: $showFilterSheet) {
                filterSheet
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
            .onAppear {
                todoViewModel.loadTodos()
                categoryViewModel.loadCategories()
            }
            // 删除确认对话框
            .alert("确定删除？", isPresented: $showDeleteConfirm) {
                Button("删除", role: .destructive) {
                    if let todo = todoToDelete {
                        Task {
                            await todoViewModel.deleteTodo(todo)
                            todoToDelete = nil
                        }
                    }
                }
                Button("取消", role: .cancel) {
                    todoToDelete = nil
                }
            } message: {
                Text("删除后无法恢复")
            }
            // 添加子任务弹窗
            .sheet(isPresented: $showAddSubtaskSheet) {
                if let todo = todoForSubtask {
                    AddSubtaskSheet(
                        todoTitle: todo.title,
                        newSubtaskTitle: $newSubtaskTitle,
                        onAdd: {
                            let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                Task {
                                    await todoViewModel.addSubtask(to: todo, title: trimmed)
                                }
                            }
                            showAddSubtaskSheet = false
                            newSubtaskTitle = ""
                            todoForSubtask = nil
                        },
                        onCancel: {
                            showAddSubtaskSheet = false
                            newSubtaskTitle = ""
                            todoForSubtask = nil
                        }
                    )
                    .presentationDetents([.height(300)])
                }
            }
        }
    }

    // MARK: - 子视图

    /// 加载视图
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("加载中...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            isQuickAddFocused = false
        }
    }

    /// 空状态视图
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: todoViewModel.searchText.isEmpty ? "checkmark.circle" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            if todoViewModel.searchText.isEmpty {
                Text("还没有待办事项")
                    .font(.title3)
                    .fontWeight(.medium)

                Text("点击右上角 + 创建第一个待办")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button(action: {
                    showCreateView = true
                }) {
                    Label("创建待办", systemImage: "plus")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(Layout.mediumCornerRadius)
                }
                .padding(.top)
            } else {
                Text("没有找到匹配的待办")
                    .font(.title3)
                    .fontWeight(.medium)

                Text("尝试其他关键词")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            isQuickAddFocused = false
        }
    }

    /// 列表内容
    private var listContent: some View {
        List {
            // 筛选状态栏
            if hasActiveFilterOrSort {
                Section {
                    filterStatusBar
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            ForEach(Array(groupedTodos.enumerated()), id: \.offset) { groupIndex, group in
                Section {
                    ForEach(Array(group.todos.enumerated()), id: \.element.id) { localIndex, todo in
                        // 计算在全局 filteredTodos 中的索引
                        let globalIndex = calculateGlobalIndex(for: todo)

                        TodoRow(
                            todo: todo,
                            onToggle: {
                                Task {
                                    await todoViewModel.toggleCompletion(todo)
                                }
                            },
                            onDelete: {
                                // 通过 ViewModel 删除
                                Task {
                                    await todoViewModel.deleteTodo(todo)
                                }
                            },
                            onAddSubtask: { subtaskTitle in
                                Task {
                                    await todoViewModel.addSubtask(to: todo, title: subtaskTitle)
                                }
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        // 左滑操作
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            // 删除按钮（红色）
                            Button(role: .destructive) {
                                todoToDelete = todo
                                showDeleteConfirm = true
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                            .tint(.red)
                            
                            // 添加子任务按钮（蓝色）
                            Button {
                                todoForSubtask = todo
                                showAddSubtaskSheet = true
                            } label: {
                                Label("子任务", systemImage: "checklist")
                            }
                            .tint(.blue)
                        }
                        .onTapGesture {
                            // 隐藏键盘并打开详情
                            isQuickAddFocused = false
                            selectedTodoItem = SelectedTodoItem(todo: todo, index: globalIndex)
                        }
                    }
                } header: {
                    if groupByCategory {
                        if let category = group.category {
                            // 分类标题
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(Color(hex: category.colorHex))
                                Text(category.name)
                                    .font(.headline)
                                Spacer()
                                Text("\(group.todos.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        } else {
                            // 无分类标题
                            HStack {
                                Image(systemName: "tray")
                                    .foregroundColor(.gray)
                                Text("未分类")
                                    .font(.headline)
                                Spacer()
                                Text("\(group.todos.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .scrollDismissesKeyboard(.interactively) // iOS 16+: 滚动时自动隐藏键盘
        .refreshable {
            await todoViewModel.refresh()
            await categoryViewModel.refresh()
        }
        .simultaneousGesture(
            // 监听滚动开始，隐藏键盘
            DragGesture(minimumDistance: 10)
                .onChanged { _ in
                    isQuickAddFocused = false
                }
        )
    }

    /// 计算 todo 在全局 filteredTodos 中的索引
    private func calculateGlobalIndex(for todo: TodoItem) -> Int {
        todoViewModel.filteredTodos.firstIndex(where: { $0.id == todo.id }) ?? 0
    }

    /// 筛选状态栏
    private var filterStatusBar: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 背景容器
            VStack(alignment: .leading, spacing: 8) {
                // 标题行
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Text("当前筛选")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Spacer()
                }

                // 筛选和排序标签
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // 筛选标签
                        if todoViewModel.currentFilter != .all {
                            FilterStatusChip(
                                icon: todoViewModel.currentFilter.icon,
                                title: todoViewModel.currentFilter.displayName,
                                onRemove: {
                                    withAnimation {
                                        todoViewModel.updateFilter(.all)
                                    }
                                }
                            )
                        }

                        // 排序标签
                        if todoViewModel.currentSort != .createdAt {
                            FilterStatusChip(
                                icon: "arrow.up.arrow.down",
                                title: todoViewModel.currentSort.displayName,
                                onRemove: {
                                    withAnimation {
                                        todoViewModel.updateSort(.createdAt)
                                    }
                                }
                            )
                        }

                        // 清除全部按钮
                        Button(action: {
                            withAnimation {
                                todoViewModel.updateFilter(.all)
                                todoViewModel.updateSort(.createdAt)
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                Text("清除全部")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    /// 筛选栏
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach([
                    TodoFilterOption.all,
                    .today,
                    .week,
                    .uncompleted,
                    .completed,
                    .overdue
                ], id: \.self) { filter in
                    FilterChip(
                        title: filter.displayName,
                        isSelected: todoViewModel.currentFilter == filter,
                        action: {
                            todoViewModel.updateFilter(filter)
                        }
                    )
                }
            }
        }
    }

    /// 筛选弹窗
    private var filterSheet: some View {
        NavigationStack {
            List {
                Section("筛选") {
                    ForEach(TodoFilterOption.allCases, id: \.self) { filter in
                        Button(action: {
                            todoViewModel.updateFilter(filter)
                            showFilterSheet = false
                        }) {
                            HStack {
                                Text(filter.displayName)
                                Spacer()
                                if todoViewModel.currentFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }

                Section("排序") {
                    ForEach(TodoSortOption.allCases, id: \.self) { sort in
                        Button(action: {
                            todoViewModel.updateSort(sort)
                            showFilterSheet = false
                        }) {
                            HStack {
                                Text(sort.displayName)
                                Spacer()
                                if todoViewModel.currentSort == sort {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("筛选和排序")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        showFilterSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    /// 工具栏内容
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // 筛选和分组按钮
        ToolbarItem(placement: .topBarLeading) {
            HStack(spacing: 16) {
                Button(action: {
                    showFilterSheet = true
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }

                Button(action: {
                    withAnimation {
                        groupByCategory.toggle()
                    }
                }) {
                    Image(systemName: groupByCategory ? "folder.fill" : "folder")
                        .foregroundColor(groupByCategory ? .blue : .primary)
                }
            }
        }

        // 添加按钮
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                showCreateView = true
            }) {
                Image(systemName: "plus")
            }
        }
    }

    /// 悬浮麦克风按钮
    private var floatingMicButton: some View {
        Button(action: {
            toggleSpeechRecognition()
        }) {
            ZStack {
                // 背景阴影
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)

                // 录音中的脉动光晕
                if speechRecognizer.isRecording {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 56, height: 56)
                        .scaleEffect(speechRecognizer.isRecording ? 1.3 : 1.0)
                        .opacity(speechRecognizer.isRecording ? 0.5 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                            value: speechRecognizer.isRecording
                        )
                }

                // 麦克风图标
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(speechRecognizer.isRecording ? .red : .orange)
            }
        }
    }

    /// 切换语音识别状态
    private func toggleSpeechRecognition() {
        // 触觉反馈
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        #endif

        if speechRecognizer.isRecording {
            // 停止录音
            speechRecognizer.stopRecording()
        } else {
            // 开始录音
            startSpeechRecognition()
        }
    }

    /// 开始语音识别
    private func startSpeechRecognition() {
        Task {
            // 请求权限
            let granted = await speechRecognizer.requestPermission()

            guard granted else {
                // TODO: 显示权限提示
                return
            }

            // 开始录音
            do {
                try speechRecognizer.startRecording { recognizedText in
                    // 语音识别的文字会通过 speechRecognizer.recognizedText 自动更新
                    // QuickAddTodoView 会监听这个变化
                }
            } catch {
                // TODO: 显示错误提示
                print("启动语音识别失败: \(error)")
            }
        }
    }

    /// 限制位置在指定范围内
    private func clampPosition(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.min(Swift.max(value, min), max)
    }
}

// MARK: - 辅助组件

/// 选中的待办项（用于 sheet presentation）
struct SelectedTodoItem: Identifiable {
    let id = UUID()
    let todo: TodoItem
    let index: Int
}

/// 筛选标签
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

/// 筛选状态标签（可关闭）
struct FilterStatusChip: View {
    let icon: String
    let title: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .foregroundColor(.blue)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - 预览
// Preview已移除 - 直接运行应用查看效果

/*
#Preview("With Sample Data") {
    // Use DataManager's shared container so TodoViewModel can load the data
    let context = DataManager.shared.context
    
    // Create a mock user for preview
    let mockUser = User(
        username: "预览用户",
        phoneNumber: "13800138000",
        email: "preview@example.com"
    )
    context.insert(mockUser)
    
    // Create sample categories
    let workCategory = Category(
        name: "工作",
        icon: "briefcase.fill",
        colorHex: "#007AFF",
        sortOrder: 1,
        user: mockUser
    )
    
    let studyCategory = Category(
        name: "学习",
        icon: "book.fill",
        colorHex: "#FF9500",
        sortOrder: 2,
        user: mockUser
    )
    
    let lifeCategory = Category(
        name: "生活",
        icon: "house.fill",
        colorHex: "#34C759",
        sortOrder: 3,
        user: mockUser
    )
    
    // Insert categories
    context.insert(workCategory)
    context.insert(studyCategory)
    context.insert(lifeCategory)
    
    // Sample todos
    // 1. High priority, due today
    let todo1 = TodoItem(
        title: "完成项目提案",
        itemDescription: "准备下周一的项目提案演示文稿，包含市场分析和技术方案",
        priority: .high,
        tags: ["紧急", "重要"],
        dueDate: Calendar.current.date(byAdding: .hour, value: 3, to: Date()),
//        category: workCategory,
        user: mockUser
    )
    todo1.estimatedPomodoros = 4
    todo1.pomodoroCount = 1
    
    // 2. Medium priority, with subtasks
    let todo2 = TodoItem(
        title: "学习 SwiftUI 进阶",
        itemDescription: "掌握 SwiftData、Observation 和现代并发编程",
        priority: .medium,
        tags: ["学习", "SwiftUI"],
        dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
        category: studyCategory,
        user: mockUser
    )
    let subtask1 = Subtask(title: "阅读官方文档", isCompleted: true, sortOrder: 1, todo: todo2)
    let subtask2 = Subtask(title: "完成练习项目", isCompleted: false, sortOrder: 2, todo: todo2)
    let subtask3 = Subtask(title: "写学习笔记", isCompleted: false, sortOrder: 3, todo: todo2)
    todo2.subtasks = [subtask1, subtask2, subtask3]
    
    // 3. Overdue task
    let todo3 = TodoItem(
        title: "缴纳水电费",
        itemDescription: "本月的水电费账单",
        priority: .high,
        tags: ["账单"],
        dueDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
        category: lifeCategory,
        user: mockUser
    )
    
    // 4. Low priority, no due date
    let todo4 = TodoItem(
        title: "整理书架",
        itemDescription: "把书架上的书按类别重新整理",
        priority: .low,
        tags: ["整理"],
        dueDate: nil,
        category: lifeCategory,
        user: mockUser
    )
    
    // 5. Completed task
    let todo5 = TodoItem(
        title: "晨跑 5 公里",
        itemDescription: "早上在公园完成",
        isCompleted: true,
        priority: .medium,
        tags: ["运动", "健康"],
        dueDate: Calendar.current.startOfDay(for: Date()),
        category: lifeCategory,
        user: mockUser
    )
    todo5.completedAt = Date()
    todo5.pomodoroCount = 1
    
    // 6. High priority with pomodoros
    let todo6 = TodoItem(
        title: "代码评审",
        itemDescription: "Review PR #234 和 PR #235 的代码变更",
        priority: .high,
        tags: ["代码", "评审"],
        dueDate: Calendar.current.date(byAdding: .hour, value: 6, to: Date()),
        category: workCategory,
        user: mockUser
    )
    todo6.estimatedPomodoros = 2
    
    // 7. Medium priority, due this week
    let todo7 = TodoItem(
        title: "准备团队周会",
        itemDescription: "整理本周工作进展和下周计划",
        priority: .medium,
        tags: ["会议"],
        dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
        category: workCategory,
        user: mockUser
    )
    
    // 8. Completed task with subtasks
    let todo8 = TodoItem(
        title: "购买日用品",
        itemDescription: "超市采购清单",
        isCompleted: true,
        priority: .low,
        tags: ["购物"],
        dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
        category: lifeCategory,
        user: mockUser
    )
    todo8.completedAt = Calendar.current.date(byAdding: .hour, value: -2, to: Date())
    let subtask4 = Subtask(title: "卫生纸", isCompleted: true, sortOrder: 1, todo: todo8)
    let subtask5 = Subtask(title: "洗洁精", isCompleted: true, sortOrder: 2, todo: todo8)
    let subtask6 = Subtask(title: "水果", isCompleted: true, sortOrder: 3, todo: todo8)
    todo8.subtasks = [subtask4, subtask5, subtask6]
    
    // Insert all todos
    context.insert(todo1)
    context.insert(todo2)
    context.insert(todo3)
    context.insert(todo4)
    context.insert(todo5)
    context.insert(todo6)
    context.insert(todo7)
    context.insert(todo8)
    
    // Insert subtasks
    context.insert(subtask1)
    context.insert(subtask2)
    context.insert(subtask3)
    context.insert(subtask4)
    context.insert(subtask5)
    context.insert(subtask6)
    
    // Save the context
    try? context.save()
    
    // Create AuthViewModel with the mock user
    let authViewModel = AuthViewModel()
    authViewModel.currentUser = mockUser
    
    // Demo: QuickAddTodoView with natural language input
    // Shows how the parser handles: "下周一下午3点开会，高优先级，添加到工作分类"
    TodoListView(authViewModel: authViewModel)
        .environment(authViewModel)
        .modelContainer(DataManager.shared.container)
}
*/

// MARK: - 添加子任务弹窗

struct AddSubtaskSheet: View {
    let todoTitle: String
    @Binding var newSubtaskTitle: String
    let onAdd: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 提示文本
                Text("为「\(todoTitle)」添加子任务")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.top)

                // 输入框
                TextField("输入子任务标题", text: $newSubtaskTitle)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onSubmit {
                        if !newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onAdd()
                        }
                    }

                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("添加子任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        onCancel()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        onAdd()
                    }
                    .disabled(newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
