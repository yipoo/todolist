/**
 * 分类编辑视图
 *
 * 用于创建和编辑分类
 */

import SwiftUI

struct CategoryEditView: View {
    // MARK: - 环境

    @Environment(\.dismiss) private var dismiss
    let categoryViewModel: CategoryViewModel
    let category: Category?
    let mode: EditMode

    // MARK: - 状态

    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColor: String

    // MARK: - 预设数据

    private let availableIcons = [
        "briefcase.fill", "house.fill", "book.fill", "heart.fill",
        "target", "cart.fill", "airplane", "car.fill",
        "fork.knife", "cup.and.saucer.fill", "bicycle", "figure.walk",
        "gamecontroller.fill", "music.note", "paintbrush.fill", "camera.fill",
        "globe", "moon.stars.fill", "sun.max.fill", "cloud.fill"
    ]

    private let availableColors = [
        "#007AFF", // 蓝色
        "#34C759", // 绿色
        "#FF9500", // 橙色
        "#FF3B30", // 红色
        "#AF52DE", // 紫色
        "#FF2D55", // 粉红
        "#5AC8FA", // 浅蓝
        "#FFCC00", // 黄色
        "#8E8E93", // 灰色
        "#00C7BE"  // 青色
    ]

    // MARK: - 初始化

    init(
        categoryViewModel: CategoryViewModel,
        category: Category? = nil,
        mode: EditMode
    ) {
        self.categoryViewModel = categoryViewModel
        self.category = category
        self.mode = mode

        // 初始化状态
        _name = State(initialValue: category?.name ?? "")
        _selectedIcon = State(initialValue: category?.icon ?? "folder.fill")
        _selectedColor = State(initialValue: category?.colorHex ?? "#007AFF")
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.largeSpacing) {
                    // 预览
                    previewCard

                    // 名称输入
                    nameSection

                    // 图标选择
                    iconSection

                    // 颜色选择
                    colorSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(mode == .create ? "创建分类" : "编辑分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(mode == .create ? "创建" : "保存") {
                        handleSave()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    // MARK: - 子视图

    /// 预览卡片
    private var previewCard: some View {
        VStack(spacing: 16) {
            Text("预览")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                // 图标
                ZStack {
                    Circle()
                        .fill(Color(hex: selectedColor).opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: selectedIcon)
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: selectedColor))
                }

                // 名称
                VStack(alignment: .leading, spacing: 4) {
                    Text(name.isEmpty ? "分类名称" : name)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("0 个待办")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(Layout.mediumCornerRadius)
        }
    }

    /// 名称输入区域
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分类名称")
                .font(.headline)

            TextField("请输入分类名称", text: $name)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(Layout.smallCornerRadius)
        }
    }

    /// 图标选择区域
    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择图标")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                ForEach(availableIcons, id: \.self) { icon in
                    Button(action: {
                        selectedIcon = icon
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.2) : Color(.secondarySystemGroupedBackground))
                                .frame(height: 50)

                            Image(systemName: icon)
                                .font(.title3)
                                .foregroundColor(selectedIcon == icon ? Color(hex: selectedColor) : .primary)
                        }
                    }
                }
            }
        }
    }

    /// 颜色选择区域
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择颜色")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                ForEach(availableColors, id: \.self) { colorHex in
                    Button(action: {
                        selectedColor = colorHex
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: colorHex))
                                .frame(width: 50, height: 50)

                            if selectedColor == colorHex {
                                Image(systemName: "checkmark")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - 方法

    /// 保存
    private func handleSave() {
        Task {
            if mode == .create {
                await categoryViewModel.createCategory(
                    name: name,
                    icon: selectedIcon,
                    colorHex: selectedColor
                )
            } else if let category = category {
                category.name = name
                category.icon = selectedIcon
                category.colorHex = selectedColor
                await categoryViewModel.updateCategory(category)
            }

            // 成功后关闭
            dismiss()
        }
    }

    /// 表单验证
    private var isFormValid: Bool {
        !name.trimmed.isEmpty
    }

    // MARK: - 编辑模式枚举

    enum EditMode {
        case create
        case edit
    }
}

// MARK: - 预览

#Preview("创建") {
    let authViewModel = AuthViewModel()
    let mockUser = User(
        username: "预览用户",
        phoneNumber: "13800138000",
        email: "preview@example.com"
    )
    authViewModel.currentUser = mockUser

    let categoryViewModel = CategoryViewModel(authViewModel: authViewModel)

    return CategoryEditView(
        categoryViewModel: categoryViewModel,
        mode: .create
    )
}

#Preview("编辑") {
    let authViewModel = AuthViewModel()
    let mockUser = User(
        username: "预览用户",
        phoneNumber: "13800138000",
        email: "preview@example.com"
    )
    authViewModel.currentUser = mockUser

    let categoryViewModel = CategoryViewModel(authViewModel: authViewModel)
    let category = Category(
        name: "工作",
        icon: "briefcase.fill",
        colorHex: "#007AFF",
        user: mockUser
    )

    return CategoryEditView(
        categoryViewModel: categoryViewModel,
        category: category,
        mode: .edit
    )
}
