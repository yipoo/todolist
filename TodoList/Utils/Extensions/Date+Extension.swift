/**
 * Date 扩展
 *
 * 为 Date 添加常用的便捷方法
 */

import Foundation

extension Date {
    // MARK: - 格式化

    /// 格式化为字符串
    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    /// 格式化为友好的时间字符串
    var friendlyString: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(self) {
            return "今天 " + toString(format: "HH:mm")
        } else if calendar.isDateInYesterday(self) {
            return "昨天 " + toString(format: "HH:mm")
        } else if calendar.isDateInTomorrow(self) {
            return "明天 " + toString(format: "HH:mm")
        } else if isThisWeek {
            let weekday = calendar.component(.weekday, from: self)
            let weekdayName = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"][weekday - 1]
            return weekdayName + " " + toString(format: "HH:mm")
        } else {
            return toString(format: "MM-dd HH:mm")
        }
    }

    /// 相对时间描述（类似"3分钟前"）
    var relativeString: String {
        let interval = Date().timeIntervalSince(self)

        if interval < 60 {
            return "刚刚"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)分钟前"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)小时前"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)天前"
        } else {
            return toString(format: "yyyy-MM-dd")
        }
    }

    // MARK: - 判断

    /// 是否是今天
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    /// 是否是本周
    var isThisWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// 是否是本月
    var isThisMonth: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }

    /// 是否是本年
    var isThisYear: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }

    /// 是否已过期
    var isPast: Bool {
        return self < Date()
    }

    /// 是否在将来
    var isFuture: Bool {
        return self > Date()
    }

    // MARK: - 计算

    /// 一天的开始
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    /// 一天的结束
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    /// 添加天数
    func addingDays(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// 添加小时
    func addingHours(_ hours: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }

    /// 添加分钟
    func addingMinutes(_ minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }

    /// 距离现在的天数
    func daysFromNow() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: self)
        return components.day ?? 0
    }

    // MARK: - 组件

    /// 年份
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    /// 月份
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    /// 日
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }

    /// 小时
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }

    /// 分钟
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }

    /// 星期几（1=周日，2=周一，...）
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }

    /// 星期几的名称
    var weekdayName: String {
        let names = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        return names[weekday - 1]
    }
}

// MARK: - 便捷构造

extension Date {
    /// 从组件创建日期
    static func from(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)
    }
}
