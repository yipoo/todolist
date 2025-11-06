# TodoList - 专业的待办事项管理应用

一个功能完整的 iOS 待办事项管理应用，采用 SwiftUI + SwiftData 构建，支持番茄钟、日历视图、Widget 小组件等高级功能。

## 项目特点

- ✅ **完整的用户认证系统**（手机号登录/注册，密码/验证码双模式）
- ✅ **强大的待办管理**（优先级、分类、子任务、标签、筛选、排序、搜索）
- ✅ **番茄钟计时器**（提高专注力，记录工作时长，音效反馈）
- ✅ **统计分析**（完成率、趋势图、优先级分布、分类统计）
- ✅ **个人中心**（头像上传/编辑、个人信息、偏好设置）
- ✅ **主题系统**（浅色/深色/跟随系统，实时切换）
- ✅ **本地数据存储**（SwiftData + Keychain + UserDefaults）
- ⏳ **日历视图**（月历、日视图，直观查看待办）- 待开发
- ⏳ **Widget 小组件**（桌面快捷查看）- 待开发
- ⏳ **iPad 适配**（响应式布局）- 待开发

## 技术栈

- **UI 框架：** SwiftUI (iOS 17+)
- **数据持久化：** SwiftData
- **安全存储：** Keychain
- **用户偏好：** UserDefaults
- **状态管理：** @Observable 宏（iOS 17+）
- **架构模式：** MVVM
- **图片处理：** UIKit + UIImagePickerController
- **Widget：** WidgetKit + App Intents（待实现）
- **通知：** UserNotifications（待实现）

## 项目结构

```
TodoList/
├── App/                  # 应用入口
├── Models/               # 数据模型（SwiftData）
│   ├── User.swift
│   ├── TodoItem.swift
│   ├── Category.swift
│   ├── Subtask.swift
│   ├── PomodoroSession.swift
│   └── PomodoroSettings.swift
├── ViewModels/           # 视图模型（MVVM）
├── Views/                # 视图
│   ├── Auth/            # 认证
│   ├── Todo/            # 待办
│   ├── Calendar/        # 日历
│   ├── Pomodoro/        # 番茄钟
│   ├── Statistics/      # 统计
│   └── Profile/         # 个人中心
├── Widget/               # Widget 扩展
├── Services/             # 服务层
└── Utils/                # 工具类

```

## 核心功能

### 1. 待办事项管理
- 创建、编辑、删除待办
- 设置优先级（高/中/低）
- 分类管理（预设 + 自定义）
- 添加子任务
- 设置截止日期和提醒
- 多维度筛选和排序
- 实时搜索

### 2. 番茄钟
- 可自定义工作/休息时长
- 关联待办事项
- 暂停/恢复功能
- 后台计时支持
- 音效和震动反馈
- 历史记录查看

### 3. 统计分析
- 概览卡片（总任务、完成任务、完成率、今日完成）
- 完成率进度环
- 优先级分布饼图
- 分类统计列表
- 7天完成趋势折线图
- 周统计汇总

### 4. 个人中心
- 头像上传（相机/相册）
- 图片编辑（缩放、平移、圆形裁剪）
- 个人信息编辑（用户名、邮箱）
- 偏好设置
  - 主题切换（浅色/深色/跟随系统）
  - 默认视图（列表/日历）
  - 自动归档设置
- 通知设置
- 分类管理
- 关于页面

### 5. 主题系统
- 三种主题模式（浅色/深色/跟随系统）
- 全局实时切换（无需重启）
- Toast 组件适配浅色/深色模式
- 持久化存储用户偏好

### 6. 日历视图（待开发）
- 月历显示
- 日期标记（有待办的日期）
- 点击查看当天详情
- 快速添加待办到指定日期

### 7. Widget 小组件（待开发）
- 小号：今日待办摘要
- 中号：待办列表
- 大号：完整视图 + 统计
- 支持快速操作

## 开发进度

查看 [PROGRESS.md](./PROGRESS.md) 了解详细进度。

当前进度：**75%** ✅

- [x] 需求分析和设计
- [x] 项目结构搭建
- [x] 核心数据模型
- [x] 常量和工具类
- [x] 服务层（80%，NotificationManager 和 WidgetDataProvider 待开发）
- [x] 认证系统
- [x] 待办功能
- [x] 番茄钟功能
- [x] 统计功能
- [x] 个人中心
- [x] 主题系统
- [ ] 日历功能
- [ ] 通知系统
- [ ] Widget 小组件
- [ ] iPad 适配

