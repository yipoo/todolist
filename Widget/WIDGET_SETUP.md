# Widget 配置说明

## App Groups 配置

### 1. 主应用配置
1. 在 Xcode 中选择 **TodoList** target
2. 进入 **Signing & Capabilities**
3. 点击 **+ Capability**
4. 添加 **App Groups**
5. 勾选或创建：`group.com.yipoo.todolist`

### 2. Widget Extension 配置
1. 在 Xcode 中选择 **WidgetExtension** target
2. 进入 **Signing & Capabilities**
3. 点击 **+ Capability**
4. 添加 **App Groups**
5. 勾选相同的：`group.com.yipoo.todolist`

## 模型文件共享配置

Widget Extension 需要访问主应用的数据模型文件。

### 添加到 Widget Extension Target

在 Xcode 中，为以下文件添加 Widget Extension 的 Target Membership：

**Models 文件夹：**
- ✅ `User.swift`
- ✅ `TodoItem.swift`
- ✅ `Category.swift`
- ✅ `Subtask.swift`
- ✅ `PomodoroSession.swift`

**操作步骤：**
1. 在项目导航器中选中文件（可以多选）
2. 在右侧的 **File Inspector** 中找到 **Target Membership**
3. 勾选 **WidgetExtension** 复选框

## 验证配置

### 1. 清理构建
```bash
xcodebuild clean -scheme TodoList
```

### 2. 重新构建
```bash
xcodebuild -scheme TodoList build
```

### 3. 运行应用
- 在模拟器或真机上运行应用
- 创建一些待办事项
- 长按主屏幕添加 Widget
- 验证 Widget 能正确显示数据

## 数据流

```
主应用 (TodoList)
    ↓
SwiftData Container (App Group)
    ↓
Widget Extension (读取数据)
    ↓
Widget UI (显示)
```

## 数据更新

- Widget 每 15 分钟自动刷新
- 主应用数据更新后，Widget 会在下次刷新时显示新数据
- 可以通过 `WidgetCenter.shared.reloadAllTimelines()` 强制刷新

## 注意事项

1. **App Group 标识符必须一致**
   - 主应用：`group.com.yipoo.todolist`
   - Widget Extension：`group.com.yipoo.todolist`

2. **数据库文件位置**
   - 存储在 App Group 共享容器中
   - 路径：`~/Library/Group Containers/group.com.yipoo.todolist/TodoList.sqlite`

3. **Widget 限制**
   - 不展示优先级（简化设计）
   - 最多显示今日待办
   - 小号：统计概览
   - 中号：4 个待办
   - 大号：6 个待办 + 统计

## 故障排查

### Widget 不显示数据
1. 检查 App Groups 配置是否正确
2. 检查模型文件是否添加到 Widget Extension
3. 检查控制台日志，查找错误信息
4. 尝试删除应用并重新安装

### 编译错误
- `cannot find type 'TodoItem' in scope`
  → 需要将模型文件添加到 Widget Extension Target

- `无法获取 App Group 容器`
  → 检查 App Groups 配置，确保标识符正确
