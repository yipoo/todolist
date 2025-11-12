/**
 * 中号 Widget 视图
 *
 * 显示待办列表
 * - 标题和完成率
 * - 最多显示 4 个待办事项
 * - 显示优先级和分类
 */

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: TodoWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 头部
            header

            // 待办列表
            if entry.todayTodos.isEmpty {
                emptyState
            } else {
                todoList
            }
        }
        .padding()
    }

    // MARK: - 头部

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("今日待办")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("完成 \(entry.statistics.todayCompletedTodos)/\(entry.todayTodos.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 完成率进度环（小）
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    .frame(width: 36, height: 36)

                Circle()
                    .trim(from: 0, to: completionRate)
                    .stroke(
                        completionRateColor,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(completionRate * 100))%")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                    .foregroundColor(completionRateColor)
            }
        }
    }

    // MARK: - 待办列表

    private var todoList: some View {
        VStack(spacing: 8) {
            // 今天待办按照未完成，时间最近排序
            let sortedTodos = entry.todayTodos.sorted { $0.dueDate ?? Date.distantFuture < $1.dueDate ?? Date.distantFuture }
            ForEach(Array(sortedTodos.prefix(3))) { todo in
                TodoRowView(todo: todo)
            }

            if entry.todayTodos.count > 3 {
                Text("还有 \(entry.todayTodos.count - 3) 个待办...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    // MARK: - 空状态

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 32))
                .foregroundColor(.green)

            Text("太棒了！今天没有待办")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 计算属性

    private var completionRate: Double {
        guard entry.todayTodos.count > 0 else { return 0 }
        let completed = entry.todayTodos.filter { $0.isCompleted }.count
        return Double(completed) / Double(entry.todayTodos.count)
    }

    private var completionRateColor: Color {
        if completionRate >= 0.8 {
            return .green
        } else if completionRate >= 0.5 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - 待办行视图

struct TodoRowView: View {
    let todo: WidgetTodoItem

    var body: some View {
        HStack(spacing: 8) {
            // 完成状态图标
            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundColor(todo.isCompleted ? .green : .gray)

            // 待办标题
            Text(todo.title)
                .font(.subheadline)
                .foregroundColor(todo.isCompleted ? .secondary : .primary)
                .strikethrough(todo.isCompleted)
                .lineLimit(1)

            Spacer()

            // 分类标签
            if let categoryName = todo.categoryName {
                Text(categoryName)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(categoryBackgroundColor)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
        }
    }

    private var categoryBackgroundColor: Color {
        guard let colorHex = todo.categoryColor else { return .blue }
        return Color(hex: colorHex) ?? .blue
    }
}

// MARK: - Color Extension for Hex

extension Color {
    /// 从十六进制字符串创建颜色
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    TodoListStaticWidget()
} timeline: {
    TodoWidgetEntry(
        date: Date(),
        todayTodos: [
            WidgetTodoItem(
                id: UUID(),
                title: "完成项目报告",
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
            )
        ],
        statistics: WidgetStatistics(
            totalTodos: 10,
            completedTodos: 6,
            todayCompletedTodos: 1
        )
    )
}
