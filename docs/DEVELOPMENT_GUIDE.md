# 开发指南

本文档为 TodoList 应用的开发者提供详细的开发指导。

---

## 目录

- [开发环境设置](#开发环境设置)
- [代码规范](#代码规范)
- [开发流程](#开发流程)
- [调试技巧](#调试技巧)
- [测试指南](#测试指南)
- [常见问题](#常见问题)

---

## 开发环境设置

### 必需工具

1. **macOS Sonoma (14.0+)**
   - 支持最新的 Xcode 和开发工具

2. **Xcode 15.0+**
   - 下载地址: [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835)
   - 或通过 [Apple Developer](https://developer.apple.com/download/)

3. **Command Line Tools**
   ```bash
   xcode-select --install
   ```

### 推荐工具

1. **Git**
   ```bash
   # 检查 Git 版本
   git --version

   # 配置用户信息
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

2. **SwiftLint** (代码规范检查)
   ```bash
   # 使用 Homebrew 安装
   brew install swiftlint
   ```

3. **Charles / Proxyman** (网络调试)
   - 用于调试网络请求(如果添加网络功能)

### 项目设置

1. **克隆仓库**
   ```bash
   git clone https://github.com/yourusername/TodoList.git
   cd TodoList
   ```

2. **打开项目**
   ```bash
   open TodoList.xcodeproj
   ```

3. **配置签名**
   - 在 Xcode 中选择项目
   - 选择 `TodoList` target
   - 进入 `Signing & Capabilities`
   - 选择你的 Team
   - 修改 Bundle Identifier (如需要)

4. **配置 App Group**
   - 确保 App Group ID 正确: `group.com.yipoo.todolist`
   - 主应用和 Widget Extension 都需要配置

5. **配置 Widget Extension**
   - 选择 `WidgetExtension` target
   - 配置相同的 Team 和 App Group

---

## 代码规范

### Swift 代码风格

遵循 [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)。

#### 命名规范

```swift
// ✅ 好的命名
class TodoViewModel { }
var isCompleted: Bool
func addTodo(_ todo: TodoItem)

// ❌ 不好的命名
class ToDoVM { }
var completed: Bool
func add_todo(todo: TodoItem)
```

#### 类型和协议

```swift
// 类名使用大驼峰
class UserProfileViewModel { }

// 协议名使用大驼峰,描述能力的用 -able/-ing 后缀
protocol Validatable { }
protocol NetworkRequesting { }

// 枚举使用大驼峰,case 使用小驼峰
enum Priority {
    case low
    case medium
    case high
}
```

#### 变量和函数

```swift
// 变量使用小驼峰
var userName: String
var isAuthenticated: Bool

// 布尔值使用 is/has/should 前缀
var isCompleted: Bool
var hasSubtasks: Bool
var shouldAutoSave: Bool

// 函数使用小驼峰,动词开头
func fetchTodos()
func updateTodo(_ todo: TodoItem)
func calculateProgress() -> Double
```

#### 注释规范

```swift
/**
 * 待办事项视图模型
 *
 * 负责管理待办事项的业务逻辑,包括:
 * - 数据的增删改查
 * - 筛选和排序
 * - 状态管理
 */
@Observable
final class TodoViewModel {
    // MARK: - 属性

    /// 当前筛选选项
    var filterOption: TodoFilterOption = .all

    // MARK: - 公共方法

    /// 添加新的待办事项
    /// - Parameters:
    ///   - todo: 待办事项对象
    ///   - context: SwiftData 上下文
    func addTodo(_ todo: TodoItem, context: ModelContext) {
        // 实现...
    }

    // MARK: - 私有方法

    /// 验证待办事项数据
    private func validate(_ todo: TodoItem) -> Bool {
        // 实现...
    }
}
```

#### 使用 MARK 组织代码

```swift
class TodoListView: View {
    // MARK: - Properties

    // MARK: - Initialization

    // MARK: - Body

    // MARK: - Private Views

    // MARK: - Methods

    // MARK: - Helpers
}
```

### SwiftUI 视图规范

#### 视图分解

将复杂视图拆分为小组件:

```swift
// ✅ 好的做法 - 视图分解
struct TodoListView: View {
    var body: some View {
        VStack {
            headerView
            todoListContent
            footerView
        }
    }

    private var headerView: some View {
        // 头部视图
    }

    private var todoListContent: some View {
        // 列表内容
    }

    private var footerView: some View {
        // 底部视图
    }
}

// ❌ 不好的做法 - 所有代码在一个 body 里
struct TodoListView: View {
    var body: some View {
        VStack {
            // 100+ 行代码...
        }
    }
}
```

#### 提取子组件

```swift
// 提取为独立组件
struct TodoRow: View {
    let todo: TodoItem

    var body: some View {
        HStack {
            completionButton
            todoContent
            priorityIndicator
        }
    }
}
```

#### 使用 @ViewBuilder

```swift
@ViewBuilder
func content(for state: LoadingState) -> some View {
    switch state {
    case .loading:
        ProgressView()
    case .loaded(let data):
        DataView(data: data)
    case .error(let message):
        ErrorView(message: message)
    }
}
```

### 文件组织

```
Models/
  TodoItem.swift           # 一个文件一个主要类型
  Category.swift
  User.swift

Views/
  Todo/
    TodoListView.swift
    TodoDetailView.swift
    Components/
      TodoRow.swift
      TodoFilters.swift

ViewModels/
  TodoViewModel.swift
  CategoryViewModel.swift
```

---

## 开发流程

### Git 工作流

#### 分支策略

```bash
main              # 主分支,稳定版本
├── develop       # 开发分支
│   ├── feature/xxx  # 功能分支
│   ├── bugfix/xxx   # 修复分支
│   └── refactor/xxx # 重构分支
└── release/x.x.x # 发布分支
```

#### 创建功能分支

```bash
# 从 develop 创建新分支
git checkout develop
git pull origin develop
git checkout -b feature/add-calendar-view

# 开发...

# 提交代码
git add .
git commit -m "feat: add calendar view"

# 推送到远程
git push origin feature/add-calendar-view

# 创建 Pull Request
```

#### 提交消息规范

```bash
# 格式
<type>(<scope>): <subject>

# 类型
feat:     新功能
fix:      Bug 修复
docs:     文档更新
style:    代码格式(不影响代码运行)
refactor: 重构
perf:     性能优化
test:     测试
chore:    构建/工具

# 示例
feat(todo): add subtask support
fix(widget): fix data sync issue
docs(readme): update installation guide
refactor(viewmodel): simplify todo filtering logic
```

### 开发新功能

#### 1. 规划

- 明确需求
- 设计数据模型
- 设计 UI/UX
- 评估技术方案

#### 2. 实现

**步骤 1: 创建数据模型**

```swift
// Models/TaskTemplate.swift
@Model
final class TaskTemplate {
    var id: UUID
    var name: String
    var defaultTitle: String
    var defaultPriority: Priority

    init(name: String, defaultTitle: String, defaultPriority: Priority = .medium) {
        self.id = UUID()
        self.name = name
        self.defaultTitle = defaultTitle
        self.defaultPriority = defaultPriority
    }
}
```

**步骤 2: 创建 ViewModel**

```swift
// ViewModels/TemplateViewModel.swift
@Observable
final class TemplateViewModel {
    var templates: [TaskTemplate] = []

    func addTemplate(_ template: TaskTemplate, context: ModelContext) {
        context.insert(template)
        try? context.save()
    }
}
```

**步骤 3: 创建视图**

```swift
// Views/Template/TemplateListView.swift
struct TemplateListView: View {
    @Environment(\.modelContext) private var context
    @Query var templates: [TaskTemplate]

    var body: some View {
        List(templates) { template in
            TemplateRow(template: template)
        }
        .navigationTitle("模板")
    }
}
```

**步骤 4: 测试**

- 单元测试
- UI 测试
- 手动测试

**步骤 5: 文档**

- 更新 API 文档
- 添加代码注释
- 更新用户文档

#### 3. 代码审查

- 自我审查
- 提交 Pull Request
- 团队审查
- 修改反馈

#### 4. 合并

```bash
# 合并到 develop
git checkout develop
git merge --no-ff feature/add-templates
git push origin develop
```

---

## 调试技巧

### 使用断点

```swift
// 在 Xcode 中设置断点
func addTodo(_ todo: TodoItem, context: ModelContext) {
    context.insert(todo)  // 在此行设置断点
    try? context.save()
}
```

### 打印调试

```swift
// 使用 print
print("Todo count: \(todos.count)")

// 使用 dump (更详细)
dump(todo)

// 使用 debugPrint
debugPrint("Debug info:", todo.id)
```

### 条件断点

在 Xcode 断点上右键 -> Edit Breakpoint:
```swift
// 条件: 仅当 priority 为 high 时暂停
todo.priority == .high
```

### LLDB 命令

```bash
# 打印变量
po todo
po todos.count

# 打印表达式
p todo.title
p todos.filter { $0.isCompleted }

# 继续执行
c

# 单步执行
n

# 进入函数
s
```

### SwiftUI 调试

#### 预览

```swift
#Preview {
    TodoListView()
        .environment(TodoViewModel())
        .modelContainer(previewContainer)
}

#Preview("Empty State") {
    TodoListView()
        .modelContainer(emptyContainer)
}

#Preview("Dark Mode") {
    TodoListView()
        .preferredColorScheme(.dark)
}
```

#### 视图层级

使用 Xcode 的 View Hierarchy Debugger:
- 运行应用
- 点击 Debug View Hierarchy 按钮
- 检查视图层级和布局

#### 布局调试

```swift
// 显示边框
.border(.red)

// 显示背景
.background(.yellow)

// 打印尺寸
.background(GeometryReader { geometry in
    Color.clear.onAppear {
        print("Size: \(geometry.size)")
    }
})
```

### SwiftData 调试

```swift
// 打印 SQL 查询
// 在 Scheme -> Run -> Arguments -> Launch Arguments 添加:
-com.apple.CoreData.SQLDebug 1

// 查询所有数据
let descriptor = FetchDescriptor<TodoItem>()
let todos = try? context.fetch(descriptor)
print("Total todos:", todos?.count ?? 0)
```

### Widget 调试

```swift
// 在 Widget 代码中打印
print("[Widget] Fetching todos...")

// 检查 App Group
let sharedDefaults = UserDefaults(suiteName: "group.com.yipoo.todolist")
print("[Widget] Shared data:", sharedDefaults?.dictionaryRepresentation() ?? [:])
```

---

## 测试指南

### 单元测试

创建测试文件:

```swift
// TodoListTests/TodoViewModelTests.swift
import XCTest
@testable import TodoList

final class TodoViewModelTests: XCTestCase {
    var viewModel: TodoViewModel!
    var context: ModelContext!

    override func setUp() {
        super.setUp()
        // 创建测试上下文
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: TodoItem.self,
            configurations: config
        )
        context = ModelContext(container)
        viewModel = TodoViewModel()
    }

    override func tearDown() {
        viewModel = nil
        context = nil
        super.tearDown()
    }

    func testAddTodo() {
        // Given
        let todo = TodoItem(title: "Test Todo")

        // When
        viewModel.addTodo(todo, context: context)

        // Then
        let descriptor = FetchDescriptor<TodoItem>()
        let todos = try? context.fetch(descriptor)
        XCTAssertEqual(todos?.count, 1)
        XCTAssertEqual(todos?.first?.title, "Test Todo")
    }

    func testFilterTodos() {
        // Given
        let completedTodo = TodoItem(title: "Completed", isCompleted: true)
        let uncompletedTodo = TodoItem(title: "Uncompleted")
        context.insert(completedTodo)
        context.insert(uncompletedTodo)

        // When
        viewModel.filterOption = .completed
        let todos = [completedTodo, uncompletedTodo]
        let filtered = viewModel.filterTodos(todos)

        // Then
        XCTAssertEqual(filtered.count, 1)
        XCTAssertTrue(filtered.first?.isCompleted == true)
    }
}
```

### UI 测试

```swift
// TodoListUITests/TodoListUITests.swift
import XCTest

final class TodoListUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddTodo() {
        // 点击添加按钮
        app.buttons["add_todo_button"].tap()

        // 输入标题
        let titleField = app.textFields["todo_title_field"]
        titleField.tap()
        titleField.typeText("Test Todo")

        // 保存
        app.buttons["save_button"].tap()

        // 验证
        XCTAssertTrue(app.staticTexts["Test Todo"].exists)
    }
}
```

### 性能测试

```swift
func testFetchPerformance() {
    measure {
        // 测试查询性能
        let descriptor = FetchDescriptor<TodoItem>(
            predicate: #Predicate { !$0.isCompleted }
        )
        _ = try? context.fetch(descriptor)
    }
}
```

### Widget 测试

```swift
func testWidgetDataProvider() {
    let provider = WidgetDataProvider.shared
    let todos = provider.fetchTodos(limit: 5)

    XCTAssertLessThanOrEqual(todos.count, 5)
}
```

---

## 常见问题

### 1. SwiftData 相关

**问题**: 数据未保存

```swift
// ❌ 错误 - 忘记调用 save
context.insert(todo)

// ✅ 正确
context.insert(todo)
try? context.save()
```

**问题**: 关系未正确设置

```swift
// ✅ 双向设置关系
subtask.todo = todo
// SwiftData 会自动处理反向关系
```

### 2. SwiftUI 相关

**问题**: 视图未更新

```swift
// ❌ 错误 - 直接修改数组
todos.append(newTodo)

// ✅ 正确 - 使用 SwiftData
context.insert(newTodo)
try? context.save()
// @Query 会自动更新
```

**问题**: 预览崩溃

```swift
// 创建预览容器
@MainActor
let previewContainer: ModelContainer = {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: TodoItem.self,
            configurations: config
        )
        // 添加示例数据
        let context = container.mainContext
        let todo = TodoItem(title: "Sample")
        context.insert(todo)
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()
```

### 3. Widget 相关

**问题**: Widget 数据未同步

- 检查 App Group 配置
- 确认两个 target 使用相同的 Group ID
- 检查数据库路径:

```swift
// 正确的数据库路径
let containerURL = FileManager.default
    .containerURL(forSecurityApplicationGroupIdentifier: "group.com.yipoo.todolist")!
let storeURL = containerURL.appending(path: "TodoList.sqlite")
```

**问题**: Widget 未刷新

```swift
// 手动刷新所有 Widget
WidgetCenter.shared.reloadAllTimelines()

// 刷新特定 Widget
WidgetCenter.shared.reloadTimelines(ofKind: "TodoListWidget")
```

### 4. 性能问题

**问题**: 列表滚动卡顿

```swift
// ✅ 使用 LazyVStack
LazyVStack {
    ForEach(todos) { todo in
        TodoRow(todo: todo)
    }
}

// ✅ 限制查询结果
@Query(
    sort: \TodoItem.createdAt,
    order: .reverse
)
var todos: [TodoItem]

var body: some View {
    List(todos.prefix(100)) { todo in
        // 只显示前 100 条
    }
}
```

---

## 最佳实践

### 1. 代码组织

- 保持文件小而专注
- 使用 MARK 组织代码
- 提取可复用组件
- 避免深层嵌套

### 2. 性能优化

- 使用 `LazyVStack/LazyHStack`
- 限制查询结果数量
- 避免不必要的计算
- 使用 `@State` 缓存计算结果

### 3. 内存管理

- 避免循环引用
- 使用 `[weak self]` 在闭包中
- 及时释放不需要的资源

### 4. 错误处理

- 使用 `Result` 类型
- 提供有意义的错误消息
- 记录错误日志

### 5. 文档

- 为公共 API 添加注释
- 保持 README 更新
- 编写使用示例

---

## 资源链接

### 官方文档
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)

### 社区资源
- [Swift Forums](https://forums.swift.org)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/swiftui)
- [Hacking with Swift](https://www.hackingwithswift.com)

### 工具
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [SwiftLint](https://github.com/realm/SwiftLint)
- [Xcode Templates](https://www.swiftbysundell.com/articles/creating-custom-xcode-templates/)

---

如有其他问题,请查阅项目文档或提交 Issue。
