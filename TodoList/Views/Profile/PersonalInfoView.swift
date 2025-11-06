/**
 * 个人资料编辑视图
 *
 * 用于编辑用户名、邮箱等个人信息
 */

import SwiftUI

struct PersonalInfoView: View {
    // MARK: - 环境

    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel

    // MARK: - 状态

    @State private var viewModel: ProfileViewModel
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var showToast = false

    // MARK: - 初始化

    init(authViewModel: AuthViewModel) {
        _viewModel = State(initialValue: ProfileViewModel(authViewModel: authViewModel))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // 基本信息
                Section {
                    // 用户名
                    HStack {
                        Text("用户名")
                            .foregroundColor(.secondary)
                        TextField("请输入用户名", text: $username)
                            .multilineTextAlignment(.trailing)
                    }

                    // 手机号（不可编辑）
                    HStack {
                        Text("手机号")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(authViewModel.currentUser?.phoneNumber ?? "")
                            .foregroundColor(.gray)
                    }

                    // 邮箱
                    HStack {
                        Text("邮箱")
                            .foregroundColor(.secondary)
                        TextField("请输入邮箱（可选）", text: $email)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                    }
                } header: {
                    Text("基本信息")
                } footer: {
                    Text("手机号不可修改")
                }

                // 账号信息
                Section {
                    HStack {
                        Text("注册时间")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(authViewModel.currentUser?.createdAt.relativeString ?? "")
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text("最后登录")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(authViewModel.currentUser?.lastLoginAt.relativeString ?? "")
                            .foregroundColor(.gray)
                    }
                } header: {
                    Text("账号信息")
                }
            }
            .navigationTitle("个人资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            await saveChanges()
                        }
                    }
                    .disabled(!hasChanges)
                }
            }
            .onAppear {
                loadUserInfo()
            }
            // Toast 提示
            .toast(
                isPresented: $showToast,
                message: viewModel.errorMessage ?? viewModel.successMessage ?? "",
                type: viewModel.errorMessage != nil ? .error : .success
            )
            .onChange(of: viewModel.errorMessage) { _, newValue in
                if newValue != nil {
                    showToast = true
                }
            }
            .onChange(of: viewModel.successMessage) { _, newValue in
                if newValue != nil {
                    showToast = true
                    // 成功后延迟关闭
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - 计算属性

    /// 是否有变更
    private var hasChanges: Bool {
        let currentUser = authViewModel.currentUser
        return username != (currentUser?.username ?? "") ||
               email != (currentUser?.email ?? "")
    }

    // MARK: - 方法

    /// 加载用户信息
    private func loadUserInfo() {
        guard let user = authViewModel.currentUser else { return }
        username = user.username
        email = user.email ?? ""
    }

    /// 保存更改
    private func saveChanges() async {
        // 更新用户名
        if username != authViewModel.currentUser?.username {
            await viewModel.updateUsername(username)
        }

        // 更新邮箱
        if email != authViewModel.currentUser?.email {
            await viewModel.updateEmail(email)
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

    return PersonalInfoView(authViewModel: authViewModel)
        .environment(authViewModel)
}
