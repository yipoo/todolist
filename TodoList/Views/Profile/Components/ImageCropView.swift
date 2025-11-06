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
                    controlBar
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
                        cropImage()
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - 子视图

    /// 控制栏
    private var controlBar: some View {
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
                Button(action: fitImage) {
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
    private func cropImage() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: cropSize, height: cropSize))

        let croppedUIImage = renderer.image { context in
            // 创建圆形路径
            let circlePath = UIBezierPath(
                ovalIn: CGRect(x: 0, y: 0, width: cropSize, height: cropSize)
            )
            circlePath.addClip()

            // 计算图片绘制位置和大小
            let imageSize = image.size
            let scaleFactor = scale
            let scaledWidth = imageSize.width * scaleFactor
            let scaledHeight = imageSize.height * scaleFactor

            // 计算居中位置
            let drawX = (cropSize - scaledWidth) / 2 + offset.width
            let drawY = (cropSize - scaledHeight) / 2 + offset.height

            let drawRect = CGRect(
                x: drawX,
                y: drawY,
                width: scaledWidth,
                height: scaledHeight
            )

            // 绘制图片
            image.draw(in: drawRect)
        }

        croppedImage = croppedUIImage
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
    private func fitImage() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            // 计算合适的缩放比例
            let imageSize = image.size
            let minDimension = min(imageSize.width, imageSize.height)
            scale = cropSize / minDimension * 1.1 // 稍微放大一点
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
