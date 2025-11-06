/**
 * 个人中心视图
 *
 * 显示用户信息、统计数据和设置入口
 */

import SwiftUI
import SwiftData

struct ProfileView: View {
    // MARK: - 环境
    
    @Environment(AuthViewModel.self) private var authViewModel
    
    // MARK: - 状态
    
    @State private var viewModel: ProfileViewModel
    
    @State private var showPersonalInfo = false
    @State private var showCategoryManagement = false
    @State private var showNotificationSettings = false
    @State private var showPreferences = false
    @State private var showAbout = false
    @State private var showLogoutAlert = false
    @State private var showAvatarPicker = false
    @State private var avatarImage: UIImage?
    @State private var showToast = false
    
    // MARK: - 初始化
    
    init(authViewModel: AuthViewModel) {
        _viewModel = State(initialValue: ProfileViewModel(authViewModel: authViewModel))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.largeSpacing) {
                    // User info card
                    userInfoCard
                    
                    // Statistics cards
                    if viewModel.isDataLoaded {
                        statisticsCards
                    }
                    
                    // Settings list
                    settingsList
                    
                    // Logout button
                    logoutButton
                }
                .padding(Layout.largePadding)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("我的")
            .refreshable {
                await loadData()
            }
            .sheet(isPresented: $showPersonalInfo) {
                PersonalInfoView(authViewModel: authViewModel)
            }
            .sheet(isPresented: $showCategoryManagement) {
                CategoryManagementView(categoryViewModel: viewModel.categoryViewModel)
            }
            .sheet(isPresented: $showNotificationSettings) {
                NotificationSettingsView()
            }
            .sheet(isPresented: $showPreferences) {
                PreferencesView()
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .alert("确定退出登录？", isPresented: $showLogoutAlert) {
                Button("退出", role: .destructive) {
                    authViewModel.logout()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("退出后需要重新登录")
            }
            .onAppear {
                Task {
                    await loadData()
                }
                avatarImage = viewModel.getAvatarImage()
            }
            .sheet(isPresented: $showAvatarPicker) {
                AvatarPickerSheet(selectedImage: $avatarImage)
            }
            .onChange(of: avatarImage) { _, newImage in
                if let image = newImage {
                    Task {
                        await viewModel.updateAvatar(image)
                    }
                }
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
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    /// User info card
    private var userInfoCard: some View {
        VStack(spacing: 16) {
            // Avatar
            Button(action: {
                showAvatarPicker = true
            }) {
                ZStack(alignment: .bottomTrailing) {
                    if let avatarImage = avatarImage {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    } else {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Text(authViewModel.currentUser?.username.prefix(1).uppercased() ?? "U")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }

                    // 编辑图标
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 28, height: 28)

                        Image(systemName: "camera.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Username and phone
            if let user = authViewModel.currentUser {
                VStack(spacing: 4) {
                    Text(user.username)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(user.phoneNumber)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let email = user.email, !email.isEmpty {
                        Text(email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Edit button
            Button(action: {
                showPersonalInfo = true
            }) {
                Text("编辑资料")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    /// Statistics cards
    private var statisticsCards: some View {
        VStack(spacing: Layout.mediumSpacing) {
            // Main stats
            HStack(spacing: 12) {
                ProfileStatCard(
                    icon: "checkmark.circle.fill",
                    title: "已完成",
                    value: "\(viewModel.completedTaskCount)",
                    color: .green
                )
                
                ProfileStatCard(
                    icon: "circle",
                    title: "进行中",
                    value: "\(viewModel.activeTaskCount)",
                    color: .blue
                )
                
                ProfileStatCard(
                    icon: "clock.fill",
                    title: "番茄钟",
                    value: "\(viewModel.totalPomodoroCount)",
                    color: .orange
                )
            }
            
            // Completion rate
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.purple)
                    Text("完成率")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(viewModel.completionRate * 100))%")
                        .font(.headline)
                        .foregroundColor(.purple)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.purple.opacity(0.2))
                            .frame(height: 8)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.purple)
                            .frame(
                                width: geometry.size.width * viewModel.completionRate,
                                height: 8
                            )
                    }
                }
                .frame(height: 8)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(Layout.mediumCornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    /// Settings list
    private var settingsList: some View {
        VStack(spacing: 0) {
            SettingRow(
                icon: "person.circle",
                title: "个人资料",
                color: .blue
            ) {
                showPersonalInfo = true
            }
            
            Divider().padding(.leading, 60)
            
            SettingRow(
                icon: "folder.fill",
                title: "分类管理",
                color: .orange,
                badge: "\(viewModel.categoryCount)"
            ) {
                showCategoryManagement = true
            }
            
            Divider().padding(.leading, 60)
            
            SettingRow(
                icon: "bell.fill",
                title: "通知设置",
                color: .purple
            ) {
                showNotificationSettings = true
            }
            
            Divider().padding(.leading, 60)
            
            SettingRow(
                icon: "gearshape.fill",
                title: "偏好设置",
                color: .gray
            ) {
                showPreferences = true
            }
            
            Divider().padding(.leading, 60)
            
            SettingRow(
                icon: "info.circle.fill",
                title: "关于应用",
                color: .green
            ) {
                showAbout = true
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    /// Logout button
    private var logoutButton: some View {
        Button(action: {
            showLogoutAlert = true
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("退出登录")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Layout.buttonHeight)
            .foregroundColor(.red)
            .background(Color(.systemBackground))
            .cornerRadius(Layout.mediumCornerRadius)
        }
    }
    
    // MARK: - 方法
    
    private func loadData() async {
        viewModel.loadData()
    }
}

// MARK: - Profile Stat Card Component

struct ProfileStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Setting Row Component

struct SettingRow: View {
    let icon: String
    let title: String
    let color: Color
    var badge: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .foregroundColor(.white)
                }
                
                // Title
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Badge
                if let badge = badge {
                    Text(badge)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(8)
                }
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 预览

#Preview("User state") {
    let authViewModel = AuthViewModel()
    let mockUser = User(
        username: "测试用户",
        phoneNumber: "13800138000",
        email: "test@example.com"
    )
    authViewModel.currentUser = mockUser
    
    return ProfileView(authViewModel: authViewModel)
        .environment(authViewModel)
        .modelContainer(DataManager.shared.container)
}

