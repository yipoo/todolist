# API 参考文档

本文档提供 TodoList 应用主要组件、类和方法的详细参考。

---

## 目录

- [数据模型 (Models)](#数据模型-models)
- [视图模型 (ViewModels)](#视图模型-viewmodels)
- [工具类 (Utils)](#工具类-utils)
- [Widget 组件](#widget-组件)

---

## 数据模型 (Models)

### TodoItem

待办事项核心数据模型。

```swift
@Model
final class TodoItem {
    // 属性
    var id: UUID
    var title: String
    var itemDescription: String?
    var isCompleted: Bool
    var priority: Priority
    var tags: [String]
    var dueDate: Date?
    var reminderTime: Date?
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    var pomodoroCount: Int
    var estimatedPomodoros: Int

    // 关系
    var user: User?
    var category: Category?
    var subtasks: [Subtask]
    var pomodoroSessions: [PomodoroSession]
}
```

#### 初始化方法

```swift
init(
    id: UUID = UUID(),
    title: String,
    itemDescription: String? = nil,
    isCompleted: Bool = false,
    priority: Priority = .medium,
    tags: [String] = [],
    dueDate: Date? = nil,
    reminderTime: Date? = nil,
    category: Category? = nil,
    user: User? = nil
)
```

#### 实例方法

##### toggleCompletion()
切换任务完成状态。

```swift
func toggleCompletion()
```

- 如果标记为完成,设置 `completedAt` 为当前时间
- 如果取消完成,清空 `completedAt`
- 更新 `updatedAt` 时间戳

##### addPomodoro()
增加番茄钟计数。

```swift
func addPomodoro()
```

- 将 `pomodoroCount` 加 1
- 更新 `updatedAt` 时间戳

##### isOverdue() -> Bool
判断任务是否已逾期。

```swift
func isOverdue() -> Bool
```

**返回值**: 如果未完成且截止日期已过,返回 `true`

##### isToday() -> Bool
判断任务是否为今日任务。

```swift
func isToday() -> Bool
```

**返回值**: 如果截止日期为今天,返回 `true`

##### isThisWeek() -> Bool
判断任务是否为本周任务。

```swift
func isThisWeek() -> Bool
```

**返回值**: 如果截止日期在本周,返回 `true`

##### subtaskProgress() -> Double
计算子任务完成进度。

```swift
func subtaskProgress() -> Double
```

**返回值**: 0.0 到 1.0 之间的进度值

##### subtaskProgressText() -> String
获取子任务进度文本。

```swift
func subtaskProgressText() -> String
```

**返回值**: 格式为 "已完成/总数" 的字符串,如 "3/5"

---

### Priority

优先级枚举。

```swift
enum Priority: String, Codable, CaseIterable, Comparable {
    case low = "低"
    case medium = "中"
    case high = "高"
}
```

#### 计算属性

```swift
var color: String        // 优先级对应颜色: "gray", "orange", "red"
var icon: String         // SF Symbol 图标名称
var weight: Int          // 排序权重: 1-3
```

---

### Category

分类数据模型。

```swift
@Model
final class Category {
    var id: UUID
    var name: String
    var icon: String           // SF Symbol 图标名称
    var colorHex: String       // 十六进制颜色,如 "#FF0000"
    var sortOrder: Int
    var createdAt: Date
    var isSystem: Bool         // 系统预设分类不可删除

    // 关系
    var user: User?
    var todos: [TodoItem]
}
```

#### 实例方法

##### uncompletedCount() -> Int
获取未完成任务数量。

```swift
func uncompletedCount() -> Int
```

##### todayCount() -> Int
获取今日任务数量。

```swift
func todayCount() -> Int
```

##### totalCount() -> Int
获取总任务数量。

```swift
func totalCount() -> Int
```

##### completedCount() -> Int
获取已完成任务数量。

```swift
func completedCount() -> Int
```

##### completionProgress() -> Double
获取完成进度。

```swift
func completionProgress() -> Double
```

**返回值**: 0.0 到 1.0 之间的进度值

##### overdueCount() -> Int
获取逾期任务数量。

```swift
func overdueCount() -> Int
```

#### 静态方法

##### createSystemCategories(for:) -> [Category]
创建系统预设分类。

```swift
static func createSystemCategories(for user: User) -> [Category]
```

**参数**:
- `user`: 分类所属用户

**返回值**: 包含"工作"、"生活"、"学习"、"健康"、"目标"的分类数组

---

### Subtask

子任务数据模型。

```swift
@Model
final class Subtask {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var sortOrder: Int
    var createdAt: Date

    // 关系
    var todo: TodoItem?
}
```

---

### PomodoroSession

番茄钟会话记录。

```swift
@Model
final class PomodoroSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var duration: Int          // 分钟
    var type: PomodoroType
    var isCompleted: Bool

    // 关系
    var todo: TodoItem?
    var user: User?
}
```

#### PomodoroType 枚举

```swift
enum PomodoroType: String, Codable {
    case work = "工作"
    case shortBreak = "短休息"
    case longBreak = "长休息"
}
```

---

### PomodoroSettings

番茄钟设置。

```swift
@Model
final class PomodoroSettings {
    var workDuration: Int = 25        // 工作时长(分钟)
    var shortBreakDuration: Int = 5   // 短休息时长
    var longBreakDuration: Int = 15   // 长休息时长
    var sessionsUntilLongBreak: Int = 4
    var autoStartBreak: Bool = false
    var autoStartWork: Bool = false
    var enableSound: Bool = true
    var enableNotification: Bool = true

    var user: User?
}
```

---

### User

用户数据模型。

```swift
@Model
final class User {
    var id: UUID
    var username: String
    var email: String
    var displayName: String?
    var avatarURL: String?
    var bio: String?
    var createdAt: Date
    var loginProvider: LoginProvider

    // 关系
    var todos: [TodoItem]
    var categories: [Category]
    var pomodoroSessions: [PomodoroSession]
    var pomodoroSettings: PomodoroSettings?
}
```

#### LoginProvider 枚举

```swift
enum LoginProvider: String, Codable {
    case email = "邮箱"
    case wechat = "微信"
}
```

---

## 视图模型 (ViewModels)

### TodoViewModel

待办事项业务逻辑。

```swift
@Observable
final class TodoViewModel {
    // 状态
    var filterOption: TodoFilterOption = .all
    var sortOption: TodoSortOption = .createdAt
    var selectedCategory: Category?
    var searchText: String = ""
    var showCompleted: Bool = true
}
```

#### 方法

##### addTodo(_:context:)
添加新待办。

```swift
func addTodo(_ todo: TodoItem, context: ModelContext)
```

##### updateTodo(_:context:)
更新待办。

```swift
func updateTodo(_ todo: TodoItem, context: ModelContext)
```

##### deleteTodo(_:context:)
删除待办。

```swift
func deleteTodo(_ todo: TodoItem, context: ModelContext)
```

##### toggleCompletion(_:context:)
切换完成状态。

```swift
func toggleCompletion(_ todo: TodoItem, context: ModelContext)
```

##### filterTodos(_:) -> [TodoItem]
根据筛选条件过滤待办。

```swift
func filterTodos(_ todos: [TodoItem]) -> [TodoItem]
```

---

### CategoryViewModel

分类管理逻辑。

```swift
@Observable
final class CategoryViewModel {
    var selectedCategory: Category?
}
```

#### 方法

##### addCategory(_:context:)
添加分类。

```swift
func addCategory(_ category: Category, context: ModelContext)
```

##### updateCategory(_:context:)
更新分类。

```swift
func updateCategory(_ category: Category, context: ModelContext)
```

##### deleteCategory(_:context:)
删除分类(系统分类除外)。

```swift
func deleteCategory(_ category: Category, context: ModelContext) throws
```

**抛出**: 如果尝试删除系统分类,抛出错误

---

### PomodoroViewModel

番茄钟计时器逻辑。

```swift
@Observable
final class PomodoroViewModel {
    // 状态
    var timerState: TimerState = .idle
    var currentType: PomodoroType = .work
    var remainingSeconds: Int = 0
    var currentTodo: TodoItem?
    var sessionCount: Int = 0
}
```

#### TimerState 枚举

```swift
enum TimerState {
    case idle       // 空闲
    case running    // 运行中
    case paused     // 暂停
}
```

#### 方法

##### start()
开始计时。

```swift
func start()
```

##### pause()
暂停计时。

```swift
func pause()
```

##### resume()
继续计时。

```swift
func resume()
```

##### reset()
重置计时器。

```swift
func reset()
```

##### skip()
跳过当前会话。

```swift
func skip()
```

##### setTodo(_:)
设置关联的待办任务。

```swift
func setTodo(_ todo: TodoItem?)
```

---

### ThemeManager

主题管理器(单例)。

```swift
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var colorScheme: ColorScheme? = nil
    @Published var accentColor: Color = .blue
}
```

#### 方法

##### setColorScheme(_:)
设置颜色方案。

```swift
func setColorScheme(_ scheme: ColorScheme?)
```

**参数**:
- `scheme`: `.light` (亮色), `.dark` (暗色), 或 `nil` (跟随系统)

---

### AuthViewModel

认证逻辑。

```swift
@Observable
final class AuthViewModel {
    var isAuthenticated: Bool = false
    var currentUser: User?
    var errorMessage: String?
}
```

#### 方法

##### login(email:password:context:)
邮箱登录。

```swift
func login(
    email: String,
    password: String,
    context: ModelContext
) async throws
```

##### register(username:email:password:context:)
注册新用户。

```swift
func register(
    username: String,
    email: String,
    password: String,
    context: ModelContext
) async throws
```

##### logout()
登出。

```swift
func logout()
```

##### loginWithWechat()
微信登录(占位)。

```swift
func loginWithWechat() async throws
```

---

## 工具类 (Utils)

### Constants

全局常量定义。

#### AppInfo
```swift
enum AppInfo {
    static let name: String
    static let version: String
    static let buildNumber: String
    static let author: String
    static let website: String
    static let email: String
}
```

#### Layout
```swift
enum Layout {
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
    static let smallCornerRadius: CGFloat = 8
    static let mediumCornerRadius: CGFloat = 12
    // ...
}
```

#### TimeConstants
```swift
enum TimeConstants {
    static let pomodoroWork: Int = 25
    static let pomodoroShortBreak: Int = 5
    static let pomodoroLongBreak: Int = 15
}
```

---

### Validators

验证工具类。

```swift
enum Validators {
    static func isValidEmail(_ email: String) -> Bool
    static func isValidPassword(_ password: String) -> Bool
    static func isValidUsername(_ username: String) -> Bool
}
```

#### isValidEmail(_:)
验证邮箱格式。

```swift
static func isValidEmail(_ email: String) -> Bool
```

**返回值**: 符合邮箱格式返回 `true`

#### isValidPassword(_:)
验证密码强度。

```swift
static func isValidPassword(_ password: String) -> Bool
```

**规则**:
- 长度至少 8 位
- 最多 32 位
- 包含字母和数字

**返回值**: 符合规则返回 `true`

#### isValidUsername(_:)
验证用户名格式。

```swift
static func isValidUsername(_ username: String) -> Bool
```

**规则**:
- 3-20 位
- 仅包含字母、数字、下划线

**返回值**: 符合规则返回 `true`

---

### Extensions

#### Date+Extension

```swift
extension Date {
    /// 是否为今天
    var isToday: Bool

    /// 是否为昨天
    var isYesterday: Bool

    /// 是否为本周
    var isThisWeek: Bool

    /// 格式化为字符串
    func formatted(_ format: String) -> String

    /// 相对时间描述,如"刚刚"、"5分钟前"
    var relativeTimeString: String
}
```

#### Color+Extension

```swift
extension Color {
    /// 从十六进制创建颜色
    init(hex: String)

    /// 转换为十六进制字符串
    var hexString: String
}
```

#### View+Extension

```swift
extension View {
    /// 添加卡片样式
    func cardStyle() -> some View

    /// 添加圆角边框
    func roundedBorder(
        color: Color,
        lineWidth: CGFloat
    ) -> some View

    /// 条件修饰符
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View
}
```

---

## Widget 组件

### TodoListWidget

主 Widget 提供者。

```swift
struct TodoListWidget: Widget {
    let kind: String = "TodoListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: TodoTimelineProvider()
        ) { entry in
            // Widget 视图
        }
        .configurationDisplayName("待办列表")
        .description("查看你的待办事项")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
```

---

### WidgetDataProvider

Widget 数据提供者。

```swift
final class WidgetDataProvider {
    static let shared = WidgetDataProvider()

    /// 获取待办列表
    func fetchTodos(limit: Int) -> [TodoItem]

    /// 获取今日待办数量
    func todayTodoCount() -> Int

    /// 获取未完成待办数量
    func uncompletedCount() -> Int
}
```

---

### AddTodoIntent

快速添加待办 Intent。

```swift
struct AddTodoIntent: AppIntent {
    static var title: LocalizedStringResource = "添加待办"

    @Parameter(title: "标题")
    var title: String

    @Parameter(title: "优先级")
    var priority: PriorityEntity?

    func perform() async throws -> some IntentResult
}
```

---

## 使用示例

### 创建待办任务

```swift
let todo = TodoItem(
    title: "完成项目文档",
    itemDescription: "编写 API 参考文档",
    priority: .high,
    dueDate: Date().addingTimeInterval(86400), // 明天
    category: workCategory
)

context.insert(todo)
try? context.save()
```

### 查询待办任务

```swift
@Query(
    filter: #Predicate<TodoItem> { todo in
        !todo.isCompleted && todo.priority == .high
    },
    sort: \TodoItem.dueDate
)
var highPriorityTodos: [TodoItem]
```

### 更新任务状态

```swift
todo.toggleCompletion()
try? context.save()
```

### 添加子任务

```swift
let subtask = Subtask(
    title: "编写模型文档",
    sortOrder: 0
)
subtask.todo = todo
context.insert(subtask)
```

### 启动番茄钟

```swift
pomodoroViewModel.setTodo(selectedTodo)
pomodoroViewModel.start()
```

---

## 数据库查询示例

### 复杂查询

```swift
// 查询本周高优先级未完成任务
@Query(
    filter: #Predicate<TodoItem> { todo in
        !todo.isCompleted &&
        todo.priority == .high &&
        todo.dueDate != nil &&
        todo.dueDate! >= weekStart &&
        todo.dueDate! <= weekEnd
    },
    sort: [
        SortDescriptor(\.priority, order: .reverse),
        SortDescriptor(\.dueDate)
    ]
)
var thisWeekHighPriorityTodos: [TodoItem]
```

### 关系查询

```swift
// 查询某个分类下的所有任务
let category = selectedCategory
let todos = category.todos.filter { !$0.isCompleted }
```

### 聚合查询

```swift
// 统计各优先级任务数量
let highCount = todos.filter { $0.priority == .high }.count
let mediumCount = todos.filter { $0.priority == .medium }.count
let lowCount = todos.filter { $0.priority == .low }.count
```

---

## 错误处理

### 常见错误类型

```swift
enum TodoError: LocalizedError {
    case emptyTitle
    case invalidDate
    case saveFailed
    case deleteFailed
    case categoryNotFound

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "标题不能为空"
        case .invalidDate:
            return "日期格式不正确"
        // ...
        }
    }
}
```

### 使用示例

```swift
do {
    try viewModel.deleteTodo(todo, context: context)
} catch {
    alertMessage = error.localizedDescription
    showAlert = true
}
```

---

## 通知

### 请求通知权限

```swift
UNUserNotificationCenter.current()
    .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            // 权限已授予
        }
    }
```

### 调度本地通知

```swift
let content = UNMutableNotificationContent()
content.title = "任务提醒"
content.body = todo.title
content.sound = .default

let trigger = UNCalendarNotificationTrigger(
    dateMatching: components,
    repeats: false
)

let request = UNNotificationRequest(
    identifier: todo.id.uuidString,
    content: content,
    trigger: trigger
)

UNUserNotificationCenter.current().add(request)
```

---

## 总结

本 API 参考文档涵盖了 TodoList 应用的核心组件和接口。随着应用的发展,文档将持续更新。

如需更多信息,请参考:
- 源代码注释
- 架构设计文档
- 示例代码
