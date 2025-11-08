/**
 * 待办列表行组件
 *
 * 显示单个待办事项的卡片
 * 支持快速操作：完成、删除
 */

import SwiftUI

struct TodoRow: View {
    // MARK: - 参数

    let todo: TodoItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onAddSubtask: ((String) -> Void)?

    // MARK: - 状态

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - 计算属性
    
    /// Card background color that works in both light and dark mode
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.15) : Color.white
    }

    // MARK: - Body

    var body: some View {
        HStack(alignment: .center,spacing: Layout.mediumSpacing) {
            // 完成状态按钮
            completionButton

            // 内容区域
            VStack(alignment: .leading) {
                // 标题和优先级
                titleRow

                // 描述
                if let description = todo.itemDescription, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // 底部信息：截止日期、分类、标签
                bottomInfo
            }

            Spacer()

            // 右侧信息
            rightInfo
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
        // 完成状态样式
        .opacity(todo.isCompleted ? 0.6 : 1.0)
    }

    // MARK: - 子视图

    /// 完成按钮
    private var completionButton: some View {
        Button(action: onToggle) {
            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(todo.isCompleted ? .green : .gray)
        }
        .buttonStyle(PlainButtonStyle())
    }

    /// 标题行
    private var titleRow: some View {
        HStack(spacing: 8) {
            // 标题
            Text(todo.title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .strikethrough(todo.isCompleted)

            // 优先级标签
            if todo.priority != .low {
                priorityBadge
            }
        }
    }

    /// 优先级徽章
    private var priorityBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: todo.priority.icon)
                .font(.caption2)
                .foregroundColor(.primary)

            Text(todo.priority.rawValue)
                .font(.caption2)
                .foregroundColor(.primary)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.priorityColor(todo.priority).opacity(0.1))
        .foregroundColor(Color.priorityColor(todo.priority))
        .cornerRadius(8)
    }

    /// 底部信息
    @ViewBuilder
    private var bottomInfo: some View {
        HStack(spacing: 12) {
            // 截止日期
            if let dueDate = todo.dueDate {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)

                    Text(dueDate.friendlyString)
                        .font(.caption)
                }
                .lineLimit(1)
                .foregroundColor(todo.isOverdue() ? .red : .secondary)
            }

            // 分类
            if let category = todo.category {
                HStack(spacing: 4) {
                    Image(systemName: category.icon)
                        .font(.caption2)

                    Text(category.name)
                        .font(.caption)
                }
                .foregroundColor(Color(hex: category.colorHex))
            }

            // 子任务进度
            if !todo.subtasks.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "checklist")
                        .font(.caption2)

                    let completedCount = todo.subtasks.filter { $0.isCompleted }.count
                    Text("\(completedCount)/\(todo.subtasks.count)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
    }

    /// 右侧信息
    @ViewBuilder
    private var rightInfo: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // 番茄钟数量
            if todo.pomodoroCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption)

                    Text("\(todo.pomodoroCount)")
                        .font(.caption)
                }
                .foregroundColor(.orange)
            }

            // 标签（最多显示2个）
            if !todo.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(todo.tags.prefix(2), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }

                    if todo.tags.count > 2 {
                        Text("+\(todo.tags.count - 2)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - 预览
