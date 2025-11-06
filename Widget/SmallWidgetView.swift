/**
 * 小号 Widget 视图
 *
 * 显示今日待办摘要
 * - 今日完成数/总数
 * - 完成率进度环
 * - 待办数量
 */

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: TodoWidgetEntry

    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                // 标题
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                    Text("今日待办")
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                }
                .foregroundColor(.white)

                Spacer()

                // 今日待办完成进度环
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 8)
                        .frame(width: 70, height: 70)

                    Circle()
                        .trim(from: 0, to: todayCompletionRate)
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: todayCompletionRate)

                    VStack(spacing: 2) {
                        Text("\(todayCompletedCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("/\(todayTotalCount)")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                }

                Spacer()

                // 底部统计
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("已完成")
                            .font(.caption2)
                        Text("\(todayCompletedCount)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("未完成")
                            .font(.caption2)
                        Text("\(todayUncompletedCount)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                .foregroundColor(.white)
            }
            .padding()
        }
    }

    // MARK: - 计算属性

    /// 今日待办总数
    private var todayTotalCount: Int {
        entry.todayTodos.count
    }

    /// 今日已完成数
    private var todayCompletedCount: Int {
        entry.todayTodos.filter { $0.isCompleted }.count
    }

    /// 今日未完成数
    private var todayUncompletedCount: Int {
        entry.todayTodos.filter { !$0.isCompleted }.count
    }

    /// 今日完成率
    private var todayCompletionRate: Double {
        guard todayTotalCount > 0 else { return 0 }
        return Double(todayCompletedCount) / Double(todayTotalCount)
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
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
            )
        ],
        statistics: WidgetStatistics(
            totalTodos: 10,
            completedTodos: 6,
            todayCompletedTodos: 2
        )
    )
}
