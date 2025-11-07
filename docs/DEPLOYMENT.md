# TodoList 部署指南

## 目录

1. [真机测试部署](#真机测试部署)
2. [App Store 发布准备](#app-store-发布准备)
3. [证书和配置文件](#证书和配置文件)
4. [App Groups 真机配置](#app-groups-真机配置)
5. [Widget 真机调试](#widget-真机调试)
6. [版本管理建议](#版本管理建议)

---

## 真机测试部署

### 1. 前置要求

**必需：**
- ✅ Mac 电脑（macOS 14.0+）
- ✅ Xcode 15.0+
- ✅ iPhone/iPad 设备（iOS 17.0+）
- ✅ Apple ID（免费或付费账号）
- ✅ Lightning/USB-C 数据线

**可选：**
- Apple Developer Program 会员（$99/年）
  - 免费账号：可以真机调试，但有限制
  - 付费账号：完整功能，可发布到 App Store

---

### 2. 设备准备

#### 2.1 连接设备

1. 使用数据线连接 iPhone 到 Mac
2. iPhone 上信任此电脑：
   - 弹出提示"信任此电脑？"
   - 点击"信任"
   - 输入 iPhone 密码确认

3. 在 Xcode 中验证设备：
   - Xcode 顶部设备选择器
   - 应该显示你的 iPhone 名称（如"丁磊的 iPhone"）

#### 2.2 启用开发者模式（iOS 16+）

iOS 16+ 需要手动启用开发者模式：

1. iPhone 上打开 **设置**
2. **隐私与安全** → **开发者模式**
3. 打开 **开发者模式**
4. 重启 iPhone
5. 重启后确认启用

**验证：**
- 设置中显示"开发者模式已启用"

---

### 3. Xcode 配置

#### 3.1 添加 Apple ID

1. 打开 Xcode
2. **Xcode → Preferences → Accounts**
3. 点击左下角 **+** 按钮
4. 选择 **Apple ID**
5. 输入你的 Apple ID 和密码
6. 点击 **Continue**

#### 3.2 配置签名（主应用）

1. 在 Xcode 中打开项目
2. 选择 **TodoList** target
3. 进入 **Signing & Capabilities**
4. 勾选 **Automatically manage signing**
5. 选择 **Team**（你的 Apple ID）
6. 修改 **Bundle Identifier**（如果已被使用）
   - 示例：`com.yourname.todolist`
   - 必须全局唯一

#### 3.3 配置签名（Widget Extension）

1. 选择 **WidgetExtension** target
2. 进入 **Signing & Capabilities**
3. 勾选 **Automatically manage signing**
4. 选择相同的 **Team**
5. Bundle Identifier 会自动设置为：
   - `com.yourname.todolist.WidgetExtension`

**截图说明：**
```
Xcode 界面：
┌─────────────────────────────────────────────┐
│ Signing & Capabilities                      │
├─────────────────────────────────────────────┤
│ ✓ Automatically manage signing              │
│                                             │
│ Team:  Your Apple ID (Personal Team)       │
│ Bundle Identifier: com.yourname.todolist    │
│ Provisioning Profile: Xcode Managed        │
│ Signing Certificate: Apple Development     │
└─────────────────────────────────────────────┘
```

---

### 4. 运行到真机

#### 4.1 选择设备

1. Xcode 顶部工具栏
2. 点击设备选择器（Run Destination）
3. 选择你的 iPhone（如"丁磊的 iPhone"）

#### 4.2 首次运行

1. 点击 **Run** 按钮（或按 `⌘ + R`）
2. Xcode 会：
   - 编译项目
   - 安装到 iPhone
   - 自动启动应用

#### 4.3 信任开发者证书

**首次运行会失败，显示：**
```
"TodoList" 无法打开，因为开发者身份无法验证
```

**解决步骤：**
1. iPhone 上打开 **设置**
2. **通用** → **VPN 与设备管理**
3. 找到 **开发者 App** 部分
4. 点击你的 Apple ID
5. 点击 **信任 "你的 Apple ID"**
6. 确认信任

#### 4.4 重新运行

1. 在 Xcode 中再次点击 **Run**
2. 应用成功启动
3. 在 iPhone 上测试功能

---

### 5. 调试技巧

#### 5.1 查看控制台日志

Xcode 底部控制台会显示应用日志：

```
✅ SwiftData 初始化成功（使用 App Group 共享容器）
📂 App Group 容器路径: /var/mobile/Containers/Shared/AppGroup/...
✅ 用户登录成功
```

**筛选日志：**
- 在控制台搜索框输入关键字（如"Error", "Success"）
- 点击控制台右下角的图标筛选日志级别

#### 5.2 断点调试

1. 在代码行号左侧点击，设置断点（蓝色标记）
2. 运行到断点时，程序暂停
3. 在控制台使用 `po` 命令查看变量：
   ```
   (lldb) po todo.title
   "完成项目报告"

   (lldb) po viewModel.todos.count
   5
   ```

#### 5.3 查看数据库内容

真机上的数据库位于 App Group 共享容器：

```swift
// 在代码中打印路径
if let appGroupURL = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: "group.com.yipoo.todolist"
) {
    print("📂 数据库路径: \(appGroupURL.path())")
}
```

**使用 Xcode 查看数据库：**
1. Window → Devices and Simulators
2. 选择你的 iPhone
3. 选择 **TodoList** 应用
4. 点击齿轮图标 → **Download Container...**
5. 导出到 Mac，使用 DB Browser for SQLite 查看

---

### 6. 常见真机测试问题

#### 问题 1：设备未识别
```
No iOS devices available
```

**解决：**
1. 拔插数据线
2. 重启 iPhone 和 Mac
3. 更新 iOS 和 macOS 到最新版本
4. 使用原装或认证数据线

#### 问题 2：签名失败
```
Signing for "TodoList" requires a development team
```

**解决：**
1. 检查是否添加了 Apple ID（Xcode → Preferences → Accounts）
2. 检查是否选择了 Team
3. 检查 Bundle Identifier 是否唯一

#### 问题 3：App Group 真机无法访问
```
❌ 无法获取 App Group 容器: group.com.yipoo.todolist
```

**原因：** 免费 Apple ID 的 App Groups 限制

**解决（免费账号）：**
1. 修改 App Group 标识符为你自己的：
   ```swift
   // DataManager.swift 和 WidgetDataProvider.swift
   private static let appGroupIdentifier = "group.com.yourname.todolist"
   ```

2. 在 Xcode 中更新 App Groups：
   - TodoList target → Signing & Capabilities → App Groups
   - 修改为 `group.com.yourname.todolist`
   - WidgetExtension target 同样修改

**解决（付费账号）：**
在 Apple Developer 网站创建 App Group（见下文）

---

## App Store 发布准备

### 1. Apple Developer Program

**加入 Apple Developer Program：**

1. 前往 [Apple Developer](https://developer.apple.com/programs/)
2. 点击 **Enroll**
3. 登录 Apple ID
4. 选择账号类型：
   - **Individual**（个人）：$99/年，以个人名义发布
   - **Organization**（组织）：$99/年，以公司名义发布
5. 填写个人/公司信息
6. 支付费用
7. 等待审核（通常 1-2 个工作日）

**会员权益：**
- ✅ 真机测试无限制
- ✅ 发布到 App Store
- ✅ TestFlight 测试（最多 10,000 用户）
- ✅ 完整的证书和配置文件管理
- ✅ App Groups、推送通知等高级功能

---

### 2. 应用信息准备

#### 2.1 应用元数据

**必需信息：**
- **应用名称**：TodoList（或其他名称）
- **副标题**：专业的待办事项管理工具
- **描述**：详细介绍应用功能（见下文模板）
- **关键词**：待办事项,Todo,任务管理,GTD,番茄钟
- **分类**：生产力工具
- **价格**：免费（或付费）

**应用描述模板：**
```
TodoList - 你的高效待办管理助手

【核心功能】
✓ 待办管理：创建、编辑、完成待办事项
✓ 优先级：高/中/低三级优先级
✓ 分类：预设分类 + 自定义分类
✓ 子任务：拆分复杂任务为小步骤
✓ 番茄钟：专注工作，提高效率
✓ 统计分析：完成率、趋势图、分类统计
✓ Widget 小组件：桌面快捷查看
✓ 主题：浅色/深色/跟随系统

【为什么选择 TodoList】
- 🎯 简洁设计：专注核心功能，无广告
- 📊 数据分析：可视化你的工作效率
- 🍅 番茄工作法：科学的时间管理
- 🔒 数据安全：本地存储，保护隐私
- 📱 原生体验：流畅的 iOS 原生应用

【适用场景】
• 工作任务管理
• 学习计划安排
• 生活琐事记录
• 目标跟踪

【系统要求】
iOS 17.0 或更高版本

【联系我们】
邮箱：support@example.com
```

#### 2.2 应用截图

**要求：**
- **iPhone 6.7"**（iPhone 15 Pro Max）：必需
  - 分辨率：1290 x 2796
  - 数量：3-10 张
- **iPhone 6.5"**（iPhone 14 Pro Max）：可选
- **iPad Pro 12.9"**：如果支持 iPad

**截图内容建议：**
1. 待办列表（展示主要功能）
2. 创建待办（展示编辑界面）
3. 统计分析（展示图表）
4. 番茄钟（展示计时器）
5. 个人中心（展示设置选项）

**制作截图：**
```bash
# 方法 1：使用模拟器
1. 运行应用到 iPhone 15 Pro Max 模拟器
2. 在需要截图的界面按 ⌘ + S
3. 截图保存到 ~/Desktop

# 方法 2：使用真机
1. 运行应用到 iPhone 15 Pro Max
2. 按 音量上 + 侧边键
3. 在 照片 中导出截图
```

**美化截图（可选）：**
- 使用 [Figma](https://www.figma.com/) 添加设备边框
- 添加标题和描述文字
- 使用 [App Store Screenshot](https://www.appstorescreenshot.com/)

#### 2.3 应用图标

**要求：**
- 尺寸：1024 x 1024（App Store 图标）
- 格式：PNG（无透明通道）
- 内容：不能包含 Alpha 通道、圆角

**已有图标：**
- 项目中的 `Assets.xcassets/AppIcon.appiconset/`
- Xcode 自动生成各种尺寸

**如需更换图标：**
1. 设计 1024x1024 图标
2. 在 Xcode 中：
   - 打开 `Assets.xcassets`
   - 选择 `AppIcon`
   - 拖入 1024x1024 图标到 App Store 位置
   - Xcode 自动生成其他尺寸

---

### 3. 版本配置

#### 3.1 设置版本号

在 Xcode 中：
1. 选择 **TodoList** target
2. **General** → **Identity**
3. 设置版本信息：
   - **Version**: 1.0.0（用户可见版本）
   - **Build**: 1（内部构建号）

**版本号规则：**
- **Version**: `主版本.次版本.修订号`（如 1.0.0, 1.1.0, 2.0.0）
- **Build**: 递增整数（如 1, 2, 3, ...）

**示例：**
| 发布次数 | Version | Build | 说明 |
|---------|---------|-------|------|
| 首次发布 | 1.0.0 | 1 | 初始版本 |
| 修复 Bug | 1.0.1 | 2 | Bug 修复 |
| 新功能 | 1.1.0 | 3 | 添加日历功能 |
| 重大更新 | 2.0.0 | 4 | 架构重构 |

#### 3.2 修改应用信息

```swift
// Constants.swift
enum AppInfo {
    static let name = "TodoList"
    static let version = "1.0.0"       // 与 Xcode 中的 Version 一致
    static let buildNumber = "1"       // 与 Xcode 中的 Build 一致
    static let author = "Your Name"    // 修改为你的名字
    static let website = "https://your-website.com"  // 修改为你的网站
    static let email = "support@your-domain.com"     // 修改为你的邮箱
}
```

---

### 4. 构建发布版本

#### 4.1 选择 Release 配置

1. Xcode 顶部工具栏：**Product → Scheme → Edit Scheme**
2. 选择 **Run** → **Info**
3. **Build Configuration** 改为 **Release**

#### 4.2 归档（Archive）

1. 选择目标设备：**Any iOS Device (arm64)**
2. Xcode 菜单：**Product → Archive**
3. 等待构建完成（几分钟）
4. 构建成功后自动打开 **Organizer** 窗口

**Organizer 界面：**
```
┌─────────────────────────────────────────────┐
│ Archives                                    │
├─────────────────────────────────────────────┤
│ TodoList                                    │
│   Version 1.0.0 (1)                        │
│   Today at 10:00 AM                        │
│                                             │
│ [Distribute App]  [Validate App]           │
└─────────────────────────────────────────────┘
```

#### 4.3 验证（Validate）

上传前先验证应用：

1. 点击 **Validate App**
2. 选择 **App Store Connect**
3. 选择 **Automatically manage signing**
4. 点击 **Next**
5. 等待验证完成（几分钟）

**验证内容：**
- ✅ 代码签名正确
- ✅ 没有违反 App Store 审核规则
- ✅ 权限声明完整
- ✅ 二进制大小合理

#### 4.4 上传（Distribute）

验证通过后上传：

1. 点击 **Distribute App**
2. 选择 **App Store Connect**
3. 选择 **Upload**
4. 点击 **Next**
5. 等待上传完成（几分钟到几十分钟）

**上传后：**
- 在 [App Store Connect](https://appstoreconnect.apple.com/) 中可以看到新构建
- 构建状态会先显示"处理中"，然后变为"可供测试"

---

### 5. App Store Connect 配置

#### 5.1 创建应用

1. 登录 [App Store Connect](https://appstoreconnect.apple.com/)
2. 点击 **我的 App**
3. 点击 **+** → **新建 App**
4. 填写信息：
   - **平台**：iOS
   - **名称**：TodoList
   - **语言**：简体中文
   - **Bundle ID**：选择你在 Xcode 中设置的 Bundle ID
   - **SKU**：com.yourname.todolist（唯一标识符）
   - **用户访问权限**：完全访问权限

#### 5.2 填写应用信息

**App 信息：**
1. **类别**：生产力工具
2. **内容版权**：2025 Your Name
3. **隐私政策 URL**（可选）：https://your-website.com/privacy

**定价与销售范围：**
1. **价格**：选择"免费"
2. **销售范围**：选择国家/地区（建议选择全球）

**App 隐私：**
根据项目实际情况填写：
- **数据类型**：
  - 联系信息：手机号码
  - 位置：否
  - 健康：否
- **数据用途**：
  - 用户登录和身份验证
- **数据关联**：
  - 关联到用户身份
- **数据跟踪**：
  - 不用于跟踪

#### 5.3 提交审核

**准备提交：**
1. 在 App Store Connect 中选择你的应用
2. 点击左侧 **1.0 准备提交**
3. 填写版本信息：
   - **此版本的新增内容**：首次发布
   - **截图**：上传准备好的截图
   - **描述**：粘贴应用描述
   - **关键词**：填写关键词
   - **技术支持 URL**（可选）
   - **营销 URL**（可选）
4. **构建版本**：选择刚上传的构建
5. **版权**：2025 Your Name
6. **App Review 信息**：
   - 姓名：Your Name
   - 电话：+86 1xxxxxxxxxx
   - 电子邮件：your-email@example.com
7. **备注**（可选）：给审核人员的说明

**提交审核：**
1. 点击右上角 **提交以供审核**
2. 回答出口合规性问题：
   - "您的应用是否使用加密？"
   - 选择 **是**（因为使用了 HTTPS 和 Keychain）
   - 选择 **否**（不包含、设计或开发加密）
3. 确认提交

**审核时间：**
- 通常 1-7 个工作日
- 首次提交可能需要更长时间

---

## 证书和配置文件

### 1. 证书类型

**开发证书（Development Certificate）：**
- 用于真机调试
- 免费账号和付费账号都可以创建
- 每个 Apple ID 可以创建多个

**发布证书（Distribution Certificate）：**
- 用于发布到 App Store
- 仅限付费 Apple Developer Program 会员
- 每个账号最多 2 个

### 2. 自动管理 vs 手动管理

#### 自动管理（推荐）

**优点：**
- ✅ Xcode 自动处理
- ✅ 无需手动配置
- ✅ 适合个人开发者

**配置：**
```
Signing & Capabilities
  ✓ Automatically manage signing
  Team: Your Apple ID
```

#### 手动管理（高级）

**适用场景：**
- 团队协作
- 多个开发者共享证书
- 需要精确控制签名

**配置：**
1. 关闭 **Automatically manage signing**
2. 在 [Apple Developer](https://developer.apple.com/) 网站创建证书
3. 下载并安装证书
4. 在 Xcode 中选择对应的 Provisioning Profile

---

### 3. 证书管理（手动）

#### 3.1 创建开发证书

1. 登录 [Apple Developer](https://developer.apple.com/)
2. **Certificates, Identifiers & Profiles** → **Certificates**
3. 点击 **+** 创建新证书
4. 选择 **iOS App Development**
5. 生成 CSR（Certificate Signing Request）：
   - 在 Mac 上打开 **钥匙串访问**
   - **钥匙串访问 → 证书助理 → 从证书颁发机构请求证书**
   - 输入邮箱，选择"存储到磁盘"
   - 保存 `.certSigningRequest` 文件
6. 上传 CSR 文件
7. 下载证书（`.cer` 文件）
8. 双击安装到钥匙串

#### 3.2 创建发布证书

步骤同上，但选择 **App Store and Ad Hoc** 类型。

---

### 4. Provisioning Profiles

#### 4.1 开发 Provisioning Profile

1. **Certificates, Identifiers & Profiles** → **Profiles**
2. 点击 **+** 创建新 Profile
3. 选择 **iOS App Development**
4. 选择 App ID（Bundle Identifier）
5. 选择证书
6. 选择设备（添加测试设备的 UDID）
7. 下载并双击安装

#### 4.2 发布 Provisioning Profile

步骤同上，但选择 **App Store** 类型。

---

## App Groups 真机配置

### 1. 为什么需要 App Groups

App Groups 允许主应用和 Widget Extension 共享数据。

**数据共享：**
```
主应用创建待办
    ↓
SwiftData 保存到 App Group 共享容器
    ↓
Widget 从共享容器读取数据
    ↓
Widget 显示待办列表
```

---

### 2. 付费账号配置（推荐）

#### 2.1 创建 App Group

1. 登录 [Apple Developer](https://developer.apple.com/)
2. **Certificates, Identifiers & Profiles** → **Identifiers**
3. 点击 **+** → 选择 **App Groups**
4. 输入描述和标识符：
   - **Description**: TodoList Shared Container
   - **Identifier**: `group.com.yipoo.todolist`
5. 点击 **Continue** → **Register**

#### 2.2 关联 App ID

**主应用 App ID：**
1. **Identifiers** → 选择你的 App ID（如 `com.yipoo.todolist`）
2. 勾选 **App Groups**
3. 点击 **Edit**
4. 勾选刚创建的 `group.com.yipoo.todolist`
5. 点击 **Continue** → **Save**

**Widget Extension App ID：**
1. 重复上述步骤
2. 选择 Widget 的 App ID（如 `com.yipoo.todolist.WidgetExtension`）
3. 勾选相同的 App Group

#### 2.3 更新 Provisioning Profiles

配置 App Groups 后需要重新生成 Provisioning Profiles：

1. 删除旧的 Provisioning Profiles
2. 在 Xcode 中重新生成：
   - **Signing & Capabilities** → 点击刷新图标
   - 或删除重新添加 App Groups

---

### 3. 免费账号配置（有限制）

免费 Apple ID 的 App Groups 支持有限：

**模拟器：**
- ✅ 完全支持
- 可以正常使用 App Groups

**真机：**
- ❌ 免费账号无法在真机上使用 App Groups
- 会报错：`❌ 无法获取 App Group 容器`

**解决方案（真机测试）：**

**方案 1：使用付费账号（推荐）**
- 加入 Apple Developer Program ($99/年)
- 完整支持 App Groups

**方案 2：禁用 Widget（临时）**
- 只测试主应用功能
- 不测试 Widget

**方案 3：修改数据存储（不推荐）**
```swift
// DataManager.swift
#if DEBUG
// 开发模式：使用默认容器（不支持 Widget）
let configuration = ModelConfiguration(schema: schema)
#else
// 生产模式：使用 App Group
let configuration = ModelConfiguration(
    schema: schema,
    groupContainer: .identifier(appGroupIdentifier)
)
#endif
```

---

### 4. 验证 App Groups 配置

#### 4.1 检查代码配置

```swift
// DataManager.swift 和 WidgetDataProvider.swift
private static let appGroupIdentifier = "group.com.yipoo.todolist"

guard let appGroupURL = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: appGroupIdentifier
) else {
    print("❌ 无法获取 App Group 容器")
    return
}

print("✅ App Group 容器路径: \(appGroupURL.path())")
```

#### 4.2 运行测试

**模拟器测试：**
```bash
1. 运行主应用到模拟器
2. 创建几个待办事项
3. 按 Home 键退出应用
4. 长按主屏幕，添加 Widget
5. 验证 Widget 能显示刚创建的待办
```

**真机测试（付费账号）：**
```bash
1. 运行主应用到真机
2. 创建几个今日待办
3. 添加 Widget 到主屏幕
4. 验证 Widget 显示正确数据
5. 在主应用中修改待办
6. 等待 Widget 刷新（15分钟）或强制刷新
```

---

## Widget 真机调试

### 1. Widget 真机安装

**自动安装：**
- 运行主应用到真机时，Widget Extension 会自动安装
- 无需单独安装

**手动添加 Widget：**
1. 长按 iPhone 主屏幕
2. 点击左上角 **+** 图标
3. 搜索 "TodoList"
4. 选择 Widget 尺寸（小/中/大）
5. 点击 **添加小组件**

---

### 2. Widget 调试

#### 2.1 查看 Widget 日志

**方式一：Xcode Console**
```bash
1. 运行主应用到真机（连接 Xcode）
2. 添加 Widget 到主屏幕
3. 在 Xcode Console 中查看日志
4. 搜索关键字："Widget", "SwiftData", "Error"
```

**方式二：设备日志**
```bash
# 在 Mac 终端中
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "WidgetExtension"'
```

#### 2.2 调试 Widget Timeline

在 `TodoWidgetProvider` 中添加调试日志：

```swift
func getTimeline(in context: Context, completion: @escaping (Timeline<TodoWidgetEntry>) -> Void) {
    print("📱 Widget 请求更新 Timeline")

    Task {
        let entry = await fetchData()
        print("📊 Widget 获取到 \(entry.todayTodos.count) 个待办")

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        print("⏰ Widget 下次更新时间: \(nextUpdate)")

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}
```

#### 2.3 强制刷新 Widget

**代码中刷新：**
```swift
import WidgetKit

// 在主应用中，创建/更新/删除待办后
WidgetCenter.shared.reloadAllTimelines()
```

**手动刷新：**
1. 长按 Widget
2. 选择 **编辑小组件**
3. 点击完成

---

### 3. Widget 真机常见问题

#### 问题 1：Widget 不显示真实数据
```
Widget 一直显示占位符数据
```

**排查步骤：**
1. 检查主应用和 Widget 的 App Groups 配置
2. 检查是否为真机配置了 App Group（付费账号）
3. 检查控制台是否有错误日志
4. 验证数据库路径是否正确

#### 问题 2：Widget 显示"无数据"
```
Widget 显示"今天没有待办事项"
```

**解决：**
1. 在主应用中创建几个待办，设置截止日期为今天
2. 强制刷新 Widget：`WidgetCenter.shared.reloadAllTimelines()`
3. 等待 Widget 刷新（最多 15 分钟）

#### 问题 3：Widget 崩溃
```
Widget 显示灰色背景或完全不显示
```

**排查：**
1. 查看 Xcode Console 错误日志
2. 检查 Widget 代码是否有语法错误
3. 检查 SwiftData 模型是否添加到 Widget Extension Target
4. 尝试卸载应用并重新安装

---

## 版本管理建议

### 1. 版本号规则

采用 **语义化版本号**（Semantic Versioning）：

```
主版本.次版本.修订号

例如：1.2.3
  │  │  │
  │  │  └─ 修订号：Bug 修复
  │  └──── 次版本：新增功能（向后兼容）
  └─────── 主版本：重大更新（可能不兼容）
```

**示例：**
- `1.0.0`：首次发布
- `1.0.1`：修复登录闪退 Bug
- `1.1.0`：添加日历功能
- `1.2.0`：添加通知功能
- `2.0.0`：重新设计 UI，重构架构

---

### 2. Git 分支管理

**推荐使用 Git Flow：**

```
main (生产分支)
  │
  ├─ develop (开发分支)
  │    │
  │    ├─ feature/calendar (功能分支)
  │    ├─ feature/notification (功能分支)
  │    └─ feature/widget (功能分支)
  │
  └─ release/1.0.0 (发布分支)
       │
       └─ hotfix/login-crash (热修复分支)
```

**分支说明：**
- **main**：生产环境，对应 App Store 版本
- **develop**：开发主分支
- **feature/**：新功能开发
- **release/**：发布准备（测试、修复）
- **hotfix/**：紧急修复

**工作流程：**
```bash
# 1. 从 develop 创建功能分支
git checkout develop
git checkout -b feature/calendar

# 2. 开发功能
git add .
git commit -m "feat: 添加日历视图"

# 3. 合并回 develop
git checkout develop
git merge feature/calendar

# 4. 创建发布分支
git checkout -b release/1.1.0

# 5. 测试并修复 Bug
git commit -m "fix: 修复日历日期显示错误"

# 6. 合并到 main 并打标签
git checkout main
git merge release/1.1.0
git tag -a v1.1.0 -m "版本 1.1.0：添加日历功能"
git push origin main --tags

# 7. 合并回 develop
git checkout develop
git merge release/1.1.0
```

---

### 3. 提交信息规范

**使用 Conventional Commits：**

```
<类型>(<范围>): <描述>

[可选的正文]

[可选的脚注]
```

**类型：**
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `test`: 测试
- `chore`: 构建/工具

**示例：**
```bash
git commit -m "feat(todo): 添加批量删除功能"
git commit -m "fix(auth): 修复登录时的崩溃问题"
git commit -m "docs: 更新 README 中的安装说明"
git commit -m "refactor(viewmodel): 优化 TodoViewModel 性能"
```

---

### 4. 发布检查清单

**每次发布前检查：**

- [ ] 版本号已更新（Version 和 Build）
- [ ] 所有功能已测试通过
- [ ] UI 在不同设备上显示正常（iPhone SE、15 Pro、Plus）
- [ ] 深色模式适配正常
- [ ] Widget 显示正常
- [ ] 没有控制台警告或错误
- [ ] App Store 截图已更新
- [ ] 更新日志已编写
- [ ] 代码已推送到 Git
- [ ] 已打 Git 标签
- [ ] 已归档（Archive）
- [ ] 已上传到 App Store Connect

**清单模板（Markdown）：**
```markdown
## 版本 1.1.0 发布检查清单

### 开发
- [x] 功能开发完成
- [x] 单元测试通过
- [x] 代码审查完成

### 测试
- [x] iPhone SE 测试通过
- [x] iPhone 15 Pro 测试通过
- [x] iPad Pro 测试通过（如果支持）
- [x] 深色模式测试通过
- [x] Widget 测试通过

### 配置
- [x] 版本号更新为 1.1.0
- [x] Build 号递增为 5
- [x] App Store 描述已更新
- [x] 截图已更新

### 发布
- [x] Git 标签已打：v1.1.0
- [x] 已归档（Archive）
- [x] 已验证（Validate）
- [x] 已上传到 App Store Connect
- [x] 已提交审核
```

---

### 5. 版本发布流程

**完整流程：**

```
1. 功能开发
   ├─ 创建 feature 分支
   ├─ 开发功能
   ├─ 测试功能
   └─ 合并到 develop

2. 发布准备
   ├─ 创建 release 分支
   ├─ 更新版本号
   ├─ 更新文档（README、CHANGELOG）
   ├─ 截图和元数据
   └─ 测试

3. 发布
   ├─ 合并到 main
   ├─ 打 Git 标签
   ├─ 归档（Archive）
   ├─ 验证（Validate）
   ├─ 上传到 App Store Connect
   └─ 提交审核

4. 审核通过
   ├─ 设置发布日期
   ├─ 监控用户反馈
   └─ 准备热修复（如需要）

5. 维护
   ├─ 收集用户反馈
   ├─ 修复 Bug
   └─ 规划下一版本
```

---

### 6. CHANGELOG 管理

**创建 CHANGELOG.md：**
```markdown
# 更新日志

本文档记录 TodoList 的所有版本变更。

## [未发布]
### 新增
- 日历视图功能
### 修复
- 修复待办列表滚动卡顿

## [1.1.0] - 2025-11-15
### 新增
- Widget 小组件支持
- 番茄钟计时器
- 统计分析功能

### 改进
- 优化列表加载性能
- 改进深色模式适配

### 修复
- 修复登录时偶尔崩溃的问题
- 修复子任务无法删除的 Bug

## [1.0.1] - 2025-11-08
### 修复
- 修复首次登录崩溃
- 修复头像上传失败

## [1.0.0] - 2025-11-01
### 新增
- 首次发布
- 待办事项管理
- 用户认证系统
- 分类管理
- 个人中心
```

---

## 总结

本部署指南涵盖了从真机测试到 App Store 发布的完整流程。

**关键要点：**
- ✅ 真机测试需要 Apple ID（免费或付费）
- ✅ Widget 真机调试需要付费账号（App Groups）
- ✅ App Store 发布需要付费 Apple Developer Program ($99/年)
- ✅ 使用语义化版本号管理版本
- ✅ 遵循 Git Flow 分支管理策略
- ✅ 每次发布前完成检查清单

**下一步：**
- 完成真机测试，确保所有功能正常
- 准备 App Store 素材（截图、描述）
- 加入 Apple Developer Program
- 提交审核，等待上架

**参考资源：**
- [App Store 审核指南](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Connect 帮助](https://help.apple.com/app-store-connect/)
