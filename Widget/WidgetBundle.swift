/**
 * Widget Bundle
 *
 * 统一管理所有 Widget
 */

import WidgetKit
import SwiftUI

@main
struct TodoListWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        // 主 Widget（待办事项）
        TodoListStaticWidget()
    }
}
