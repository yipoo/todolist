#!/bin/bash

# App Icon 生成脚本 (使用 macOS 自带工具)
# 需要先手动将 SVG 导出为 1024x1024 的 PNG

echo "📱 App Icon 生成脚本"
echo ""
echo "⚠️  由于 SVG 转换需要额外工具，请按照以下步骤操作："
echo ""
echo "方案 1: 使用在线工具（推荐）"
echo "  1. 打开 https://www.appicon.co"
echo "  2. 上传 app_icon_design.svg"
echo "  3. 下载生成的 iOS 图标包"
echo "  4. 解压并复制到 TodoList/Assets.xcassets/AppIcon.appiconset/"
echo ""
echo "方案 2: 使用 Sketch/Figma/Photoshop"
echo "  1. 在设计软件中打开 app_icon_design.svg"
echo "  2. 导出为 1024x1024 的 PNG"
echo "  3. 运行本脚本进行批量缩放"
echo ""
echo "方案 3: 安装 Python 工具"
echo "  1. 运行: pip3 install cairosvg pillow"
echo "  2. 运行: python3 generate_app_icons.py"
echo ""

read -p "是否已经准备好 1024x1024 的 PNG 文件? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "请先准备好图标文件后再运行此脚本"
    exit 1
fi

# 如果用户确认有 PNG 文件，继续生成
SOURCE_PNG="app_icon_1024.png"

if [ ! -f "$SOURCE_PNG" ]; then
    echo "❌ 找不到 $SOURCE_PNG 文件"
    exit 1
fi

OUTPUT_DIR="TodoList/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$OUTPUT_DIR"

echo "🎨 开始生成各种尺寸的图标..."

# 使用 sips 生成各种尺寸
declare -A sizes=(
    ["Icon-20.png"]=20
    ["Icon-20@2x.png"]=40
    ["Icon-20@3x.png"]=60
    ["Icon-29.png"]=29
    ["Icon-29@2x.png"]=58
    ["Icon-29@3x.png"]=87
    ["Icon-40.png"]=40
    ["Icon-40@2x.png"]=80
    ["Icon-40@3x.png"]=120
    ["Icon-60@2x.png"]=120
    ["Icon-60@3x.png"]=180
    ["Icon-76.png"]=76
    ["Icon-76@2x.png"]=152
    ["Icon-83.5@2x.png"]=167
    ["Icon-1024.png"]=1024
)

for filename in "${!sizes[@]}"; do
    size=${sizes[$filename]}
    sips -z $size $size "$SOURCE_PNG" --out "$OUTPUT_DIR/$filename" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ $filename ($size x $size)"
    else
        echo "❌ $filename 生成失败"
    fi
done

echo ""
echo "🎉 完成!"
echo "📌 请在 Xcode 中查看 Assets.xcassets -> AppIcon"
