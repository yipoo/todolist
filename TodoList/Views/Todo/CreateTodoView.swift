/**
 * 创建/编辑待办视图
 *
 * 表单包含：
 * - 标题（必填）
 * - 描述
 * - 优先级
 * - 截止日期
 * - 分类
 * - 标签
 */

import SwiftUI
import SwiftData

struct CreateTodoView: View {
    // MARK: - 环境

    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel
    let todoViewModel: TodoViewModel

    // MARK: - 状态

    @State private var categoryViewModel: CategoryViewModel?
    @State private var title = ""
    @State private var description = ""
    @State private var priority: Priority = .medium
    @State private var dueDate: Date?
    @State private var hasDueDate = false
    @State private var selectedCategory: Category?
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var showToast = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.largeSpacing) {
                    // 标题输入
                    titleSection

                    // 描述输入
                    descriptionSection

                    // 优先级选择
                    prioritySection

                    // 截止日期
                    dueDateSection

                    // 分类选择
                    if let categoryVM = categoryViewModel {
                        categorySection(categoryVM: categoryVM)
                    }

                    // 标签
                    tagsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("新建待办")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        handleCreate()
                    }
                    .disabled(!isFormValid)
                }
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
                    // 创建成功后延迟关闭
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // 清空之前的消息，确保每次打开都能看到新的提示
                todoViewModel.clearMessagesPublic()
                // 初始化 CategoryViewModel
                categoryViewModel = CategoryViewModel(authViewModel: authViewModel)
                categoryViewModel?.loadCategories()
            }
        }
    }

    // MARK: - 子视图

    /// 标题部分
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("标题", systemImage: "text.alignleft")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            TextField("输入待办标题", text: $title)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(Layout.smallCornerRadius)
        }
    }

    /// 描述部分
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("描述", systemImage: "text.quote")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            TextEditor(text: $description)
                .frame(height: 100)
                .padding(8)
                .scrollContentBackground(.hidden)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(Layout.smallCornerRadius)
                .overlay(
                    Group {
                        if description.isEmpty {
                            Text("输入详细描述（可选）")
                                .foregroundColor(.secondary)
                                .padding(.leading, 12)
                                .padding(.top, 16)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }

    /// 优先级部分
    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("优先级", systemImage: "flag")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ForEach([Priority.low, .medium, .high], id: \.self) { p in
                    PriorityButton(
                        priority: p,
                        isSelected: priority == p,
                        action: {
                            priority = p
                        }
                    )
                }
            }
        }
    }

    /// 分类选择部分
    private func categorySection(categoryVM: CategoryViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("分类", systemImage: "folder")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // 用户自定义分类（非系统分类）
                    ForEach(categoryVM.categories.filter { !$0.isSystem }) { category in
                        CategoryChip(
                            category: category,
                            isSelected: selectedCategory?.id == category.id,
                            action: {
                                selectedCategory = category
                            }
                        )
                    }

                    // 系统预设分类
                    ForEach(categoryVM.categories.filter { $0.isSystem }) { category in
                        CategoryChip(
                            category: category,
                            isSelected: selectedCategory?.id == category.id,
                            action: {
                                selectedCategory = category
                            }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    /// 截止日期部分
    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $hasDueDate) {
                Label("截止日期", systemImage: "calendar")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }

            if hasDueDate {
                DatePicker(
                    "选择日期",
                    selection: Binding(
                        get: { dueDate ?? Date() },
                        set: { dueDate = $0 }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(Layout.smallCornerRadius)
            }
        }
    }

    /// 标签部分
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("标签", systemImage: "tag")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            // 已添加的标签
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            TagChip(
                                text: tag,
                                onDelete: {
                                    tags.removeAll { $0 == tag }
                                }
                            )
                        }
                    }
                }
                .padding(.bottom, 8)
            }

            // 添加新标签
            HStack {
                TextField("添加标签", text: $newTag)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    // .textFieldStyle(.roundedBorder)
                    // .textInputAutocapitalization(.never)
                    .cornerRadius(Layout.smallCornerRadius)
                    .onSubmit {
                        addTag()
                    }

                Button(action: addTag) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .disabled(newTag.trimmed.isEmpty)
            }
        }
    }

    // MARK: - 方法

    /// 处理创建
    private func handleCreate() {
        Task {
            await todoViewModel.createTodo(
                title: title,
                description: description.isEmpty ? nil : description,
                priority: priority,
                dueDate: hasDueDate ? dueDate : nil,
                category: selectedCategory,
                tags: tags
            )
        }
    }

    /// 添加标签
    private func addTag() {
        let trimmed = newTag.trimmed
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }

        tags.append(trimmed)
        newTag = ""
    }

    /// 表单验证
    private var isFormValid: Bool {
        !title.trimmed.isEmpty
    }
}

// MARK: - 辅助组件

/// 优先级按钮
struct PriorityButton: View {
    let priority: Priority
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: priority.icon)
                    .font(.title3)

                Text(priority.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? Color.priorityColor(priority).opacity(0.2)
                    : Color(.secondarySystemGroupedBackground)
            )
            .foregroundColor(
                isSelected
                    ? Color.priorityColor(priority)
                    : .secondary
            )
            .cornerRadius(Layout.smallCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.smallCornerRadius)
                    .stroke(
                        isSelected ? Color.priorityColor(priority) : Color.clear,
                        lineWidth: 2
                    )
            )
        }
    }
}

/// 分类芯片
struct CategoryChip: View {
    let category: Category?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let category = category {
                    Image(systemName: category.icon)
                        .font(.subheadline)
                    Text(category.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                } else {
                    Image(systemName: "tray")
                        .font(.subheadline)
                    Text("无分类")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? (category != nil ? Color(hex: category!.colorHex).opacity(0.2) : Color.gray.opacity(0.2))
                    : Color(.secondarySystemGroupedBackground)
            )
            .foregroundColor(
                isSelected
                    ? (category != nil ? Color(hex: category!.colorHex) : .gray)
                    : .secondary
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected
                            ? (category != nil ? Color(hex: category!.colorHex) : .gray)
                            : Color.clear,
                        lineWidth: 2
                    )
            )
        }
    }
}

/// 标签芯片
struct TagChip: View {
    let text: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text("#\(text)")
                .font(.subheadline)

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(16)
    }
}

// MARK: - 预览

#Preview {
    let authViewModel = AuthViewModel()
    let mockUser = User(
        username: "预览用户",
        phoneNumber: "13800138000",
        email: "preview@example.com"
    )
    authViewModel.currentUser = mockUser

    return CreateTodoView(todoViewModel: TodoViewModel(authViewModel: authViewModel))
        .environment(authViewModel)
        .modelContainer(DataManager.shared.container)
}
