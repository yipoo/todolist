/**
 * Color 扩展
 *
 * 为 Color 添加便捷的初始化方法
 */

import SwiftUI

extension Color {
    // MARK: - 从十六进制创建

    /// 从十六进制字符串创建颜色
    /// - Parameter hex: 十六进制字符串（如 "#FF0000" 或 "FF0000"）
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - 转换为十六进制

    /// 转换为十六进制字符串
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])

        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }

    // MARK: - 预设颜色

    /// 优先级颜色
    static func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .gray
        }
    }

    /// 随机颜色
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

// MARK: - 颜色调整

extension Color {
    /// 调整亮度
    func lighter(by percentage: Double = 0.2) -> Color {
        return adjust(by: abs(percentage))
    }

    /// 调整暗度
    func darker(by percentage: Double = 0.2) -> Color {
        return adjust(by: -abs(percentage))
    }

    private func adjust(by percentage: Double) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return Color(
            .sRGB,
            red: min(Double(red + percentage), 1.0),
            green: min(Double(green + percentage), 1.0),
            blue: min(Double(blue + percentage), 1.0),
            opacity: Double(alpha)
        )
    }

    /// 计算颜色的相对亮度 (Relative Luminance)
    /// 使用 WCAG 2.0 标准公式
    var luminance: Double {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        func adjust(component: CGFloat) -> Double {
            let value = Double(component)
            if value <= 0.03928 {
                return value / 12.92
            } else {
                return pow((value + 0.055) / 1.055, 2.4)
            }
        }

        let r = adjust(component: red)
        let g = adjust(component: green)
        let b = adjust(component: blue)

        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    /// 判断颜色是否为深色
    var isDark: Bool {
        return luminance < 0.5
    }

    /// 获取与背景形成良好对比的文字颜色
    var contrastingTextColor: Color {
        return isDark ? .white : .black
    }

    /// 获取与背景形成对比的柔和文字颜色
    var softContrastingTextColor: Color {
        return isDark ? Color.white.opacity(0.9) : Color.black.opacity(0.85)
    }
}
