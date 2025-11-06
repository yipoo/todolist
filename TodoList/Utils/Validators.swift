/**
 * 验证工具类
 *
 * 提供各种输入验证功能
 * 类似前端的表单验证
 */

import Foundation

struct Validators {
    // MARK: - 用户名验证

    /// 验证用户名
    /// - Parameter username: 用户名
    /// - Returns: 验证结果
    static func validateUsername(_ username: String) -> ValidationResult {
        // 去除首尾空格
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)

        // 检查长度
        guard trimmed.count >= ValidationRules.minUsernameLength else {
            return .failure("用户名至少 \(ValidationRules.minUsernameLength) 个字符")
        }

        guard trimmed.count <= ValidationRules.maxUsernameLength else {
            return .failure("用户名最多 \(ValidationRules.maxUsernameLength) 个字符")
        }

        // 检查格式（字母、数字、下划线）
        let regex = ValidationRules.usernameRegex
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)

        guard predicate.evaluate(with: trimmed) else {
            return .failure("用户名只能包含字母、数字和下划线")
        }

        return .success
    }

    // MARK: - 手机号验证

    /// 验证手机号码（中国大陆）
    static func validatePhoneNumber(_ phone: String) -> ValidationResult {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return .failure("手机号不能为空")
        }

        // 中国大陆手机号：1开头，11位数字
        let regex = "^1[3-9]\\d{9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)

        guard predicate.evaluate(with: trimmed) else {
            return .failure("请输入正确的手机号码")
        }

        return .success
    }

    /// 验证验证码（6位数字）
    static func validateVerificationCode(_ code: String) -> ValidationResult {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return .failure("验证码不能为空")
        }

        guard trimmed.count == 6 else {
            return .failure("验证码为6位数字")
        }

        let regex = "^\\d{6}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)

        guard predicate.evaluate(with: trimmed) else {
            return .failure("验证码格式不正确")
        }

        return .success
    }

    // MARK: - 邮箱验证

    /// 验证邮箱
    static func validateEmail(_ email: String) -> ValidationResult {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return .failure("邮箱不能为空")
        }

        let regex = ValidationRules.emailRegex
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)

        guard predicate.evaluate(with: trimmed) else {
            return .failure("邮箱格式不正确")
        }

        return .success
    }

    /// 简单验证邮箱格式（返回Bool）
    static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = ValidationRules.emailRegex
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: trimmed)
    }

    // MARK: - 密码验证

    /// 验证密码
    static func validatePassword(_ password: String) -> ValidationResult {
        guard password.count >= ValidationRules.minPasswordLength else {
            return .failure("密码至少 \(ValidationRules.minPasswordLength) 个字符")
        }

        guard password.count <= ValidationRules.maxPasswordLength else {
            return .failure("密码最多 \(ValidationRules.maxPasswordLength) 个字符")
        }

        // 检查是否包含字母
        let hasLetters = password.rangeOfCharacter(from: .letters) != nil

        // 检查是否包含数字
        let hasNumbers = password.rangeOfCharacter(from: .decimalDigits) != nil

        guard hasLetters && hasNumbers else {
            return .failure("密码必须包含字母和数字")
        }

        return .success
    }

    /// 验证密码强度
    static func passwordStrength(_ password: String) -> PasswordStrength {
        var score = 0

        // 长度加分
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }

        // 包含小写字母
        if password.rangeOfCharacter(from: .lowercaseLetters) != nil { score += 1 }

        // 包含大写字母
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }

        // 包含数字
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }

        // 包含特殊字符
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        if password.rangeOfCharacter(from: specialCharacters) != nil { score += 1 }

        switch score {
        case 0...2:
            return .weak
        case 3...4:
            return .medium
        default:
            return .strong
        }
    }

    // MARK: - 待办标题验证

    /// 验证待办标题
    static func validateTodoTitle(_ title: String) -> ValidationResult {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return .failure("标题不能为空")
        }

        guard trimmed.count <= 100 else {
            return .failure("标题最多 100 个字符")
        }

        return .success
    }

    // MARK: - 通用验证

    /// 验证非空字符串
    static func validateNonEmpty(_ text: String, fieldName: String = "此字段") -> ValidationResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return .failure("\(fieldName)不能为空")
        }

        return .success
    }

    /// 验证字符串长度
    static func validateLength(
        _ text: String,
        min: Int,
        max: Int,
        fieldName: String = "此字段"
    ) -> ValidationResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.count >= min else {
            return .failure("\(fieldName)至少 \(min) 个字符")
        }

        guard trimmed.count <= max else {
            return .failure("\(fieldName)最多 \(max) 个字符")
        }

        return .success
    }
}

// MARK: - 验证结果

enum ValidationResult {
    case success
    case failure(String)

    var isValid: Bool {
        if case .success = self {
            return true
        }
        return false
    }

    var errorMessage: String? {
        if case .failure(let message) = self {
            return message
        }
        return nil
    }
}

// MARK: - 密码强度

enum PasswordStrength {
    case weak
    case medium
    case strong

    var description: String {
        switch self {
        case .weak: return "弱"
        case .medium: return "中等"
        case .strong: return "强"
        }
    }

    var color: String {
        switch self {
        case .weak: return "red"
        case .medium: return "orange"
        case .strong: return "green"
        }
    }

    var progress: Double {
        switch self {
        case .weak: return 0.33
        case .medium: return 0.66
        case .strong: return 1.0
        }
    }
}

// MARK: - 批量验证

struct FormValidation {
    /// 验证多个字段
    static func validateAll(_ validations: [ValidationResult]) -> ValidationResult {
        for validation in validations {
            if case .failure(let message) = validation {
                return .failure(message)
            }
        }
        return .success
    }

    /// 验证登录表单
    static func validateLoginForm(email: String, password: String) -> ValidationResult {
        return validateAll([
            Validators.validateEmail(email),
            Validators.validateNonEmpty(password, fieldName: "密码")
        ])
    }

    /// 验证注册表单
    static func validateRegistrationForm(
        username: String,
        email: String,
        password: String,
        confirmPassword: String
    ) -> ValidationResult {
        // 先验证各个字段
        let results = [
            Validators.validateUsername(username),
            Validators.validateEmail(email),
            Validators.validatePassword(password)
        ]

        // 检查是否有失败
        if let failure = results.first(where: { !$0.isValid }) {
            return failure
        }

        // 验证密码确认
        guard password == confirmPassword else {
            return .failure("两次输入的密码不一致")
        }

        return .success
    }
}
