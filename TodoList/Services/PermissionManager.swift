/**
 * 权限管理器
 *
 * 统一管理应用的各种权限请求
 * - 相机权限
 * - 相册权限
 * - 通知权限
 */

import Foundation
import AVFoundation
import Photos
import UIKit

@MainActor
final class PermissionManager {
    // MARK: - 单例

    static let shared = PermissionManager()

    private init() {}

    // MARK: - 相机权限

    /// 相机权限状态
    var cameraAuthorizationStatus: AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    /// 请求相机权限
    func requestCameraPermission() async -> Bool {
        let status = cameraAuthorizationStatus

        switch status {
        case .notDetermined:
            // 未确定，请求权限
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            print(granted ? "✅ 相机权限已授予" : "❌ 相机权限被拒绝")
            return granted

        case .restricted, .denied:
            // 被限制或拒绝
            print("⚠️ 相机权限被拒绝或受限")
            return false

        case .authorized:
            // 已授权
            return true

        @unknown default:
            return false
        }
    }

    /// 检查是否有相机权限
    func checkCameraPermission() -> Bool {
        return cameraAuthorizationStatus == .authorized
    }

    // MARK: - 相册权限

    /// 相册权限状态
    var photoLibraryAuthorizationStatus: PHAuthorizationStatus {
        if #available(iOS 14, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            return PHPhotoLibrary.authorizationStatus()
        }
    }

    /// 请求相册权限
    func requestPhotoLibraryPermission() async -> Bool {
        let status = photoLibraryAuthorizationStatus

        switch status {
        case .notDetermined:
            // 未确定，请求权限
            let newStatus: PHAuthorizationStatus
            if #available(iOS 14, *) {
                newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            } else {
                newStatus = await withCheckedContinuation { continuation in
                    PHPhotoLibrary.requestAuthorization { status in
                        continuation.resume(returning: status)
                    }
                }
            }

            let granted = newStatus == .authorized || newStatus == .limited
            print(granted ? "✅ 相册权限已授予" : "❌ 相册权限被拒绝")
            return granted

        case .restricted, .denied:
            // 被限制或拒绝
            print("⚠️ 相册权限被拒绝或受限")
            return false

        case .authorized, .limited:
            // 已授权
            return true

        @unknown default:
            return false
        }
    }

    /// 检查是否有相册权限
    func checkPhotoLibraryPermission() -> Bool {
        let status = photoLibraryAuthorizationStatus
        return status == .authorized || status == .limited
    }

    // MARK: - 通用方法

    /// 打开系统设置
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            Task { @MainActor in
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    /// 显示权限被拒绝的提示
    func showPermissionDeniedAlert(for permission: String) -> (title: String, message: String) {
        return (
            title: "\(permission)权限被拒绝",
            message: "请在设置中允许访问\(permission)，以便使用此功能。"
        )
    }
}

// MARK: - 权限类型枚举

enum PermissionType {
    case camera
    case photoLibrary
    case notification

    var displayName: String {
        switch self {
        case .camera: return "相机"
        case .photoLibrary: return "相册"
        case .notification: return "通知"
        }
    }
}
