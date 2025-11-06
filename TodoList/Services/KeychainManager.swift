/**
 * Keychain 管理器
 *
 * 安全存储敏感信息（密码、Token 等）
 * Keychain 是 iOS 提供的加密存储，比 UserDefaults 更安全
 */

import Foundation
import Security

final class KeychainManager {
    // MARK: - 单例

    static let shared = KeychainManager()

    private init() {}

    // MARK: - 公开方法

    /// 保存密码
    func savePassword(_ password: String, for username: String) -> Bool {
        let key = KeychainKeys.userPassword + ".\(username)"
        return save(password, forKey: key)
    }

    /// 获取密码
    func getPassword(for username: String) -> String? {
        let key = KeychainKeys.userPassword + ".\(username)"
        return get(forKey: key)
    }

    /// 删除密码
    func deletePassword(for username: String) -> Bool {
        let key = KeychainKeys.userPassword + ".\(username)"
        return delete(forKey: key)
    }

    /// 保存登录 Token
    func saveLoginToken(_ token: String) -> Bool {
        return save(token, forKey: KeychainKeys.loginToken)
    }

    /// 获取登录 Token
    func getLoginToken() -> String? {
        return get(forKey: KeychainKeys.loginToken)
    }

    /// 删除登录 Token
    func deleteLoginToken() -> Bool {
        return delete(forKey: KeychainKeys.loginToken)
    }

    /// 清空所有数据
    func clearAll() {
        deleteLoginToken()
        // 可以添加更多清理操作
    }

    // MARK: - 私有方法

    /// 保存数据到 Keychain
    private func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // 删除旧数据（如果存在）
        delete(forKey: key)

        // 构建查询字典
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        // 添加到 Keychain
        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            print("✅ Keychain 保存成功: \(key)")
            return true
        } else {
            print("❌ Keychain 保存失败: \(key), 错误: \(status)")
            return false
        }
    }

    /// 从 Keychain 获取数据
    private func get(forKey key: String) -> String? {
        // 构建查询字典
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        } else {
            return nil
        }
    }

    /// 从 Keychain 删除数据
    private func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// 更新 Keychain 数据
    private func update(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        return status == errSecSuccess
    }
}

// MARK: - 扩展：批量操作

extension KeychainManager {
    /// 保存多个键值对
    func saveBatch(_ items: [String: String]) -> Bool {
        var allSuccess = true
        for (key, value) in items {
            if !save(value, forKey: key) {
                allSuccess = false
            }
        }
        return allSuccess
    }

    /// 删除多个键
    func deleteBatch(_ keys: [String]) -> Bool {
        var allSuccess = true
        for key in keys {
            if !delete(forKey: key) {
                allSuccess = false
            }
        }
        return allSuccess
    }
}

// MARK: - 扩展：密码哈希

extension KeychainManager {
    /// 对密码进行哈希（SHA256）
    static func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// 验证密码
    static func verifyPassword(_ password: String, hashedPassword: String) -> Bool {
        return hashPassword(password) == hashedPassword
    }
}

// MARK: - SHA256 哈希（简化版）

import CryptoKit

struct SHA256 {
    static func hash(data: Data) -> Data {
        let hashed = CryptoKit.SHA256.hash(data: data)
        return Data(hashed)
    }
}
