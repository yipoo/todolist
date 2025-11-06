# Widget 测试指南

## 配置完成状态 ✅

### 已完成的开发任务
- ✅ Widget 三种尺寸视图（小号、中号、大号）
- ✅ App Groups 数据共享配置
- ✅ SwiftData 共享容器集成
- ✅ Widget 数据提供者（WidgetDataProvider）
- ✅ 主应用 DataManager App Groups 支持
- ✅ 编译成功（BUILD SUCCEEDED）

### 当前配置
- **App Group 标识符**: `group.com.yipoo.todolist`
- **SwiftData 配置**: 使用 `groupContainer: .identifier()` 参数
- **Widget 刷新频率**: 每 15 分钟自动更新
- **优先级显示**: 已按要求不在 Widget 中显示

## 运行前必须完成的手动配置

### 1. 添加模型文件到 Widget Extension Target

在 Xcode 中，必须将以下文件添加到 WidgetExtension 的 Target Membership：

**操作步骤：**
1. 在项目导航器中，按住 Cmd 键多选以下文件：
   - `TodoList/Models/User.swift`
   - `TodoList/Models/TodoItem.swift`
   - `TodoList/Models/Category.swift`
   - `TodoList/Models/Subtask.swift`
   - `TodoList/Models/PomodoroSession.swift`

2. 在右侧的 **File Inspector** 面板中找到 **Target Membership**

3. 勾选 **WidgetExtension** 复选框（保持 TodoList 也勾选）

4. 重新编译项目验证没有错误

### 2. 验证 App Groups 配置

确认以下两个 target 都已正确配置 App Groups：

**TodoList target:**
- Xcode → 选择 TodoList target
- Signing & Capabilities → App Groups
- 确保勾选了 `group.com.yipoo.todolist`

**WidgetExtension target:**
- Xcode → 选择 WidgetExtension target
- Signing & Capabilities → App Groups
- 确保勾选了 `group.com.yipoo.todolist`

## 测试步骤

### 第一步：准备测试数据

1. **运行主应用**（真机或模拟器）
   ```bash
   # 如果需要，可以通过命令行运行
   xcodebuild -scheme TodoList -destination 'platform=iOS Simulator,name=iPhone 15' build
   ```

2. **创建测试待办事项**
   - 登录/注册账号
   - 创建至少 5-6 个待办事项
   - **重要**：将截止日期设置为今天
   - 分配不同的分类
   - 完成其中 2-3 个待办

3. **验证数据已保存**
   - 在控制台查看日志：
     ```
     📂 App Group 容器路径: /Users/.../group.com.yipoo.todolist
     ✅ SwiftData 初始化成功（使用 App Group 共享容器）
     ```

### 第二步：添加 Widget 到主屏幕

1. **长按主屏幕** 进入编辑模式
2. **点击左上角 "+" 按钮**
3. **搜索 "TodoList"** 或滚动找到你的应用
4. **选择 Widget 尺寸**：
   - 小号：显示完成统计和进度环
   - 中号：显示最多 4 个今日待办
   - 大号：显示统计卡片 + 最多 6 个今日待办
5. **添加到主屏幕**

### 第三步：验证功能

#### 小号 Widget 应该显示：
- ✅ "今日待办" 标题
- ✅ 圆形进度环（显示完成率）
- ✅ 完成数量 / 总数量（例如：3/10）
- ✅ 渐变背景（蓝色到紫色）

#### 中号 Widget 应该显示：
- ✅ "今日待办" 标题和日期
- ✅ 完成率百分比条
- ✅ 最多 4 个今日待办事项
- ✅ 每个待办显示：
  - 完成状态图标（圆圈或打勾）
  - 标题
  - 分类标签（如果有）
- ✅ 如果超过 4 个，显示 "还有 N 个待办..."

#### 大号 Widget 应该显示：
- ✅ "待办事项" 标题和日期
- ✅ 4 个统计卡片：
  - 总任务数（蓝色）
  - 已完成数（绿色）
  - 今日完成数（橙色）
  - 完成率进度环（紫色）
- ✅ 最多 6 个今日待办列表
- ✅ 如果超过 6 个，显示 "还有 N 个待办..."

### 第四步：测试数据同步

1. **在主应用中创建新的今日待办**
2. **等待最多 15 分钟**（Widget 自动刷新周期）
3. **或强制刷新**：
   - 删除 Widget 并重新添加
   - 或等待系统自动刷新
4. **验证 Widget 显示新数据**

## 故障排查

### Widget 显示空数据或占位符

