/**
 * 统计视图
 *
 * 展示各种统计数据和图表
 */

import SwiftUI
import SwiftData

struct StatisticsView: View {
    // MARK: - 环境

    @Environment(AuthViewModel.self) private var authViewModel

    // MARK: - 状态

    @State private var viewModel: StatisticsViewModel

    // MARK: - 初始化

    init(authViewModel: AuthViewModel) {
        _viewModel = State(initialValue: StatisticsViewModel(authViewModel: authViewModel))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.largeSpacing) {
                    // 概览卡片
                    overviewSection

                    // 完成率圆环
                    completionRateSection

                    // 优先级分布
                    priorityDistributionSection

                    // 分类统计
                    categoryStatsSection

                    // 7天趋势
                    weekTrendSection

                    // 本周统计
                    thisWeekSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("统计")
            .onAppear {
                viewModel.loadData()
            }
            .refreshable {
                viewModel.loadData()
            }
        }
    }

    // MARK: - 子视图

    /// 概览部分
    private var overviewSection: some View {
        VStack(spacing: 0) {
            // 标题
            HStack {
                Text("数据概览")
                    .font(.headline)
                Spacer()
            }
            .padding(.bottom, 12)

            // 统计卡片网格
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                StatCard(
                    title: "总任务",
                    value: "\(viewModel.totalTaskCount)",
                    icon: "list.bullet",
                    color: .blue
                )

                StatCard(
                    title: "已完成",
                    value: "\(viewModel.completedTaskCount)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatCard(
                    title: "进行中",
                    value: "\(viewModel.activeTaskCount)",
                    icon: "clock.fill",
                    color: .orange
                )

                StatCard(
                    title: "已逾期",
                    value: "\(viewModel.overdueTaskCount)",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                )
            }
        }
    }

    /// 完成率部分
    private var completionRateSection: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text("完成率")
                    .font(.headline)
                Spacer()
                Text("\(Int(viewModel.completionRate * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }

            // 进度环
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 180, height: 180)

                Circle()
                    .trim(from: 0, to: viewModel.completionRate)
                    .stroke(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(viewModel.completedTaskCount)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.primary)

                    Text("/ \(viewModel.totalTaskCount) 任务")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // 番茄钟统计
            HStack(spacing: 20) {
                Image(systemName: "timer.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text("累计番茄钟")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(viewModel.totalPomodoroCount) 个")
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Spacer()
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(Layout.smallCornerRadius)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    /// 优先级分布部分
    private var priorityDistributionSection: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text("优先级分布")
                    .font(.headline)
                Spacer()
            }

            let priorityStats = viewModel.tasksByPriority().filter { $0.count > 0 }

            if priorityStats.isEmpty {
                emptyStateView(message: "暂无数据")
            } else {
                HStack(spacing: 20) {
                    // 饼图
                    PieChartView(
                        data: priorityStats.map { stat in
                            PieSliceData(
                                value: stat.count,
                                color: Color.priorityColor(stat.priority),
                                label: stat.priority.rawValue
                            )
                        },
                        size: 140
                    )

                    // 图例
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(priorityStats) { stat in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.priorityColor(stat.priority))
                                    .frame(width: 12, height: 12)

                                Text(stat.priority.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)

                                Spacer()

                                Text("\(stat.count)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    /// 分类统计部分
    private var categoryStatsSection: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text("分类统计")
                    .font(.headline)
                Spacer()
            }

            let categoryStats = viewModel.tasksByCategory()

            if categoryStats.isEmpty {
                emptyStateView(message: "暂无分类数据")
            } else {
                VStack(spacing: 12) {
                    ForEach(categoryStats.prefix(5)) { stat in
                        HStack {
                            // 图标
                            ZStack {
                                Circle()
                                    .fill(stat.color.opacity(0.2))
                                    .frame(width: 40, height: 40)

                                Image(systemName: stat.icon)
                                    .foregroundColor(stat.color)
                            }

                            // 名称
                            Text(stat.name)
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Spacer()

                            // 数量
                            Text("\(stat.count)")
                                .font(.headline)
                                .foregroundColor(.primary)

                            // 进度条
                            ProgressView(value: Double(stat.count), total: Double(viewModel.totalTaskCount))
                                .frame(width: 60)
                                .tint(stat.color)
                        }
                        .padding(.vertical, 8)

                        if stat.id != categoryStats.prefix(5).last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    /// 7天趋势部分
    private var weekTrendSection: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text("最近7天趋势")
                    .font(.headline)
                Spacer()
            }

            let trendData = viewModel.completionTrendLast7Days()

            if trendData.allSatisfy({ $0.completedCount == 0 && $0.createdCount == 0 }) {
                emptyStateView(message: "暂无趋势数据")
            } else {
                VStack(spacing: 12) {
                    // 折线图
                    LineChartView(
                        data: trendData.map { stat in
                            ChartDataPoint(
                                label: stat.dayName,
                                value: Double(stat.completedCount)
                            )
                        },
                        color: .blue,
                        height: 150
                    )

                    // X 轴标签
                    HStack {
                        ForEach(trendData) { stat in
                            VStack(spacing: 2) {
                                Text(stat.dayName)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                Text(stat.shortDate)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }

                    // 图例
                    HStack(spacing: 20) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                            Text("已完成")
                                .font(.caption)
                        }

                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 8, height: 8)
                            Text("新创建")
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    /// 本周统计部分
    private var thisWeekSection: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text("本周统计")
                    .font(.headline)
                Spacer()
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                // 本周完成
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)

                    Text("\(viewModel.thisWeekCompletedCount)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)

                    Text("本周完成")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(Layout.smallCornerRadius)

                // 本周创建
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)

                    Text("\(viewModel.thisWeekCreatedCount)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)

                    Text("本周创建")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(Layout.smallCornerRadius)
            }

            // 本周番茄钟
            HStack() {
                Spacer()
                Image(systemName: "timer.circle.fill")
                    .font(.title)
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 8) {
                    Text("本周番茄钟")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(viewModel.thisWeekPomodoroCount) 个")
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Spacer()
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(Layout.smallCornerRadius)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(Layout.mediumCornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    /// 空状态视图
    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - 预览

#Preview {
    let authViewModel = AuthViewModel()
    let mockUser = User(
        username: "预览用户",
        phoneNumber: "13800138000",
        email: "preview@example.com"
    )
    authViewModel.currentUser = mockUser

    return StatisticsView(authViewModel: authViewModel)
        .environment(authViewModel)
        .modelContainer(DataManager.shared.container)
}
