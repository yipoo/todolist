# 快速测试番茄钟提示音

## 立即测试（无需下载音频）

番茄钟提示音功能已经可以使用了！即使没有添加自定义音频文件，应用也会自动使用 iOS 系统声音。

### 测试步骤：

1. **运行应用**
   ```bash
   在 Xcode 中按 Cmd + R 运行应用
   ```

2. **进入番茄钟**
   - 点击底部 Tab Bar 的"番茄钟"
   
3. **开始测试**
   - 滑动到 1 分钟预设（用于快速测试）
   - 点击"开始"按钮
   - 等待 1 分钟

4. **验证结果**
   - ✅ 听到提示音（系统 Tink 声音）
   - ✅ 看到本地通知
   - ✅ 自动切换到休息模式

## 推荐的免费音效下载

### 选项 1：使用以下直接链接（免登录）

**番茄钟完成音效：**
```
名称：Success Bell
网站：Pixabay
链接：https://pixabay.com/sound-effects/success-bell-6776/
特点：清脆的铃声，1.5秒，适合工作完成
```

**休息完成音效：**
```
名称：Soft Chime
网站：Pixabay  
链接：https://pixabay.com/sound-effects/soft-notification-6369/
特点：柔和的提示音，2秒，适合休息结束
```

### 选项 2：使用我推荐的关键词搜索

在 [Pixabay](https://pixabay.com/sound-effects/) 搜索：
- "success bell" - 成功铃声
- "soft chime" - 柔和钟声
- "gentle notification" - 轻柔通知

### 下载和添加步骤（详细）

1. **下载音效**
   - 点击上面的链接
   - 点击"Free Download"
   - 选择 MP3 格式（推荐）

2. **重命名文件**
   ```
   下载后的文件重命名为：
   - pomodoro_complete.mp3  （番茄钟完成）
   - break_complete.mp3     （休息完成）
   ```

3. **添加到 Xcode 项目**
   
   a. 确保 Sounds 目录存在：
   ```
   TodoList/Resources/Sounds/
   ```
   
   b. 在 Xcode 中：
   - 右键点击 `TodoList/Resources/Sounds` 目录
   - 选择 "Add Files to 'TodoList'..."
   - 选择你重命名后的文件
   - 确保勾选：
     ☑️ Copy items if needed
     ☑️ TodoList (在 Add to targets 中)
   - 点击 "Add"

4. **验证添加成功**
   - 在项目导航器中应该能看到：
     ```
     TodoList/
       Resources/
         Sounds/
           pomodoro_complete.mp3
           break_complete.mp3
     ```

5. **Clean 和重新构建**
   ```
   1. Product -> Clean Build Folder (Cmd + Shift + K)
   2. Product -> Build (Cmd + B)
   3. Product -> Run (Cmd + R)
   ```

6. **测试自定义音效**
   - 开始一个 1 分钟番茄钟
   - 等待完成
   - 应该听到你的自定义音效！

## 音效文件规格建议

| 属性 | 推荐值 |
|------|--------|
| 格式 | MP3 |
| 比特率 | 128 kbps |
| 采样率 | 44.1 kHz |
| 时长 | 1-3 秒 |
| 文件大小 | < 100 KB |

## 故障排除

### 问题 1：听不到声音

**检查清单：**
- [ ] 手机没有静音
- [ ] 音量足够大
- [ ] 文件名正确（不要多空格或错误的扩展名）
- [ ] 文件已添加到 TodoList target
- [ ] 已经 Clean Build

**解决方法：**
```swift
// 如果还是不行，可以在 SoundManager.swift 中添加调试日志
print("Attempting to play sound: \(type.filename)")
print("Sound URL: \(url?.absoluteString ?? "not found")")
```

### 问题 2：找不到 Sounds 目录

**创建目录：**
1. 在 Finder 中创建 `TodoList/Resources/Sounds` 目录
2. 在 Xcode 中右键项目根目录
3. New Group -> 命名为 "Resources"
4. 右键 Resources -> New Group -> 命名为 "Sounds"

### 问题 3：文件添加了但不播放

**检查 target 成员关系：**
1. 选中音频文件
2. 查看右侧的 File Inspector
3. 确保 "Target Membership" 中勾选了 "TodoList"

## 快速命令

```bash
# 如果你有音频文件在下载文件夹
# 1. 重命名
cd ~/Downloads
mv downloaded_sound_1.mp3 pomodoro_complete.mp3
mv downloaded_sound_2.mp3 break_complete.mp3

# 2. 复制到项目（替换路径）
cp pomodoro_complete.mp3 /path/to/TodoList/TodoList/Resources/Sounds/
cp break_complete.mp3 /path/to/TodoList/TodoList/Resources/Sounds/
```

## 验证成功的标志

✅ **成功标志：**
1. 番茄钟完成时听到声音
2. 控制台没有"Sound file not found"错误
3. 声音清晰，不失真
4. 音量适中

❌ **失败标志：**
1. 只听到系统默认声音（Tink）
2. 完全没有声音
3. 控制台有错误日志

## 推荐的测试流程

1. **第一次测试**（系统声音）
   - 不添加任何文件
   - 运行应用
   - 验证系统声音播放正常

2. **第二次测试**（自定义音效）
   - 添加 pomodoro_complete.mp3
   - Clean Build
   - 运行应用
   - 验证自定义音效

3. **第三次测试**（完整体验）
   - 添加所有音效文件
   - 测试工作 -> 短休息 -> 工作 -> 长休息
   - 验证所有场景

## 需要帮助？

如果遇到问题，检查以下文件中的实现：

1. **SoundManager.swift** - 音频播放逻辑
2. **PomodoroViewModel.swift** - 番茄钟完成回调
3. **AudioSession** 配置是否正确

## 总结

番茄钟提示音功能完全可用：
- ✅ 不需要任何音频文件即可运行（使用系统声音）
- ✅ 支持自定义音效
- ✅ 自动降级处理
- ✅ 本地通知已集成

现在就可以测试！🎉


