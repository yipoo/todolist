# Widget 故障排查指南

## 常见错误：SendProcessControlEvent Error

### 错误信息
```
SendProcessControlEvent:toPid: encountered an error: Error Domain=com.apple.dt.deviceprocesscontrolservice Code=8 "Failed to show Widget 'yipoo.TodoList.Widget' error: Error Domain…
```

### 错误原因

这个错误通常发生在以下几种情况：

1. **Widget 首次加载** - 系统缓存问题
2. **Widget 配置错误** - Timeline Provider 返回错误
3. **数据访问问题** - 无法访问 App Group 数据
4. **预览问题** - Xcode Preview 与实际 Widget 不同步

### 解决方案

#### 方案 1：清理并重新安装（最有效）

```bash
# 1. 停止应用
# 2. 在模拟器中删除应用
# 3. 清理构建缓存
xcodebuild clean -scheme TodoList

# 4. 删除 DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData

# 5. 重新编译
xcodebuild -scheme TodoList -destination 'platform=iOS Simulator,name=iPhone 17' build

# 6. 在 Xcode 中重新运行
```

#### 方案 2：重启模拟器

1. 关闭模拟器
2. 在 Xcode 菜单中：`Window > Devices and Simulators`
3. 右键点击模拟器 > `Restart`
4. 重新运行应用

#### 方案 3：删除 Widget 缓存

在模拟器中：
```
设置 > 开发者 > Clear Widget Caches
```

如果没有开发者选项，在终端运行：
```bash
xcrun simctl spawn booted defaults delete com.apple.chronod
xcrun simctl spawn booted killall chronod
```

#### 方案 4：检查 Widget 配置

确保所有 Widget 都有正确的 Provider：

1. **TodoListStaticWidget** - 使用 `TodoWidgetProvider`
2. **QuickAddWidget** - 使用 `QuickAddProvider`

检查 WidgetBundle.swift：
```swift
@main
struct TodoListWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        TodoListStaticWidget()  // ✅
        QuickAddWidget()        // ✅
    }
}
```

#### 方案 5：检查 Timeline Provider

确保每个 Provider 都返回有效的 Entry：

```swift
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let entry = QuickAddEntry(date: Date())
    let timeline = Timeline(entries: [entry], policy: .after(Date()))
    completion(timeline)  // ✅ 必须调用 completion
}
```

## 具体 Widget 问题排查

### QuickAddWidget 问题

#### 症状：Widget 无法显示或崩溃

**检查清单**：
- [ ] URL 创建是否安全（已使用 `if let`）
- [ ] Timeline Provider 是否返回有效数据
- [ ] Widget 视图是否有强制解包

**已修复的问题**：
- ✅ URL 强制解包 → 改为可选绑定
- ✅ 添加了错误状态显示

### TodoListStaticWidget 问题

#### 症状：无法获取今日待办数据

**错误日志**：
```
❌ Widget: 获取今日待办失败: SwiftDataError
```

**已修复的问题**：
- ✅ SwiftData Predicate 强制解包 → 改为内存过滤
- ✅ App Group 配置正确

## 验证 Widget 是否正常工作

### 1. 检查日志

在控制台查找以下日志：

**成功日志**：
```
📂 Widget App Group 容器路径: ...
✅ Widget: SwiftData 容器初始化成功
```

**失败日志**：
```
❌ Widget: 无法获取 App Group 容器
❌ Widget: 无法创建 ModelContainer
❌ Widget: 获取今日待办失败
```

### 2. 测试步骤

#### 测试 TodoListStaticWidget

1. 在主应用中创建今日待办事项
2. 添加 Widget 到主屏幕（小号/中号/大号）
3. 验证显示：
   - ✅ 小号：今日完成率、进度环
   - ✅ 中号：今日待办列表（最多 4 个）
   - ✅ 大号：统计卡片 + 待办列表（最多 6 个）

#### 测试 QuickAddWidget

1. 添加 Widget 到主屏幕（小号/中号）
2. 点击 Widget
3. 预期行为：
   - ⚠️ **如果未配置 URL Scheme**：无响应或显示错误
   - ✅ **如果已配置 URL Scheme**：打开主应用添加页面

### 3. Widget 画廊预览

