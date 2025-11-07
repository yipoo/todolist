/**
 * 音频管理器
 *
 * 管理应用中的音效播放
 */

import Foundation
import AVFoundation

final class SoundManager {
    // MARK: - 单例
    
    static let shared = SoundManager()
    
    // MARK: - 属性
    
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - 音效类型
    
    enum SoundType: String {
        case pomodoroComplete = "pomodoro_complete"
        case breakComplete = "break_complete"
        case tick = "tick"
        
        var filename: String {
            rawValue
        }
    }
    
    // MARK: - 初始化
    
    private init() {
        setupAudioSession()
    }
    
    // MARK: - 设置
    
    /// 设置音频会话
    private func setupAudioSession() {
        #if os(iOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        #endif
    }
    
    // MARK: - 播放
    
    /// 播放音效
    /// - Parameters:
    ///   - type: 音效类型
    ///   - volume: 音量（0.0 - 1.0）
    func play(_ type: SoundType, volume: Float = 1.0) {
        // 如果使用系统声音
        if type == .pomodoroComplete || type == .breakComplete {
            playSystemSound()
            return
        }
        
        // 尝试从 Bundle 加载音频文件
        guard let url = Bundle.main.url(forResource: type.filename, withExtension: "mp3", subdirectory: "Sounds") ??
                        Bundle.main.url(forResource: type.filename, withExtension: "wav", subdirectory: "Sounds") ??
                        Bundle.main.url(forResource: type.filename, withExtension: "m4a", subdirectory: "Sounds") else {
            print("Sound file not found: \(type.filename)")
            // 降级到系统声音
            playSystemSound()
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
            // 降级到系统声音
            playSystemSound()
        }
    }
    
    /// 播放系统声音
    private func playSystemSound() {
        // 使用系统的 Tink 声音 (Sound ID 1306)
        // 或者使用默认提示音 (Sound ID 1005)
        AudioServicesPlaySystemSound(1306)
    }
    
    /// 停止播放
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    /// 预加载音效
    /// - Parameter type: 音效类型
    func preload(_ type: SoundType) {
        guard let url = Bundle.main.url(forResource: type.filename, withExtension: "mp3", subdirectory: "Sounds") ??
                        Bundle.main.url(forResource: type.filename, withExtension: "wav", subdirectory: "Sounds") ??
                        Bundle.main.url(forResource: type.filename, withExtension: "m4a", subdirectory: "Sounds") else {
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
        } catch {
            print("Failed to preload sound: \(error)")
        }
    }
}

