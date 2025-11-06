/**
 * 关于应用视图
 *
 * 显示应用版本、开发者信息等
 */

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    private let appVersion = "1.0.0"
    private let buildNumber = "100"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // App Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)

                    // App Name
                    Text("TodoList")
                        .font(.title)
                        .fontWeight(.bold)

                    // Version Info
                    VStack(spacing: 8) {
                        Text("版本 \(appVersion)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Build \(buildNumber)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Description
                    Text("一个简洁高效的待办事项管理应用")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    // Info List
                    VStack(spacing: 0) {
                        AboutInfoRow(title: "开发者", value: "Yipoo")
                        Divider()
                        AboutInfoRow(title: "技术栈", value: "SwiftUI + SwiftData")
                        Divider()
                        AboutInfoRow(title: "系统要求", value: "iOS 17.0+")
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(Layout.mediumCornerRadius)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)

                    // Copyright
                    Text("© 2025 TodoList. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)

                    Spacer()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - About Info Row

struct AboutInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .foregroundColor(.primary)
        }
        .padding()
    }
}

#Preview {
    AboutView()
}
