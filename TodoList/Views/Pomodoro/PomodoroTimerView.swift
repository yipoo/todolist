/**
 * 番茄钟计时器视图
 *
 * 简洁清爽的界面设计：
 * - 大字号显示剩余时间
 * - 圆形进度条
 * - 简单的控制按钮
 * - 整页滑动切换时长
 * - 运行时隐藏TabBar，点击空白处唤出
 */

import SwiftUI
import SwiftData

struct PomodoroTimerView: View {
    // MARK: - 环境

    @Environment(AuthViewModel.self) private var authViewModel
    @State private var viewModel: PomodoroViewModel

    // MARK: - 状态

    @State private var selectedPresetIndex: Int = 1 // 默认25分钟
    @State private var showTabBar = true

    // MARK: - 初始化

    init(authViewModel: AuthViewModel, todo: TodoItem? = nil) {
        _viewModel = State(initialValue: PomodoroViewModel(authViewModel: authViewModel))
        if let todo = todo {
            _viewModel.wrappedValue.setTodo(todo)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景渐变色
                backgroundGradient

                // 整页滑动切换预设
                if !viewModel.isRunning {
                    pageView
                } else {
                    runningView
                }
            }
            // .navigationTitle(currentPresetName)
            // .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .tabBar)
            .toolbar(showTabBar ? .visible : .hidden, for: .tabBar)
        }
    }

    // MARK: - 子视图

    /// 背景渐变色
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: sessionColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: viewModel.currentSessionType)
    }

    /// 整页滑动视图（未开始状态）
    private var pageView: some View {
        TabView(selection: $selectedPresetIndex) {
            ForEach(Array(PomodoroPreset.presets.enumerated()), id: \.offset) { index, preset in
                presetPageContent(preset: preset)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onChange(of: selectedPresetIndex) { _, newIndex in
            updateDuration(PomodoroPreset.presets[newIndex].duration)
        }
        .background(
            // 点击空白处的手势
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    // 空白处不做任何事
                }
        )
    }

    /// 预设页面内容
    private func presetPageContent(preset: PomodoroPreset) -> some View {
        VStack(spacing: 40) {
            Spacer()

            // 预设图标(对应 sessionTypeIndicator 的位置)
            HStack(spacing: 12) {
                Text(preset.emoji)
                    .font(.largeTitle)

                Text(preset.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.2))
            .cornerRadius(20)

            // 圆形计时器
            timerCircle

            // 时间显示
            timeDisplay

            // 开始按钮(对应 controlButtons 的位置)
            Button(action: {
                viewModel.start()
                showTabBar = false
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("开始")
                }
                .frame(width: 200, height: 56)
                .background(Color.white)
                .foregroundColor(Color(hex: viewModel.currentSessionType.colorHex))
                .cornerRadius(28)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }

            Spacer()

            // 番茄钟计数或关联待办
            bottomInfo
        }
        .padding()
    }

    /// 运行中视图
    private var runningView: some View {
        VStack(spacing: 40) {
            Spacer()

            // 会话类型指示器(对应预设图标的位置,保持布局一致)
            sessionTypeIndicator

            // 圆形计时器
            timerCircle

            // 时间显示
            timeDisplay

            // 控制按钮
            controlButtons

            Spacer()

            // 番茄钟计数或关联待办
            bottomInfo
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            // 点击空白处显示TabBar
            withAnimation {
                showTabBar.toggle()
            }
        }
    }

    /// 会话类型指示器
    private var sessionTypeIndicator: some View {
        HStack(spacing: 12) {
            Text(viewModel.currentSessionType.emoji)
                .font(.largeTitle)

            Text(viewModel.currentSessionType.rawValue)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.2))
        .cornerRadius(20)
    }

    /// 圆形计时器
    private var timerCircle: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 20)
                .frame(width: 280, height: 280)

            // 进度圆环
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
        }
    }

    /// 时间显示
    private var timeDisplay: some View {
        Text(viewModel.formattedTime)
            .font(.system(size: 72, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .monospacedDigit()
    }

    /// 控制按钮
    private var controlButtons: some View {
        HStack(spacing: 20) {
            // 暂停按钮
            Button(action: {
                viewModel.pause()
            }) {
                HStack {
                    Image(systemName: "pause.fill")
                    Text("暂停")
                }
                .frame(width: 120, height: 56)
                .background(Color.white.opacity(0.9))
                .foregroundColor(Color(hex: viewModel.currentSessionType.colorHex))
                .cornerRadius(28)
            }

            // 停止按钮
            Button(action: {
                viewModel.stop()
                showTabBar = true
            }) {
                Image(systemName: "stop.fill")
                    .frame(width: 56, height: 56)
                    .background(Color.white.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(28)
            }
        }
    }

    /// 底部信息
    private var bottomInfo: some View {
        VStack(spacing: 12) {
            // 关联的待办
            if let todo = viewModel.currentTodo {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white.opacity(0.8))
                    Text(todo.title)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .lineLimit(1)

                    if todo.estimatedPomodoros > 0 {
                        Text("\(todo.pomodoroCount)/\(todo.estimatedPomodoros)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.15))
                .cornerRadius(16)
            }

            // 番茄钟计数器（本轮）
            if !viewModel.isRunning || viewModel.currentSessionType == .work {
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.settings.sessionsBeforeLongBreak, id: \.self) { index in
                        Circle()
                            .fill(index < viewModel.completedPomodoros ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 12, height: 12)
                    }
                }
            }
        }
        .padding(.bottom, 20)
    }

    // MARK: - 辅助属性

    /// 当前预设名称
    private var currentPresetName: String {
        if viewModel.isRunning {
            // 运行时显示会话类型
            return "\(viewModel.currentSessionType.emoji) \(viewModel.currentSessionType.rawValue)"
        } else {
            return PomodoroPreset.presets[selectedPresetIndex].name
        }
    }

    /// 当前会话类型对应的渐变色
    private var sessionColors: [Color] {
        let baseColor = Color(hex: viewModel.currentSessionType.colorHex)
        return [
            baseColor,
            baseColor.opacity(0.7)
        ]
    }

    // MARK: - 方法

    /// 更新时长
    private func updateDuration(_ minutes: Int) {
        viewModel.settings.workDuration = minutes
        viewModel.remainingSeconds = minutes * 60
    }
}

// MARK: - 预览

#Preview {
    PomodoroTimerView(authViewModel: AuthViewModel())
        .environment(AuthViewModel())
        .modelContainer(DataManager.shared.container)
}
