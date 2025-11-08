# 语音识别功能配置指南

## 概述
本项目已集成语音识别功能，用户可以通过语音输入快速创建待办事项。使用了 Apple 的 Speech Framework 和 AVFoundation。

## 配置步骤

### 1. 添加权限说明到 Info.plist

需要在 Xcode 项目中添加以下权限说明：

#### 方法一：通过 Xcode 界面添加

1. 在 Xcode 中选择项目的 `TodoList` target
2. 选择 `Info` 标签页
3. 点击 `+` 按钮添加以下两个键值对：

**麦克风权限：**
- Key: `Privacy - Microphone Usage Description`
- Value: `需要使用麦克风进行语音输入待办事项`

**语音识别权限：**
- Key: `Privacy - Speech Recognition Usage Description`
- Value: `需要使用语音识别功能将语音转换为文字`

#### 方法二：直接编辑 Info.plist 文件

如果项目有独立的 Info.plist 文件，添加以下内容：

```xml
<key>NSMicrophoneUsageDescription</key>
<string>需要使用麦克风进行语音输入待办事项</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>需要使用语音识别功能将语音转换为文字</string>
```

### 2. 确保 Capabilities 配置

虽然语音识别不需要特殊的 Capability，但请确保：

1. 在 Xcode 中选择 `TodoList` target
2. 选择 `Signing & Capabilities` 标签
3. 确保已正确配置 Team 和 Bundle Identifier

### 3. 测试设备要求

- iOS 17.0 或更高版本
- 真机测试（模拟器可能不支持麦克风）
- 网络连接（语音识别需要联网）

## 使用说明

### 用户使用流程

1. **首次使用**：
   - 点击快捷添加区域的麦克风图标
   - 系统会弹出权限请求对话框（两次：麦克风 + 语音识别）
   - 点击"允许"授予权限

2. **语音输入**：
   - 点击麦克风图标开始录音（图标变红并有动画）
   - 说出待办内容，例如："明天早上9点去图书馆"
   - 系统实时显示识别的文字
   - 点击"完成"按钮停止录音

3. **智能解析**：
   - 系统自动从语音文本中提取时间、优先级等信息
   - 显示识别到的时间（如："✨ 识别到: 明天早上"）
   - 用户可以手动调整识别结果

### 支持的语音命令示例

**时间相关：**
- "明天早上9点开会"
- "下周一下午3点交报告"
- "后天中午吃饭"
- "12月25日晚上看电影"

**优先级：**
- "紧急：完成项目方案"
- "高优先级：联系客户"
- "不急：整理书架"

## 技术实现

### 核心组件

1. **SpeechRecognitionManager.swift**
   - 封装了 Speech Framework 的使用
   - 处理权限请求
   - 管理录音和识别流程
   - 提供实时识别回调

2. **NaturalLanguageParser.swift**
   - 解析自然语言文本
   - 提取时间、日期、优先级
   - 智能清理文本

3. **QuickAddTodoView.swift**
   - 集成语音输入 UI
   - 显示录音状态
   - 实时更新识别结果

### 语音识别流程

```
用户点击麦克风
    ↓
检查/请求权限
    ↓
开始录音（AVAudioEngine）
    ↓
实时语音识别（SFSpeechRecognizer）
    ↓
更新 UI 显示识别文本
    ↓
用户点击完成/自动结束
    ↓
停止录音和识别
    ↓
NLP 解析文本
    ↓
创建待办事项
```

## 故障排查

### 常见问题

**1. 权限被拒绝**
- 解决：引导用户前往"设置 > TodoList > 麦克风/语音识别"开启权限
- 应用会自动显示提示对话框

**2. 识别不准确**
- 确保网络连接良好
- 在安静环境下使用
- 清晰地说出内容

**3. 无法启动录音**
- 检查设备是否支持语音识别
- 确保 iOS 版本 >= 17.0
- 在真机上测试（模拟器可能不支持）

**4. 语音识别服务不可用**
- 检查网络连接
- 确认设备地区和语言设置
- 稍后重试

## 隐私说明

- 语音数据仅用于转换为文字
- 不会保存或上传录音文件
- 使用 Apple 的语音识别服务（符合隐私政策）
- 可选择设备端识别（iOS 13+，更快更隐私）

## 开发注意事项

### 权限处理最佳实践

1. **首次请求**：在用户明确操作时请求（点击麦克风）
2. **权限被拒绝**：提供清晰的引导去设置开启
3. **错误处理**：捕获并显示友好的错误信息
4. **状态管理**：正确管理录音状态，避免资源泄漏

### 性能优化

1. 使用 `@Observable` 管理状态，避免不必要的重绘
2. 录音完成后及时释放资源
3. 合理设置音频缓冲区大小（1024）
4. 支持设备端识别以提高响应速度

### 测试清单

- [ ] 首次权限请求流程
- [ ] 权限被拒绝后的引导流程
- [ ] 录音开始/停止状态切换
- [ ] 实时识别文本更新
- [ ] 错误情况处理
- [ ] 多种语音命令格式
- [ ] 与其他功能的集成

## 更新日志

### v1.0.0 (2025-01-08)
- ✅ 集成 Speech Framework
- ✅ 实现实时语音识别
- ✅ 添加智能 NLP 解析
- ✅ 完善 UI 状态反馈
- ✅ 权限管理和错误处理

## 参考资料

- [Apple Speech Framework Documentation](https://developer.apple.com/documentation/speech)
- [AVFoundation Audio Recording](https://developer.apple.com/documentation/avfoundation)
- [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)
