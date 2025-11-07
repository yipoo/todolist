# TodoList 文档结构树

```
TodoList/
│
├── 📄 README.md (中文)                  # 项目主页,快速开始
├── 📄 README.en.md (English)            # English version
│
├── 📁 docs/                             # 文档中心
│   ├── 📄 README.md                    # 文档导航索引 ⭐
│   ├── 📄 USER_GUIDE.md                # 用户使用手册 👤
│   ├── 📄 DEVELOPMENT_GUIDE.md         # 开发指南 💻
│   ├── 📄 ARCHITECTURE.md              # 架构设计文档 🏗️
│   ├── 📄 API_REFERENCE.md             # API 参考手册 📖
│   ├── 📄 TECHNICAL_GUIDE.md           # 技术指南 🔧
│   ├── 📄 DEPLOYMENT.md                # 部署发布指南 🚀
│   └── 📄 TECHNICAL_MANUAL.md          # 技术手册 📚
│
├── 📁 Widget/                           # Widget 文档
│   ├── 📄 WIDGET_SETUP.md              # Widget 配置
│   ├── 📄 QUICK_ADD_WIDGET_GUIDE.md    # 快速添加指南
│   ├── 📄 WIDGET_TESTING_GUIDE.md      # Widget 测试
│   ├── 📄 WIDGET_TROUBLESHOOTING.md    # 故障排除
│   └── 📄 WIDGET_OPTIMIZATION_SUMMARY.md # 性能优化
│
└── 📁 TodoList/                         # 项目文档
    ├── 📄 README.md                    # 项目说明
    ├── 📄 PRD.md                       # 产品需求文档
    └── 📄 PROGRESS.md                  # 开发进度
```

---

## 📚 文档分类

### 🎯 新手入门路径

1. **了解项目** → [README.md](../README.md)
2. **开发环境** → [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)
3. **架构理解** → [ARCHITECTURE.md](./ARCHITECTURE.md)
4. **开始编码** → [API_REFERENCE.md](./API_REFERENCE.md)

### 👥 按角色导航

#### 最终用户
- [用户手册](./USER_GUIDE.md)
- [Widget 配置](../Widget/WIDGET_SETUP.md)

#### 新手开发者
- [开发指南](./DEVELOPMENT_GUIDE.md) ⭐ 从这里开始
- [技术指南](./TECHNICAL_GUIDE.md)
- [API 参考](./API_REFERENCE.md)

#### 资深开发者
- [架构设计](./ARCHITECTURE.md)
- [技术手册](./TECHNICAL_MANUAL.md)
- [Widget 优化](../Widget/WIDGET_OPTIMIZATION_SUMMARY.md)

#### 产品/项目经理
- [产品需求文档](../TodoList/PRD.md)
- [开发进度](../TodoList/PROGRESS.md)
- [用户手册](./USER_GUIDE.md)

#### 运维/发布
- [部署指南](./DEPLOYMENT.md)
- [Widget 配置](../Widget/WIDGET_SETUP.md)

---

## 📊 文档统计

| 类型 | 数量 | 总行数 |
|------|------|--------|
| 主要文档 | 2 | ~800 |
| 开发文档 | 6 | ~4,800 |
| Widget 文档 | 5 | ~1,500 |
| 项目文档 | 3 | ~1,000 |
| **总计** | **16** | **~8,100** |

---

## 🔍 快速查找

### 按主题

- **SwiftUI**: [技术指南](./TECHNICAL_GUIDE.md#swiftui), [开发指南](./DEVELOPMENT_GUIDE.md#swiftui-视图规范)
- **SwiftData**: [架构设计](./ARCHITECTURE.md#为什么选择-swiftdata), [API 参考](./API_REFERENCE.md#数据模型-models)
- **Widget**: [Widget 目录](../Widget/)
- **MVVM**: [架构设计](./ARCHITECTURE.md#mvvm)
- **测试**: [开发指南](./DEVELOPMENT_GUIDE.md#测试指南)
- **性能**: [架构设计](./ARCHITECTURE.md#性能优化), [Widget 优化](../Widget/WIDGET_OPTIMIZATION_SUMMARY.md)
- **部署**: [部署指南](./DEPLOYMENT.md)

### 按文件类型

- **Markdown 文档**: 16 个
- **Swift 代码**: 62 个
- **配置文件**: 若干

---

## 📝 文档维护

### 更新频率
- **主 README**: 每次重大功能更新
- **开发文档**: 架构变更时更新
- **API 文档**: API 变更时更新
- **用户手册**: 功能变更时更新

### 贡献指南
参见 [README.md](../README.md#贡献指南)

---

**最后更新**: 2024-11-07
