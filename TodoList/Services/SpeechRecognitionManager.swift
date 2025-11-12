/**
 * 语音识别管理器
 *
 * 功能：
 * - 使用 Apple Speech Framework 进行语音识别
 * - 实时转换语音为文字
 * - 权限管理
 * - 错误处理
 *
 * 使用示例：
 * let manager = SpeechRecognitionManager()
 * await manager.requestPermission()
 * manager.startRecording { text in
 *     print("识别到: \(text)")
 * }
 */

import Foundation
import Speech
import AVFoundation
import Observation

@Observable
@MainActor
final class SpeechRecognitionManager: NSObject {

    // MARK: - Properties

    /// 是否正在录音
    var isRecording = false

    /// 识别到的文本
    var recognizedText = ""

    /// 错误消息
    var errorMessage: String?

    /// 授权状态
    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    // MARK: - Private Properties

    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // MARK: - Initialization

    override init() {
        // 初始化语音识别器（使用系统语言，中文为 zh-CN）
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
        super.init()

        // 设置代理
        speechRecognizer?.delegate = self

        // 获取当前授权状态
        authorizationStatus = SFSpeechRecognizer.authorizationStatus()
    }

    // MARK: - Permission

    /// 请求语音识别权限
    func requestPermission() async -> Bool {
        // 1. 请求语音识别权限
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        authorizationStatus = speechStatus

        guard speechStatus == .authorized else {
            errorMessage = "语音识别权限未授权"
            return false
        }

        // 2. 请求麦克风权限
        let microphoneStatus = await AVAudioApplication.requestRecordPermission()

        guard microphoneStatus else {
            errorMessage = "麦克风权限未授权"
            return false
        }

        return true
    }

    // MARK: - Recording

    /// 开始录音识别
    func startRecording(onResult: @escaping (String) -> Void) throws {
        // 检查是否已经在录音
        guard !isRecording else {
            throw SpeechError.alreadyRecording
        }

        // 检查语音识别器是否可用
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechError.recognizerUnavailable
        }

        // 检查授权状态
        guard authorizationStatus == .authorized else {
            throw SpeechError.notAuthorized
        }

        // 取消之前的任务
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        // 配置音频会话
        #if os(iOS)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        #endif

        // 创建识别请求
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.requestCreationFailed
        }

        // 配置识别请求
        recognitionRequest.shouldReportPartialResults = true // 实时返回部分结果

        // 如果设备支持，使用设备上的识别（更快、更隐私）
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }

        // 获取音频输入节点
        let inputNode = audioEngine.inputNode

        // 清空之前识别的文本
        recognizedText = ""
        errorMessage = nil

        // 开始识别任务
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            var isFinal = false

            if let result = result {
                // 更新识别到的文本
                Task { @MainActor in
                    self.recognizedText = result.bestTranscription.formattedString
                    onResult(self.recognizedText)
                }
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                // 停止音频引擎
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                Task { @MainActor in
                    self.isRecording = false

                    if let error = error {
                        self.errorMessage = "识别错误: \(error.localizedDescription)"
                    }
                }
            }
        }

        // 配置音频输入
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        // 准备并启动音频引擎
        audioEngine.prepare()
        try audioEngine.start()

        isRecording = true
    }

    /// 停止录音识别
    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }

        isRecording = false
    }

    /// 取消录音
    func cancelRecording() {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        stopRecording()
        recognizedText = ""
    }

    // MARK: - Helper Methods

    /// 重置状态
    func reset() {
        cancelRecording()
        recognizedText = ""
        errorMessage = nil
    }
}

// MARK: - SFSpeechRecognizerDelegate

extension SpeechRecognitionManager: SFSpeechRecognizerDelegate {
    nonisolated func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        Task { @MainActor in
            if !available {
                errorMessage = "语音识别暂时不可用"
            }
        }
    }
}

// MARK: - Error Types

enum SpeechError: LocalizedError {
    case alreadyRecording
    case recognizerUnavailable
    case notAuthorized
    case requestCreationFailed

    var errorDescription: String? {
        switch self {
        case .alreadyRecording:
            return "已经在录音中"
        case .recognizerUnavailable:
            return "语音识别服务不可用"
        case .notAuthorized:
            return "未获得语音识别授权"
        case .requestCreationFailed:
            return "创建识别请求失败"
        }
    }
}
