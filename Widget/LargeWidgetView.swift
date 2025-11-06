/**
 * 大号 Widget 视图
 *
 * 显示完整视图 + 统计
 * - 统计卡片
 * - 待办列表
 * - 优先级分布
 */

import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let entry: TodoWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 头部统计
            statisticsHeader

            Divider()

            // 待办列表
            if entry.todayTodos.isEmpty {
                emptyState
            } else {
                todoListSection
            }
        }
        .padding()
    }

    // MARK: - 统计头部

    private var statisticsHeader: some View {
        VStack(spacing: 12) {
            // 标题
            HStack {
                Text("待办事项")
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 统计卡片
            HStack(spacing: 12) {
                statCard(
                    title: "总任务",
                    value: "\(entry.statistics.totalTodos)",
                    icon: "list.bullet",
                    color: .blue
                )

                statCard(
                    title: "已完成",
                    value: "\(entry.statistics.completedTodos)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                statCard(
                    title: "今日完成",
                    value: "\(entry.statistics.todayCompletedTodos)",
                    icon: "calendar",
                    color: .orange
                )

                // 完成率
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                            .frame(width: 48, height: 48)

                        Circle()
                            .trim(from: 0, to: entry.statistics.completionRate)
                            .stroke(
                                completionColor,
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 48, height: 48)
                            .rotationEffect(.degrees(-90))

                        Text("\(Int(entry.statistics.completionRate * 100))%")
                            .font(.caption)
                            .fontWeight(.bold)
                    }

                    Text("完成率")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - 待办列表区域

    private var todoListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("今日待办")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                if entry.todayTodos.count > 6 {
                    Text("显示 6/\(entry.todayTodos.count)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            ForEach(Array(entry.todayTodos.prefix(6))) { todo in
                LargeTodoRowView(todo: todo)
            }

            if entry.todayTodos.count > 6 {
                Text("还有 \(entry.todayTodos.count - 6) 个待办，打开应用查看")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
        }
    }

    // MARK: - 空状态

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundColor(.green)

            Text("太棒了！")
                .font(.title3)
                .fontWeight(.bold)

            Text("今天没有待办事项")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 统计卡片

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 计算属性

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: entry.date)
    }

    private var completionColor: Color {
        let rate = entry.statistics.completionRate
        if rate >= 0.8 {
            return .green
        } else if rate >= 0.5 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - 大号待办行视图

struct LargeTodoRowView: View {
    let todo: WidgetTodoItem

    var body: some View {
        HStack(spacing: 10) {
            // 完成状态
            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 18))
                .foregroundColor(todo.isCompleted ? .green : .gray)

            // 内容
            VStack(alignment: .leading, spacing: 2) {
                Text(todo.title)
                    .font(.subheadline)
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    .strikethrough(todo.isCompleted)
                    .lineLimit(1)

                if let dueDate = todo.dueDate {
                    Text(formattedTime(dueDate))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // 分类标签
            if let categoryName = todo.categoryName {
                Text(categoryName)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(categoryBackgroundColor)
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - 辅助方法

    private var categoryBackgroundColor: Color {
        guard let colorHex = todo.categoryColor else { return .blue }
        return Color(hex: colorHex) ?? .blue
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview(as: .systemLarge) {
    TodoListStaticWidget()
} timeline: {
    TodoWidgetEntry(
        date: Date(),
        todayTodos: [
            WidgetTodoItem(
                id: UUID(),
                title: "完成 Widget 开发",
                isCompleted: false,
                priority: "high",
                dueDate: Date(),
                categoryName: "工作",
                categoryColor: "blue"
            ),
            WidgetTodoItem(
                id: UUID(),
                title: "Code Review",
                isCompleted: true,
                priority: "high",
                dueDate: Date(),
                categoryName: "工作",
                categoryColor: "blue"
            ),
            WidgetTodoItem(
                id: UUID(),
                title: "晚上跑步",
                isCompleted: false,
                priority: "medium",
                dueDate: Date(),
                categoryName: "健康",
                categoryColor: "green"
            ),
            WidgetTodoItem(
                id: UUID(),
                title: "买菜做饭",
                isCompleted: false,
                priority: "low",
                dueDate: Date(),
                categoryName: "生活",
                categoryColor: "orange"
            ),
            WidgetTodoItem(
                id: UUID(),
                title: "学习 SwiftUI",
                isCompleted: false,
                priority: "medium",
                dueDate: Date(),
                categoryName: "学习",
                categoryColor: "purple"
            )
        ],
        statistics: WidgetStatistics(
            totalTodos: 15,
            completedTodos: 9,
            todayCompletedTodos: 3
        )
    )
}
