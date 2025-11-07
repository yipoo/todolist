/**
 * 快速添加待办 Widget
 *
 * iOS 17+ Interactive Widget
 * 支持直接在 Widget 上输入并添加待办事项
 */

import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Timeline Entry

struct QuickAddEntry: TimelineEntry {
    let date: Date
}

// MARK: - Timeline Provider

struct QuickAddProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickAddEntry {
        QuickAddEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickAddEntry) -> Void) {
        let entry = QuickAddEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickAddEntry>) -> Void) {
        let entry = QuickAddEntry(date: Date())

        // 每小时更新一次（实际上这个 Widget 不需要频繁更新）
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }
}

// MARK: - Widget Configuration

struct QuickAddWidget: Widget {
    let kind: String = "QuickAddWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickAddProvider()) { entry in
            QuickAddWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("快速添加")
        .description("快速添加待办事项")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget View

struct QuickAddWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: QuickAddEntry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallQuickAddView()
        case .systemMedium:
            MediumQuickAddView()
        default:
            SmallQuickAddView()
        }
    }
}

// MARK: - Small Widget View

struct SmallQuickAddView: View {
    var body: some View {
        if let url = URL(string: "todolist://add") {
            Link(destination: url) {
                VStack(spacing: 12) {
                    // 图标
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // 文字
                    VStack(spacing: 4) {
                        Text("快速添加")
                            .font(.headline)
                            .fontWeight(.bold)

                        Text("轻触添加待办")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)

                Text("配置错误")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Medium Widget View

struct MediumQuickAddView: View {
    var body: some View {
        if let url = URL(string: "todolist://add") {
            Link(destination: url) {
                HStack(spacing: 16) {
                    // 左侧图标
                    VStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .frame(width: 80)

                    // 右侧内容
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("快速添加待办")
                                .font(.headline)
                                .fontWeight(.bold)

                            Text("轻触打开添加页面")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        // 输入提示
                        HStack {
                            Image(systemName: "plus")
                                .font(.caption)
                                .foregroundColor(.blue)

                            Text("添加新的待办事项")
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }

                    Spacer()
                }
                .padding()
            }
        } else {
            HStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)

                Text("配置错误")
                    .font(.headline)

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    QuickAddWidget()
} timeline: {
    QuickAddEntry(date: Date())
}

#Preview(as: .systemMedium) {
    QuickAddWidget()
} timeline: {
    QuickAddEntry(date: Date())
}
