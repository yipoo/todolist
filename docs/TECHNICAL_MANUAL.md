# TodoList SwiftUI 项目技术手册

## 目录

- [1. 项目架构](#1-项目架构)
- [2. 核心技术](#2-核心技术)
- [3. 数据模型](#3-数据模型)
- [4. 服务层](#4-服务层)
- [5. Widget 开发](#5-widget-开发)
- [6. UI 组件](#6-ui-组件)
- [7. 最佳实践](#7-最佳实践)
- [8. 常见问题和解决方案](#8-常见问题和解决方案)
- [9. 扩展开发指南](#9-扩展开发指南)
- [10. 代码示例](#10-代码示例)

---

## 1. 项目架构

### 1.1 项目结构

```
TodoList/
├── TodoList/                      # 主应用目录
│   ├── App/                      # 应用入口和配置
│   │   ├── TodoListApp.swift     # 应用主入口（@main）
│   │   ├── ContentView.swift     # 根视图（认证路由）
│   │   └── MainTabView.swift     # 主 Tab 导航
│   │
│   ├── Models/                   # 数据模型层（SwiftData）
│   │   ├── User.swift           # 用户模型
│   │   ├── TodoItem.swift       # 待办事项模型
│   │   ├── Category.swift       # 分类模型
│   │   ├── Subtask.swift        # 子任务模型
│   │   ├── PomodoroSession.swift # 番茄钟会话模型
│   │   └── PomodoroSettings.swift # 番茄钟设置模型
│   │
│   ├── ViewModels/              # 视图模型层（业务逻辑）
│   │   ├── AuthViewModel.swift   # 认证业务逻辑
│   │   ├── TodoViewModel.swift   # 待办业务逻辑
│   │   ├── CategoryViewModel.swift # 分类业务逻辑
│   │   ├── PomodoroViewModel.swift # 番茄钟业务逻辑
│   │   ├── StatisticsViewModel.swift # 统计业务逻辑
│   │   ├── ProfileViewModel.swift # 个人资料业务逻辑
│   │   └── ThemeManager.swift    # 主题管理
│   │
│   ├── Views/                   # 视图层（UI）
│   │   ├── Auth/               # 认证相关视图
│   │   │   ├── LoginView.swift
│   │   │   ├── RegisterView.swift
│   │   │   ├── PhoneLoginView.swift
│   │   │   └── PasswordVerificationView.swift
│   │   ├── Todo/               # 待办相关视图
│   │   │   ├── TodoListView.swift
│   │   │   ├── CreateTodoView.swift
│   │   │   ├── TodoDetailView.swift
│   │   │   └── Components/
│   │   │       └── TodoRow.swift
│   │   ├── Category/           # 分类相关视图
│   │   │   ├── CategoryManagementView.swift
│   │   │   └── CategoryEditView.swift
│   │   ├── Pomodoro/          # 番茄钟相关视图
│   │   │   └── PomodoroTimerView.swift
│   │   ├── Statistics/        # 统计相关视图
│   │   │   ├── StatisticsView.swift
│   │   │   └── Components/
│   │   │       ├── PieChartView.swift
│   │   │       ├── LineChartView.swift
│   │   │       ├── BarChartView.swift
│   │   │       └── StatCard.swift
│   │   ├── Profile/           # 个人中心相关视图
│   │   │   ├── ProfileView.swift
│   │   │   ├── PersonalInfoView.swift
│   │   │   ├── PreferencesView.swift
│   │   │   └── AboutView.swift
│   │   └── Calendar/          # 日历相关视图
│   │       └── CalendarPlaceholderView.swift
│   │
│   ├── Services/              # 服务层（数据访问和工具）
│   │   ├── DataManager.swift  # SwiftData 数据管理器
│   │   ├── KeychainManager.swift # 钥匙串管理（密码存储）
│   │   └── UserPreferencesManager.swift # 用户偏好设置
│   │
│   ├── Utils/                 # 工具类
│   │   ├── Constants.swift    # 全局常量
│   │   ├── Validators.swift   # 验证工具
│   │   └── Extensions/        # Swift 扩展
│   │       ├── Date+Extension.swift
│   │       ├── String+Extension.swift
│   │       ├── Color+Extension.swift
│   │       └── View+Extension.swift
│   │
│   ├── Resources/             # 资源文件
│   │   └── Sounds/           # 音频文件
│   │
│   └── Assets.xcassets/       # 图片和颜色资源
│
├── Widget/                    # Widget Extension
│   ├── TodoListWidget.swift   # 主 Widget（小/中/大）
│   ├── QuickAddWidget.swift   # 快速添加 Widget
│   ├── WidgetDataProvider.swift # Widget 数据提供者
│   ├── WidgetBundle.swift     # Widget Bundle
│   ├── SmallWidgetView.swift  # 小号 Widget 视图
│   ├── MediumWidgetView.swift # 中号 Widget 视图
│   ├── LargeWidgetView.swift  # 大号 Widget 视图
│   └── AddTodoIntent.swift    # App Intent（交互）
│
├── TodoList.entitlements       # 主应用权限配置
└── WidgetExtension.entitlements # Widget 权限配置
```

### 1.2 架构模式：MVVM

本项目采用 **MVVM (Model-View-ViewModel)** 架构模式：

```
┌─────────────────────────────────────────────────────────┐
│                         View                            │
│  (SwiftUI Views - 纯 UI，无业务逻辑)                       │
│  - TodoListView.swift                                   │
│  - CreateTodoView.swift                                 │
│  - TodoDetailView.swift                                 │
└──────────────────┬──────────────────────────────────────┘
                   │ @Environment / @Bindable
                   │ 单向数据流
                   ↓
┌─────────────────────────────────────────────────────────┐
│                      ViewModel                          │
│  (@Observable - 业务逻辑和状态管理)                         │
│  - TodoViewModel.swift                                  │
│  - AuthViewModel.swift                                  │
│  - CategoryViewModel.swift                              │
└──────────────────┬──────────────────────────────────────┘
                   │ 调用数据操作
                   ↓
┌─────────────────────────────────────────────────────────┐
│                    Service Layer                        │
│  (数据访问层 - DAL)                                       │
│  - DataManager.swift                                    │
│  - KeychainManager.swift                                │
└──────────────────┬──────────────────────────────────────┘
                   │ SwiftData API
                   ↓
┌─────────────────────────────────────────────────────────┐
│                       Model                             │
│  (@Model - SwiftData 数据模型)                           │
│  - User.swift                                           │
│  - TodoItem.swift                                       │
│  - Category.swift                                       │
└─────────────────────────────────────────────────────────┘
```

#### MVVM 层级说明

**Model 层（数据模型）**
- 使用 SwiftData 的 `@Model` 宏
- 定义数据结构和关系
- 包含简单的业务逻辑方法（如计算属性）
- 不依赖于视图和视图模型

**ViewModel 层（视图模型）**
- 使用 `@Observable` 宏（iOS 17+）
- 管理视图的状态和业务逻辑
- 调用 Service 层进行数据操作
- 提供给视图使用的计算属性和方法
- 不直接依赖于具体的视图

**View 层（视图）**
- 纯 SwiftUI 视图
- 通过 `@Environment` 注入 ViewModel
- 只负责 UI 展示和用户交互
- 不包含业务逻辑

**Service 层（服务）**
- 封装数据访问逻辑
- 提供统一的数据操作 API
- 处理错误和异常
- 支持测试和 Mock

### 1.3 数据流图

```
用户操作 → View → ViewModel → Service → SwiftData → 数据库
                    ↑                              ↓
                    └──────── 状态更新 ←────────────┘
```

**具体流程示例（创建待办）：**

1. 用户在 `CreateTodoView` 中填写表单并点击"保存"
2. View 调用 `viewModel.createTodo()`
3. ViewModel 验证数据并调用 `DataManager.createTodo()`
4. DataManager 使用 SwiftData API 保存数据
5. 保存成功后，ViewModel 更新状态（`successMessage`）
6. View 监听到状态变化，自动重新渲染

---

## 2. 核心技术

### 2.1 SwiftUI 详解

**SwiftUI** 是 Apple 的声明式 UI 框架，类似于 React。

#### 2.1.1 核心概念

**声明式语法**
```swift
// 传统 UIKit（命令式）
let label = UILabel()
label.text = "Hello"
label.textColor = .blue
view.addSubview(label)

// SwiftUI（声明式）
Text("Hello")
    .foregroundColor(.blue)
```

**状态管理**
```swift
struct TodoListView: View {
    // @State - 视图私有状态
    @State private var searchText = ""

    // @Environment - 环境注入（共享状态）
    @Environment(TodoViewModel.self) private var viewModel

    // @Binding - 双向绑定
    @Binding var isPresented: Bool

    var body: some View {
        TextField("搜索", text: $searchText)
            .onChange(of: searchText) { oldValue, newValue in
                // 响应变化
            }
    }
}
```

**视图组合**
```swift
var body: some View {
    VStack {  // 垂直布局
        HStack {  // 水平布局
            Text("标题")
            Spacer()
            Image(systemName: "star")
        }
        ZStack {  // 层叠布局
            Rectangle()
            Text("内容")
        }
    }
}
```

#### 2.1.2 SwiftUI 与 React 对比

| SwiftUI | React | 说明 |
|---------|-------|------|
| `@State` | `useState` | 组件私有状态 |
| `@Environment` | `useContext` | 跨组件共享状态 |
| `@Binding` | `props` + 回调 | 双向数据绑定 |
| `@Observable` | Redux/MobX | 全局状态管理 |
| `.onChange()` | `useEffect` | 副作用处理 |
| `.task()` | `useEffect` (async) | 异步任务 |
| `View` protocol | 函数组件 | 组件定义 |

### 2.2 SwiftData 数据持久化

**SwiftData** 是 iOS 17+ 的原生 ORM 框架，类似于 Core Data 的现代版本。

#### 2.2.1 核心概念

**1. 定义模型**
```swift
import SwiftData

@Model
final class TodoItem {
    // 唯一属性
    @Attribute(.unique) var id: UUID

    // 普通属性
    var title: String
    var isCompleted: Bool
    var createdAt: Date

    // 关系（一对多）
    @Relationship(deleteRule: .cascade, inverse: \Subtask.todo)
    var subtasks: [Subtask] = []

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
    }
}
```

**2. 配置容器**
```swift
import SwiftData

// 定义 Schema
let schema = Schema([
    User.self,
    TodoItem.self,
    Category.self
])

// 创建容器
let container = try ModelContainer(
    for: schema,
    configurations: [ModelConfiguration(
        schema: schema,
        groupContainer: .identifier("group.com.yipoo.todolist")
    )]
)
```

**3. 数据操作**
```swift
// 插入
let todo = TodoItem(title: "新任务")
context.insert(todo)
try context.save()

// 查询
let descriptor = FetchDescriptor<TodoItem>(
    predicate: #Predicate { $0.isCompleted == false },
    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
)
let todos = try context.fetch(descriptor)

// 更新
todo.isCompleted = true
try context.save()

// 删除
context.delete(todo)
try context.save()
```

#### 2.2.2 Predicate 查询

**SwiftData 使用宏来定义查询条件：**

```swift
// ✅ 正确：使用宏定义 predicate
let predicate = #Predicate<TodoItem> { todo in
    todo.isCompleted == false && todo.priority == .high
}

// ✅ 正确：可选值安全处理
let predicate = #Predicate<TodoItem> { todo in
    if let dueDate = todo.dueDate {
        return dueDate < Date()
    }
    return false
}

// ❌ 错误：不能在 predicate 中强制解包
let predicate = #Predicate<TodoItem> { todo in
    todo.dueDate! < Date()  // 编译错误！
}
```

**在 Widget 中避免 Predicate 问题：**
```swift
// ❌ 不推荐：在 predicate 中处理可选值（容易出错）
let predicate = #Predicate<TodoItem> { todo in
    todo.dueDate != nil && todo.dueDate! >= today
}

// ✅ 推荐：先查询所有数据，再在内存中过滤
let allTodos = try context.fetch(FetchDescriptor<TodoItem>())
let todayTodos = allTodos.filter { todo in
    guard let dueDate = todo.dueDate else { return false }
    return dueDate >= today && dueDate < tomorrow
}
```

### 2.3 App Groups 共享机制

**App Groups** 允许主应用和 Widget 共享数据。

#### 2.3.1 配置步骤

**1. 添加 App Group 权限**

在 `TodoList.entitlements` 中：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.yipoo.todolist</string>
    </array>
</dict>
</plist>
```

在 `WidgetExtension.entitlements` 中添加相同配置。

**2. 在代码中使用 App Group**

```swift
// DataManager.swift
private static let appGroupIdentifier = "group.com.yipoo.todolist"

// 获取共享容器 URL
guard let appGroupURL = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: appGroupIdentifier
) else {
    fatalError("无法获取 App Group 容器")
}

// 使用 App Group 配置 SwiftData
let configuration = ModelConfiguration(
    schema: schema,
    groupContainer: .identifier(appGroupIdentifier)
)
```

#### 2.3.2 数据共享原理

```
┌──────────────────────┐         ┌──────────────────────┐
│   主应用 (TodoList)   │         │  Widget Extension    │
│                      │         │                      │
│  DataManager.shared  │         │  WidgetDataProvider  │
│         ↓            │         │         ↓            │
│   ModelContainer     │         │   ModelContainer     │
│         ↓            │         │         ↓            │
│  App Group Container │  共享   │  App Group Container │
│         ↓            │  ←───→  │         ↓            │
│  default.store       │         │  default.store       │
└──────────────────────┘         └──────────────────────┘
           ↓                                ↓
           └────────── 同一个数据库文件 ──────┘
```

### 2.4 WidgetKit 实现细节

**WidgetKit** 是 iOS 14+ 的桌面小组件框架。

#### 2.4.1 Widget 生命周期

```
添加 Widget → 调用 placeholder() → 显示占位符
      ↓
  Widget 画廊预览 → 调用 getSnapshot() → 显示预览
      ↓
    添加到桌面 → 调用 getTimeline() → 定期更新
```

#### 2.4.2 Timeline Provider

```swift
struct TodoWidgetProvider: TimelineProvider {
    // 1. 占位符（首次添加时显示）
    func placeholder(in context: Context) -> TodoWidgetEntry {
        TodoWidgetEntry(
            date: Date(),
            todayTodos: placeholderTodos(),
            statistics: WidgetStatistics()
        )
    }

    // 2. 快照（Widget 画廊预览）
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

    // 3. 时间线（实际数据）
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            let entry = await fetchData()

            // 15 分钟后更新
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

#### 2.4.3 Widget 刷新策略

**1. 时间策略（atEnd / after）**
```swift
// 在特定时间后刷新
let timeline = Timeline(
    entries: [entry],
    policy: .after(nextUpdateDate)
)

// 显示完最后一个 entry 后刷新
let timeline = Timeline(
    entries: entries,
    policy: .atEnd
)
```

**2. 手动刷新**
```swift
import WidgetKit

// 在主应用中刷新所有 Widget
WidgetCenter.shared.reloadAllTimelines()

// 刷新特定 Widget
WidgetCenter.shared.reloadTimelines(ofKind: "TodoListWidget")
```

### 2.5 Deep Link URL Scheme

**URL Scheme** 允许从 Widget 打开主应用的特定页面。

#### 2.5.1 注册 URL Scheme

在 `Info.plist` 中：
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>todolist</string>
        </array>
    </dict>
</array>
```

#### 2.5.2 定义 URL 格式

```swift
// URL 格式：todolist://action?param=value

// 示例
todolist://add                    // 打开添加页面
todolist://todo?id=123            // 打开特定待办详情
todolist://category?id=456        // 打开特定分类
```

#### 2.5.3 处理 Deep Link

```swift
// TodoListApp.swift
var body: some Scene {
    WindowGroup {
        ContentView()
            .onOpenURL { url in
                handleDeepLink(url)
            }
    }
}

func handleDeepLink(_ url: URL) {
    guard url.scheme == "todolist" else { return }

    switch url.host {
    case "add":
        // 导航到添加页面
        navigationPath.append(Route.createTodo)

    case "todo":
        // 解析参数
        if let id = url.queryParameters["id"],
           let uuid = UUID(uuidString: id) {
            navigationPath.append(Route.todoDetail(id: uuid))
        }

    default:
        break
    }
}
```

#### 2.5.4 在 Widget 中使用

```swift
// QuickAddWidget.swift
var body: some View {
    if let url = URL(string: "todolist://add") {
        Link(destination: url) {
            VStack {
                Image(systemName: "plus.circle.fill")
                Text("快速添加")
            }
        }
    }
}
```

---

## 3. 数据模型

### 3.1 User 模型详解

**用户模型**，管理用户的基本信息和认证。

```swift
@Model
final class User {
    // 基本信息
    @Attribute(.unique) var id: UUID
    var username: String
    @Attribute(.unique) var phoneNumber: String  // 主要登录方式
    var email: String?
    var passwordHash: String?  // 不存储明文密码

    // 头像
    var avatarURL: String?
    @Attribute(.externalStorage) var avatarImageData: Data?  // 本地存储

    // 时间戳
    var createdAt: Date
    var lastLoginAt: Date

    // 关系（一对多）
    @Relationship(deleteRule: .cascade, inverse: \TodoItem.user)
    var todos: [TodoItem] = []

    @Relationship(deleteRule: .cascade, inverse: \Category.user)
    var categories: [Category] = []

    @Relationship(deleteRule: .cascade, inverse: \PomodoroSession.user)
    var pomodoroSessions: [PomodoroSession] = []
}
```

**关键点：**
- `@Attribute(.unique)` - 确保字段唯一性
- `@Attribute(.externalStorage)` - 大文件外部存储（如图片）
- `@Relationship(deleteRule: .cascade)` - 级联删除（删除用户时自动删除所有待办）
- `inverse` - 反向关系（双向绑定）

### 3.2 TodoItem 模型详解

**待办事项模型**，核心业务模型。

```swift
@Model
final class TodoItem {
    // 基本信息
    @Attribute(.unique) var id: UUID
    var title: String  // 标题
    var itemDescription: String?  // 描述
    var isCompleted: Bool  // 完成状态

    // 分类和优先级
    var priority: Priority  // 优先级枚举
    var tags: [String]  // 标签数组

    // 时间相关
    var dueDate: Date?  // 截止日期
    var reminderTime: Date?  // 提醒时间
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?

    // 番茄钟
    var pomodoroCount: Int = 0  // 已完成的番茄钟
    var estimatedPomodoros: Int = 0  // 预计需要的番茄钟

    // 关系
    var user: User?
    var category: Category?

    @Relationship(deleteRule: .cascade, inverse: \Subtask.todo)
    var subtasks: [Subtask] = []

    @Relationship(deleteRule: .nullify, inverse: \PomodoroSession.todo)
    var pomodoroSessions: [PomodoroSession] = []
}
```

**业务方法：**
```swift
extension TodoItem {
    // 切换完成状态
    func toggleCompletion() {
        isCompleted.toggle()
        updatedAt = Date()
        completedAt = isCompleted ? Date() : nil
    }

    // 判断是否逾期
    func isOverdue() -> Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }

    // 判断是否是今天的待办
    func isToday() -> Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    // 子任务完成进度
    func subtaskProgress() -> Double {
        guard !subtasks.isEmpty else { return 0 }
        let completed = subtasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(subtasks.count)
    }
}
```

### 3.3 Category 模型详解

**分类模型**，用于组织待办事项。

```swift
@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var name: String  // 分类名称
    var icon: String  // SF Symbols 图标名
    var colorHex: String  // 颜色（十六进制）
    var sortOrder: Int  // 排序顺序
    var isSystem: Bool  // 是否为系统预设（不可删除）
    var createdAt: Date

    // 关系
    var user: User?
    @Relationship(inverse: \TodoItem.category)
    var todos: [TodoItem] = []
}
```

**系统预设分类：**
```swift
extension Category {
    static func createSystemCategories(for user: User) -> [Category] {
        return [
            Category(name: "工作", icon: "briefcase.fill", colorHex: "#007AFF", sortOrder: 1, isSystem: true, user: user),
            Category(name: "生活", icon: "house.fill", colorHex: "#34C759", sortOrder: 2, isSystem: true, user: user),
            Category(name: "学习", icon: "book.fill", colorHex: "#FF9500", sortOrder: 3, isSystem: true, user: user),
            Category(name: "健康", icon: "heart.fill", colorHex: "#FF3B30", sortOrder: 4, isSystem: true, user: user),
            Category(name: "目标", icon: "target", colorHex: "#AF52DE", sortOrder: 5, isSystem: true, user: user)
        ]
    }
}
```

### 3.4 Subtask 模型详解

**子任务模型**，用于分解大任务。

```swift
@Model
final class Subtask {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var sortOrder: Int  // 排序顺序
    var createdAt: Date

    // 关系
    var todo: TodoItem?

    func toggleCompletion() {
        isCompleted.toggle()
    }
}
```

### 3.5 PomodoroSession 模型详解

**番茄钟会话模型**，记录番茄钟使用情况。

```swift
@Model
final class PomodoroSession {
    @Attribute(.unique) var id: UUID
    var startTime: Date  // 开始时间
    var endTime: Date?  // 结束时间（进行中为 nil）
    var plannedDuration: Int  // 计划时长（分钟）
    var actualDuration: Int?  // 实际时长（分钟）
    var sessionType: SessionType  // 会话类型（工作/休息）
    var isCompleted: Bool  // 是否完成（中途放弃为 false）
    var createdAt: Date

    // 关系
    var todo: TodoItem?
    var user: User?
}

// 会话类型枚举
enum SessionType: String, Codable, CaseIterable {
    case work = "工作"
    case shortBreak = "短休息"
    case longBreak = "长休息"
}
```

### 3.6 模型关系图

```
┌─────────────┐
│    User     │
│  (用户)      │
└──────┬──────┘
       │ 1
       │
       │ *
       ├──────────┬──────────────┬──────────────┐
       │          │              │              │
       ↓          ↓              ↓              ↓
┌──────────┐ ┌──────────┐ ┌──────────────┐ ┌──────────┐
│ TodoItem │ │ Category │ │PomodoroSession│ │    ...   │
│ (待办)    │ │ (分类)    │ │ (番茄钟会话)   │ │          │
└────┬─────┘ └────┬─────┘ └───────────────┘ └──────────┘
     │ 1          │ 1
     │            │
     │ *          │ *
     ↓            ↓
┌──────────┐ ┌──────────┐
│ Subtask  │ │ TodoItem │
│ (子任务)  │ │          │
└──────────┘ └──────────┘

关系说明：
- User ←→ TodoItem: 一对多（一个用户有多个待办）
- User ←→ Category: 一对多（一个用户有多个分类）
- User ←→ PomodoroSession: 一对多
- TodoItem ←→ Category: 多对一（一个待办属于一个分类）
- TodoItem ←→ Subtask: 一对多（一个待办有多个子任务）
- TodoItem ←→ PomodoroSession: 一对多（一个待办有多个番茄钟会话）
```

---

## 4. 服务层

### 4.1 DataManager 详解

**DataManager** 是统一的数据访问层，封装所有 SwiftData 操作。

#### 4.1.1 单例模式

```swift
@MainActor
final class DataManager {
    static let shared = DataManager()

    private(set) var container: ModelContainer
    var context: ModelContext {
        container.mainContext
    }

    private init() {
        // 初始化容器
    }
}
```

**为什么使用单例？**
- 确保整个应用使用同一个 ModelContainer
- 避免多次创建容器导致的性能问题
- 便于集中管理数据库配置

#### 4.1.2 初始化流程

```swift
private init() {
    // 1. 获取 App Group 容器 URL
    guard let appGroupURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: "group.com.yipoo.todolist"
    ) else {
        fatalError("无法获取 App Group 容器")
    }

    print("📂 App Group 容器路径: \(appGroupURL.path())")

    // 2. 定义 Schema
    let schema = Schema([
        User.self,
        TodoItem.self,
        Category.self,
        Subtask.self,
        PomodoroSession.self
    ])

    // 3. 配置使用 App Group
    let configuration = ModelConfiguration(
        schema: schema,
        groupContainer: .identifier("group.com.yipoo.todolist")
    )

    // 4. 创建容器
    do {
        container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        print("✅ SwiftData 初始化成功")
    } catch {
        fatalError("❌ 无法创建 ModelContainer: \(error)")
    }
}
```

### 4.2 数据操作 API

#### 4.2.1 用户操作

```swift
// 创建用户
func createUser(username: String, phoneNumber: String, email: String? = nil, passwordHash: String? = nil) throws -> User {
    let user = User(
        username: username,
        phoneNumber: phoneNumber,
        email: email,
        passwordHash: passwordHash
    )

    context.insert(user)

    // 创建系统预设分类
    let categories = Category.createSystemCategories(for: user)
    categories.forEach { context.insert($0) }

    try context.save()
    return user
}

// 根据手机号查找用户
func findUser(byPhoneNumber phoneNumber: String) -> User? {
    let predicate = #Predicate<User> { user in
        user.phoneNumber == phoneNumber
    }

    let descriptor = FetchDescriptor<User>(predicate: predicate)
    return try? context.fetch(descriptor).first
}

// 根据 ID 查找用户
func findUser(byId id: UUID) -> User? {
    let predicate = #Predicate<User> { user in
        user.id == id
    }

    let descriptor = FetchDescriptor<User>(predicate: predicate)
    return try? context.fetch(descriptor).first
}

// 更新最后登录时间
func updateUserLastLogin(_ user: User) {
    user.updateLastLogin()
    try? context.save()
}
```

#### 4.2.2 待办操作

```swift
// 创建待办
func createTodo(_ todo: TodoItem) throws {
    context.insert(todo)
    try context.save()
}

// 更新待办
func updateTodo(_ todo: TodoItem) throws {
    todo.updatedAt = Date()
    try context.save()
}

// 删除待办
func deleteTodo(_ todo: TodoItem) throws {
    context.delete(todo)
    try context.save()
}

// 获取用户的待办（带筛选）
func fetchTodos(
    for user: User,
    filter: TodoFilterOption = .all,
    sortBy: TodoSortOption = .createdAt
) -> [TodoItem] {
    // 查询所有待办
    let descriptor = FetchDescriptor<TodoItem>(
        sortBy: sortBy.descriptor()
    )
    let allTodos = (try? context.fetch(descriptor)) ?? []

    // 过滤出当前用户的待办
    let userTodos = allTodos.filter { $0.user?.id == user.id }

    // 根据筛选条件进一步过滤
    switch filter {
    case .all:
        return userTodos
    case .today:
        return userTodos.filter { $0.isToday() }
    case .week:
        return userTodos.filter { $0.isThisWeek() }
    case .completed:
        return userTodos.filter { $0.isCompleted }
    case .uncompleted:
        return userTodos.filter { !$0.isCompleted }
    case .overdue:
        return userTodos.filter { $0.isOverdue() }
    }
}
```

#### 4.2.3 分类操作

```swift
// 创建分类
func createCategory(_ category: Category) throws {
    context.insert(category)
    try context.save()
}

// 更新分类
func updateCategory(_ category: Category) throws {
    try context.save()
}

// 删除分类
func deleteCategory(_ category: Category) throws {
    guard !category.isSystem else {
        throw DataError.cannotDeleteSystemCategory
    }
    context.delete(category)
    try context.save()
}

// 获取用户的分类
func fetchCategories(for user: User) -> [Category] {
    let descriptor = FetchDescriptor<Category>(
        sortBy: [SortDescriptor(\.sortOrder)]
    )
    let allCategories = (try? context.fetch(descriptor)) ?? []
    return allCategories.filter { $0.user?.id == user.id }
}
```

### 4.3 错误处理

```swift
// 定义错误类型
enum DataError: LocalizedError {
    case cannotDeleteSystemCategory
    case userNotFound
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .cannotDeleteSystemCategory:
            return "系统预设分类不能删除"
        case .userNotFound:
            return "用户不存在"
        case .saveFailed:
            return "保存失败"
        }
    }
}

// 在 ViewModel 中处理错误
func createTodo(title: String) async {
    do {
        let todo = TodoItem(title: title, user: currentUser)
        try dataManager.createTodo(todo)
        successMessage = "创建成功"
    } catch let error as DataError {
        errorMessage = error.errorDescription
    } catch {
        errorMessage = "未知错误：\(error.localizedDescription)"
    }
}
```

---

## 5. Widget 开发

### 5.1 Widget 架构

```
WidgetBundle
    ├── TodoListStaticWidget (小/中/大号)
    │   ├── TodoWidgetProvider (TimelineProvider)
    │   ├── SmallWidgetView
    │   ├── MediumWidgetView
    │   └── LargeWidgetView
    │
    └── QuickAddWidget (小/中号)
        ├── QuickAddProvider
        └── QuickAddWidgetView
```

### 5.2 Timeline Provider 详解

```swift
struct TodoWidgetProvider: TimelineProvider {
    // 1. 占位符（Widget 首次添加时显示）
    func placeholder(in context: Context) -> TodoWidgetEntry {
        TodoWidgetEntry(
            date: Date(),
            todayTodos: placeholderTodos(),
            statistics: WidgetStatistics(
                totalTodos: 5,
                completedTodos: 3,
                todayCompletedTodos: 2
            )
        )
    }

    // 2. 快照（Widget 画廊预览）
    func getSnapshot(in context: Context, completion: @escaping (TodoWidgetEntry) -> Void) {
        if context.isPreview {
            // 预览模式：使用占位符
            let entry = placeholder(in: context)
            completion(entry)
        } else {
            // 非预览：获取真实数据
            Task {
                let entry = await fetchData()
                completion(entry)
            }
        }
    }

    // 3. 时间线（实际显示的数据）
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoWidgetEntry>) -> Void) {
        Task {
            // 获取实际数据
            let entry = await fetchData()

            // 设置下次更新时间（15 分钟后）
            let nextUpdate = Calendar.current.date(
                byAdding: .minute,
                value: 15,
                to: Date()
            )!

            // 创建时间线
            let timeline = Timeline(
                entries: [entry],
                policy: .after(nextUpdate)
            )

            completion(timeline)
        }
    }

    // 获取数据
    private func fetchData() async -> TodoWidgetEntry {
        let todayTodos = await MainActor.run {
            WidgetDataProvider.getTodayTodos()
        }

        let statistics = await MainActor.run {
            WidgetDataProvider.getStatistics()
        }

        return TodoWidgetEntry(
            date: Date(),
            todayTodos: todayTodos,
            statistics: statistics
        )
    }
}
```

### 5.3 数据共享实现

**WidgetDataProvider** 负责从共享容器读取数据。

```swift
@MainActor
final class WidgetDataProvider {
    private static let appGroupIdentifier = "group.com.yipoo.todolist"

    // 创建共享容器
    private static func createContainer() -> ModelContainer? {
        guard let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            print("❌ Widget: 无法获取 App Group 容器")
            return nil
        }

        let schema = Schema([
            User.self,
            TodoItem.self,
            Category.self,
            Subtask.self,
            PomodoroSession.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(appGroupIdentifier)
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            print("✅ Widget: SwiftData 容器初始化成功")
            return container
        } catch {
            print("❌ Widget: 无法创建 ModelContainer: \(error)")
            return nil
        }
    }

    // 获取今日待办
    static func getTodayTodos() -> [WidgetTodoItem] {
        guard let container = createContainer() else {
            return []
        }

        let context = ModelContext(container)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        do {
            // 查询所有待办
            let descriptor = FetchDescriptor<TodoItem>(
                sortBy: [SortDescriptor(\.dueDate, order: .forward)]
            )
            let allTodos = try context.fetch(descriptor)

            // 在内存中过滤今日待办
            let todos = allTodos.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return dueDate >= today && dueDate < tomorrow
            }

            // 转换为 WidgetTodoItem
            return todos.map { todo in
                WidgetTodoItem(
                    id: todo.id,
                    title: todo.title,
                    isCompleted: todo.isCompleted,
                    priority: "low",  // Widget 中不展示优先级
                    dueDate: todo.dueDate,
                    categoryName: todo.category?.name,
                    categoryColor: todo.category?.colorHex
                )
            }
        } catch {
            print("❌ Widget: 获取今日待办失败: \(error)")
            return []
        }
    }

    // 获取统计数据
    static func getStatistics() -> WidgetStatistics {
        guard let container = createContainer() else {
            return WidgetStatistics()
        }

        let context = ModelContext(container)

        do {
            let allDescriptor = FetchDescriptor<TodoItem>()
            let allTodos = try context.fetch(allDescriptor)

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

            let todayTodos = allTodos.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return dueDate >= today && dueDate < tomorrow
            }

            return WidgetStatistics(
                totalTodos: allTodos.count,
                completedTodos: allTodos.filter { $0.isCompleted }.count,
                todayCompletedTodos: todayTodos.filter { $0.isCompleted }.count
            )
        } catch {
            print("❌ Widget: 获取统计数据失败: \(error)")
            return WidgetStatistics()
        }
    }
}
```

### 5.4 小号/中号/大号 Widget 设计

#### 5.4.1 小号 Widget（SmallWidgetView）

显示今日待办摘要和完成率。

```swift
struct SmallWidgetView: View {
    let entry: TodoWidgetEntry

    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                Text("今日待办")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text(formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding()

            Spacer()

            // 中间进度环
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                    .frame(width: 90, height: 90)

                Circle()
                    .trim(from: 0, to: todayCompletionRate)
                    .stroke(progressGradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(todayCompletedCount)")
                        .font(.system(size: 32, weight: .bold))
                    Text("/\(todayTotalCount)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // 底部统计
            HStack {
                VStack(alignment: .leading) {
                    Text("已完成")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("\(todayCompletedCount)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1, height: 30)

                VStack(alignment: .trailing) {
                    Text("未完成")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("\(todayUncompletedCount)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
        }
    }
}
```

#### 5.4.2 中号 Widget（MediumWidgetView）

显示今日待办列表（3-4 项）。

#### 5.4.3 大号 Widget（LargeWidgetView）

显示完整的今日待办列表和统计信息。

### 5.5 快速添加 Widget

```swift
struct QuickAddWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "QuickAddWidget", provider: QuickAddProvider()) { entry in
            QuickAddWidgetView(entry: entry)
        }
        .configurationDisplayName("快速添加")
        .description("快速添加待办事项")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SmallQuickAddView: View {
    var body: some View {
        if let url = URL(string: "todolist://add") {
            Link(destination: url) {
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(spacing: 4) {
                        Text("快速添加")
                            .font(.headline)
                            .fontWeight(.bold)

                        Text("轻触添加待办")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
```

### 5.6 故障排查

**问题 1：Widget 不显示数据**
```
检查清单：
1. 确认 App Group 配置正确
2. 主应用和 Widget 使用相同的 App Group ID
3. 检查权限文件（.entitlements）
4. 查看 Widget 日志（Xcode Console）
5. 确认主应用已保存数据
```

**问题 2：Widget 数据不更新**
```
解决方案：
1. 在主应用中手动刷新 Widget
   WidgetCenter.shared.reloadAllTimelines()

2. 检查 Timeline 更新策略
   let timeline = Timeline(
       entries: [entry],
       policy: .after(nextUpdate)  // 确认更新时间设置正确
   )

3. 强制刷新 Widget（长按 Widget → 编辑 Widget）
```

**问题 3：SwiftData Predicate 错误**
```
错误示例：
let predicate = #Predicate<TodoItem> { todo in
    todo.dueDate! < Date()  // ❌ 不能强制解包
}

正确做法：
// 方案 1：在 predicate 中安全处理
let predicate = #Predicate<TodoItem> { todo in
    if let dueDate = todo.dueDate {
        return dueDate < Date()
    }
    return false
}

// 方案 2：先查询再过滤（推荐用于 Widget）
let allTodos = try context.fetch(FetchDescriptor<TodoItem>())
let filtered = allTodos.filter { todo in
    guard let dueDate = todo.dueDate else { return false }
    return dueDate < Date()
}
```

---

## 6. UI 组件

### 6.1 主要视图说明

#### 6.1.1 TodoListView

**待办列表视图**，显示所有待办事项。

```swift
struct TodoListView: View {
    @Environment(TodoViewModel.self) private var viewModel
    @State private var showCreateSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredTodos) { todo in
                    TodoRow(todo: todo)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.deleteTodo(todo)
                                }
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
            .navigationTitle("待办事项")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateTodoView()
            }
        }
        .task {
            viewModel.loadTodos()
        }
    }
}
```

#### 6.1.2 CreateTodoView

**创建待办视图**，表单页面。

```swift
struct CreateTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TodoViewModel.self) private var viewModel

    @State private var title = ""
    @State private var description = ""
    @State private var priority: Priority = .medium
    @State private var dueDate = Date()
    @State private var hasDueDate = false

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("标题", text: $title)
                    TextField("描述", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("优先级") {
                    Picker("优先级", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("截止日期") {
                    Toggle("设置截止日期", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("截止日期", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("创建待办")
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
                            await viewModel.createTodo(
                                title: title,
                                description: description.isEmpty ? nil : description,
                                priority: priority,
                                dueDate: hasDueDate ? dueDate : nil
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
```

### 6.2 自定义组件

#### 6.2.1 TodoRow

```swift
struct TodoRow: View {
    let todo: TodoItem
    @Environment(TodoViewModel.self) private var viewModel

    var body: some View {
        HStack(spacing: 12) {
            // 完成按钮
            Button {
                Task {
                    await viewModel.toggleCompletion(todo)
                }
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(todo.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)

            // 内容
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.body)
                    .strikethrough(todo.isCompleted)

                if let description = todo.itemDescription {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // 标签
                HStack(spacing: 8) {
                    // 优先级
                    priorityBadge

                    // 截止日期
                    if let dueDate = todo.dueDate {
                        dueDateBadge(dueDate)
                    }

                    // 分类
                    if let category = todo.category {
                        categoryBadge(category)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var priorityBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: todo.priority.icon)
            Text(todo.priority.rawValue)
        }
        .font(.caption2)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(todo.priority.color).opacity(0.2))
        .foregroundColor(Color(todo.priority.color))
        .cornerRadius(6)
    }

    private func dueDateBadge(_ date: Date) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
            Text(date.formatted(date: .abbreviated, time: .omitted))
        }
        .font(.caption2)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(todo.isOverdue() ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
        .foregroundColor(todo.isOverdue() ? .red : .blue)
        .cornerRadius(6)
    }

    private func categoryBadge(_ category: Category) -> some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
            Text(category.name)
        }
        .font(.caption2)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(hex: category.colorHex).opacity(0.2))
        .foregroundColor(Color(hex: category.colorHex))
        .cornerRadius(6)
    }
}
```

### 6.3 颜色系统

```swift
// Constants.swift
enum AppColors {
    // 主题色
    static let primary = Color("Primary")
    static let secondary = Color("Secondary")
    static let accent = Color("Accent")

    // 优先级颜色
    static let highPriority = Color.red
    static let mediumPriority = Color.orange
    static let lowPriority = Color.gray

    // 分类颜色（十六进制）
    static let categoryColors = [
        "#007AFF",  // 蓝色
        "#34C759",  // 绿色
        "#FF9500",  // 橙色
        "#FF3B30",  // 红色
        "#AF52DE",  // 紫色
        "#FF2D55",  // 粉色
        "#5856D6",  // 靛蓝
        "#00C7BE",  // 青色
    ]

    // 状态颜色
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
}

// Color+Extension.swift
extension Color {
    // 从十六进制字符串创建颜色
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

### 6.4 字体系统

```swift
extension Font {
    // 标题
    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title = Font.system(size: 28, weight: .bold)
    static let title2 = Font.system(size: 22, weight: .bold)
    static let title3 = Font.system(size: 20, weight: .semibold)

    // 正文
    static let headline = Font.system(size: 17, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let callout = Font.system(size: 16, weight: .regular)
    static let subheadline = Font.system(size: 15, weight: .regular)
    static let footnote = Font.system(size: 13, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)
    static let caption2 = Font.system(size: 11, weight: .regular)
}
```

---

## 7. 最佳实践

### 7.1 SwiftUI 最佳实践

#### 7.1.1 状态管理

```swift
// ✅ 正确：使用 @State 管理视图私有状态
struct MyView: View {
    @State private var isExpanded = false
    @State private var text = ""

    var body: some View {
        VStack {
            TextField("输入", text: $text)
            Button("展开") {
                isExpanded.toggle()
            }
        }
    }
}

// ✅ 正确：使用 @Environment 注入共享状态
struct TodoListView: View {
    @Environment(TodoViewModel.self) private var viewModel

    var body: some View {
        List(viewModel.todos) { todo in
            Text(todo.title)
        }
    }
}

// ❌ 错误：在 View 中直接创建 ViewModel
struct BadView: View {
    @State private var viewModel = TodoViewModel()  // ❌ 每次重新渲染都会创建新实例
}
```

#### 7.1.2 视图拆分

```swift
// ✅ 正确：将复杂视图拆分为小组件
struct TodoListView: View {
    var body: some View {
        List {
            ForEach(todos) { todo in
                TodoRow(todo: todo)  // 拆分为独立组件
            }
        }
    }
}

struct TodoRow: View {
    let todo: TodoItem

    var body: some View {
        HStack {
            CheckboxButton(isCompleted: todo.isCompleted)
            TodoContent(todo: todo)
            PriorityBadge(priority: todo.priority)
        }
    }
}

// ❌ 错误：所有逻辑都写在一个 View 中
struct BadView: View {
    var body: some View {
        List {
            ForEach(todos) { todo in
                HStack {
                    // 100 行代码...
                }
            }
        }
    }
}
```

#### 7.1.3 性能优化

```swift
// ✅ 正确：使用 @ViewBuilder 延迟渲染
struct ConditionalView<Content: View>: View {
    let condition: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        if condition {
            content()
        }
    }
}

// ✅ 正确：使用 Identifiable 而不是索引
ForEach(todos) { todo in  // ✅ 使用 id
    Text(todo.title)
}

ForEach(todos.indices, id: \.self) { index in  // ❌ 使用索引
    Text(todos[index].title)
}

// ✅ 正确：避免在 body 中进行复杂计算
struct TodoListView: View {
    @Environment(TodoViewModel.self) private var viewModel

    // 使用计算属性
    private var sortedTodos: [TodoItem] {
        viewModel.todos.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        List(sortedTodos) { todo in  // ✅ 使用预计算的结果
            Text(todo.title)
        }
    }
}
```

### 7.2 SwiftData 最佳实践

#### 7.2.1 模型设计

```swift
// ✅ 正确：使用 @Attribute 定义约束
@Model
final class User {
    @Attribute(.unique) var id: UUID  // 唯一性约束
    @Attribute(.unique) var email: String  // 唯一性约束
    @Attribute(.externalStorage) var avatarData: Data?  // 外部存储（大文件）

    var name: String
    var createdAt: Date
}

// ✅ 正确：定义关系的删除规则
@Model
final class TodoItem {
    var id: UUID
    var title: String

    // 删除用户时级联删除待办
    var user: User?

    // 删除待办时级联删除子任务
    @Relationship(deleteRule: .cascade, inverse: \Subtask.todo)
    var subtasks: [Subtask] = []

    // 删除待办时将番茄钟会话的关联置为 nil
    @Relationship(deleteRule: .nullify, inverse: \PomodoroSession.todo)
    var pomodoroSessions: [PomodoroSession] = []
}

// ❌ 错误：没有定义反向关系
@Model
final class BadTodoItem {
    @Relationship(deleteRule: .cascade)  // ❌ 缺少 inverse
    var subtasks: [Subtask] = []
}
```

#### 7.2.2 查询优化

```swift
// ✅ 正确：使用 FetchDescriptor 进行高效查询
func fetchTodos(isCompleted: Bool) -> [TodoItem] {
    let predicate = #Predicate<TodoItem> { todo in
        todo.isCompleted == isCompleted
    }

    let descriptor = FetchDescriptor<TodoItem>(
        predicate: predicate,
        sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )

    return (try? context.fetch(descriptor)) ?? []
}

// ✅ 正确：在内存中过滤可选值（避免 predicate 问题）
func fetchTodayTodos() -> [TodoItem] {
    let allTodos = (try? context.fetch(FetchDescriptor<TodoItem>())) ?? []

    return allTodos.filter { todo in
        guard let dueDate = todo.dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
}

// ❌ 错误：在 predicate 中强制解包
func badFetchTodos() -> [TodoItem] {
    let predicate = #Predicate<TodoItem> { todo in
        todo.dueDate! < Date()  // ❌ 编译错误！
    }
    // ...
}
```

#### 7.2.3 事务管理

```swift
// ✅ 正确：批量操作使用事务
func batchCreateTodos(_ todos: [TodoItem]) throws {
    // 所有操作在一个事务中
    for todo in todos {
        context.insert(todo)
    }
    try context.save()  // 一次性保存
}

// ❌ 错误：每次操作都保存
func badBatchCreate(_ todos: [TodoItem]) throws {
    for todo in todos {
        context.insert(todo)
        try context.save()  // ❌ 频繁 I/O
    }
}

// ✅ 正确：使用 do-catch 处理错误
func createTodo(_ todo: TodoItem) {
    do {
        context.insert(todo)
        try context.save()
    } catch {
        print("保存失败: \(error)")
        // 回滚或重试
    }
}
```

### 7.3 Widget 最佳实践

#### 7.3.1 性能优化

```swift
// ✅ 正确：限制查询数量
func getTodayTodos() -> [WidgetTodoItem] {
    let allTodos = try? context.fetch(FetchDescriptor<TodoItem>())

    return allTodos?
        .filter { $0.isToday() }
        .prefix(10)  // 只取前 10 个
        .map { convertToWidgetItem($0) }
        ?? []
}

// ✅ 正确：使用轻量级数据模型
struct WidgetTodoItem: Identifiable {
    let id: UUID
    let title: String
    let isCompleted: Bool
    // 只包含必要字段，不包含复杂对象
}

// ❌ 错误：在 Widget 中使用完整的 SwiftData 模型
struct BadWidgetView: View {
    let todo: TodoItem  // ❌ 可能导致性能问题
}
```

#### 7.3.2 更新策略

```swift
// ✅ 正确：合理设置更新间隔
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    Task {
        let entry = await fetchData()

        // 根据数据特点设置更新时间
        let nextUpdate: Date
        if hasUrgentTodos {
            nextUpdate = Date().addingTimeInterval(5 * 60)  // 5 分钟
        } else {
            nextUpdate = Date().addingTimeInterval(30 * 60)  // 30 分钟
        }

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// ✅ 正确：在主应用中主动刷新 Widget
func saveTodo(_ todo: TodoItem) {
    do {
        try dataManager.createTodo(todo)

        // 保存成功后刷新 Widget
        WidgetCenter.shared.reloadAllTimelines()
    } catch {
        print("保存失败: \(error)")
    }
}
```

### 7.4 性能优化建议

#### 7.4.1 列表优化

```swift
// ✅ 正确：使用 LazyVStack 延迟加载
ScrollView {
    LazyVStack {
        ForEach(todos) { todo in
            TodoRow(todo: todo)
        }
    }
}

// ✅ 正确：限制列表项数量
var displayedTodos: [TodoItem] {
    Array(todos.prefix(100))  // 只显示前 100 个
}

// ✅ 正确：使用分页加载
@State private var page = 1
@State private var todos: [TodoItem] = []

func loadMore() {
    let newTodos = fetchTodos(page: page, pageSize: 20)
    todos.append(contentsOf: newTodos)
    page += 1
}
```

#### 7.4.2 图片优化

```swift
// ✅ 正确：使用 AsyncImage 异步加载
AsyncImage(url: URL(string: avatarURL)) { phase in
    switch phase {
    case .success(let image):
        image.resizable()
            .scaledToFill()
            .frame(width: 50, height: 50)
            .clipShape(Circle())
    case .failure:
        Image(systemName: "person.circle.fill")
    case .empty:
        ProgressView()
    @unknown default:
        EmptyView()
    }
}

// ✅ 正确：压缩图片数据
func compressImage(_ image: UIImage) -> Data? {
    // 压缩到 500KB 以下
    var quality: CGFloat = 1.0
    var imageData = image.jpegData(compressionQuality: quality)

    while let data = imageData, data.count > 500_000 && quality > 0.1 {
        quality -= 0.1
        imageData = image.jpegData(compressionQuality: quality)
    }

    return imageData
}
```

---

## 8. 常见问题和解决方案

### 8.1 SwiftData Predicate 问题

**问题：在 Predicate 中使用可选值导致编译错误**

```swift
// ❌ 错误示例
let predicate = #Predicate<TodoItem> { todo in
    todo.dueDate! < Date()  // 编译错误：不能强制解包
}
```

**解决方案：**

```swift
// ✅ 方案 1：在 Predicate 中安全处理
let predicate = #Predicate<TodoItem> { todo in
    if let dueDate = todo.dueDate {
        return dueDate < Date()
    }
    return false
}

// ✅ 方案 2：先查询再过滤（推荐用于 Widget）
let allTodos = try context.fetch(FetchDescriptor<TodoItem>())
let filtered = allTodos.filter { todo in
    guard let dueDate = todo.dueDate else { return false }
    return dueDate < Date()
}
```

### 8.2 Widget 显示问题

**问题：Widget 不显示数据或显示占位符**

**排查步骤：**

1. **检查 App Group 配置**
```swift
// 主应用和 Widget 必须使用相同的 App Group ID
private static let appGroupIdentifier = "group.com.yipoo.todolist"

// 检查是否能获取容器
guard let appGroupURL = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: appGroupIdentifier
) else {
    print("❌ 无法获取 App Group 容器")
    return
}
print("✅ App Group 容器路径: \(appGroupURL.path())")
```

2. **检查权限文件**
```xml
<!-- TodoList.entitlements 和 WidgetExtension.entitlements 都需要 -->
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.yipoo.todolist</string>
</array>
```

3. **查看日志**
```swift
// 在 WidgetDataProvider 中添加详细日志
print("📂 Widget 开始获取数据")
print("📦 查询到 \(allTodos.count) 个待办")
print("✅ 今日待办: \(todayTodos.count) 个")
```

4. **手动刷新 Widget**
```swift
// 在主应用中调用
import WidgetKit
WidgetCenter.shared.reloadAllTimelines()
```

### 8.3 App Groups 配置问题

**问题：App Group 容器获取失败**

**解决方案：**

1. **在 Xcode 中添加 App Groups 能力**
   - 选择主应用 Target → Signing & Capabilities
   - 点击 "+ Capability"
   - 添加 "App Groups"
   - 点击 "+" 添加组 ID：`group.com.yipoo.todolist`

2. **为 Widget Extension 添加相同配置**
   - 选择 WidgetExtension Target
   - 重复上述步骤，使用相同的 App Group ID

3. **验证配置**
```swift
// 验证代码
let appGroupID = "group.com.yipoo.todolist"
if let containerURL = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: appGroupID
) {
    print("✅ App Group 配置成功: \(containerURL.path())")
} else {
    print("❌ App Group 配置失败，请检查权限")
}
```

### 8.4 编译错误解决

**问题 1：找不到模型定义**

```
错误：Cannot find 'TodoItem' in scope
```

**解决方案：**
- 确保 Widget Target 包含了所有模型文件
- 在 Xcode 中选择模型文件 → File Inspector → Target Membership
- 勾选 WidgetExtension

**问题 2：SwiftData 初始化失败**

```
错误：Fatal error: Unable to create ModelContainer
```

**解决方案：**
```swift
// 1. 检查 Schema 是否包含所有模型
let schema = Schema([
    User.self,
    TodoItem.self,
    Category.self,
    Subtask.self,
    PomodoroSession.self  // 不要遗漏任何模型
])

// 2. 使用 do-catch 捕获详细错误
do {
    container = try ModelContainer(for: schema, configurations: [configuration])
} catch {
    print("❌ ModelContainer 创建失败: \(error)")
    print("错误详情: \(error.localizedDescription)")
    fatalError("无法创建容器")
}
```

**问题 3：模型迁移问题**

```
错误：The model used to open the store is incompatible with the one used to create the store
```

**解决方案：**
```swift
// 开发阶段：删除旧数据库
#if DEBUG
let defaultStoreURL = appGroupURL.appendingPathComponent("default.store")
if FileManager.default.fileExists(atPath: defaultStoreURL.path()) {
    try? FileManager.default.removeItem(at: defaultStoreURL)
    print("🗑️ 已删除旧数据库")
}
#endif

// 生产环境：实现数据迁移（TODO）
```

---

## 9. 扩展开发指南

### 9.1 如何添加新功能

**示例：添加"待办标签"功能**

**步骤 1：修改数据模型**

```swift
// TodoItem.swift
@Model
final class TodoItem {
    // 现有属性...

    // 新增：标签数组
    var tags: [String] = []

    // 新增：标签颜色映射（可选）
    var tagColors: [String: String] = [:]  // 标签名 -> 颜色
}
```

**步骤 2：更新 DataManager**

```swift
// DataManager.swift
extension DataManager {
    // 根据标签查询待办
    func fetchTodos(withTag tag: String, for user: User) -> [TodoItem] {
        let allTodos = (try? context.fetch(FetchDescriptor<TodoItem>())) ?? []

        return allTodos.filter { todo in
            todo.user?.id == user.id && todo.tags.contains(tag)
        }
    }

    // 获取所有标签
    func fetchAllTags(for user: User) -> [String] {
        let todos = fetchTodos(for: user)
        var tags = Set<String>()

        todos.forEach { todo in
            todo.tags.forEach { tags.insert($0) }
        }

        return Array(tags).sorted()
    }
}
```

**步骤 3：更新 ViewModel**

```swift
// TodoViewModel.swift
extension TodoViewModel {
    // 添加标签
    func addTag(_ tag: String, to todo: TodoItem) async {
        guard !tag.isEmpty && !todo.tags.contains(tag) else {
            return
        }

        todo.tags.append(tag)
        await updateTodo(todo)
    }

    // 删除标签
    func removeTag(_ tag: String, from todo: TodoItem) async {
        todo.tags.removeAll { $0 == tag }
        await updateTodo(todo)
    }

    // 按标签筛选
    var selectedTag: String?

    var filteredTodosByTag: [TodoItem] {
        guard let tag = selectedTag else {
            return filteredTodos
        }

        return filteredTodos.filter { $0.tags.contains(tag) }
    }
}
```

**步骤 4：创建 UI 组件**

```swift
// Views/Todo/Components/TagView.swift
struct TagView: View {
    let tag: String
    let color: Color
    var onTap: (() -> Void)?
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)

            if let onDelete = onDelete {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .cornerRadius(6)
        .onTapGesture {
            onTap?()
        }
    }
}

// 标签输入视图
struct TagInputView: View {
    @Binding var tags: [String]
    @State private var newTag = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("标签")
                .font(.headline)

            // 显示已有标签
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    TagView(tag: tag, color: .blue) {
                        tags.removeAll { $0 == tag }
                    }
                }
            }

            // 添加新标签
            HStack {
                TextField("添加标签", text: $newTag)
                    .textFieldStyle(.roundedBorder)

                Button("添加") {
                    if !newTag.isEmpty && !tags.contains(newTag) {
                        tags.append(newTag)
                        newTag = ""
                    }
                }
                .disabled(newTag.isEmpty)
            }
        }
    }
}
```

**步骤 5：集成到现有视图**

```swift
// CreateTodoView.swift
struct CreateTodoView: View {
    // 现有状态...
    @State private var tags: [String] = []

    var body: some View {
        Form {
            // 现有部分...

            Section("标签") {
                TagInputView(tags: $tags)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    Task {
                        await viewModel.createTodo(
                            title: title,
                            // ...其他参数
                            tags: tags  // 传入标签
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}
```

### 9.2 如何添加新的 Widget

**示例：创建"本周统计" Widget**

**步骤 1：定义数据结构**

```swift
// Widget/WeeklyStatsWidget.swift
import WidgetKit
import SwiftUI

// Entry
struct WeeklyStatsEntry: TimelineEntry {
    let date: Date
    let weeklyStats: WeeklyStatistics
}

// 统计数据
struct WeeklyStatistics {
    let completedCount: Int
    let totalCount: Int
    let dailyStats: [DailyStats]  // 7 天的数据
}

struct DailyStats {
    let date: Date
    let count: Int
}
```

**步骤 2：创建 Timeline Provider**

```swift
struct WeeklyStatsProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeeklyStatsEntry {
        WeeklyStatsEntry(
            date: Date(),
            weeklyStats: WeeklyStatistics(
                completedCount: 25,
                totalCount: 40,
                dailyStats: generateSampleDailyStats()
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WeeklyStatsEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
        } else {
            Task {
                let entry = await fetchWeeklyStats()
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeeklyStatsEntry>) -> Void) {
        Task {
            let entry = await fetchWeeklyStats()

            // 每天凌晨更新
            let tomorrow = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
            let timeline = Timeline(entries: [entry], policy: .after(tomorrow))

            completion(timeline)
        }
    }

    private func fetchWeeklyStats() async -> WeeklyStatsEntry {
        // 从 SwiftData 获取本周数据
        let stats = await MainActor.run {
            WidgetDataProvider.getWeeklyStats()
        }

        return WeeklyStatsEntry(date: Date(), weeklyStats: stats)
    }
}
```

**步骤 3：创建视图**

```swift
struct WeeklyStatsWidgetView: View {
    let entry: WeeklyStatsEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("本周统计")
                    .font(.headline)
                Spacer()
                Text("\(entry.weeklyStats.completedCount)/\(entry.weeklyStats.totalCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 柱状图
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(entry.weeklyStats.dailyStats, id: \.date) { stat in
                    VStack(spacing: 4) {
                        // 柱子
                        Rectangle()
                            .fill(Color.blue)
                            .frame(height: barHeight(for: stat.count))

                        // 日期标签
                        Text(weekdayLabel(for: stat.date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 100)

            // 完成率
            HStack {
                Text("完成率")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(completionRate)%")
                    .font(.headline)
                    .foregroundColor(.green)
            }
        }
        .padding()
    }

    private func barHeight(for count: Int) -> CGFloat {
        let maxCount = entry.weeklyStats.dailyStats.map { $0.count }.max() ?? 1
        return CGFloat(count) / CGFloat(maxCount) * 80
    }

    private var completionRate: Int {
        guard entry.weeklyStats.totalCount > 0 else { return 0 }
        return Int(Double(entry.weeklyStats.completedCount) / Double(entry.weeklyStats.totalCount) * 100)
    }

    private func weekdayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}
```

**步骤 4：注册 Widget**

```swift
struct WeeklyStatsWidget: Widget {
    let kind: String = "WeeklyStatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeeklyStatsProvider()) { entry in
            WeeklyStatsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("本周统计")
        .description("查看本周的待办完成情况")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
```

**步骤 5：添加到 WidgetBundle**

```swift
// WidgetBundle.swift
@main
struct TodoListWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodoListStaticWidget()
        QuickAddWidget()
        WeeklyStatsWidget()  // 新增
    }
}
```

### 9.3 如何修改数据模型

**重要提示：修改模型会导致数据库结构变化，需要谨慎处理。**

**场景 1：添加新属性（向后兼容）**

```swift
// 在 TodoItem 中添加新属性
@Model
final class TodoItem {
    // 现有属性...

    // 新增属性（提供默认值）
    var notes: String = ""  // ✅ 提供默认值，兼容旧数据
    var attachments: [String] = []  // ✅ 空数组作为默认值
}
```

**场景 2：删除属性（需要迁移）**

```swift
// 如果要删除属性，需要先备份数据

// 1. 导出现有数据
func exportData() throws {
    let todos = try context.fetch(FetchDescriptor<TodoItem>())
    let encoder = JSONEncoder()
    let data = try encoder.encode(todos)
    // 保存到文件
}

// 2. 删除旧数据库
#if DEBUG
let dbURL = appGroupURL.appendingPathComponent("default.store")
try? FileManager.default.removeItem(at: dbURL)
#endif

// 3. 修改模型（删除属性）
@Model
final class TodoItem {
    // 删除了某个属性
}

// 4. 导入数据（跳过已删除的属性）
func importData() throws {
    let decoder = JSONDecoder()
    let todos = try decoder.decode([TodoItem].self, from: data)
    // 插入新数据
}
```

**场景 3：重命名属性**

```swift
// 方案 1：添加新属性，迁移数据，删除旧属性
@Model
final class TodoItem {
    // var description: String  // 旧属性
    var itemDescription: String  // 新属性

    // 迁移方法
    func migrateDescription() {
        if itemDescription.isEmpty && !description.isEmpty {
            itemDescription = description
        }
    }
}

// 方案 2：使用版本控制（推荐）
// SwiftData 会在未来版本支持更好的迁移机制
```

### 9.4 如何添加新的分类

**方法 1：在代码中添加系统分类**

```swift
// Category.swift
extension Category {
    static func createSystemCategories(for user: User) -> [Category] {
        return [
            // 现有分类...

            // 新增分类
            Category(
                name: "购物",
                icon: "cart.fill",
                colorHex: "#FF6B6B",
                sortOrder: 6,
                isSystem: true,
                user: user
            ),
            Category(
                name: "旅行",
                icon: "airplane",
                colorHex: "#4ECDC4",
                sortOrder: 7,
                isSystem: true,
                user: user
            )
        ]
    }
}
```

**方法 2：用户自定义分类（UI 方式）**

```swift
// CategoryManagementView.swift
struct CategoryManagementView: View {
    @Environment(CategoryViewModel.self) private var viewModel
    @State private var showCreateSheet = false

    var body: some View {
        List {
            ForEach(viewModel.categories) { category in
                CategoryRow(category: category)
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    let category = viewModel.categories[index]
                    Task {
                        await viewModel.deleteCategory(category)
                    }
                }
            }
        }
        .navigationTitle("分类管理")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateCategoryView()
        }
    }
}

// CreateCategoryView.swift
struct CreateCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CategoryViewModel.self) private var viewModel

    @State private var name = ""
    @State private var selectedIcon = "folder.fill"
    @State private var selectedColor = "#007AFF"

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("分类名称", text: $name)
                }

                Section("图标") {
                    IconPicker(selectedIcon: $selectedIcon)
                }

                Section("颜色") {
                    ColorPicker(selectedColor: $selectedColor)
                }
            }
            .navigationTitle("创建分类")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            await viewModel.createCategory(
                                name: name,
                                icon: selectedIcon,
                                colorHex: selectedColor
                            )
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
```

---

## 10. 代码示例

### 10.1 创建待办事项

```swift
// 完整示例：创建一个待办事项

import SwiftUI

// 1. 在 ViewModel 中定义方法
@Observable
@MainActor
final class TodoViewModel {
    func createTodo(
        title: String,
        description: String? = nil,
        priority: Priority = .medium,
        dueDate: Date? = nil,
        category: Category? = nil,
        tags: [String] = []
    ) async {
        guard let user = authViewModel.currentUser else {
            errorMessage = "请先登录"
            return
        }

        guard !title.trimmed.isEmpty else {
            errorMessage = "请输入待办标题"
            return
        }

        isLoading = true

        do {
            // 创建待办对象
            let todo = TodoItem(
                title: title.trimmed,
                itemDescription: description?.trimmed,
                priority: priority,
                tags: tags,
                dueDate: dueDate,
                category: category,
                user: user
            )

            // 保存到数据库
            try dataManager.createTodo(todo)

            // 刷新列表
            loadTodos()

            // 刷新 Widget
            WidgetCenter.shared.reloadAllTimelines()

            successMessage = "创建成功"
            isLoading = false

        } catch {
            errorMessage = "创建失败：\(error.localizedDescription)"
            isLoading = false
        }
    }
}

// 2. 在 View 中调用
struct CreateTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TodoViewModel.self) private var viewModel

    @State private var title = ""
    @State private var description = ""
    @State private var priority: Priority = .medium
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var selectedCategory: Category?
    @State private var tags: [String] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("标题", text: $title)
                    TextField("描述", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("优先级") {
                    Picker("优先级", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            HStack {
                                Image(systemName: priority.icon)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("分类") {
                    CategoryPicker(selectedCategory: $selectedCategory)
                }

                Section("截止日期") {
                    Toggle("设置截止日期", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker(
                            "截止日期",
                            selection: $dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }

                Section("标签") {
                    TagInputView(tags: $tags)
                }
            }
            .navigationTitle("创建待办")
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
                            await viewModel.createTodo(
                                title: title,
                                description: description.isEmpty ? nil : description,
                                priority: priority,
                                dueDate: hasDueDate ? dueDate : nil,
                                category: selectedCategory,
                                tags: tags
                            )

                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
            .alert("错误", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("确定") {
                    viewModel.clearMessagesPublic()
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}
```

### 10.2 查询数据

```swift
// 完整示例：查询待办事项

// 1. 基础查询
func fetchAllTodos() -> [TodoItem] {
    let descriptor = FetchDescriptor<TodoItem>()
    return (try? context.fetch(descriptor)) ?? []
}

// 2. 带条件查询
func fetchCompletedTodos() -> [TodoItem] {
    let predicate = #Predicate<TodoItem> { todo in
        todo.isCompleted == true
    }

    let descriptor = FetchDescriptor<TodoItem>(predicate: predicate)
    return (try? context.fetch(descriptor)) ?? []
}

// 3. 带排序查询
func fetchTodosSorted() -> [TodoItem] {
    let descriptor = FetchDescriptor<TodoItem>(
        sortBy: [
            SortDescriptor(\.createdAt, order: .reverse)
        ]
    )
    return (try? context.fetch(descriptor)) ?? []
}

// 4. 复杂查询（多条件）
func fetchTodosComplex(
    isCompleted: Bool,
    priority: Priority,
    categoryId: UUID
) -> [TodoItem] {
    let predicate = #Predicate<TodoItem> { todo in
        todo.isCompleted == isCompleted &&
        todo.priority == priority
    }

    let descriptor = FetchDescriptor<TodoItem>(
        predicate: predicate,
        sortBy: [SortDescriptor(\.dueDate, order: .forward)]
    )

    let todos = (try? context.fetch(descriptor)) ?? []

    // 在内存中过滤分类（避免复杂的 predicate）
    return todos.filter { $0.category?.id == categoryId }
}

// 5. 安全处理可选值
func fetchTodayTodos() -> [TodoItem] {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

    // 先查询所有待办
    let allTodos = (try? context.fetch(FetchDescriptor<TodoItem>())) ?? []

    // 在内存中过滤
    return allTodos.filter { todo in
        guard let dueDate = todo.dueDate else { return false }
        return dueDate >= today && dueDate < tomorrow
    }
}

// 6. 分页查询
func fetchTodosPaged(page: Int, pageSize: Int = 20) -> [TodoItem] {
    var descriptor = FetchDescriptor<TodoItem>(
        sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )

    // 设置偏移量和限制
    descriptor.fetchOffset = page * pageSize
    descriptor.fetchLimit = pageSize

    return (try? context.fetch(descriptor)) ?? []
}

// 7. 统计查询
func getStatistics(for user: User) -> TodoStatistics {
    let allTodos = (try? context.fetch(FetchDescriptor<TodoItem>())) ?? []
    let userTodos = allTodos.filter { $0.user?.id == user.id }

    let total = userTodos.count
    let completed = userTodos.filter { $0.isCompleted }.count
    let pending = total - completed

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

    let todayTodos = userTodos.filter { todo in
        guard let dueDate = todo.dueDate else { return false }
        return dueDate >= today && dueDate < tomorrow
    }

    let overdue = userTodos.filter { $0.isOverdue() }

    return TodoStatistics(
        total: total,
        completed: completed,
        pending: pending,
        today: todayTodos.count,
        overdue: overdue.count
    )
}
```

### 10.3 Widget 数据获取

```swift
// 完整示例：Widget 中获取数据

import WidgetKit
import SwiftUI
import SwiftData

@MainActor
final class WidgetDataProvider {
    private static let appGroupIdentifier = "group.com.yipoo.todolist"

    // 创建共享容器
    private static func createContainer() -> ModelContainer? {
        guard let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            print("❌ Widget: 无法获取 App Group 容器")
            return nil
        }

        print("📂 Widget App Group 容器路径: \(appGroupURL.path())")

        let schema = Schema([
            User.self,
            TodoItem.self,
            Category.self,
            Subtask.self,
            PomodoroSession.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(appGroupIdentifier)
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            print("✅ Widget: SwiftData 容器初始化成功")
            return container
        } catch {
            print("❌ Widget: 无法创建 ModelContainer: \(error)")
            return nil
        }
    }

    // 获取今日待办
    static func getTodayTodos() -> [WidgetTodoItem] {
        print("📊 Widget: 开始获取今日待办")

        guard let container = createContainer() else {
            print("❌ Widget: 容器创建失败")
            return []
        }

        let context = ModelContext(container)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        print("📅 Widget: 今日范围 \(today) - \(tomorrow)")

        do {
            // 查询所有待办
            let descriptor = FetchDescriptor<TodoItem>(
                sortBy: [SortDescriptor(\.dueDate, order: .forward)]
            )
            let allTodos = try context.fetch(descriptor)

            print("📦 Widget: 查询到 \(allTodos.count) 个待办")

            // 在内存中过滤今日待办
            let todayTodos = allTodos.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return dueDate >= today && dueDate < tomorrow
            }

            print("✅ Widget: 今日待办 \(todayTodos.count) 个")

            // 转换为 WidgetTodoItem
            let widgetItems = todayTodos.map { todo in
                WidgetTodoItem(
                    id: todo.id,
                    title: todo.title,
                    isCompleted: todo.isCompleted,
                    priority: "low",
                    dueDate: todo.dueDate,
                    categoryName: todo.category?.name,
                    categoryColor: todo.category?.colorHex
                )
            }

            return widgetItems

        } catch {
            print("❌ Widget: 获取今日待办失败: \(error)")
            return []
        }
    }

    // 获取统计数据
    static func getStatistics() -> WidgetStatistics {
        print("📊 Widget: 开始获取统计数据")

        guard let container = createContainer() else {
            return WidgetStatistics()
        }

        let context = ModelContext(container)

        do {
            let allDescriptor = FetchDescriptor<TodoItem>()
            let allTodos = try context.fetch(allDescriptor)

            print("📦 Widget: 总待办数 \(allTodos.count)")

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

            let todayTodos = allTodos.filter { todo in
                guard let dueDate = todo.dueDate else { return false }
                return dueDate >= today && dueDate < tomorrow
            }

            let totalCount = allTodos.count
            let completedCount = allTodos.filter { $0.isCompleted }.count
            let todayCompletedCount = todayTodos.filter { $0.isCompleted }.count

            print("✅ Widget: 统计完成 - 总数:\(totalCount), 已完成:\(completedCount)")

            return WidgetStatistics(
                totalTodos: totalCount,
                completedTodos: completedCount,
                todayCompletedTodos: todayCompletedCount
            )

        } catch {
            print("❌ Widget: 获取统计数据失败: \(error)")
            return WidgetStatistics()
        }
    }
}
```

### 10.4 Deep Link 处理

```swift
// 完整示例：处理 Deep Link

// 1. 定义 Deep Link 路由
enum DeepLinkRoute {
    case createTodo
    case todoDetail(id: UUID)
    case category(id: UUID)
    case pomodoro
    case statistics
}

// 2. 解析 URL
class DeepLinkManager {
    static func parse(_ url: URL) -> DeepLinkRoute? {
        guard url.scheme == "todolist" else { return nil }

        switch url.host {
        case "add":
            return .createTodo

        case "todo":
            if let idString = url.queryParameters["id"],
               let uuid = UUID(uuidString: idString) {
                return .todoDetail(id: uuid)
            }

        case "category":
            if let idString = url.queryParameters["id"],
               let uuid = UUID(uuidString: idString) {
                return .category(id: uuid)
            }

        case "pomodoro":
            return .pomodoro

        case "statistics":
            return .statistics

        default:
            return nil
        }

        return nil
    }
}

// 3. URL 扩展（解析查询参数）
extension URL {
    var queryParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return [:]
        }

        var params: [String: String] = [:]
        for item in queryItems {
            params[item.name] = item.value
        }
        return params
    }
}

// 4. 在 App 中处理 Deep Link
@main
struct TodoListApp: App {
    @State private var authViewModel = AuthViewModel()
    @State private var themeManager = ThemeManager.shared
    @State private var navigationPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .environment(themeManager)
                .modelContainer(DataManager.shared.container)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        print("📱 收到 Deep Link: \(url)")

        guard let route = DeepLinkManager.parse(url) else {
            print("❌ 无法解析 Deep Link")
            return
        }

        // 确保用户已登录
        guard authViewModel.isAuthenticated else {
            print("❌ 用户未登录，忽略 Deep Link")
            return
        }

        // 根据路由导航
        handleRoute(route)
    }

    private func handleRoute(_ route: DeepLinkRoute) {
        switch route {
        case .createTodo:
            print("📝 导航到创建待办")
            // 显示创建待办页面
            NotificationCenter.default.post(
                name: .init("ShowCreateTodo"),
                object: nil
            )

        case .todoDetail(let id):
            print("📋 导航到待办详情: \(id)")
            // 导航到待办详情
            NotificationCenter.default.post(
                name: .init("ShowTodoDetail"),
                object: id
            )

        case .category(let id):
            print("📁 导航到分类: \(id)")
            // 导航到分类页面

        case .pomodoro:
            print("🍅 导航到番茄钟")
            // 切换到番茄钟 Tab

        case .statistics:
            print("📊 导航到统计")
            // 切换到统计 Tab
        }
    }
}

// 5. 在 Widget 中使用 Deep Link
struct SmallQuickAddView: View {
    var body: some View {
        if let url = URL(string: "todolist://add") {
            Link(destination: url) {
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(spacing: 4) {
                        Text("快速添加")
                            .font(.headline)
                        Text("轻触添加待办")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// 6. 测试 Deep Link
// 在终端运行：
// xcrun simctl openurl booted "todolist://add"
// xcrun simctl openurl booted "todolist://todo?id=123e4567-e89b-12d3-a456-426614174000"
```

---

## 总结

本技术手册涵盖了 TodoList SwiftUI 项目的所有核心技术和开发细节：

1. **项目架构**：清晰的 MVVM 架构，分层明确
2. **核心技术**：SwiftUI、SwiftData、WidgetKit、App Groups、Deep Link
3. **数据模型**：完整的模型定义和关系设计
4. **服务层**：统一的数据访问层（DAL）
5. **Widget 开发**：完整的 Widget 实现方案
6. **UI 组件**：可复用的组件和设计系统
7. **最佳实践**：各层级的最佳实践和性能优化
8. **问题解决**：常见问题的完整解决方案
9. **扩展开发**：详细的扩展开发指南
10. **代码示例**：大量完整可用的代码示例

通过这份手册，任何开发者都可以：
- 快速理解项目架构和技术栈
- 学习 SwiftUI 和 SwiftData 的最佳实践
- 掌握 Widget 开发的核心技术
- 解决开发中遇到的常见问题
- 扩展和定制项目功能

**关键技术点：**
- ✅ SwiftData 的 App Groups 共享机制
- ✅ SwiftData Predicate 的正确使用方式
- ✅ Widget Timeline Provider 的完整实现
- ✅ MVVM 架构的最佳实践
- ✅ Deep Link 的完整处理流程

**注意事项：**
- ⚠️ 修改数据模型时需要考虑数据迁移
- ⚠️ Widget 中避免使用复杂的 Predicate
- ⚠️ App Groups 配置必须在主应用和 Widget 中保持一致
- ⚠️ 性能优化要考虑列表大小和数据加载策略

祝开发愉快！