## 数据模型

### User（用户）
- 用户名、邮箱、手机号、密码
- 头像图片数据
- 一对多：待办、分类、番茄钟记录

### TodoItem（待办事项）
- 标题、描述
- 优先级（高/中/低）、完成状态
- 截止日期、提醒时间
- 标签数组
- 关联：用户、分类、子任务

### Category（分类）
- 名称、图标、颜色、排序
- 系统预设（工作、生活、学习、健康、购物、旅行）+ 用户自定义

### Subtask（子任务）
- 标题、完成状态
- 关联：父待办事项

### PomodoroSession（番茄钟会话）
- 开始/结束时间
- 会话类型（工作/休息）
- 工作时长、休息时长
- 关联待办事项和用户

### PomodoroSettings（番茄钟设置）
- 工作时长、短休息、长休息
- 循环次数、自动开始
- 音效开关

## 如何使用

### 创建 Xcode 项目

1. 打开 Xcode
2. 创建新的 iOS App 项目
3. 选择 SwiftUI + SwiftData
4. 最低版本：iOS 17.0
5. 将本项目文件导入

### 配置项目

1. **添加权限**（Info.plist）：
   ```xml
   <key>NSUserNotificationsUsageDescription</key>
   <string>需要通知权限来提醒待办事项</string>
   ```

2. **配置 Widget Extension**：
   - File → New → Target → Widget Extension
   - 将 Widget 文件夹中的代码添加到 Widget Target

3. **配置 App Groups**（用于 Widget 共享数据）：
   - Signing & Capabilities
   - 添加 App Groups
   - 创建组：group.com.yourapp.todolist

### 运行项目

```bash
# 选择目标设备（模拟器或真机）
# 点击运行按钮（⌘ + R）
```

## 核心代码示例

### 数据模型定义

```swift
@Model
final class TodoItem {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var priority: Priority
    var dueDate: Date?

    @Relationship(deleteRule: .cascade)
    var subtasks: [Subtask] = []

    var user: User?
    var category: Category?
}
```

### SwiftData 查询

```swift
// 查询今天的待办
@Query(
    filter: #Predicate<TodoItem> { todo in
        Calendar.current.isDateInToday(todo.dueDate ?? Date())
    },
    sort: \\TodoItem.priority
)
var todayTodos: [TodoItem]
```

### 状态管理

```swift
@Observable
final class TodoViewModel {
    var todos: [TodoItem] = []
    var selectedFilter: TodoFilterOption = .all

    func createTodo(_ todo: TodoItem) {
        // 保存逻辑
    }

    func toggleCompletion(_ todo: TodoItem) {
        todo.toggleCompletion()
    }
}
```

## 核心技术实现

### 1. 主题系统实现
```swift
// ThemeManager.swift - 全局主题管理
@Observable
final class ThemeManager {
    static let shared = ThemeManager()
    private let preferences = UserPreferencesManager.shared

    var colorScheme: ColorScheme? {
        currentTheme.systemColorScheme
    }

    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
}

// TodoListApp.swift - 应用主题
ContentView()
    .environment(themeManager)
    .preferredColorScheme(themeManager.colorScheme)
```

### 2. 图片编辑实现
```swift
// ImageCropView.swift - 手势缩放和裁剪
struct ImageCropView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        Image(uiImage: image)
            .scaleEffect(scale)
            .offset(offset)
            .gesture(MagnificationGesture().onChanged { /* zoom */ })
            .simultaneousGesture(DragGesture().onChanged { /* pan */ })
    }

    private func cropImage() {
        // 使用 UIGraphicsImageRenderer 裁剪圆形头像
    }
}
```

### 3. 自定义图表组件
```swift
// PieChartView.swift - 饼图实现
struct PieChartView: View {
    let data: [PieSliceData]

    var body: some View {
        ZStack {
            ForEach(Array(data.enumerated()), id: \.offset) { index, slice in
                PieSlice(
                    startAngle: startAngle(for: index),
                    endAngle: endAngle(for: index),
                    color: slice.color
                )
            }
        }
    }
}
```

## 学习资源

### 项目文档
- [PRD.md](./PRD.md) - 完整的产品需求文档
- [PROGRESS.md](./PROGRESS.md) - 开发进度跟踪

