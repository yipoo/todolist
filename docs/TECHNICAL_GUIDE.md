# TodoList 技术指南

## 目录

1. [技术栈详解](#技术栈详解)
2. [架构设计](#架构设计)
3. [编译步骤和要求](#编译步骤和要求)
4. [Xcode 配置](#xcode-配置)
5. [依赖管理](#依赖管理)
6. [开发环境配置](#开发环境配置)
7. [常见问题解决](#常见问题解决)

---

## 技术栈详解

### 1. SwiftUI (iOS 17+)

SwiftUI 是 Apple 推出的声明式 UI 框架，本项目使用 iOS 17+ 的最新特性。

**核心特性：**
- **声明式语法**：描述 UI 应该是什么样子，而不是如何构建
- **状态驱动**：UI 自动响应状态变化
- **组件化**：高度可复用的视图组件
- **预览功能**：实时预览 UI 变化

**示例：待办列表视图**
```swift
struct TodoListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var viewModel: TodoViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredTodos) { todo in
                    TodoRow(todo: todo, viewModel: viewModel)
                }
            }
            .navigationTitle("待办事项")
        }
    }
}
```

**为什么选择 SwiftUI：**
- 代码量更少（相比 UIKit 减少 40-60%）
- 更易维护和测试
- 自动支持 Dark Mode
- 原生动画和过渡效果
- 与 iOS 生态深度集成

---

### 2. SwiftData

SwiftData 是 iOS 17+ 的现代数据持久化框架，是 Core Data 的简化版本。

**核心特性：**
- **@Model 宏**：自动生成数据库代码
- **类型安全**：编译时检查
- **关系管理**：自动处理对象关系
- **@Query 宏**：声明式数据查询

**数据模型定义：**
```swift
@Model
final class TodoItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var priority: Priority
    var dueDate: Date?

    // 关系：多对一
    var user: User?
    var category: Category?

    // 关系：一对多（级联删除）
    @Relationship(deleteRule: .cascade, inverse: \Subtask.todo)
    var subtasks: [Subtask] = []

    init(title: String, user: User? = nil) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.priority = .medium
        self.createdAt = Date()
        self.user = user
    }
}
```

**数据查询示例：**
```swift
// 1. 使用 @Query 宏（自动响应变化）
@Query(
    filter: #Predicate<TodoItem> { todo in
        !todo.isCompleted
    },
    sort: [SortDescriptor(\.dueDate)]
)
var todos: [TodoItem]

// 2. 使用 DataManager（手动查询）
let descriptor = FetchDescriptor<TodoItem>(
    predicate: #Predicate { $0.user?.id == userId },
    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
)
let todos = try context.fetch(descriptor)
```

**SwiftData 容器配置：**
```swift
// DataManager.swift
@MainActor
final class DataManager {
    static let shared = DataManager()

    private static let appGroupIdentifier = "group.com.yipoo.todolist"

    private(set) var container: ModelContainer

    private init() {
        let schema = Schema([
            User.self,
            TodoItem.self,
            Category.self,
            Subtask.self,
            PomodoroSession.self
        ])

        // 使用 App Group 共享容器（用于 Widget）
        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(appGroupIdentifier)
        )

        container = try! ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
}
```

---

### 3. WidgetKit

WidgetKit 用于创建主屏幕小组件，可以快速查看待办事项。

**Widget 架构：**
```
主应用 (TodoList)
    ↓
SwiftData (App Group 共享容器)
    ↓
WidgetDataProvider (读取数据)
    ↓
Widget Timeline Provider (生成时间线)
    ↓
Widget UI (显示)
```

**Timeline Provider 实现：**
```swift
struct TodoWidgetProvider: TimelineProvider {
    // 占位符（Widget 首次添加时显示）
    func placeholder(in context: Context) -> TodoWidgetEntry {
        TodoWidgetEntry(
            date: Date(),
            todayTodos: placeholderTodos(),
            statistics: WidgetStatistics(
                totalTodos: 5,
                completedTodos: 3
            )
        )
    }

    // 快照（Widget 画廊预览）
    func getSnapshot(in context: Context, completion: @escaping (TodoWidgetEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
        } else {
            Task {
                let entry = await fetchData()
                completion(entry)
            }
        }
    }

    // 时间线（实际显示的数据）
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoWidgetEntry>) -> Void) {
        Task {
            let entry = await fetchData()

            // 每 15 分钟更新一次
            let nextUpdate = Calendar.current.date(
                byAdding: .minute,
                value: 15,
                to: Date()
            )!

            let timeline = Timeline(
                entries: [entry],
                policy: .after(nextUpdate)
            )

            completion(timeline)
        }
    }
}
```

**Widget 数据提供者：**
```swift
@MainActor
final class WidgetDataProvider {
    private static let appGroupIdentifier = "group.com.yipoo.todolist"

    // 获取今日待办
    static func getTodayTodos() -> [WidgetTodoItem] {
        guard let container = createContainer() else {
            return []
        }

        let context = ModelContext(container)
        let descriptor = FetchDescriptor<TodoItem>(
            sortBy: [SortDescriptor(\.dueDate, order: .forward)]
        )

        let allTodos = try? context.fetch(descriptor)

        // 过滤出今日待办
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        return allTodos?.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return dueDate >= today && dueDate < tomorrow
        }.map { todo in
            WidgetTodoItem(
                id: todo.id,
                title: todo.title,
                isCompleted: todo.isCompleted,
                priority: "low",
                dueDate: todo.dueDate,
                categoryName: todo.category?.name,
                categoryColor: todo.category?.colorHex
            )
        } ?? []
    }
}
```

**支持的 Widget 尺寸：**
- **小号 (systemSmall)**：统计概览
- **中号 (systemMedium)**：4 个待办事项
- **大号 (systemLarge)**：6 个待办事项 + 统计

---

### 4. 其他技术

#### Keychain（安全存储）
```swift
final class KeychainManager {
    static let shared = KeychainManager()

    // 保存密码
    func savePassword(_ password: String, for username: String) -> Bool {
        let key = KeychainKeys.userPassword + ".\(username)"
        guard let data = password.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}
```

#### CryptoKit（密码哈希）
```swift
import CryptoKit

extension KeychainManager {
    static func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = CryptoKit.SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
```

#### UserDefaults（用户偏好）
```swift
final class UserPreferencesManager {
    static let shared = UserPreferencesManager()
    private let defaults = UserDefaults.standard

    var theme: AppTheme {
        get {
            guard let rawValue = defaults.string(forKey: "theme"),
                  let theme = AppTheme(rawValue: rawValue) else {
                return .system
            }
            return theme
        }
        set {
            defaults.set(newValue.rawValue, forKey: "theme")
        }
    }
}
```

---

## 架构设计

### MVVM 架构模式

本项目采用 **Model-View-ViewModel (MVVM)** 架构模式，清晰分离业务逻辑和 UI。

```
┌─────────────────────────────────────────────┐
│                   View                       │
│  (SwiftUI Views - 纯 UI，无业务逻辑)        │
└─────────────────┬───────────────────────────┘
                  │ @Observable
                  │ Environment
                  ↓
┌─────────────────────────────────────────────┐
│               ViewModel                      │
│  (业务逻辑、状态管理、数据转换)              │
└─────────────────┬───────────────────────────┘
                  │ DataManager
                  │ Services
                  ↓
┌─────────────────────────────────────────────┐
│                 Model                        │
│  (SwiftData 数据模型 - 纯数据)               │
└─────────────────────────────────────────────┘
```

#### 层次职责

**1. Model 层（数据模型）**
- 定义数据结构
- 使用 `@Model` 宏
- 定义关系（一对多、多对一）
- 提供便捷方法（不包含业务逻辑）

**示例：**
```swift
@Model
final class TodoItem {
    var id: UUID
    var title: String
    var isCompleted: Bool

    // 关系
    var user: User?
    var category: Category?

    // 便捷方法（简单的状态判断）
    func isOverdue() -> Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }
}
```

**2. ViewModel 层（业务逻辑）**
- 管理视图状态
- 处理用户交互
- 调用数据服务
- 数据转换和格式化

**示例：**
```swift
@Observable
@MainActor
final class TodoViewModel {
    // 状态
    var todos: [TodoItem] = []
    var isLoading = false
    var errorMessage: String?

    // 依赖
    private let dataManager = DataManager.shared
    private let authViewModel: AuthViewModel

    // 业务方法
    func createTodo(title: String, category: Category?) async {
        guard let user = authViewModel.currentUser else {
            errorMessage = "请先登录"
            return
        }

        isLoading = true

        let todo = TodoItem(
            title: title,
            category: category,
            user: user
        )

        do {
            try dataManager.createTodo(todo)
            loadTodos()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
```

**3. View 层（UI 展示）**
- 纯 UI 展示
- 绑定 ViewModel
- 处理用户输入（转发给 ViewModel）
- 使用 `@Environment` 和 `@State`

**示例：**
```swift
struct TodoListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var viewModel: TodoViewModel

    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(viewModel.filteredTodos) { todo in
                        TodoRow(todo: todo) {
                            Task {
                                await viewModel.toggleCompletion(todo)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadTodos()
        }
    }
}
```

---

### 数据流

#### 1. 单向数据流

```
用户操作 → View → ViewModel → DataManager → SwiftData
                    ↓
                状态更新
                    ↓
                View 刷新
```

**示例：创建待办**
```swift
// 1. 用户点击"创建"按钮
Button("创建") {
    Task {
        // 2. 调用 ViewModel 方法
        await viewModel.createTodo(title: title)
    }
}

// 3. ViewModel 处理业务逻辑
func createTodo(title: String) async {
    let todo = TodoItem(title: title)

    // 4. 调用 DataManager 保存数据
    try dataManager.createTodo(todo)

    // 5. 更新状态，触发 View 刷新
    loadTodos()
}
```

#### 2. 状态管理

使用 iOS 17+ 的 `@Observable` 宏（替代 `@ObservableObject`）：

```swift
// ViewModel
@Observable
final class TodoViewModel {
    var todos: [TodoItem] = []  // 状态自动追踪
}

// View
struct TodoListView: View {
    @State private var viewModel: TodoViewModel

    var body: some View {
        // 自动响应 viewModel.todos 的变化
        List(viewModel.todos) { todo in
            Text(todo.title)
        }
    }
}
```

#### 3. 依赖注入

使用 `@Environment` 进行全局状态管理：

```swift
// App 入口
@main
struct TodoListApp: App {
    @State private var authViewModel = AuthViewModel()
    @State private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .environment(themeManager)
                .modelContainer(DataManager.shared.container)
        }
    }
}

// 子视图中使用
struct TodoListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(ThemeManager.self) private var themeManager
}
```

---

### 目录结构

```
TodoList/
├── TodoList/                    # 主应用
│   ├── App/                     # 应用入口
│   │   ├── TodoListApp.swift    # @main 入口
│   │   ├── ContentView.swift    # 根视图
│   │   └── MainTabView.swift    # Tab 导航
│   │
│   ├── Models/                  # 数据模型
│   │   ├── User.swift           # 用户模型
│   │   ├── TodoItem.swift       # 待办模型
│   │   ├── Category.swift       # 分类模型
│   │   ├── Subtask.swift        # 子任务模型
│   │   ├── PomodoroSession.swift # 番茄钟会话
│   │   └── PomodoroSettings.swift # 番茄钟设置
│   │
│   ├── ViewModels/              # 视图模型
│   │   ├── AuthViewModel.swift  # 认证业务逻辑
│   │   ├── TodoViewModel.swift  # 待办业务逻辑
│   │   ├── CategoryViewModel.swift # 分类管理
│   │   ├── PomodoroViewModel.swift # 番茄钟逻辑
│   │   ├── StatisticsViewModel.swift # 统计分析
│   │   ├── ProfileViewModel.swift # 个人中心
│   │   └── ThemeManager.swift   # 主题管理
│   │
│   ├── Views/                   # 视图层
│   │   ├── Auth/               # 认证相关视图
│   │   │   ├── LoginView.swift
│   │   │   ├── RegisterView.swift
│   │   │   └── PhoneLoginView.swift
│   │   ├── Todo/               # 待办相关视图
│   │   │   ├── TodoListView.swift
│   │   │   ├── CreateTodoView.swift
│   │   │   ├── TodoDetailView.swift
│   │   │   └── Components/
│   │   │       └── TodoRow.swift
│   │   ├── Calendar/           # 日历视图
│   │   ├── Pomodoro/           # 番茄钟视图
│   │   ├── Statistics/         # 统计视图
│   │   └── Profile/            # 个人中心视图
│   │
│   ├── Services/               # 服务层
│   │   ├── DataManager.swift   # 数据管理（DAL）
│   │   ├── KeychainManager.swift # 安全存储
│   │   └── UserPreferencesManager.swift # 用户偏好
│   │
│   ├── Utils/                  # 工具类
│   │   ├── Constants.swift     # 常量定义
│   │   ├── Validators.swift    # 验证工具
│   │   └── Extensions/         # Swift 扩展
│   │
│   └── TodoList.entitlements   # 权限配置
│
├── Widget/                      # Widget 扩展
│   ├── TodoListWidget.swift    # Widget 主文件
│   ├── WidgetDataProvider.swift # 数据提供者
│   ├── SmallWidgetView.swift   # 小号视图
│   ├── MediumWidgetView.swift  # 中号视图
│   ├── LargeWidgetView.swift   # 大号视图
│   └── QuickAddWidget.swift    # 快速添加 Widget
│
└── WidgetExtension.entitlements # Widget 权限配置
```

---

## 编译步骤和要求

### 系统要求

| 项目 | 要求 |
|------|------|
| macOS 版本 | macOS 14.0+ (Sonoma) |
| Xcode 版本 | Xcode 15.0+ |
| iOS 版本 | iOS 17.0+ |
| Swift 版本 | Swift 5.9+ |
| 开发语言 | Swift |

### 编译步骤

#### 1. 克隆项目
```bash
cd /Users/dinglei/Mobile/study/swiftui/TodoList
```

#### 2. 打开 Xcode 项目
```bash
open TodoList.xcodeproj
```

或在 Xcode 中：`File → Open → 选择 TodoList.xcodeproj`

#### 3. 配置签名

**主应用 (TodoList) Target：**
1. 选择 **TodoList** target
2. 进入 **Signing & Capabilities**
3. 选择 **Team**（个人或团队账号）
4. 设置 **Bundle Identifier**（如：`com.yourname.todolist`）

**Widget Extension Target：**
1. 选择 **WidgetExtension** target
2. 进入 **Signing & Capabilities**
3. 选择相同的 **Team**
4. 设置 **Bundle Identifier**（如：`com.yourname.todolist.WidgetExtension`）

#### 4. 配置 App Groups

**主应用：**
1. 选择 **TodoList** target
2. 进入 **Signing & Capabilities**
3. 点击 **+ Capability**
4. 添加 **App Groups**
5. 勾选或创建：`group.com.yipoo.todolist`

**Widget Extension：**
1. 选择 **WidgetExtension** target
2. 重复上述步骤
3. 勾选相同的 App Group：`group.com.yipoo.todolist`

#### 5. 选择目标设备

- **模拟器**：选择 iPhone 15 Pro (或任意 iOS 17+ 模拟器)
- **真机**：连接 iPhone/iPad（需要 Apple 开发者账号）

#### 6. 编译运行

**方式一：Xcode 图形界面**
- 点击左上角的 **Run** 按钮（或按 `⌘ + R`）

**方式二：命令行编译**
```bash
# 清理构建
xcodebuild clean -scheme TodoList

# 编译（模拟器）
xcodebuild -scheme TodoList \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0' \
    build

# 编译（真机）
xcodebuild -scheme TodoList \
    -sdk iphoneos \
    -destination 'generic/platform=iOS' \
    build
```

#### 7. 运行测试
```bash
# 运行单元测试（如果有）
xcodebuild test -scheme TodoList \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

---

### 常见编译错误

#### 错误 1：缺少开发者账号
```
Signing for "TodoList" requires a development team.
```

**解决方案：**
1. 前往 Xcode → Preferences → Accounts
2. 添加 Apple ID
3. 在 Signing & Capabilities 中选择 Team

#### 错误 2：App Group 未配置
```
无法获取 App Group 容器: group.com.yipoo.todolist
```

**解决方案：**
1. 检查 **TodoList** 和 **WidgetExtension** 的 App Groups
2. 确保两个 Target 使用相同的 App Group 标识符
3. 如果使用真机，需要在 Apple Developer 网站配置 App Group

#### 错误 3：Widget 找不到数据模型
```
cannot find type 'TodoItem' in scope
```

**解决方案：**
在 Xcode 中为以下文件添加 **WidgetExtension** Target Membership：
- `User.swift`
- `TodoItem.swift`
- `Category.swift`
- `Subtask.swift`
- `PomodoroSession.swift`

**操作步骤：**
1. 选中模型文件
2. 在右侧 **File Inspector** 中找到 **Target Membership**
3. 勾选 **WidgetExtension**

---

## Xcode 配置

### 1. Target 配置

项目包含两个 Target：

#### TodoList (主应用)
- **Bundle Identifier**: `com.yipoo.todolist`
- **Deployment Target**: iOS 17.0
- **Supported Devices**: iPhone, iPad
- **Orientation**: Portrait

#### WidgetExtension (小组件)
- **Bundle Identifier**: `com.yipoo.todolist.WidgetExtension`
- **Deployment Target**: iOS 17.0
- **Widget Configuration**: Static Configuration

---

### 2. App Groups 配置

App Groups 用于主应用和 Widget 共享数据。

**配置步骤：**

**主应用 (TodoList)：**
1. 选择 **TodoList** target
2. **Signing & Capabilities** → **+ Capability**
3. 添加 **App Groups**
4. 勾选或创建：`group.com.yipoo.todolist`

**Widget Extension：**
1. 选择 **WidgetExtension** target
2. 重复上述步骤
3. 确保使用相同的 App Group 标识符

**验证配置：**
```swift
// DataManager.swift 和 WidgetDataProvider.swift 中
private static let appGroupIdentifier = "group.com.yipoo.todolist"

guard let appGroupURL = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: appGroupIdentifier
) else {
    fatalError("❌ 无法获取 App Group 容器")
}
```

**真机配置：**
在 [Apple Developer](https://developer.apple.com/) 网站：
1. **Certificates, Identifiers & Profiles** → **Identifiers**
2. 选择 App ID
3. 启用 **App Groups**
4. 创建 App Group：`group.com.yipoo.todolist`
5. 将 App Group 关联到主应用和 Widget 的 App ID

---

### 3. Target Membership 配置

某些文件需要同时添加到主应用和 Widget Extension：

**需要共享的文件：**
- ✅ Models/ 文件夹下的所有文件
  - `User.swift`
  - `TodoItem.swift`
  - `Category.swift`
  - `Subtask.swift`
  - `PomodoroSession.swift`

**配置步骤：**
1. 在项目导航器中选中文件（可多选）
2. 在右侧 **File Inspector** 中找到 **Target Membership**
3. 勾选 **TodoList** 和 **WidgetExtension**

**验证：**
```bash
# 编译 Widget Extension
xcodebuild -scheme WidgetExtension -sdk iphonesimulator build
```

如果编译成功，说明 Target Membership 配置正确。

---

### 4. Info.plist 配置

**主应用 Info.plist（自动生成）：**
- 无需手动配置，Xcode 自动管理

**Widget Info.plist（自动生成）：**
- Widget Extension 创建时自动生成
- 包含 Widget 的基本信息

---

### 5. Entitlements 文件

#### TodoList.entitlements
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.yipoo.todolist</string>
    </array>
</dict>
</plist>
```

#### WidgetExtension.entitlements
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.yipoo.todolist</string>
    </array>
</dict>
</plist>
```

---

### 6. Build Settings 配置

**重要配置项：**

| 配置项 | 值 | 说明 |
|--------|-----|------|
| iOS Deployment Target | 17.0 | 最低支持版本 |
| Swift Language Version | Swift 5 | Swift 版本 |
| Enable Bitcode | No | iOS 默认禁用 |
| Code Signing Identity | Apple Development | 开发签名 |
| Provisioning Profile | Automatic | 自动管理 |

---

## 依赖管理

### 无外部依赖

本项目 **不使用任何第三方库**，全部使用 Apple 原生框架：

| 功能 | 使用的框架 |
|------|-----------|
| UI | SwiftUI |
| 数据持久化 | SwiftData |
| 安全存储 | Security (Keychain) |
| 密码哈希 | CryptoKit |
| Widget | WidgetKit |
| 用户偏好 | Foundation (UserDefaults) |
| 图片处理 | UIKit |

**优点：**
- 无需安装依赖包
- 项目体积小
- 编译快速
- 兼容性好

**对比其他项目：**
- ❌ 不使用 CocoaPods
- ❌ 不使用 Swift Package Manager
- ❌ 不使用 Carthage
- ✅ 纯 Swift + Apple 原生框架

---

## 开发环境配置

### 1. Xcode 配置

**推荐版本：** Xcode 15.0+

**配置步骤：**

#### 1.1 安装 Xcode
```bash
# 从 App Store 安装 Xcode
# 或从 Apple Developer 网站下载

# 验证安装
xcodebuild -version
# 输出：Xcode 15.0
```

#### 1.2 配置 Xcode 偏好设置

**Accounts（账号）：**
1. Xcode → Preferences → Accounts
2. 添加 Apple ID
3. 下载开发者证书

**Locations（路径）：**
1. Xcode → Preferences → Locations
2. 设置 **Command Line Tools** 为最新版本

**Text Editing（编辑器）：**
- ✅ 启用 **Automatic indentation**
- ✅ 启用 **Line numbers**
- ✅ 启用 **Code completion**

---

### 2. Git 配置

**克隆项目：**
```bash
cd ~/Mobile/study/swiftui
git clone <repository-url> TodoList
cd TodoList
```

**配置 .gitignore：**
```bash
# 已包含在项目中
# .gitignore 文件内容：

# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
*.xcworkspace/
xcuserdata/
DerivedData/
build/

# Swift Package Manager
.swiftpm/

# CocoaPods (未使用)
# Pods/

# macOS
.DS_Store
```

---

### 3. 模拟器配置

**创建模拟器：**
```bash
# 列出可用设备
xcrun simctl list devicetypes

# 创建 iPhone 15 Pro 模拟器
xcrun simctl create "iPhone 15 Pro" com.apple.CoreSimulator.SimDeviceType.iPhone-15-Pro

# 启动模拟器
xcrun simctl boot "iPhone 15 Pro"
open -a Simulator
```

**推荐模拟器：**
- iPhone 15 Pro (iOS 17.0)
- iPhone 15 Pro Max (iOS 17.0)
- iPad Pro 12.9-inch (iOS 17.0)

---

### 4. 真机调试配置

**前提条件：**
- Apple Developer 账号（免费或付费）
- iPhone/iPad 设备（iOS 17.0+）
- Lightning/USB-C 数据线

**配置步骤：**

#### 4.1 连接设备
1. 使用数据线连接 iPhone 到 Mac
2. iPhone 上信任此电脑
3. Xcode 自动识别设备

#### 4.2 配置签名
1. Xcode → TodoList target → Signing & Capabilities
2. 选择 **Team**（你的 Apple ID）
3. Xcode 自动配置 Provisioning Profile

#### 4.3 运行应用
1. 选择真机设备
2. 点击 **Run** (⌘ + R)
3. 首次运行需要在 iPhone 上信任开发者证书：
   - 设置 → 通用 → VPN 与设备管理
   - 信任你的 Apple ID

---

### 5. Widget 调试配置

**模拟器调试：**
1. 运行主应用
2. 长按模拟器主屏幕
3. 点击左上角 **+** 添加 Widget
4. 选择 **TodoList**
5. 选择尺寸（小/中/大）

**真机调试：**
1. 运行主应用到真机
2. Widget 会自动安装
3. 长按主屏幕添加 Widget

**查看 Widget 日志：**
```bash
# 在 Xcode Console 中
# 筛选 "Widget" 关键字
# 查看 WidgetDataProvider 的 print 输出
```

---

## 常见问题解决

### 1. 编译问题

#### 问题 1：SwiftData 编译错误
```
Cannot find 'ModelContainer' in scope
```

**原因：** 最低部署目标低于 iOS 17.0

**解决：**
1. 选择 **TodoList** target
2. **General** → **Deployment Info**
3. 设置 **Minimum Deployments** 为 **iOS 17.0**

---

#### 问题 2：Widget 找不到模型
```
cannot find type 'TodoItem' in scope
```

**解决：**
为模型文件添加 **WidgetExtension** Target Membership：
1. 选中 `Models/` 文件夹下的所有文件
2. **File Inspector** → **Target Membership**
3. 勾选 **WidgetExtension**

---

#### 问题 3：App Group 无法访问
```
❌ 无法获取 App Group 容器: group.com.yipoo.todolist
```

**解决（模拟器）：**
1. 检查两个 Target 的 App Groups 配置
2. 确保 App Group 标识符一致
3. 清理并重新编译

**解决（真机）：**
1. 前往 [Apple Developer](https://developer.apple.com/)
2. **Identifiers** → 选择 App ID
3. 启用 **App Groups**
4. 创建 App Group：`group.com.yipoo.todolist`
5. 重新下载 Provisioning Profile

---

### 2. 运行时问题

#### 问题 1：SwiftData 崩溃
```
Fatal error: 无法创建 ModelContainer
```

**原因：** 数据库模型发生变化

**解决（开发环境）：**
```swift
// DataManager.swift 中取消注释以下代码
#if DEBUG
let defaultStoreURL = appGroupURL.appendingPathComponent("default.store")
if FileManager.default.fileExists(atPath: defaultStoreURL.path()) {
    try? FileManager.default.removeItem(at: defaultStoreURL)
    print("🗑️ 已删除旧数据库，将创建新数据库")
}
#endif
```

**解决（生产环境）：**
实现数据迁移（Migration）：
```swift
let configuration = ModelConfiguration(
    schema: schema,
    groupContainer: .identifier(appGroupIdentifier),
    migrationPlan: TodoListMigrationPlan.self
)
```

---

#### 问题 2：Widget 不显示数据
```
Widget 显示占位符数据，不显示真实数据
```

**排查步骤：**

1. **检查 App Groups 配置**
   - 主应用和 Widget 使用相同的 App Group
   - 真机需在 Apple Developer 配置

2. **检查数据库路径**
   ```swift
   // 在 DataManager 和 WidgetDataProvider 中
   guard let appGroupURL = FileManager.default.containerURL(
       forSecurityApplicationGroupIdentifier: "group.com.yipoo.todolist"
   ) else {
       print("❌ 无法获取 App Group 容器")
       return
   }

   print("📂 容器路径: \(appGroupURL.path())")
   ```

3. **检查模型文件 Target Membership**
   - 确保所有模型文件添加到 WidgetExtension

4. **强制刷新 Widget**
   ```swift
   // 在主应用中添加数据后
   import WidgetKit

   WidgetCenter.shared.reloadAllTimelines()
   ```

---

#### 问题 3：Keychain 访问失败
```
❌ Keychain 保存失败: -34018
```

**原因：** 模拟器上的已知问题

**解决：**
- 使用真机测试
- 或在 Entitlements 中添加 Keychain Access Groups（不推荐）

---

### 3. Widget 问题

#### 问题 1：Widget 显示"无数据"
```
Widget 显示"今天没有待办事项"
```

**原因：** 数据库中没有今日待办

**解决：**
1. 打开主应用
2. 创建几个今日待办（设置截止日期为今天）
3. 等待 Widget 自动刷新（15分钟）
4. 或强制刷新 Widget

---

#### 问题 2：Widget 不更新
```
Widget 一直显示旧数据
```

**解决：**
1. 在主应用中强制刷新：
   ```swift
   import WidgetKit

   // 创建/更新/删除待办后
   WidgetCenter.shared.reloadAllTimelines()
   ```

2. 或手动刷新 Widget：
   - 长按 Widget
   - 重新添加 Widget

---

### 4. 性能问题

#### 问题 1：列表滚动卡顿
```
待办列表滚动时出现卡顿
```

**优化：**
```swift
// 使用 LazyVStack 替代 VStack
ScrollView {
    LazyVStack {
        ForEach(todos) { todo in
            TodoRow(todo: todo)
        }
    }
}

// 或使用 List（已经是懒加载）
List(todos) { todo in
    TodoRow(todo: todo)
}
```

---

#### 问题 2：数据查询慢
```
待办列表加载缓慢
```

**优化：**
```swift
// 使用 @Query 替代手动查询
@Query(
    filter: #Predicate<TodoItem> { todo in
        !todo.isCompleted
    },
    sort: [SortDescriptor(\.dueDate)]
)
var todos: [TodoItem]

// 或在 DataManager 中添加索引
// SwiftData 会自动优化 @Attribute(.unique) 的查询
```

---

### 5. 主题问题

#### 问题 1：主题切换不生效
```
切换主题后，UI 没有变化
```

**原因：** ThemeManager 未正确注入

**解决：**
```swift
// TodoListApp.swift
@State private var themeManager = ThemeManager.shared

var body: some Scene {
    WindowGroup {
        ContentView()
            .environment(themeManager)
            .preferredColorScheme(themeManager.colorScheme)  // 必须添加
    }
}
```

---

## 总结

本技术指南涵盖了 TodoList 项目的核心技术栈、架构设计、编译配置和常见问题。

**关键要点：**
- ✅ 使用 SwiftUI + SwiftData 构建现代 iOS 应用
- ✅ 采用 MVVM 架构，职责清晰
- ✅ 无第三方依赖，纯 Apple 原生框架
- ✅ 支持 Widget 小组件，使用 App Groups 共享数据
- ✅ 完整的主题系统和安全存储

**下一步：**
- 阅读 [DEPLOYMENT.md](./DEPLOYMENT.md) 了解如何部署到真机和 App Store
- 参考项目源码学习具体实现细节
- 尝试添加新功能（如日历视图、通知系统）
