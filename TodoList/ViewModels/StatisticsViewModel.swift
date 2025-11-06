/**
 * 统计视图模型
 *
 * 负责统计数据的计算和管理
 */

import Foundation
import SwiftUI

@Observable
@MainActor
final class StatisticsViewModel {
    // MARK: - 属性

    private let dataManager = DataManager.shared
    private let authViewModel: AuthViewModel

    var todos: [TodoItem] = []
    var categories: [Category] = []

    // MARK: - 初始化

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }

    // MARK: - 数据加载

    func loadData() {
        guard let user = authViewModel.currentUser else { return }
        todos = dataManager.fetchTodos(for: user)
        categories = dataManager.fetchCategories(for: user)
    }

    // MARK: - 总体统计

    /// 总任务数
    var totalTaskCount: Int {
        todos.count
    }

    /// 已完成任务数
    var completedTaskCount: Int {
        todos.filter { $0.isCompleted }.count
    }

    /// 进行中任务数
    var activeTaskCount: Int {
        todos.filter { !$0.isCompleted }.count
    }

    /// 逾期任务数
    var overdueTaskCount: Int {
        todos.filter { $0.isOverdue() }.count
    }

    /// 完成率
    var completionRate: Double {
        guard totalTaskCount > 0 else { return 0 }
        return Double(completedTaskCount) / Double(totalTaskCount)
    }

    /// 总番茄钟数
    var totalPomodoroCount: Int {
        todos.reduce(0) { $0 + $1.pomodoroCount }
    }

    // MARK: - 优先级统计

    /// 按优先级统计
    func tasksByPriority() -> [PriorityStats] {
        var stats: [Priority: Int] = [:]

        for priority in Priority.allCases {
            stats[priority] = todos.filter { $0.priority == priority }.count
        }

        return Priority.allCases.map { priority in
            PriorityStats(
                priority: priority,
                count: stats[priority] ?? 0
            )
        }
    }

    // MARK: - 分类统计

    /// 按分类统计
    func tasksByCategory() -> [CategoryStats] {
        var categoryMap: [UUID?: (category: Category?, count: Int)] = [:]

        for todo in todos {
            let key = todo.category?.id
            if var existing = categoryMap[key] {
                existing.count += 1
                categoryMap[key] = existing
            } else {
                categoryMap[key] = (category: todo.category, count: 1)
            }
        }

        return categoryMap.map { _, value in
            CategoryStats(
                category: value.category,
                count: value.count
            )
        }.sorted { $0.count > $1.count }
    }

    // MARK: - 完成趋势（最近7天）

    /// 最近7天完成趋势
    func completionTrendLast7Days() -> [DailyStats] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var stats: [DailyStats] = []

        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }

            let completed = todos.filter { todo in
                guard let completedAt = todo.completedAt else { return false }
                return calendar.isDate(completedAt, inSameDayAs: date)
            }.count

            let created = todos.filter { todo in
                calendar.isDate(todo.createdAt, inSameDayAs: date)
            }.count

            stats.append(DailyStats(
                date: date,
                completedCount: completed,
                createdCount: created
            ))
        }

        return stats.reversed()
    }

    // MARK: - 本周统计

    /// 本周完成数
    var thisWeekCompletedCount: Int {
        let calendar = Calendar.current
        let now = Date()

        return todos.filter { todo in
            guard let completedAt = todo.completedAt else { return false }
            return calendar.isDate(completedAt, equalTo: now, toGranularity: .weekOfYear)
        }.count
    }

    /// 本周创建数
    var thisWeekCreatedCount: Int {
        let calendar = Calendar.current
        let now = Date()

        return todos.filter { todo in
            calendar.isDate(todo.createdAt, equalTo: now, toGranularity: .weekOfYear)
        }.count
    }

    /// 本周番茄钟数
    var thisWeekPomodoroCount: Int {
        let calendar = Calendar.current
        let now = Date()

        return todos.filter { todo in
            calendar.isDate(todo.createdAt, equalTo: now, toGranularity: .weekOfYear)
        }.reduce(0) { $0 + $1.pomodoroCount }
    }
}

// MARK: - 统计数据结构

/// 优先级统计
struct PriorityStats: Identifiable {
    let id = UUID()
    let priority: Priority
    let count: Int

    var percentage: Double {
        // 在使用时需要传入总数来计算百分比
        0
    }
}

/// 分类统计
struct CategoryStats: Identifiable {
    let id = UUID()
    let category: Category?
    let count: Int

    var name: String {
        category?.name ?? "无分类"
    }

    var color: Color {
        if let category = category {
            return Color(hex: category.colorHex)
        }
        return .gray
    }

    var icon: String {
        category?.icon ?? "tray"
    }
}

/// 每日统计
struct DailyStats: Identifiable {
    let id = UUID()
    let date: Date
    let completedCount: Int
    let createdCount: Int

    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}
