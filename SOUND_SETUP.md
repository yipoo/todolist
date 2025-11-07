# 番茄钟提示音设置指南

## 已完成功能

✅ **音频管理器**（SoundManager）
- 支持播放 MP3、WAV、M4A 格式
- 自动降级到系统声音
- 音量控制
- 音频预加载

✅ **番茄钟集成**
- 工作完成提示音
- 休息完成提示音
- 本地通知支持

## 如何添加提示音文件

### 方案一：使用免费音效（推荐）

1. **下载提示音文件**

推荐的免费音效网站：
- [Freesound](https://freesound.org/) - 需要注册
- [Pixabay](https://pixabay.com/sound-effects/) - 无需注册
- [Zapsplat](https://www.zapsplat.com/) - 需要注册

搜索关键词：
- "bell" - 铃声
- "chime" - 钟声
- "ding" - 叮咚声
- "notification" - 通知音

2. **添加到项目**

在 Xcode 中：
```
1. 在项目导航器中找到 TodoList/Resources/Sounds/ 目录
2. 右键点击 Sounds 文件夹
3. 选择 "Add Files to TodoList"
4. 选择下载的音频文件
5. 确保勾选 "Copy items if needed"
6. 确保勾选 "TodoList" target
```

3. **文件命名**

将下载的文件重命名为以下名称之一：
- `pomodoro_complete.mp3` - 番茄钟完成音效
- `break_complete.mp3` - 休息完成音效

### 方案二：使用系统声音（已实现）

如果没有添加音频文件，应用会自动使用 iOS 系统的 "Tink" 声音（Sound ID: 1306）。

**优点：**
- 无需额外文件
- 已经集成在代码中
- 立即可用

**缺点：**
- 无法自定义
- 声音较短

## 支持的音频格式

- **MP3** - 最常见，兼容性好
- **WAV** - 无损音质，文件较大
- **M4A** - Apple 推荐格式

## 推荐的音效特征

1. **时长：** 1-3 秒
2. **音量：** 适中，不要太刺耳
3. **音调：** 
   - 工作完成：较高音调，积极向上
   - 休息完成：柔和音调，放松舒缓
4. **文件大小：** 小于 100KB

## 测试提示音

添加文件后：

1. 在 Xcode 中运行应用
2. 进入番茄钟页面
3. 开始一个 1 分钟的番茄钟（用于测试）
4. 等待完成，听到提示音表示成功

## 常见问题

### Q: 为什么听不到提示音？

A: 检查以下几点：
1. 手机是否静音
2. 音量是否太小
3. 文件是否正确添加到项目
4. 文件名是否正确
5. 是否在设置中启用了音效

### Q: 可以使用自己录制的声音吗？

A: 可以！只要：
1. 格式为 MP3/WAV/M4A
2. 文件命名正确
3. 添加到 Sounds 目录

### Q: 如何更换提示音？

A: 
1. 在 Xcode 中删除旧的音频文件
2. 添加新的音频文件（保持相同的文件名）
3. Clean Build Folder (Cmd + Shift + K)
4. 重新运行应用

## 代码位置

如需修改音频逻辑，查看以下文件：

- **SoundManager.swift** - 音频管理器
- **PomodoroViewModel.swift** - 番茄钟逻辑（`playCompletionSound()` 方法）

## 临时解决方案

如果暂时没有音频文件，代码已经实现了降级处理：
- 自动使用 iOS 系统声音
- 同时发送本地通知
- 不会影响应用正常使用

## 进阶：添加更多音效

如果想添加更多音效（如滴答声），可以：

1. 在 `SoundManager.swift` 中添加新的音效类型：

```swift
enum SoundType: String {
    case pomodoroComplete = "pomodoro_complete"
    case breakComplete = "break_complete"
    case tick = "tick"  // 滴答声
    case start = "start"  // 开始声
    // 添加更多...
}
```

2. 添加对应的音频文件到 Sounds 目录

3. 在需要的地方调用：

```swift
SoundManager.shared.play(.tick)
```

## 总结

番茄钟提示音功能已经完全实现，包括：

✅ 音频播放管理
✅ 系统声音降级
✅ 本地通知集成
✅ 音量控制
✅ 灵活的音效系统

现在你只需要：
1. 下载喜欢的提示音
2. 添加到项目
3. 享受番茄钟！


