/**
 * 快捷添加 Todo 视图
 *
 * 功能：
 * - 智能文本输入框（带语义理解）
 * - 自动提取时间、优先级
 * - 可视化显示解析结果
 * - 一键保存
 *
 * 示例用法：
 * - 用户输入："明天早上9点去图书馆"
 * - 系统自动识别：时间=明天9:00, 内容="去图书馆"
 */

import SwiftUI

struct QuickAddTodoView: View {
    // MARK: - Environment
    @State private var categoryViewModel: CategoryViewModel
    let todoViewModel: TodoViewModel
    let onSave: () -> Void

    // MARK: - State
    @State private var inputText: String = ""
    @State private var parsedInfo: ParsedTodoInfo = ParsedTodoInfo(content: "")
    @State private var selectedCategory: Category?
    @State private var manualPriority: Priority?    // 手动选择的优先级
    @State private var manualDate: Date?            // 手动选择的日期
    @State private var showCategoryPicker = false
    @State private var showDatePicker = false       // 是否显示时间选择器
    @State private var isExpanded = false           // 是否展开为 full 状态（显示第二行）

    // 语音识别相关（从外部传入）
    @Binding var speechRecognizer: SpeechRecognitionManager
    
    // 输入框焦点状态（从外部传入，便于父视图控制键盘显示/隐藏）
    var isTextFieldFocused: FocusState<Bool>.Binding

    // MARK: - 初始化
    init(
        todoViewModel: TodoViewModel,
        authViewModel: AuthViewModel,
        speechRecognizer: Binding<SpeechRecognitionManager>,
        isTextFieldFocused: FocusState<Bool>.Binding,
        onSave: @escaping () -> Void
    ) {
        self.todoViewModel = todoViewModel
        self.onSave = onSave
        _speechRecognizer = speechRecognizer
        self.isTextFieldFocused = isTextFieldFocused
        _categoryViewModel = State(initialValue: CategoryViewModel(authViewModel: authViewModel))
    }

    // MARK: - Computed Properties

    /// 最终使用的优先级（手动选择优先于自动识别）
    private var finalPriority: Priority {
        manualPriority ?? parsedInfo.priority ?? .medium
    }

    /// 最终使用的日期（手动选择优先于自动识别）
    private var finalDate: Date? {
        manualDate ?? parsedInfo.dueDate
    }