**可能原因 1**: 没有今日待办
- **解决方案**: 确保创建的待办事项截止日期是今天

**可能原因 2**: App Groups 配置不正确
- **检查**: 两个 target 的 App Groups 标识符必须完全一致
- **验证**: 查看控制台日志是否有错误

**可能原因 3**: 模型文件未添加到 Widget Extension
- **解决方案**: 按照上面的步骤添加 Target Membership
- **验证**: 重新编译，不应该有 "cannot find type" 错误

### Widget 显示 "❌ Widget: 无法获取 App Group 容器"

**原因**: App Groups 未正确配置
- **检查 1**: 确认 App Groups capability 已添加
- **检查 2**: 确认标识符拼写正确：`group.com.yipoo.todolist`
- **检查 3**: 确认你的 Apple Developer 账号有权限创建 App Groups

### Widget 显示 "❌ Widget: 无法创建 ModelContainer"

**原因**: SwiftData 配置问题或模型文件未共享
- **检查 1**: 所有模型文件都添加到 WidgetExtension target
- **检查 2**: 检查控制台的详细错误信息
- **解决方案**: 删除应用并重新安装，清除旧数据

### Widget 显示旧数据

**原因**: Widget 时间线未更新
- **解决方案 1**: 删除 Widget 并重新添加
- **解决方案 2**: 等待 15 分钟自动刷新
- **未来优化**: 可以在主应用数据更新时调用：
  ```swift
  import WidgetKit
  WidgetCenter.shared.reloadAllTimelines()
  ```

## 控制台日志参考

### 主应用启动成功日志：
```
📂 App Group 容器路径: /Users/.../Library/Group Containers/group.com.yipoo.todolist
✅ SwiftData 初始化成功（使用 App Group 共享容器）
```

### Widget 刷新成功日志：
```
📂 Widget App Group 容器路径: /Users/.../Library/Group Containers/group.com.yipoo.todolist
✅ Widget: SwiftData 容器初始化成功
```

### 如果看到错误：
```
❌ Widget: 无法获取 App Group 容器
```
→ 检查 App Groups 配置

```
❌ Widget: 无法创建 ModelContainer: ...
```
→ 检查模型文件 Target Membership

```
❌ Widget: 获取今日待办失败: ...
```
→ 检查数据库中是否有今日待办事项

## 性能优化建议

### 当前实现特点：
- ✅ Widget 每次刷新都会重新创建 ModelContainer
- ✅ 只查询今日待办，数据量小
- ✅ 使用 @MainActor 确保主线程操作
- ✅ 错误处理返回空数据而非崩溃

### 未来优化方向：
1. **主动刷新**: 在主应用数据更新时调用 `WidgetCenter.shared.reloadAllTimelines()`
2. **后台刷新**: 使用 Background Tasks 更新 Widget
3. **缓存优化**: 考虑缓存 ModelContainer 实例（需要测试内存占用）

## 文件清单

### Widget Extension 文件：
- `Widget/TodoListWidget.swift` - 主 Widget 配置
- `Widget/WidgetDataProvider.swift` - 数据提供者
- `Widget/SmallWidgetView.swift` - 小号视图
- `Widget/MediumWidgetView.swift` - 中号视图
- `Widget/LargeWidgetView.swift` - 大号视图
- `Widget/WidgetBundle.swift` - Widget 入口

### 主应用修改的文件：
- `TodoList/Services/DataManager.swift` - 添加 App Groups 支持

### 文档文件：
- `Widget/WIDGET_SETUP.md` - 配置说明
- `Widget/WIDGET_TESTING_GUIDE.md` - 本测试指南

## 测试检查清单

测试前请确认：
- [ ] 已将 5 个模型文件添加到 WidgetExtension target
- [ ] 两个 target 都配置了相同的 App Groups
- [ ] 项目编译成功无错误
- [ ] 主应用可以正常创建待办事项

测试时请验证：
- [ ] 小号 Widget 显示统计数据
- [ ] 中号 Widget 显示待办列表
- [ ] 大号 Widget 显示统计 + 列表
- [ ] 完成状态图标正确显示
- [ ] 分类标签正确显示
- [ ] 数据在主应用更新后能同步到 Widget

## 需要帮助？

如果遇到问题，请提供以下信息：
1. 控制台日志（特别是带 ❌ 或 ✅ 的日志）
2. Widget 当前显示的内容（可以截图）
3. 主应用中待办事项的数量和截止日期
4. 使用的测试设备（真机/模拟器，iOS 版本）

祝测试顺利！🎉