### SwiftUI 学习
- [Apple 官方文档](https://developer.apple.com/documentation/swiftui/)
- [SwiftData 指南](https://developer.apple.com/documentation/swiftdata)

### 相关概念
- **SwiftData：** iOS 17+ 的数据持久化框架，类似 Core Data 但更简单
- **MVVM：** Model-View-ViewModel 架构模式
- **@Observable：** iOS 17+ 的新状态管理方式，替代 ObservableObject
- **@Query：** SwiftData 的查询宏，自动响应数据变化
- **UserDefaults：** 轻量级键值存储，用于用户偏好设置
- **UIGraphicsImageRenderer：** 高质量图片渲染和处理

## 开发建议

### 渐进式开发

1. **Phase 1：** ✅ 认证系统（手机号登录）
2. **Phase 2：** ✅ 基础待办功能（创建、编辑、删除、筛选、排序）
3. **Phase 3：** ✅ 番茄钟功能（计时、设置、历史记录）
4. **Phase 4：** ✅ 统计分析（多图表展示）
5. **Phase 5：** ✅ 个人中心（头像、偏好设置、主题）
6. **Phase 6：** ⏳ 日历视图（待开发）
7. **Phase 7：** ⏳ 通知系统和 Widget（待开发）

### 代码规范

- 使用 `// MARK: -` 分隔代码区块
- 添加详细的中文注释
- 遵循 SwiftUI 命名约定
- 保持视图简洁，复杂逻辑放到 ViewModel

### 性能优化

- 使用 `@Query` 的 `filter` 和 `sort` 参数
- 避免在 `body` 中进行复杂计算
- 使用 `LazyVStack/LazyHStack` 渲染大列表
- Widget 使用 Timeline 减少更新频率

## 项目亮点

### 1. 完整的主题系统
- 支持浅色/深色/跟随系统三种模式
- 全局实时切换，无需重启
- Toast 等组件完全适配
- UserDefaults 持久化存储

### 2. 专业的图片编辑
- 支持相机拍摄和相册选择
- 手势缩放（0.5x-5x）和平移
- 精确的圆形裁剪
- 图片压缩优化（300x300，JPEG 0.7）

### 3. 纯 SwiftUI 图表
- 无第三方依赖
- 饼图/圆环图
- 折线图（带渐变填充）
- 柱状图
- 完全自定义样式

### 4. 番茄钟计时器
- 后台计时支持
- 暂停/恢复功能
- 音效和震动反馈
- 历史记录查看

### 5. MVVM 架构
- @Observable 宏（iOS 17+）
- 清晰的职责分离
- 易于测试和维护
- 详细的中文注释

## 常见问题

### Q: 为什么选择 SwiftData 而不是 Core Data？
A: SwiftData 是 iOS 17+ 的新框架，API 更简洁，类型安全，与 SwiftUI 集成更好。

### Q: 如何实现主题实时切换？
A: 使用 @Observable + preferredColorScheme，配合 ThemeManager 全局管理主题状态。

### Q: 图表组件是如何实现的？
A: 使用 SwiftUI 的 Path、GeometryReader 和数学计算，完全自定义绘制。

### Q: 头像编辑的手势如何处理？
A: 使用 MagnificationGesture 和 DragGesture，通过 simultaneousGesture 组合多个手势。

### Q: Widget 如何访问主应用数据？
A: 使用 App Groups 共享 SwiftData 容器（待实现）。

### Q: 番茄钟如何在后台计时？
A: 记录开始时间，使用时间差计算剩余时间，配合通知提醒。

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 作者

- 基于 SwiftUI 学习项目开发
- 适合作为学习 SwiftUI 的完整案例

## 项目统计

- **Swift 文件：** 50+ 个
- **代码行数：** 11,522 行（含详细注释）
- **开发周期：** 持续开发中
- **完成度：** 75%
- **iOS 版本：** iOS 17.0+
- **架构：** MVVM

## 更新日志

### 2025-11-06
- ✅ 实现完整的统计功能（6个图表组件）
- ✅ 完成个人中心（头像上传/编辑、个人信息、偏好设置）
- ✅ 实现主题系统（浅色/深色/跟随系统）
- ✅ Toast 组件适配浅色/深色模式
- ✅ 修复偏好设置进入时显示 toast 的问题
- ✅ 实现主题切换实时生效

### 历史版本
- ✅ 用户认证系统（手机号登录）
- ✅ 待办管理功能（CRUD + 筛选排序搜索）
- ✅ 番茄钟功能（计时器 + 设置 + 历史记录）

---

**开始你的 SwiftUI 开发之旅！** 🚀