    /// 是否可以保存
    private var canSave: Bool {
        !parsedInfo.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 是否显示第二行（有文字输入或语音输入时）
    private var shouldShowSecondRow: Bool {
        !inputText.isEmpty || speechRecognizer.isRecording
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // 分隔线
            Divider()
                .contentShape(Rectangle())
                .onTapGesture {
                    // 点击分隔线区域时隐藏键盘
                    isTextFieldFocused.wrappedValue = false
                }

            VStack(spacing: 0) {
                // 第一行：输入框 + 发送按钮（垂直居中对齐）
                HStack(alignment: .center, spacing: 12) {
                    // 文本输入框
                    TextField("输入待办事项...", text: $inputText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16))
                        .lineLimit(1...3)
                        .focused(isTextFieldFocused)
                        .onChange(of: inputText) { _, newValue in
                            parseInput(newValue)
                        }
                        .submitLabel(.send)
                        .onSubmit {
                            if canSave {
                                handleSend()
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)

                    // 发送按钮
                    Button(action: {
                        handleSend()
                    }) {
                        Image(systemName: canSave ? "arrow.up.circle.fill" : "arrow.up.circle")
                            .font(.system(size: 28))
                            .foregroundColor(canSave ? .blue : .gray)
                    }
                    .disabled(!canSave)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

                // 第二行：时间、优先级、类别（有内容时显示）
                if shouldShowSecondRow {
                    HStack(spacing: 12) {
                        // 时间按钮
                        Button(action: {
                            showDatePicker = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                    .font(.system(size: 14))
                                if let date = finalDate {
                                    Text(formatDate(date))
                                        .font(.subheadline)
                                } else {
                                    Text("时间")
                                        .font(.subheadline)
                                }
                            }
                            .foregroundColor(finalDate != nil ? .blue : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(finalDate != nil ? Color.blue.opacity(0.15) : Color(.systemGray6))
                            .cornerRadius(8)
                        }

                        // 优先级
                        Menu {
                            Button(action: { manualPriority = .high }) {
                                Label("高", systemImage: Priority.high.icon)
                            }
                            Button(action: { manualPriority = .medium }) {
                                Label("中", systemImage: Priority.medium.icon)
                            }
                            Button(action: { manualPriority = .low }) {
                                Label("低", systemImage: Priority.low.icon)
                            }
                            if manualPriority != nil {
                                Divider()
                                Button(role: .destructive, action: { manualPriority = nil }) {
                                    Label("清除", systemImage: "xmark")
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: finalPriority.icon)
                                    .font(.system(size: 14))
                                Text(finalPriority.rawValue)
                                    .font(.subheadline)
                            }
                            .foregroundColor(getPriorityColor(finalPriority))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(getPriorityColor(finalPriority).opacity(0.15))
                            .cornerRadius(8)
                        }

                        // 类别
                        Button(action: {
                            showCategoryPicker = true
                        }) {
                            HStack(spacing: 6) {
                                if let category = selectedCategory {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 14))
                                    Text(category.name)
                                        .font(.subheadline)
                                } else {
                                    Image(systemName: "folder")
                                        .font(.system(size: 14))
                                    Text("类别")
                                        .font(.subheadline)
                                }
                            }
                            .foregroundColor(selectedCategory != nil ? Color(hex: selectedCategory!.colorHex) : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedCategory != nil ? Color(hex: selectedCategory!.colorHex).opacity(0.15) : Color(.systemGray6))
                            .cornerRadius(8)
                        }

                        Spacer()

                        // 解析提示（仅在有时间信息时显示）
                        // if let timeText = parsedInfo.detectedTimeText, !timeText.isEmpty {
                        //     HStack(spacing: 6) {
                        //         Image(systemName: "sparkles")
                        //             .font(.system(size: 12))
                        //             .foregroundColor(.blue)
                        //         Text(timeText)
                        //             .font(.subheadline)
                        //             .foregroundColor(.secondary)
                        //     }
                        //     .padding(.horizontal, 10)
                        //     .padding(.vertical, 6)
                        //     .background(Color.blue.opacity(0.08))
                        //     .cornerRadius(8)
                        // }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .sheet(isPresented: $showCategoryPicker) {
            categoryPickerSheet
        }
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
        .onChange(of: speechRecognizer.recognizedText) { _, newValue in
            if !newValue.isEmpty && speechRecognizer.isRecording {
                inputText = newValue
            }
        }
        .onAppear {
            categoryViewModel.loadCategories()
        }
    }

    // MARK: - Subviews

    /// 类别选择器
    private var categoryPickerSheet: some View {
        NavigationStack {
            List {
                // 无分类选项
                Button(action: {
                    selectedCategory = nil
                    showCategoryPicker = false
                }) {
                    HStack {
                        Image(systemName: "tray")
                            .foregroundColor(.gray)
                        Text("无分类")
                        Spacer()
                        if selectedCategory == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }

                // 所有分类
                ForEach(categoryViewModel.categories) { category in
                    Button(action: {
                        selectedCategory = category
                        showCategoryPicker = false
                    }) {
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(Color(hex: category.colorHex))
                            Text(category.name)
                            Spacer()
                            if selectedCategory?.id == category.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择类别")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        showCategoryPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    /// 时间选择器
    private var datePickerSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 日期时间选择器
                DatePicker(
                    "选择时间",
                    selection: Binding(
                        get: { manualDate ?? finalDate ?? Date() },
                        set: { manualDate = $0 }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                // 快捷选项
                VStack(spacing: 12) {
                    Text("快捷选项")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // 今天
                            QuickDateButton(title: "今天", icon: "calendar") {
                                let calendar = Calendar.current
                                manualDate = calendar.startOfDay(for: Date())
                            }
                            
                            // 明天
                            QuickDateButton(title: "明天", icon: "sunrise") {
                                let calendar = Calendar.current
                                if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) {
                                    manualDate = calendar.startOfDay(for: tomorrow)
                                }
                            }
                            
                            // 后天
                            QuickDateButton(title: "后天", icon: "sun.max") {
                                let calendar = Calendar.current
                                if let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: Date()) {
                                    manualDate = calendar.startOfDay(for: dayAfterTomorrow)
                                }
                            }
                            
                            // 下周
                            QuickDateButton(title: "下周", icon: "calendar.badge.plus") {
                                let calendar = Calendar.current
                                if let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: Date()) {
                                    manualDate = calendar.startOfDay(for: nextWeek)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("选择时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        showDatePicker = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        showDatePicker = false
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    if manualDate != nil {
                        Button(role: .destructive, action: {
                            manualDate = nil
                            showDatePicker = false
                        }) {
                            Label("清除时间", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Methods

    /// 解析输入文本
    private func parseInput(_ text: String) {
        parsedInfo = NaturalLanguageParser.shared.parse(text)
    }

    /// 处理发送（保存 Todo）
    private func handleSend() {
        // 如果正在录音，先停止
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        }

        // 保存 Todo
        saveTodo()
    }

    /// 保存待办
    private func saveTodo() {
        guard canSave else { return }

        Task {
            await todoViewModel.createTodo(
                title: parsedInfo.content,
                description: nil,
                priority: finalPriority,
                dueDate: finalDate,
                category: selectedCategory,
                tags: []
            )

            // 清空输入
            inputText = ""
            parsedInfo = ParsedTodoInfo(content: "")
            manualPriority = nil
            manualDate = nil
            selectedCategory = nil
            isExpanded = false

            // 回调
            onSave()
        }
    }

    /// 格式化日期显示
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "今天 " + formatter.string(from: date)
        } else if calendar.isDateInTomorrow(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "明天 " + formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd HH:mm"
            return formatter.string(from: date)
        }
    }

    /// 获取优先级颜色
    private func getPriorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .gray
        }
    }
}

// MARK: - Helper Views

/// 快捷日期按钮
private struct QuickDateButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.subheadline)
            }
            .frame(width: 80, height: 80)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var speechRecognizer = SpeechRecognitionManager()
        @FocusState private var isTextFieldFocused: Bool
        let authViewModel: AuthViewModel

        init() {
            let viewModel = AuthViewModel()
            let mockUser = User(
                username: "预览用户",
                phoneNumber: "13800138000",
                email: "preview@example.com"
            )
            viewModel.currentUser = mockUser
            self.authViewModel = viewModel
        }

        var body: some View {
            VStack {
                Spacer()
                QuickAddTodoView(
                    todoViewModel: TodoViewModel(authViewModel: authViewModel),
                    authViewModel: authViewModel,
                    speechRecognizer: $speechRecognizer,
                    isTextFieldFocused: $isTextFieldFocused,
                    onSave: {}
                )
            }
            .background(Color(.systemGroupedBackground))
            .onTapGesture {
                // 点击背景隐藏键盘
                isTextFieldFocused = false
            }
        }
    }

    return PreviewWrapper()
}
