/**
 * 子任务数据模型
 *
 * 待办事项的子任务，用于分解大任务
 */

import Foundation
import SwiftData

@Model
final class Subtask {
    // MARK: - 属性

    /// 唯一标识符
    @Attribute(.unique) var id: UUID

    /// 子任务标题
    var title: String

    /// 完成状态
    var isCompleted: Bool

    /// 排序顺序
    var sortOrder: Int

    /// 创建时间
    var createdAt: Date

    // MARK: - 关系

    /// 所属的待办事项
    var todo: TodoItem?

    // MARK: - 初始化

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        sortOrder: Int = 0,
        todo: TodoItem? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.sortOrder = sortOrder
        self.createdAt = Date()
        self.todo = todo
    }

    // MARK: - 便捷方法

    /// 切换完成状态
    func toggleCompletion() {
        isCompleted.toggle()
    }
}
