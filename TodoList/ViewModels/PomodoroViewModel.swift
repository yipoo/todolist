/**
 * 番茄钟视图模型
 *
 * 管理番茄钟的业务逻辑：
 * - 计时器管理
 * - 会话状态
 * - 设置管理
 */

import Foundation
import SwiftData
import Observation
import UserNotifications

@Observable
@MainActor
final class PomodoroViewModel {
    // MARK: - 依赖

    private let authViewModel: AuthViewModel
    private let dataManager = DataManager.shared

    // MARK: - 设置

    var settings: PomodoroSettings

    // MARK: - 状态

    /// 当前会话
    var currentSession: PomodoroSession?

    /// 计时器状态
    var isRunning = false

    /// 剩余秒数
    var remainingSeconds: Int = 25 * 60

    /// 当前会话类型
    var currentSessionType: SessionType = .work

    /// 当前关联的待办
    var currentTodo: TodoItem?

    /// 已完成的番茄钟数（本轮）
    var completedPomodoros: Int = 0

    /// 计时器
    private var timer: Timer?

    // MARK: - 计算属性

    /// 格式化的时间显示（MM:SS）
    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// 进度（0.0 - 1.0）
    var progress: Double {
        let total = Double(currentDuration * 60)
        guard total > 0 else { return 0 }
        let elapsed = total - Double(remainingSeconds)
        return min(1.0, max(0.0, elapsed / total))
    }

    /// 当前时长（分钟）
    var currentDuration: Int {
        switch currentSessionType {
        case .work:
            return settings.workDuration
        case .shortBreak:
            return settings.shortBreakDuration
        case .longBreak:
            return settings.longBreakDuration
        }
    }

    // MARK: - 初始化

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        self.settings = PomodoroSettings.load()
        self.remainingSeconds = settings.workDuration * 60
    }

    // MARK: - 计时器控制

    /// 开始计时
    func start() {
        guard !isRunning else { return }

        isRunning = true

        // 创建会话
        if currentSession == nil {
            let session = PomodoroSession(
                plannedDuration: currentDuration,
                sessionType: currentSessionType,
                todo: currentTodo,
                user: authViewModel.currentUser
            )
            currentSession = session

            // 保存到数据库
            try? dataManager.createPomodoroSession(session)
        }

        // 启动计时器（在主线程）
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                await self?.tick()
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    /// 暂停计时
    func pause() {
        guard isRunning else { return }

        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    /// 停止/放弃计时
    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil

        // 标记会话为放弃
        if let session = currentSession {
            session.abandon()
            try? dataManager.context.save()
        }

        // 重置状态
        reset()
    }

    /// 重置计时器
    func reset() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        currentSession = nil
        remainingSeconds = currentDuration * 60
    }

    /// 计时器滴答
    func tick() async {
        guard remainingSeconds > 0 else {
            complete()
            return
        }

        remainingSeconds -= 1
    }

    /// 完成当前会话
    private func complete() {
        isRunning = false
        timer?.invalidate()
        timer = nil

        // 标记会话为完成
        if let session = currentSession {
            session.complete()
            try? dataManager.context.save()
        }

        // 如果是工作会话，增加计数
        if currentSessionType == .work {
            completedPomodoros += 1
        }

        // 播放完成音效（可选）
        playCompletionSound()

        // 发送通知（可选）
        if settings.notificationsEnabled {
            sendCompletionNotification()
        }

        // 自动切换到下一个会话
        if shouldAutoStart() {
            switchToNextSession()
            start()
        } else {
            switchToNextSession()
            reset()
        }
    }

    // MARK: - 会话切换

    /// 切换到下一个会话
    func switchToNextSession() {
        switch currentSessionType {
        case .work:
            // 工作结束，判断是长休息还是短休息
            if completedPomodoros >= settings.sessionsBeforeLongBreak {
                currentSessionType = .longBreak
                completedPomodoros = 0
            } else {
                currentSessionType = .shortBreak
            }
        case .shortBreak, .longBreak:
            // 休息结束，开始工作
            currentSessionType = .work
        }

        remainingSeconds = currentDuration * 60
        currentSession = nil
    }

    /// 手动切换会话类型
    func setSessionType(_ type: SessionType) {
        guard !isRunning else { return }

        currentSessionType = type
        reset()
    }

    /// 是否应该自动开始
    private func shouldAutoStart() -> Bool {
        switch currentSessionType {
        case .work:
            return settings.autoStartBreaks
        case .shortBreak, .longBreak:
            return settings.autoStartPomodoros
        }
    }

    // MARK: - 待办关联

    /// 设置关联的待办
    func setTodo(_ todo: TodoItem?) {
        guard !isRunning else { return }
        currentTodo = todo
    }

    // MARK: - 设置管理

    /// 保存设置
    func saveSettings() {
        settings.save()
        // 如果没有在运行，更新剩余时间
        if !isRunning {
            remainingSeconds = currentDuration * 60
        }
    }

    // MARK: - 音效和通知

    /// 播放完成音效
    private func playCompletionSound() {
        guard settings.soundEnabled else { return }
        
        // 根据会话类型播放不同的音效
        let soundType: SoundManager.SoundType = currentSessionType == .work 
            ? .pomodoroComplete 
            : .breakComplete
        
        SoundManager.shared.play(soundType)
    }

    /// 发送完成通知
    private func sendCompletionNotification() {
        let content = UNMutableNotificationContent()
        
        // 根据会话类型设置通知内容
        switch currentSessionType {
        case .work:
            content.title = "🍅 番茄钟完成！"
            content.body = "工作时间结束，休息一下吧"
        case .shortBreak:
            content.title = "☕️ 短休息结束"
            content.body = "准备好开始下一个番茄钟了吗？"
        case .longBreak:
            content.title = "🎉 长休息结束"
            content.body = "你已经完成了一轮番茄钟，做得很棒！"
        }
        
        content.sound = .default
        
        // 立即触发通知
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }

}
