/**
 * TodoList Widget
 *
 * 待办事项小组件
 * 支持小号、中号、大号三种尺寸
 */

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Widget Entry

/// Widget 数据快照
struct TodoWidgetEntry: TimelineEntry {
    let date: Date
    let todayTodos: [WidgetTodoItem]
    let statistics: WidgetStatistics
}

// MARK: - 简化的待办数据模型（用于 Widget）

/// Widget 使用的简化待办模型
struct WidgetTodoItem: Identifiable {
    let id: UUID
    let title: String
    let isCompleted: Bool
    let priority: String // "high", "medium", "low"
    let dueDate: Date?
    let categoryName: String?
    let categoryColor: String?
}

/// Widget 统计数据
struct WidgetStatistics {
    var totalTodos: Int = 0
    var completedTodos: Int = 0
    var todayCompletedTodos: Int = 0

    var completionRate: Double {
        totalTodos > 0 ? Double(completedTodos) / Double(totalTodos) : 0.0
    }
}

// MARK: - Timeline Provider

/// Widget 时间线提供者
struct TodoWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodoWidgetEntry {
        // 占位符数据（Widget 首次添加时显示）
        TodoWidgetEntry(
            date: Date(),
            todayTodos: placeholderTodos(),
            statistics: WidgetStatistics(
                totalTodos: 5,
                completedTodos: 3,
                todayCompletedTodos: 2
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoWidgetEntry) -> Void) {
        // 快照（用于 Widget 画廊预览）
        if context.isPreview {
            let entry = placeholder(in: context)
            completion(entry)
        } else {
            Task {
                let entry = await fetchData()
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoWidgetEntry>) -> Void) {
        // 时间线（实际显示的数据）
        Task {
            let entry = await fetchData()

            // 每 15 分钟更新一次
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

            completion(timeline)
        }
    }

    // MARK: - 数据获取

    /// 获取 Widget 数据
    private func fetchData() async -> TodoWidgetEntry {
        // 从 SwiftData 获取实际数据
        let todayTodos = await MainActor.run {
            WidgetDataProvider.getTodayTodos()
        }

        let statistics = await MainActor.run {
            WidgetDataProvider.getStatistics()
        }

        return TodoWidgetEntry(
            date: Date(),
            todayTodos: todayTodos,
            statistics: statistics
        )
    }

    /// 占位符待办数据
    private func placeholderTodos() -> [WidgetTodoItem] {
        [
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
                title: "健身锻炼",
                isCompleted: false,
                priority: "medium",
                dueDate: Date(),
                categoryName: "健康",
                categoryColor: "green"
            )
        ]
    }

    /// 示例待办数据
    private func sampleTodos() -> [WidgetTodoItem] {
        [
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
                isCompleted: false,
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
        ]
    }
}

// MARK: - Widget 配置

/// TodoList Widget
struct TodoListStaticWidget: Widget {
    let kind: String = "TodoListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoWidgetProvider()) { entry in
            TodoWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("待办事项")
        .description("快速查看你的待办任务")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget 主视图

/// Widget 入口视图（根据尺寸显示不同内容）
struct TodoWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: TodoWidgetEntry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
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
            )
        ],
        statistics: WidgetStatistics(
            totalTodos: 10,
            completedTodos: 6,
            todayCompletedTodos: 3
        )
    )
}

#Preview(as: .systemMedium) {
    TodoListStaticWidget()
} timeline: {
    TodoWidgetEntry(
        date: Date(),
        todayTodos: [],
        statistics: WidgetStatistics(
            totalTodos: 10,
            completedTodos: 6,
            todayCompletedTodos: 3
        )
    )
}

#Preview(as: .systemLarge) {
    TodoListStaticWidget()
} timeline: {
    TodoWidgetEntry(
        date: Date(),
        todayTodos: [],
        statistics: WidgetStatistics(
            totalTodos: 10,
            completedTodos: 6,
            todayCompletedTodos: 3
        )
    )
}
