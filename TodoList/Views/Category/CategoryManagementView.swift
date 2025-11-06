/**
 * 分类管理视图
 *
 * 管理所有待办分类
 * 支持创建、编辑、删除分类
 */

import SwiftUI

struct CategoryManagementView: View {
    // MARK: - 环境

    @Environment(\.dismiss) private var dismiss
    let categoryViewModel: CategoryViewModel

    // MARK: - 状态

    @State private var showCreateSheet = false
    @State private var showEditSheet = false
    @State private var selectedCategory: Category?
    @State private var showDeleteAlert = false
    @State private var showToast = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                if categoryViewModel.isLoading && categoryViewModel.categories.isEmpty {
                    // 加载中
                    loadingView
                } else if categoryViewModel.categories.isEmpty {
                    // 空状态
                    emptyView
                } else {
                    // 分类列表
                    categoryList
                }
            }
            .navigationTitle("分类管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showCreateSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CategoryEditView(
                    categoryViewModel: categoryViewModel,
                    mode: .create
                )
            }
            .sheet(item: $selectedCategory) { category in
                CategoryEditView(
                    categoryViewModel: categoryViewModel,
                    category: category,
                    mode: .edit
                )
            }
            .toast(
                isPresented: $showToast,
                message: categoryViewModel.errorMessage ?? categoryViewModel.successMessage ?? "",
                type: categoryViewModel.errorMessage != nil ? .error : .success
            )
            .onChange(of: categoryViewModel.errorMessage) { _, newValue in
                if newValue != nil {
                    showToast = true
                }
            }
            .onChange(of: categoryViewModel.successMessage) { _, newValue in
                if newValue != nil {
                    showToast = true
                }
            }
            .alert("确定删除？", isPresented: $showDeleteAlert) {
                Button("删除", role: .destructive) {
                    if let category = selectedCategory {
                        Task {
                            await categoryViewModel.deleteCategory(category)
                        }
                    }
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("删除后该分类下的待办将变为未分类")
            }
            .onAppear {
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
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("还没有自定义分类")
                .font(.title3)
                .fontWeight(.medium)

            Text("点击右上角 + 创建第一个分类")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: {
                showCreateSheet = true
            }) {
                Label("创建分类", systemImage: "plus")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(Layout.mediumCornerRadius)
            }
            .padding(.top)
        }
        .padding()
    }

    /// 分类列表
    private var categoryList: some View {
        List {
            ForEach(categoryViewModel.categories) { category in
                CategoryRow(category: category)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        selectedCategory = category
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        // 删除按钮（系统分类不可删除）
                        if !category.isSystem {
                            Button(role: .destructive) {
                                selectedCategory = category
                                showDeleteAlert = true
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }

                        // 编辑按钮
                        Button {
                            selectedCategory = category
                        } label: {
                            Label("编辑", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - 分类行视图

struct CategoryRow: View {
    let category: Category

    var body: some View {
        HStack(spacing: 16) {
            // 图标
            ZStack {
                Circle()
                    .fill(Color(hex: category.colorHex).opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundColor(Color(hex: category.colorHex))
            }

            // 信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(category.name)
                        .font(.headline)

                    if category.isSystem {
                        Text("系统")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.secondary)
                            .cornerRadius(4)
                    }
                }

                HStack(spacing: 12) {
                    Label("\(category.uncompletedCount())", systemImage: "circle")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label("\(category.completedCount())", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.green)

                    if category.overdueCount() > 0 {
                        Label("\(category.overdueCount())", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }

            Spacer()

            // 进度指示器
            if category.totalCount() > 0 {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(category.completedCount())/\(category.totalCount())")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    CircularProgressView(
                        progress: category.completionProgress(),
                        color: Color(hex: category.colorHex)
                    )
                    .frame(width: 40, height: 40)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - 环形进度视图

struct CircularProgressView: View {
    let progress: Double
    let color: Color

    var body: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 4)

            // 进度圆环
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))

            // 百分比文本
            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
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

    let categoryViewModel = CategoryViewModel(authViewModel: authViewModel)

    return CategoryManagementView(categoryViewModel: categoryViewModel)
}
