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
        VStack(spacing: 0) {
            // 顶部标题区域
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                Text("今日待办")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text(formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)

            Spacer(minLength: 0)

            // 中间进度环区域
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                    .frame(width: 90, height: 90)

                Circle()
                    .trim(from: 0, to: todayCompletionRate)
                    .stroke(
                        progressGradient,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: todayCompletionRate)

                VStack(spacing: 0) {
                    Text("\(todayCompletedCount)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    Text("/\(todayTotalCount)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            Spacer(minLength: 0)

            // 底部统计区域
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("已完成")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("\(todayCompletedCount)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(completionColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1, height: 30)

                VStack(alignment: .trailing, spacing: 3) {
                    Text("未完成")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("\(todayUncompletedCount)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.orange)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
    }

    // MARK: - 辅助属性

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: entry.date)
    }

    /// 进度环渐变色
    private var progressGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [.blue, .purple, .blue]),
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
    }

    /// 完成数量的颜色
    private var completionColor: Color {
        if todayCompletedCount >= todayTotalCount {
            return .green
        } else if todayCompletedCount > 0 {
            return .blue
        } else {
            return .gray
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
