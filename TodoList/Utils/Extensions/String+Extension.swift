/**
 * String 扩展
 *
 * 为 String 添加常用的便捷方法
 */

import Foundation

extension String {
    // MARK: - 验证

    /// 是否为空（去除空格后）
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 是否为有效的邮箱
    var isValidEmail: Bool {
        let regex = ValidationRules.emailRegex
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }

    /// 是否为有效的用户名
    var isValidUsername: Bool {
        let regex = ValidationRules.usernameRegex
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }

    // MARK: - 转换

    /// 去除首尾空格
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 转换为 Date
    func toDate(format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }

    // MARK: - 截取

    /// 限制字符串长度
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            let index = self.index(self.startIndex, offsetBy: length)
            return String(self[..<index]) + trailing
        }
        return self
    }

    /// 获取子字符串
    subscript(range: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start..<end])
    }
}

// MARK: - 本地化

extension String {
    /// 本地化字符串
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    /// 本地化字符串（带参数）
    func localized(with arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }
}
