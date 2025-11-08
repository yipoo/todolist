# 悬浮麦克风按钮 - 实现说明

## 🎯 实现目标

将麦克风按钮从快捷添加视图中独立出来,实现为悬浮操作按钮(FAB),类似于右上角的 + 按钮。

## 📐 架构设计

### 状态管理

采用**状态提升**模式:

```
TodoListView (父组件)
    ├── speechRecognizer @State        // 语音识别状态
    ├── QuickAddTodoView              // 接收 binding
    │   └── @Binding speechRecognizer  // 监听识别文本
    └── floatingMicButton             // 控制录音开关
```

**优势:**
- 单一数据源 - speechRecognizer 在 TodoListView 中管理
- 组件解耦 - QuickAddTodoView 只负责显示和接收识别文本
- 控制集中 - 悬浮按钮直接控制语音识别状态

## 🔧 实现细节

### 1. TodoListView.swift

#### 添加状态管理

```swift
// 在 TodoListView 中添加
@State private var speechRecognizer = SpeechRecognitionManager()
```

#### 传递 Binding 到子组件

```swift
QuickAddTodoView(
    todoViewModel: todoViewModel,
    authViewModel: authViewModel,
    speechRecognizer: $speechRecognizer,  // 传递 binding
    onSave: { }
)
```

#### 悬浮麦克风按钮

```swift
private var floatingMicButton: some View {
    Button(action: {
        toggleSpeechRecognition()
    }) {
        ZStack {
            // 背景阴影
            Circle()
                .fill(Color(.systemBackground))
                .frame(width: 60, height: 60)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)

            // 录音中的脉动光晕
            if speechRecognizer.isRecording {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 56, height: 56)
                    .scaleEffect(speechRecognizer.isRecording ? 1.3 : 1.0)
                    .opacity(speechRecognizer.isRecording ? 0.5 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                        value: speechRecognizer.isRecording
                    )
            }

            // 麦克风图标
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(speechRecognizer.isRecording ? .red : .orange)
        }
    }
}
```

#### 语音识别控制

```swift
private func toggleSpeechRecognition() {
    // 触觉反馈
    #if os(iOS)
    let impact = UIImpactFeedbackGenerator(style: .medium)
    impact.impactOccurred()
    #endif

    if speechRecognizer.isRecording {
        speechRecognizer.stopRecording()
    } else {
        startSpeechRecognition()
    }
}

private func startSpeechRecognition() {
    Task {
        let granted = await speechRecognizer.requestPermission()
        guard granted else { return }

        do {
            try speechRecognizer.startRecording { recognizedText in
                // 文字通过 speechRecognizer.recognizedText 自动更新
            }
        } catch {
            print("启动语音识别失败: \(error)")
        }
    }
}
```

### 2. QuickAddTodoView.swift

#### 接收 Binding

```swift
struct QuickAddTodoView: View {
    // 从外部传入（不再自己创建）
    @Binding var speechRecognizer: SpeechRecognitionManager

    init(
        todoViewModel: TodoViewModel,
        authViewModel: AuthViewModel,
        speechRecognizer: Binding<SpeechRecognitionManager>,  // 接收 binding
        onSave: @escaping () -> Void
    ) {
        self.todoViewModel = todoViewModel
        self.onSave = onSave
        _speechRecognizer = speechRecognizer  // 绑定
        _categoryViewModel = State(initialValue: CategoryViewModel(authViewModel: authViewModel))
    }
}
```

#### 监听识别文本

```swift
.onChange(of: speechRecognizer.recognizedText) { _, newValue in
    if !newValue.isEmpty && speechRecognizer.isRecording {
        inputText = newValue  // 实时更新输入框
    }
}
```

#### 发送时停止录音

```swift
private func handleSend() {
    // 如果正在录音，先停止
    if speechRecognizer.isRecording {
        speechRecognizer.stopRecording()
    }

    // 保存 Todo
    saveTodo()
}
```

#### 移除的代码

- ❌ 移除 `@State var speechRecognizer` (改为 `@Binding`)
- ❌ 移除 `toggleSpeechRecognition()` 方法
- ❌ 移除 `startSpeechRecognition()` 方法
- ❌ 移除权限提示相关代码

## 🎨 视觉效果

### 默认状态（待机）

```
┌────────────────┐
│      🎤        │  ← 橙色，56pt
│   (orange)     │
└────────────────┘
```

### 录音状态

```
┌────────────────┐
│   ⭕️ (脉动)   │  ← 红色光晕，动画
│      🎤        │  ← 红色，56pt
│    (red)       │
└────────────────┘
```

