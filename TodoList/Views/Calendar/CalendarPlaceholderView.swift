/**
 * 日历占位视图
 *
 * 临时占位页面，待后续实现完整功能
 */

import SwiftUI

struct CalendarPlaceholderView: View {
    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 图标
                Image(systemName: "calendar.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // 标题
                Text("日历视图")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // 描述
                Text("功能开发中...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // 功能预览
                VStack(alignment: .leading, spacing: 12) {
                    Label("月视图展示", systemImage: "calendar")
                    Label("待办事项标记", systemImage: "checkmark.circle")
                    Label("日期快速跳转", systemImage: "arrow.right.circle")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .navigationTitle("日历")
        }
    }
}

// MARK: - 预览

#Preview {
    CalendarPlaceholderView()
}
