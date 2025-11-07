# 架构设计文档

## 目录
- [总体架构](#总体架构)
- [设计模式](#设计模式)
- [数据流](#数据流)
- [模块划分](#模块划分)
- [技术决策](#技术决策)

---

## 总体架构

TodoList 采用 **MVVM (Model-View-ViewModel)** 架构模式,结合 SwiftUI 和 SwiftData 构建。

```
┌─────────────────────────────────────────────────────┐
│                    Presentation Layer                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │  Views   │  │  Widgets │  │   App    │          │
│  │ (SwiftUI)│  │(WidgetKit)│  │  Entry   │          │
│  └─────┬────┘  └────┬─────┘  └────┬─────┘          │
└────────┼────────────┼─────────────┼─────────────────┘
         │            │             │
         ▼            ▼             ▼
┌─────────────────────────────────────────────────────┐
│                   Business Layer                     │
│  ┌──────────────┐  ┌──────────────┐                │
│  │  ViewModels  │  │  App Intents │                │
│  │  (Combine)   │  │              │                │
│  └──────┬───────┘  └──────┬───────┘                │
└─────────┼──────────────────┼───────────────────────┘
          │                  │
          ▼                  ▼
┌─────────────────────────────────────────────────────┐
│                     Data Layer                       │
│  ┌──────────────┐  ┌──────────────┐                │
│  │   Models     │  │DataProviders │                │
│  │ (SwiftData)  │  │              │                │
│  └──────┬───────┘  └──────┬───────┘                │
└─────────┼──────────────────┼───────────────────────┘
          │                  │
          ▼                  ▼
┌─────────────────────────────────────────────────────┐
│                   Storage Layer                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │SwiftData │  │App Group │  │ Keychain │          │
│  │ Database │  │UserDefaults│ │ Storage  │          │
│  └──────────┘  └──────────┘  └──────────┘          │
└─────────────────────────────────────────────────────┘
```

---

## 设计模式

### 1. MVVM (Model-View-ViewModel)

#### Model (数据模型)
- 纯数据结构,使用 `@Model` 宏标记
- 包含业务逻辑方法
- 定义数据关系

**示例:**
```swift
@Model
final class TodoItem {
    var title: String
    var isCompleted: Bool
    var category: Category?
    var subtasks: [Subtask] = []

    func toggleCompletion() {
        isCompleted.toggle()
        updatedAt = Date()
    }
}
```

#### View (视图)
- 使用 SwiftUI 声明式语法
- 无业务逻辑,只负责展示
- 通过 `@Environment` 和 `@Query` 访问数据
- 通过 ViewModel 处理用户交互

**示例:**
```swift
struct TodoListView: View {
    @Environment(TodoViewModel.self) private var viewModel
    @Query(sort: \TodoItem.createdAt) var todos: [TodoItem]

    var body: some View {
        List(todos) { todo in
            TodoRow(todo: todo)
        }
    }
}
```

#### ViewModel (视图模型)
- 使用 `@Observable` 宏标记,支持自动观察
- 处理业务逻辑和用户交互
- 管理视图状态
- 与数据层交互

**示例:**
```swift
@Observable
final class TodoViewModel {
    var filterOption: TodoFilterOption = .all
    var sortOption: TodoSortOption = .createdAt

    func addTodo(_ todo: TodoItem, context: ModelContext) {
        context.insert(todo)
        try? context.save()
    }
}
```

### 2. Repository Pattern

虽然 SwiftData 简化了数据访问,但仍保留部分 Repository 概念:

- `DataManager`: 管理 SwiftData 容器
- `WidgetDataProvider`: Widget 数据访问层

### 3. Dependency Injection

使用 SwiftUI 的环境系统进行依赖注入:

```swift
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
```

### 4. Singleton Pattern

用于全局共享的管理器:

```swift
final class ThemeManager {
    static let shared = ThemeManager()
    private init() {}
}
```

---

## 数据流

### 主应用数据流

```
User Action
    │
    ▼
┌─────────┐    trigger    ┌──────────────┐
│  View   │─────────────→ │  ViewModel   │
│         │               │              │
└─────────┘               └──────┬───────┘
    ▲                            │
    │                            │ manipulate
    │                            ▼
    │                     ┌──────────────┐
    │      @Query        │ ModelContext │
    └─────────────────── │  SwiftData   │
                         └──────────────┘
```

### Widget 数据流

```
Widget Timeline
    │
    ▼
┌──────────────────┐
│ TimelineProvider │
│                  │
└────────┬─────────┘
         │
         │ fetch data
         ▼
┌──────────────────┐     ┌──────────────┐
│WidgetDataProvider│────→│  App Group   │
│                  │     │  SwiftData   │
└────────┬─────────┘     └──────────────┘
         │
         │ create entries
         ▼
┌──────────────────┐
│  Widget View     │
│                  │
└──────────────────┘
```

### App Intent 数据流 (Widget 交互)

```
User Tap Widget
    │
    ▼
┌──────────────────┐
│   App Intent     │
│                  │
└────────┬─────────┘
         │
         │ perform action
         ▼
┌──────────────────┐     ┌──────────────┐
│  Data Provider   │────→│  App Group   │
│                  │     │  SwiftData   │
└────────┬─────────┘     └──────────────┘
         │
         │ refresh
         ▼
┌──────────────────┐
│ Timeline Reload  │
│                  │
└──────────────────┘
```

---

## 模块划分

### 1. App 模块
**职责**: 应用入口和主框架

**主要文件**:
- `TodoListApp.swift`: 应用主入口,配置环境
- `ContentView.swift`: 根视图,处理认证状态
- `MainTabView.swift`: 主标签导航

### 2. Todo 模块
**职责**: 待办事项核心功能

**主要组件**:
- `TodoItem` Model: 数据模型
- `TodoViewModel`: 业务逻辑
- `TodoListView`: 列表视图
- `TodoDetailView`: 详情视图
- `AddTodoView`: 添加/编辑视图

**功能**:
- CRUD 操作
- 筛选排序
- 子任务管理
- 优先级设置

### 3. Category 模块
**职责**: 分类管理

**主要组件**:
- `Category` Model
- `CategoryViewModel`
- `CategoryListView`
- `CategoryEditView`

**功能**:
- 分类 CRUD
- 颜色图标自定义
- 统计信息

### 4. Pomodoro 模块
**职责**: 番茄钟计时器

**主要组件**:
- `PomodoroSession` Model
- `PomodoroSettings` Model
- `PomodoroViewModel`
- `PomodoroView`

**功能**:
- 计时控制
- 任务关联
- 统计记录
- 通知提醒

### 5. Calendar 模块
**职责**: 日历视图

**主要组件**:
- `CalendarView`
- Calendar Components

**功能**:
- 月历显示
- 日期选择
- 任务标记

### 6. Statistics 模块
**职责**: 数据统计

**主要组件**:
- `StatisticsViewModel`
- `StatisticsView`
- Chart Components

**功能**:
- 完成趋势
- 分类分布
- 效率分析

### 7. Profile 模块
**职责**: 用户中心

**主要组件**:
- `User` Model
- `ProfileViewModel`
- `ProfileView`
- `SettingsView`

**功能**:
- 用户信息管理
- 设置配置
- 主题切换

### 8. Auth 模块
**职责**: 认证授权

**主要组件**:
- `AuthViewModel`
- `LoginView`
- `RegisterView`

**功能**:
- 邮箱登录注册
- 微信登录
- 会话管理

### 9. Widget 模块
**职责**: 主屏幕小组件

**主要组件**:
- `TodoListWidget`
- `QuickAddWidget`
- `WidgetDataProvider`
- Size-specific Views

**功能**:
- 数据展示
- 快速添加
- Deep Link

---

## 技术决策

### 为什么选择 SwiftData?

**优势**:
1. **原生集成**: Apple 官方框架,与 SwiftUI 无缝集成
2. **类型安全**: 完全的 Swift 类型系统
3. **简化代码**: 相比 Core Data 大幅减少样板代码
4. **现代化**: 使用 Swift 宏和新特性
5. **性能**: 针对 SwiftUI 优化

**替代方案比较**:
- Core Data: 更成熟但代码冗长
- Realm: 第三方依赖,学习曲线
- 纯文件存储: 缺乏查询能力

### 为什么使用 MVVM?

**适合 SwiftUI 的原因**:
1. 声明式 UI 与响应式数据绑定
2. `@Observable` 宏简化状态管理
3. 清晰的职责分离
4. 易于测试

### App Group 的使用

**必要性**:
1. Widget 需要访问主应用数据
2. SwiftData 数据库共享
3. UserDefaults 共享

**配置**:
- Group ID: `group.com.yipoo.todolist`
- 主应用和 Widget Extension 都需配置

### 为什么选择 @Observable 而非 ObservableObject?

**优势**:
1. 更细粒度的观察,性能更好
2. 语法更简洁
3. 自动跟踪属性变化
4. iOS 17+ 推荐方式

```swift
// 新方式 - @Observable
@Observable
final class TodoViewModel {
    var todos: [TodoItem] = []
}

// 旧方式 - ObservableObject
final class TodoViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
}
```

### Widget 更新策略

**Timeline Policy**:
- 小组件: 每 15 分钟更新
- 快速添加 Widget: 每次操作后立即刷新
- 使用 `WidgetCenter.shared.reloadTimelines()` 手动刷新

### 通知策略

**本地通知**:
- 任务提醒: 用户设置的时间
- 番茄钟提醒: 工作/休息结束时
- 权限处理: 首次使用时请求

---

## 性能优化

### 1. 数据查询优化

```swift
// 使用 @Query 的谓词和排序
@Query(
    filter: #Predicate<TodoItem> { !$0.isCompleted },
    sort: \TodoItem.priority,
    order: .reverse
)
var todos: [TodoItem]
```

### 2. 视图优化

```swift
// 使用 LazyVStack 延迟加载
LazyVStack {
    ForEach(todos) { todo in
        TodoRow(todo: todo)
    }
}
```

### 3. Widget 性能

- 限制数据量(最多显示 8 个)
- 避免复杂计算
- 使用缓存策略

### 4. 图片资源

- 使用 Asset Catalog
- 支持矢量图标
- 提供 @2x, @3x 资源

---

## 安全考虑

### 数据安全

1. **敏感数据**: 使用 Keychain 存储
2. **密码加密**: 不存储明文密码
3. **数据隔离**: App Group 限制访问范围

### 权限管理

1. **通知权限**: 首次使用时请求
2. **日历权限**: 如需要集成系统日历
3. **照片权限**: 上传头像时

---

## 可扩展性

### 未来扩展方向

1. **iCloud 同步**: 跨设备数据同步
2. **协作功能**: 分享和协作任务
3. **Siri 快捷指令**: 语音添加任务
4. **Apple Watch**: 手表端应用
5. **iPad 优化**: 多窗口支持
6. **macOS**: Mac Catalyst 或原生应用

### 插件化设计

预留扩展点:
- 第三方登录(微信、QQ、微博)
- 导入导出(CSV、JSON)
- 主题系统(自定义主题)
- 插件系统(自定义功能)

---

## 总结

TodoList 的架构设计遵循以下原则:

1. **简洁性**: 使用现代 Swift 特性简化代码
2. **可维护性**: 清晰的模块划分和职责分离
3. **可测试性**: MVVM 架构便于单元测试
4. **性能**: 充分利用 SwiftUI 和 SwiftData 的优化
5. **扩展性**: 为未来功能预留空间

通过合理的架构设计,TodoList 实现了功能强大、性能优秀、易于维护的目标。
