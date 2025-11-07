# TodoList 技术文档

本目录包含 TodoList SwiftUI 项目的完整技术文档。

## 文档列表

### 1. [TECHNICAL_GUIDE.md](./TECHNICAL_GUIDE.md) - 技术指南
**内容：**
- 技术栈详解（SwiftUI, SwiftData, WidgetKit）
- MVVM 架构设计
- 数据流和状态管理
- 编译步骤和系统要求
- Xcode 配置详解
- Target Membership 配置
- App Groups 配置
- 依赖管理（无外部依赖）
- 开发环境配置
- 常见问题解决（20+ 个问题）

**适合人群：**
- 想了解项目技术架构的开发者
- 需要搭建开发环境的新成员
- 遇到编译或运行问题的开发者

**篇幅：** 1327 行，约 32KB

---

### 2. [DEPLOYMENT.md](./DEPLOYMENT.md) - 部署指南
**内容：**
- 真机测试完整流程
  - 设备准备和开发者模式
  - 签名配置
  - 首次运行和证书信任
  - 调试技巧
- App Store 发布准备
  - Apple Developer Program 注册
  - 应用信息和截图准备
  - 版本配置
  - 构建和上传流程
- 证书和配置文件管理
  - 开发证书 vs 发布证书
  - 自动管理 vs 手动管理
  - Provisioning Profiles 配置
- App Groups 真机配置
  - 付费账号完整配置
  - 免费账号限制和解决方案
- Widget 真机调试
  - Widget 安装和调试
  - 日志查看
  - 常见问题排查
- 版本管理建议
  - 语义化版本号
  - Git Flow 分支管理
  - 提交信息规范
  - 发布检查清单
  - CHANGELOG 管理

**适合人群：**
- 准备真机测试的开发者
- 准备发布到 App Store 的开发者
- 需要配置 Widget 真机调试的开发者
- 团队协作中的版本管理者

**篇幅：** 1142 行，约 28KB

---

### 3. [ARCHITECTURE.md](./ARCHITECTURE.md) - 架构文档
**内容：**
- 项目整体架构
- MVVM 模式详解
- 数据层设计
- 业务逻辑层
- 视图层组织
- 模块划分
- 设计模式应用

**适合人群：**
- 想深入了解架构设计的开发者
- 需要扩展功能的开发者

**篇幅：** 517 行，约 13KB

---

### 4. [API_REFERENCE.md](./API_REFERENCE.md) - API 参考
**内容：**
- 数据模型 API
- ViewModel API
- Service API
- 工具类 API
- 扩展方法

**适合人群：**
- 需要查阅 API 文档的开发者
- 集成项目代码的开发者

**篇幅：** 992 行，约 16KB

---

## 快速导航

### 我是新手，从哪里开始？
1. 先阅读 [TECHNICAL_GUIDE.md](./TECHNICAL_GUIDE.md) 了解技术栈和架构
2. 按照指南搭建开发环境
3. 运行项目到模拟器
4. 阅读 [ARCHITECTURE.md](./ARCHITECTURE.md) 了解代码结构

### 我要在真机上测试
1. 阅读 [DEPLOYMENT.md](./DEPLOYMENT.md) 的"真机测试部署"章节
2. 配置签名和 App Groups
3. 解决可能遇到的问题（参考"常见问题"章节）

### 我要发布到 App Store
1. 阅读 [DEPLOYMENT.md](./DEPLOYMENT.md) 的"App Store 发布准备"章节
2. 注册 Apple Developer Program
3. 准备应用信息和截图
4. 按照流程构建、验证、上传

### 我要调试 Widget
1. 阅读 [TECHNICAL_GUIDE.md](./TECHNICAL_GUIDE.md) 的"WidgetKit"章节
2. 配置 App Groups（付费账号）
3. 阅读 [DEPLOYMENT.md](./DEPLOYMENT.md) 的"Widget 真机调试"章节

### 我遇到了问题
1. 查看 [TECHNICAL_GUIDE.md](./TECHNICAL_GUIDE.md) 的"常见问题解决"章节
2. 查看 [DEPLOYMENT.md](./DEPLOYMENT.md) 的各个"常见问题"章节
3. 检查控制台日志
4. 搜索相关错误信息

---

## 文档特点

### 详细的代码示例
每个技术点都配有完整的代码示例，可以直接复制使用。

**示例：SwiftData 查询**
```swift
@Query(
    filter: #Predicate<TodoItem> { todo in
        !todo.isCompleted
    },
    sort: [SortDescriptor(\.dueDate)]
)
var todos: [TodoItem]
```

### 清晰的配置说明
所有配置步骤都有详细的图文说明和截图描述。

**示例：App Groups 配置**
```
1. 选择 TodoList target
2. Signing & Capabilities → + Capability
3. 添加 App Groups
4. 勾选 group.com.yipoo.todolist
```

### 完整的问题解决
收录了 20+ 个常见问题和解决方案。

**示例：Widget 不显示数据**
- 原因分析
- 排查步骤
- 多种解决方案

### 实用的清单和模板
提供发布检查清单、CHANGELOG 模板等实用工具。

---

## 使用建议

### 按需阅读
文档内容丰富，建议根据当前需求选择性阅读：
- 开发阶段：重点阅读技术指南
- 测试阶段：重点阅读部署指南前半部分
- 发布阶段：重点阅读部署指南后半部分

### 收藏常用章节
建议在浏览器中收藏常用章节：
- 常见问题解决
- Widget 配置
- 发布检查清单

### 配合源码阅读
文档中的代码示例均来自实际项目，建议配合源码一起阅读。

---

## 文档维护

### 更新频率
- 每次重大功能更新后同步更新文档
- 发现新问题时及时补充到"常见问题"章节

### 反馈建议
如果发现文档有误或需要补充的内容：
1. 提交 Issue
2. 或直接修改后提交 PR

---

## 相关资源

### 项目文档
- [README.md](../TodoList/README.md) - 项目概览
- [PRD.md](../TodoList/PRD.md) - 产品需求文档
- [PROGRESS.md](../TodoList/PROGRESS.md) - 开发进度

### Widget 文档
- [WIDGET_SETUP.md](../Widget/WIDGET_SETUP.md) - Widget 配置说明
- [WIDGET_TESTING_GUIDE.md](../Widget/WIDGET_TESTING_GUIDE.md) - Widget 测试指南
- [WIDGET_TROUBLESHOOTING.md](../Widget/WIDGET_TROUBLESHOOTING.md) - Widget 问题排查

### Apple 官方文档
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

## 总结

本技术文档提供了 TodoList 项目从开发到部署的完整指南，覆盖：
- ✅ 技术栈详解（1300+ 行）
- ✅ 部署流程（1100+ 行）
- ✅ 架构设计（500+ 行）
- ✅ API 参考（900+ 行）
- ✅ 20+ 个常见问题解决方案
- ✅ 代码示例和配置截图说明

**总篇幅：** 约 4000 行，近 90KB

希望这些文档能帮助你更好地理解和使用 TodoList 项目！
