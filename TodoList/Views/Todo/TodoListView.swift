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

    // MARK: - 初始化

    init(authViewModel: AuthViewModel) {
        _todoViewModel = State(initialValue: TodoViewModel(authViewModel: authViewModel))
        _categoryViewModel = State(initialValue: CategoryViewModel(authViewModel: authViewModel))
    }

    // MARK: - 计算属性

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
    }

    /// 列表内容
    private var listContent: some View {
        List {
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
                        .onTapGesture {
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
        .refreshable {
            await todoViewModel.refresh()
            await categoryViewModel.refresh()
        }
    }

    /// 计算 todo 在全局 filteredTodos 中的索引
    private func calculateGlobalIndex(for todo: TodoItem) -> Int {
        todoViewModel.filteredTodos.firstIndex(where: { $0.id == todo.id }) ?? 0
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

// MARK: - 预览

#Preview("Empty State") {
    // Create a mock user for preview
    let authViewModel = AuthViewModel()
    let mockUser = User(
        username: "预览用户",
        phoneNumber: "13800138000",
        email: "preview@example.com"
    )
    authViewModel.currentUser = mockUser
    
    return TodoListView(authViewModel: authViewModel)
        .environment(authViewModel)
        .modelContainer(DataManager.shared.container)
}

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
    
    return TodoListView(authViewModel: authViewModel)
        .environment(authViewModel)
        .modelContainer(DataManager.shared.container)
}

#Preview("Loading State") {
    let authViewModel = AuthViewModel()
    let mockUser = User(
        username: "预览用户",
        phoneNumber: "13800138000",
        email: "preview@example.com"
    )
    authViewModel.currentUser = mockUser
    
    return TodoListView(authViewModel: authViewModel)
        .environment(authViewModel)
        .modelContainer(DataManager.shared.container)
}
