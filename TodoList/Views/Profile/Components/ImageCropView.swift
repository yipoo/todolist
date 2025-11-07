/**
 * 图片裁剪编辑视图
 *
 * 支持缩放、拖动以适应圆形头像
 */

import SwiftUI

struct ImageCropView: View {
    // MARK: - 参数

    let image: UIImage
    @Binding var croppedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    // MARK: - 状态

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    // MARK: - 常量

    private let cropSize: CGFloat = 300

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            bodyContent(screenWidth: geometry.size.width)
        }
    }

    @ViewBuilder
    private func bodyContent(screenWidth: CGFloat) -> some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack {
                    Spacer()

                    // 裁剪区域
                    ZStack {
                        // 图片
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        scale *= delta
                                        // 限制缩放范围
                                        scale = min(max(scale, 0.5), 5.0)
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                    }
                            )
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )

                        // 圆形遮罩
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 2)
                            .frame(width: cropSize, height: cropSize)

                        // 外部半透明遮罩
                        ZStack {
                            Color.black.opacity(0.5)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)

                            Circle()
                                .frame(width: cropSize, height: cropSize)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                        .allowsHitTesting(false)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Spacer()

                    // 控制栏
                    controlBar(screenWidth: screenWidth)
                        .padding(.bottom, 40)
                }
            }
            .navigationTitle("编辑头像")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        cropImage(screenWidth: screenWidth)
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - 子视图

    /// 控制栏
    private func controlBar(screenWidth: CGFloat) -> some View {
        VStack(spacing: 20) {
            // 缩放滑块
            HStack(spacing: 16) {
                Image(systemName: "minus.magnifyingglass")
                    .foregroundColor(.white)

                Slider(value: $scale, in: 0.5...5.0, step: 0.1)
                    .tint(.white)
                    .onChange(of: scale) { _, newValue in
                        lastScale = newValue
                    }

                Image(systemName: "plus.magnifyingglass")
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 30)

            // 操作按钮
            HStack(spacing: 30) {
                // 重置按钮
                Button(action: resetTransform) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title3)

                        Text("重置")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                }

                // 居中按钮
                Button(action: centerImage) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.grid.3x1.fill.below.line.grid.1x2")
                            .font(.title3)

                        Text("居中")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                }

                // 适应按钮
                Button(action: {
                    fitImage(screenWidth: screenWidth)
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.title3)

                        Text("适应")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
        .background(Color.black.opacity(0.3))
    }

    // MARK: - 方法

    /// 裁剪图片
    private func cropImage(screenWidth: CGFloat) {
        let imageSize = image.size

        // 计算图片在视图中的基础显示尺寸（scaledToFit）
        let imageAspect = imageSize.width / imageSize.height
        let baseWidth: CGFloat
        let baseHeight: CGFloat

        if imageAspect > 1 {
            // 横图：宽度匹配屏幕宽度
            baseWidth = screenWidth
            baseHeight = screenWidth / imageAspect
        } else {
            // 竖图：按比例缩放
            baseHeight = screenWidth
            baseWidth = screenWidth * imageAspect
        }

        // 应用用户的缩放系数
        let viewWidth = baseWidth * scale
        let viewHeight = baseHeight * scale

        // 计算图片在视图中的位置（考虑用户拖动的偏移）
        let viewX = (screenWidth - viewWidth) / 2 + offset.width
        let viewY = (screenWidth - viewHeight) / 2 + offset.height

        // 计算裁剪区域在视图中的位置
        let cropX = (screenWidth - cropSize) / 2
        let cropY = (screenWidth - cropSize) / 2

        // 计算裁剪区域相对于图片的位置和大小（在原始图片坐标系中）
        let scale = imageSize.width / viewWidth
        let cropRect = CGRect(
            x: (cropX - viewX) * scale,
            y: (cropY - viewY) * scale,
            width: cropSize * scale,
            height: cropSize * scale
        )

        // 使用 CGImage 进行精确裁剪
        guard let cgImage = image.cgImage,
              let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return
        }

        // 转换为 UIImage 并调整大小到目标尺寸
        let croppedUIImage = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)

        // 将裁剪后的图片调整到最终尺寸 (cropSize x cropSize)
        let finalSize = CGSize(width: cropSize, height: cropSize)
        UIGraphicsBeginImageContextWithOptions(finalSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        // 创建圆形裁剪路径
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: finalSize))
        circlePath.addClip()

        // 绘制图片
        croppedUIImage.draw(in: CGRect(origin: .zero, size: finalSize))

        if let finalImage = UIGraphicsGetImageFromCurrentImageContext() {
            croppedImage = finalImage
        }
    }

    /// 重置变换
    private func resetTransform() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            scale = 1.0
            lastScale = 1.0
            offset = .zero
            lastOffset = .zero
        }
    }

    /// 居中图片
    private func centerImage() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            offset = .zero
            lastOffset = .zero
        }
    }

    /// 适应图片
    private func fitImage(screenWidth: CGFloat) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            // 计算合适的缩放比例
            let imageSize = image.size
            let imageAspect = imageSize.width / imageSize.height
            let baseWidth: CGFloat

            if imageAspect > 1 {
                baseWidth = screenWidth
            } else {
                baseWidth = screenWidth * imageAspect
            }

            // 计算需要的缩放比例，让图片刚好填充裁剪区域
            scale = (cropSize / baseWidth) * 1.1 // 稍微放大一点
            lastScale = scale
            offset = .zero
            lastOffset = .zero
        }
    }
}

// MARK: - 预览

#Preview {
    ImageCropView(
        image: UIImage(systemName: "person.circle.fill")!,
        croppedImage: .constant(nil)
    )
}
