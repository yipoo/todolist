#!/usr/bin/env python3
"""
App Icon 生成脚本

将 SVG 设计转换为 iOS 所需的各种尺寸的 PNG 图标
需要安装: pip install cairosvg pillow
"""

import os
from pathlib import Path

try:
    import cairosvg
    from PIL import Image
    import io
except ImportError:
    print("❌ 缺少必要的库，请先安装：")
    print("   pip3 install cairosvg pillow")
    exit(1)


# iOS App Icon 所需尺寸
ICON_SIZES = [
    # iPhone 尺寸
    ("Icon-20@2x.png", 40),      # iPhone Notification iOS 7-14
    ("Icon-20@3x.png", 60),      # iPhone Notification iOS 7-14
    ("Icon-29@2x.png", 58),      # iPhone Settings iOS 7-14
    ("Icon-29@3x.png", 87),      # iPhone Settings iOS 7-14
    ("Icon-40@2x.png", 80),      # iPhone Spotlight iOS 7-14
    ("Icon-40@3x.png", 120),     # iPhone Spotlight iOS 7-14
    ("Icon-60@2x.png", 120),     # iPhone App iOS 7-14
    ("Icon-60@3x.png", 180),     # iPhone App iOS 7-14

    # iPad 尺寸
    ("Icon-20.png", 20),         # iPad Notifications iOS 7-14
    ("Icon-20@2x.png", 40),      # iPad Notifications iOS 7-14
    ("Icon-29.png", 29),         # iPad Settings iOS 7-14
    ("Icon-29@2x.png", 58),      # iPad Settings iOS 7-14
    ("Icon-40.png", 40),         # iPad Spotlight iOS 7-14
    ("Icon-40@2x.png", 80),      # iPad Spotlight iOS 7-14
    ("Icon-76.png", 76),         # iPad App iOS 7-14
    ("Icon-76@2x.png", 152),     # iPad App iOS 7-14
    ("Icon-83.5@2x.png", 167),   # iPad Pro App iOS 9-14

    # App Store
    ("Icon-1024.png", 1024),     # App Store
]


def generate_icons(svg_path: str, output_dir: str):
    """从 SVG 生成各种尺寸的 PNG 图标"""

    svg_path = Path(svg_path)
    output_dir = Path(output_dir)

    if not svg_path.exists():
        print(f"❌ SVG 文件不存在: {svg_path}")
        return

    # 创建输出目录
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"📱 开始生成 App Icons...")
    print(f"   源文件: {svg_path}")
    print(f"   输出目录: {output_dir}")
    print()

    # 读取 SVG 内容
    with open(svg_path, 'r') as f:
        svg_data = f.read()

    success_count = 0

    for filename, size in ICON_SIZES:
        try:
            # 使用 cairosvg 将 SVG 转换为 PNG
            png_data = cairosvg.svg2png(
                bytestring=svg_data.encode('utf-8'),
                output_width=size,
                output_height=size
            )

            # 使用 PIL 优化 PNG
            img = Image.open(io.BytesIO(png_data))

            # 转换为 RGB 模式（如果需要）
            if img.mode != 'RGB':
                img = img.convert('RGB')

            # 保存
            output_path = output_dir / filename
            img.save(output_path, 'PNG', optimize=True)

            print(f"✅ {filename:<25} ({size}x{size})")
            success_count += 1

        except Exception as e:
            print(f"❌ {filename:<25} 失败: {e}")

    print()
    print(f"🎉 完成! 成功生成 {success_count}/{len(ICON_SIZES)} 个图标")

    # 更新 Contents.json
    update_contents_json(output_dir)


def update_contents_json(output_dir: Path):
    """生成或更新 Contents.json 文件"""

    contents = {
        "images": [
            # iPhone
            {
                "filename": "Icon-20@2x.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "20x20"
            },
            {
                "filename": "Icon-20@3x.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "20x20"
            },
            {
                "filename": "Icon-29@2x.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "29x29"
            },
            {
                "filename": "Icon-29@3x.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "29x29"
            },
            {
                "filename": "Icon-40@2x.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "40x40"
            },
            {
                "filename": "Icon-40@3x.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "40x40"
            },
            {
                "filename": "Icon-60@2x.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "60x60"
            },
            {
                "filename": "Icon-60@3x.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "60x60"
            },
            # iPad
            {
                "filename": "Icon-20.png",
                "idiom": "ipad",
                "scale": "1x",
                "size": "20x20"
            },
            {
                "filename": "Icon-20@2x.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "20x20"
            },
            {
                "filename": "Icon-29.png",
                "idiom": "ipad",
                "scale": "1x",
                "size": "29x29"
            },
            {
                "filename": "Icon-29@2x.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "29x29"
            },
            {
                "filename": "Icon-40.png",
                "idiom": "ipad",
                "scale": "1x",
                "size": "40x40"
            },
            {
                "filename": "Icon-40@2x.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "40x40"
            },
            {
                "filename": "Icon-76.png",
                "idiom": "ipad",
                "scale": "1x",
                "size": "76x76"
            },
            {
                "filename": "Icon-76@2x.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "76x76"
            },
            {
                "filename": "Icon-83.5@2x.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "83.5x83.5"
            },
            # App Store
            {
                "filename": "Icon-1024.png",
                "idiom": "ios-marketing",
                "scale": "1x",
                "size": "1024x1024"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }

    import json

    contents_path = output_dir / "Contents.json"
    with open(contents_path, 'w') as f:
        json.dump(contents, f, indent=2)

    print(f"📝 已生成 Contents.json")


if __name__ == "__main__":
    # 配置路径
    script_dir = Path(__file__).parent
    svg_file = script_dir / "app_icon_design.svg"
    output_directory = script_dir / "TodoList" / "Assets.xcassets" / "AppIcon.appiconset"

    # 生成图标
    generate_icons(svg_file, output_directory)

    print()
    print("📌 下一步操作：")
    print("   1. 在 Xcode 中打开项目")
    print("   2. 查看 Assets.xcassets -> AppIcon")
    print("   3. 所有尺寸的图标已自动填充")
    print("   4. 运行项目即可看到新图标！")
