# TodoList App Icon 设计说明

## 设计概览

我根据你的应用主色调（蓝色到紫色渐变）设计了一个现代化的 App Icon。

### 视觉特征

**主色调**
- 渐变背景：蓝色 (#007AFF) → 紫色 (#5E5CE6)
- 与应用内的 UI 保持一致

**设计元素**
- ✓ 白色对勾：象征任务完成
- 📋 列表线条：代表待办事项
- 🎨 扁平化设计：符合现代 iOS 设计语言

**设计风格**
- 简洁明了，一眼就能识别
- 渐变背景有层次感
- 白色元素在深色背景上清晰可见

## 设计文件

📁 **app_icon_design.svg** - 矢量设计文件（1024x1024）

这是主设计文件，包含：
- 蓝紫渐变背景
- 白色半透明卡片
- 三个列表项（一个已完成，两个未完成）
- 装饰性小圆点

## 生成 iOS 图标

### 方案 1：在线工具（最简单）✅

1. 访问 **https://www.appicon.co** 或 **https://makeappicon.com**
2. 上传 `app_icon_design.svg` 文件
3. 选择 iOS 平台
4. 下载生成的图标包
5. 解压后复制所有文件到：
   ```
   TodoList/Assets.xcassets/AppIcon.appiconset/
   ```

### 方案 2：使用设计软件

**Figma/Sketch/Adobe XD/Photoshop**

1. 在设计软件中打开 `app_icon_design.svg`
2. 导出为 1024x1024 PNG（命名为 `app_icon_1024.png`）
3. 运行脚本自动生成其他尺寸：
   ```bash
   cd TodoList项目目录
   ./generate_icons_simple.sh
   ```

### 方案 3：使用 Python 脚本（需要安装依赖）

```bash
# 安装依赖
pip3 install cairosvg pillow

# 运行脚本
python3 generate_app_icons.py
```

脚本会自动生成所有 iOS 所需的图标尺寸。

## 所需图标尺寸

iOS 应用需要以下尺寸的图标：

| 用途 | 尺寸 | 文件名 |
|------|------|--------|
| iPhone 通知 | 40x40, 60x60 | Icon-20@2x.png, Icon-20@3x.png |
| iPhone 设置 | 58x58, 87x87 | Icon-29@2x.png, Icon-29@3x.png |
| iPhone Spotlight | 80x80, 120x120 | Icon-40@2x.png, Icon-40@3x.png |
| iPhone App | 120x120, 180x180 | Icon-60@2x.png, Icon-60@3x.png |
| iPad 各种场景 | 20-167px | Icon-*.png |
| App Store | 1024x1024 | Icon-1024.png |

## 预览效果

### 在不同场景下的显示

**主屏幕**
- iPhone: 60x60@3x (180x180)
- iPad: 76x76@2x (152x152)

**设置页面**
- 较小的图标仍然清晰可见
- 对勾和列表元素清晰可辨

**App Store**
- 1024x1024 高清展示
- 渐变效果完美呈现

## 设计原则

1. **简洁性** - 图标在小尺寸下仍然清晰
2. **识别性** - 一眼就能看出是待办应用
3. **一致性** - 与应用内配色保持一致
4. **现代感** - 符合 iOS 设计趋势

## 颜色代码

```
主渐变：
起点: #007AFF (iOS 标准蓝)
终点: #5E5CE6 (iOS 标准紫)

辅助色：
白色: #FFFFFF
白色半透明: rgba(255, 255, 255, 0.15-0.3)
```

## 安装步骤

1. **生成图标文件**（使用上述任一方案）

2. **在 Xcode 中查看**
   - 打开项目
   - 导航到 `Assets.xcassets`
   - 点击 `AppIcon`
   - 确认所有尺寸都已填充

3. **在模拟器/真机上测试**
   - 运行项目
   - 查看主屏幕图标
   - 检查各种场景下的显示效果

4. **提交 App Store**
   - 1024x1024 图标会自动用于 App Store 展示

## 可选调整

如果想修改设计，可以编辑 `app_icon_design.svg`：

**调整颜色**
```xml
<!-- 修改渐变色 -->
<linearGradient id="bgGradient">
  <stop offset="0%" style="stop-color:#YOUR_COLOR"/>
  <stop offset="100%" style="stop-color:#YOUR_COLOR"/>
</linearGradient>
```

**调整元素位置**
- 修改 `<g transform="translate(x, y)">` 中的坐标

**更改设计**
- 在任何矢量编辑软件中编辑 SVG
- 保持 1024x1024 的画板尺寸

## 故障排除

**问题：图标边缘有白边**
- 确保 SVG 没有透明背景
- 渐变应该覆盖整个 1024x1024 区域

**问题：小尺寸下细节模糊**
- 这是正常的，iOS 会自动优化
- 主要元素（对勾、列表）仍然清晰

**问题：颜色与应用不一致**
- 检查应用内的实际颜色值
- 调整 SVG 中的渐变色

---

**设计日期**: 2025-11-07
**设计者**: Claude Code
**版本**: 1.0