长按主屏幕 > 点击 "+" > 搜索 "TodoList"

应该看到：
- **待办事项** Widget（3 个预览：小号、中号、大号）
- **快速添加** Widget（2 个预览：小号、中号）

如果看不到，说明 Widget 注册有问题。

## 开发环境问题

### Xcode Preview 不工作

```swift
#Preview(as: .systemSmall) {
    QuickAddWidget()
} timeline: {
    QuickAddEntry(date: Date())
}
```

**常见问题**：
- Preview 需要 iOS 17+ SDK
- Preview 可能不显示 Link 交互
- Preview 中的数据是模拟数据

**解决方案**：
- 使用真机或模拟器测试，不要依赖 Preview
- Preview 仅用于快速查看布局

### 模拟器 vs 真机

| 功能 | 模拟器 | 真机 |
|------|--------|------|
| Widget 显示 | ✅ | ✅ |
| Deep Link | ⚠️ 可能有延迟 | ✅ |
| App Groups | ✅ | ✅ |
| SwiftData | ✅ | ✅ |

## 性能问题

### Widget 刷新太慢

**原因**：
- Timeline 更新策略设置过长
- 数据获取耗时

**解决方案**：

1. **调整刷新频率**：
```swift
// 当前：每 15 分钟
let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!

// 如果需要更频繁：
let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
```

2. **主动刷新**：
```swift
// 在主应用数据更新后
import WidgetKit
WidgetCenter.shared.reloadAllTimelines()
```

3. **优化数据查询**：
- 减少数据库查询
- 缓存常用数据
- 使用索引

### Widget 占用内存过高

**检查点**：
- 是否加载了过多图片
- 是否有内存泄漏
- Timeline entries 是否太多

**建议**：
- 每次 Timeline 只返回 1-5 个 entries
- 不要在 Widget 中加载大图片
- 使用 `atEnd` policy 而非频繁刷新

## 调试技巧

### 1. 启用详细日志

在 WidgetDataProvider.swift 中添加更多日志：

```swift
func getTodayTodos() -> [WidgetTodoItem] {
    print("🔍 Widget: 开始获取今日待办")

    guard let container = createContainer() else {
        print("❌ Widget: 容器创建失败")
        return []
    }

    print("✅ Widget: 容器创建成功")

    // ... 其他代码

    print("📊 Widget: 获取到 \(todos.count) 个今日待办")
    return todos.map { ... }
}
```

### 2. 使用断点

在 Xcode 中：
1. 选择 WidgetExtension scheme
2. 运行 Widget Extension
3. 在代码中设置断点
4. 添加 Widget 触发断点

### 3. 查看 Widget 进程

在终端运行：
```bash
# 查看所有 Widget 进程
xcrun simctl spawn booted ps aux | grep Widget

# 杀死 Widget 进程（强制重启）
xcrun simctl spawn booted killall WidgetExtension
```

## 已知限制

### iOS Widget 技术限制

1. **不支持真正的文本输入** - 这就是为什么 QuickAddWidget 使用 Deep Link
2. **有内存限制** - 每个 Widget ~30MB
3. **有 CPU 限制** - 不能执行长时间任务
4. **网络请求受限** - 建议使用本地数据

### App Groups 限制

1. **需要开发者账号** - 真机测试需要付费账号
2. **标识符必须一致** - 主应用和 Widget 必须使用相同的 App Group
3. **权限问题** - 确保两个 target 都勾选了 App Groups capability

## 检查清单

在添加 Widget 到主屏幕之前，确认：

- [ ] 应用已编译成功（BUILD SUCCEEDED）
- [ ] 应用已安装到模拟器/真机
- [ ] 应用至少运行过一次（创建了数据库）
- [ ] App Groups 配置正确
- [ ] 模型文件已添加到 Widget Extension target
- [ ] Widget 在 WidgetBundle 中注册

## 获取帮助

如果以上方法都无法解决问题，提供以下信息：

1. **完整错误日志**（从控制台复制）
2. **Xcode 版本**
3. **iOS 版本**（模拟器或真机）
4. **操作步骤**（如何重现问题）
5. **截图**（Widget 的显示状态）

---

**更新时间**：2025-11-06
**适用版本**：iOS 17+, Xcode 16+
