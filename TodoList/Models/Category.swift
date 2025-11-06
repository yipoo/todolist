/**
 * 分类数据模型
 *
 * 用于组织和分类待办事项
 */

import Foundation
import SwiftData

@Model
final class Category {
    // MARK: - 属性

    /// 唯一标识符
    @Attribute(.unique) var id: UUID

    /// 分类名称
    var name: String

    /// SF Symbols 图标名称
    var icon: String

    /// 颜色（十六进制字符串，如 "#FF0000"）
    var colorHex: String

    /// 排序顺序
    var sortOrder: Int

    /// 创建时间
    var createdAt: Date

    /// 是否为系统预设分类（不可删除）
    var isSystem: Bool

    // MARK: - 关系

    /// 所属用户
    var user: User?

    /// 该分类下的所有待办事项
    @Relationship(inverse: \TodoItem.category)
    var todos: [TodoItem] = []

    // MARK: - 初始化

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String,
        sortOrder: Int = 0,
        isSystem: Bool = false,
        user: User? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.createdAt = Date()
        self.isSystem = isSystem
        self.user = user
    }

    // MARK: - 便捷方法

    /// 获取该分类下未完成的待办数量
    func uncompletedCount() -> Int {
        todos.filter { !$0.isCompleted }.count
    }

    /// 获取该分类下今天的待办数量
    func todayCount() -> Int {
        let calendar = Calendar.current
        return todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return calendar.isDateInToday(dueDate) && !todo.isCompleted
        }.count
    }

    /// 获取该分类下所有待办数量
    func totalCount() -> Int {
        todos.count
    }

    /// 获取该分类下已完成的待办数量
    func completedCount() -> Int {
        todos.filter { $0.isCompleted }.count
    }

    /// 获取完成进度（0.0 - 1.0）
    func completionProgress() -> Double {
        let total = todos.count
        guard total > 0 else { return 0 }
        let completed = completedCount()
        return Double(completed) / Double(total)
    }

    /// 获取该分类下逾期的待办数量
    func overdueCount() -> Int {
        todos.filter { $0.isOverdue() }.count
    }
}

// MARK: - 预设分类

extension Category {
    /// 创建系统预设分类
    static func createSystemCategories(for user: User) -> [Category] {
        return [
            Category(
                name: "工作",
                icon: "briefcase.fill",
                colorHex: "#007AFF",
                sortOrder: 1,
                isSystem: true,
                user: user
            ),
            Category(
                name: "生活",
                icon: "house.fill",
                colorHex: "#34C759",
                sortOrder: 2,
                isSystem: true,
                user: user
            ),
            Category(
                name: "学习",
                icon: "book.fill",
                colorHex: "#FF9500",
                sortOrder: 3,
                isSystem: true,
                user: user
            ),
            Category(
                name: "健康",
                icon: "heart.fill",
                colorHex: "#FF3B30",
                sortOrder: 4,
                isSystem: true,
                user: user
            ),
            Category(
                name: "目标",
                icon: "target",
                colorHex: "#AF52DE",
                sortOrder: 5,
                isSystem: true,
                user: user
            )
        ]
    }
}