**动画参数:**
- 光晕初始透明度: 0.2
- 光晕脉动透明度: 0.5
- 缩放比例: 1.0 → 1.3
- 动画时长: 0.8秒
- 循环模式: 无限往返

## 🔄 交互流程

### 完整流程

```
1. 用户点击悬浮麦克风
   ↓
2. 触觉反馈 (iOS)
   ↓
3. TodoListView.toggleSpeechRecognition()
   ↓
4. 请求权限（首次）
   ↓
5. 开始录音
   ↓
6. 麦克风变红 + 光晕动画
   ↓
7. speechRecognizer.recognizedText 更新
   ↓
8. QuickAddTodoView 监听到变化
   ↓
9. inputText 自动更新
   ↓
10. NLP 解析提取时间/优先级
   ↓
11. 用户再次点击麦克风或点击发送
   ↓
12. 停止录音 + 保存 Todo
```

### 数据流

```
用户说话
    ↓
SpeechRecognizer.recognizedText (Observable)
    ↓
QuickAddTodoView.inputText (onChange)
    ↓
NaturalLanguageParser.parse()
    ↓
parsedInfo (时间、优先级)
    ↓
界面更新（第二行显示）
```

## 📍 布局位置

```
┌──────────────────────────────┐
│  待办列表                     │
│                              │
│  ┌────────────────┐          │
│  │ Todo 1         │          │
│  └────────────────┘          │
│                              │
│  ┌────────────────┐          │
│  │ Todo 2         │          │
│  └────────────────┘          │
│                              │
│                              │
│                        🎤    │ ← 悬浮麦克风
│  ┌───────────────┬──┐       │    (右下角)
│  │ 输入框...     │⬆️│       │ ← 快捷添加
│  └───────────────┴──┘       │
└──────────────────────────────┘
```

**定位参数:**
- `.padding(.trailing, 20)` - 距离右边缘 20pt
- `.padding(.bottom, 90)` - 距离底部 90pt (在快捷添加上方)

## ✅ 优势总结

### 1. 架构优势

- ✅ **单一数据源** - speechRecognizer 集中管理
- ✅ **组件解耦** - 各组件职责明确
- ✅ **易于测试** - 状态独立可测试

### 2. 交互优势

- ✅ **位置突出** - 悬浮在右下角，易于点击
- ✅ **状态清晰** - 颜色 + 动画清楚表达录音状态
- ✅ **触觉反馈** - 增强操作确认感

### 3. 功能优势

- ✅ **智能停止** - 点击发送自动停止录音
- ✅ **实时更新** - 识别文字即时显示
- ✅ **NLP 解析** - 自动提取时间和优先级

## 🎯 与原设计对比

| 项目 | 原设计 | 新设计 |
|------|--------|--------|
| 麦克风位置 | QuickAddTodoView 内部 | TodoListView 悬浮 |
| 状态管理 | QuickAddTodoView 内部 | TodoListView (提升) |
| 按钮样式 | 行内按钮 | 悬浮操作按钮 (FAB) |
| 录音控制 | 内部方法 | 父组件控制 |
| 文字更新 | 直接设置 | Binding + onChange |
| 视觉占用 | 占用第一行空间 | 不占用布局空间 |

## 🔧 技术要点

### Observable + Binding

```swift
// SpeechRecognitionManager 是 @Observable
@Observable
@MainActor
final class SpeechRecognitionManager: NSObject {
    var isRecording = false
    var recognizedText = ""
}

// TodoListView 持有 @State
@State private var speechRecognizer = SpeechRecognitionManager()

// QuickAddTodoView 接收 @Binding
@Binding var speechRecognizer: SpeechRecognitionManager
```

### 平台兼容

```swift
#if os(iOS)
let impact = UIImpactFeedbackGenerator(style: .medium)
impact.impactOccurred()
#endif
```

### 条件渲染

```swift
// 只在录音时显示光晕
if speechRecognizer.isRecording {
    Circle()
        .fill(Color.red.opacity(0.2))
        // ...
}
```

## 📝 后续优化建议

1. **权限提示优化**
   - 添加 Alert 显示权限被拒原因
   - 提供跳转到设置的按钮

2. **错误处理**
   - 显示录音启动失败提示
   - 显示识别错误信息

3. **动画优化**
   - 添加麦克风按钮显示/隐藏动画
   - 优化光晕动画性能

4. **可访问性**
   - 添加 VoiceOver 支持
   - 添加动态字体支持

---

## 🎉 总结

通过状态提升和悬浮按钮设计,实现了麦克风功能的独立和复用,同时保持了与快捷添加视图的紧密协作。整体架构清晰,交互流畅,符合 Material Design 的 FAB 设计规范。
