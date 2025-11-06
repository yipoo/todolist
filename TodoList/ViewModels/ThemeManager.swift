/**
 * 主题管理器
 *
 * 管理应用全局主题和外观
 */

import SwiftUI

@Observable
final class ThemeManager {
    // MARK: - 单例

    static let shared = ThemeManager()

    // MARK: - 属性

    private let preferences = UserPreferencesManager.shared

    var currentTheme: AppTheme {
        get { preferences.theme }
        set { preferences.theme = newValue }
    }

    /// 获取当前应该使用的 ColorScheme
    var colorScheme: ColorScheme? {
        currentTheme.systemColorScheme
    }

    // MARK: - 初始化

    private init() {}

    // MARK: - 方法

    /// 设置主题
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }

    /// 获取主题显示名称
    func themeName() -> String {
        currentTheme.rawValue
    }

    /// 是否为深色模式（根据系统或设置）
    func isDarkMode(_ systemColorScheme: ColorScheme) -> Bool {
        switch currentTheme {
        case .light:
            return false
        case .dark:
            return true
        case .system:
            return systemColorScheme == .dark
        }
    }
}
