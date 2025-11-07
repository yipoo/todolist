/**
 * 图片选择器
 *
 * 支持从相册选择或拍照
 */

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    // MARK: - 参数

    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType

    // MARK: - Coordinator

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    // MARK: - UIViewControllerRepresentable

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// MARK: - PhotosPicker Wrapper (iOS 16+)

struct PhotosPickerView: View {
    @Binding var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images
        ) {
            Label("从相册选择", systemImage: "photo.on.rectangle")
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
    }
}

// MARK: - 头像选择器弹窗

struct AvatarPickerSheet: View {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var tempImage: UIImage?
    @State private var showCropView = false
    @State private var currentPreview: UIImage? // 当前预览的图片
    @State private var showPermissionAlert = false
    @State private var permissionAlertMessage = ""

    private let permissionManager = PermissionManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 当前头像预览
                if let image = currentPreview {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.top, 20)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 150, height: 150)

                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                }

                // 选项按钮
                VStack(spacing: 16) {
                    // 拍照
                    Button(action: {
                        Task {
                            await requestCameraPermission()
                        }
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.title3)

                            Text("拍照")
                                .font(.body)
                                .fontWeight(.medium)

                            Spacer()
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(Layout.smallCornerRadius)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // 从相册选择
                    Button(action: {
                        Task {
                            await requestPhotoLibraryPermission()
                        }
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title3)

                            Text("从相册选择")
                                .font(.body)
                                .fontWeight(.medium)

                            Spacer()
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(Layout.smallCornerRadius)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // 删除头像（如果已有头像）
                    if currentPreview != nil {
                        Button(action: {
                            currentPreview = nil
                            selectedImage = UIImage() // 使用空图片标记删除
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .font(.title3)

                                Text("删除头像")
                                    .font(.body)
                                    .fontWeight(.medium)

                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(Layout.smallCornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("选择头像")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                if currentPreview != nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完成") {
                            selectedImage = currentPreview
                            dismiss()
                        }
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $tempImage, sourceType: .camera)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showPhotoLibrary) {
                ImagePicker(image: $tempImage, sourceType: .photoLibrary)
                    .ignoresSafeArea()
            }
            .onChange(of: tempImage) { _, newImage in
                if newImage != nil {
                    showCropView = true
                }
            }
            .fullScreenCover(isPresented: $showCropView) {
                if let image = tempImage {
                    ImageCropView(image: image, croppedImage: $currentPreview)
                }
            }
            .onAppear {
                // 初始化时不设置 currentPreview，保持为 nil
                // 这样用户第一次打开时不会显示旧头像
            }
            .alert("权限被拒绝", isPresented: $showPermissionAlert) {
                Button("前往设置") {
                    permissionManager.openSettings()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text(permissionAlertMessage)
            }
        }
    }

    // MARK: - 权限请求方法

    /// 请求相机权限
    private func requestCameraPermission() async {
        let granted = await permissionManager.requestCameraPermission()

        if granted {
            showCamera = true
        } else {
            let alert = permissionManager.showPermissionDeniedAlert(for: "相机")
            permissionAlertMessage = alert.message
            showPermissionAlert = true
        }
    }

    /// 请求相册权限
    private func requestPhotoLibraryPermission() async {
        let granted = await permissionManager.requestPhotoLibraryPermission()

        if granted {
            showPhotoLibrary = true
        } else {
            let alert = permissionManager.showPermissionDeniedAlert(for: "相册")
            permissionAlertMessage = alert.message
            showPermissionAlert = true
        }
    }
}

// MARK: - 预览

#Preview {
    AvatarPickerSheet(selectedImage: .constant(nil))
}
