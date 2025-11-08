/**
 * 自然语言解析器
 *
 * 功能：
 * - 从自然语言文本中提取时间信息
 * - 从自然语言文本中提取优先级信息
 * - 分离待办内容和元数据
 *
 * 示例：
 * - "明天早上10点去图书馆" -> 时间: 明天10:00, 类别: 学习, 内容: "去图书馆"
 * - "下周一3点开会" -> 时间: 下周一15:00, 类别: 工作, 内容: "开会"
 * - "下周一下午3点开会，高优先级" -> 时间: 下周一15:00, 优先级: 高, 类别: 工作, 内容: "开会"
 * - "明天早上去买菜" -> 时间: 明天9:00, 类别: 生活, 内容: "去买菜"
 * - "晚上跑步锻炼" -> 时间: 今天19:00, 类别: 健康, 内容: "跑步锻炼"
 */

import Foundation
import SwiftUI

struct ParsedTodoInfo {
    var content: String  // 待办内容
    var dueDate: Date?  // 截止日期
    var priority: Priority?  // 优先级
    var categoryName: String?  // 识别到的类别名称
    var detectedTimeText: String?  // 检测到的时间文本（用于UI显示）
}

@MainActor
final class NaturalLanguageParser {

    // MARK: - 单例
    static let shared = NaturalLanguageParser()
    private init() {}

    // MARK: - 主要解析方法

    /// 解析自然语言文本
    func parse(_ text: String) -> ParsedTodoInfo {
        var result = ParsedTodoInfo(content: text)

        // 1. 提取优先级
        let (textWithoutPriority, priority) = extractPriority(from: text)
        result.priority = priority

        // 2. 提取类别
        let (textWithoutCategory, categoryName) = extractCategory(from: textWithoutPriority)
        result.categoryName = categoryName

        // 3. 提取时间
        let (textWithoutTime, date, timeText) = extractDateTime(from: textWithoutCategory)
        result.dueDate = date
        result.detectedTimeText = timeText

        // 4. 清理并设置最终内容
        result.content = textWithoutTime.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        return result
    }

    // MARK: - 优先级提取

    /// 从文本中提取优先级
    private func extractPriority(from text: String) -> (cleanText: String, priority: Priority?) {
        let lowercaseText = text.lowercased()
        var cleanText = text
        var priority: Priority? = nil

        // 高优先级关键词
        let highKeywords = ["高优先级", "紧急", "重要", "urgent", "high", "!!!"]
        for keyword in highKeywords {
            if lowercaseText.contains(keyword.lowercased()) {
                priority = .high
                cleanText = cleanText.replacingOccurrences(
                    of: keyword, with: "", options: .caseInsensitive)
                break
            }
        }

        // 低优先级关键词
        if priority == nil {
            let lowKeywords = ["低优先级", "不急", "low", "!"]
            for keyword in lowKeywords {
                if lowercaseText.contains(keyword.lowercased()) {
                    priority = .low
                    cleanText = cleanText.replacingOccurrences(
                        of: keyword, with: "", options: .caseInsensitive)
                    break
                }
            }
        }

        // 中优先级关键词
        if priority == nil {
            let mediumKeywords = ["中优先级", "一般", "medium", "!!"]
            for keyword in mediumKeywords {
                if lowercaseText.contains(keyword.lowercased()) {
                    priority = .medium
                    cleanText = cleanText.replacingOccurrences(
                        of: keyword, with: "", options: .caseInsensitive)
                    break
                }
            }
        }

        return (cleanText, priority)
    }

    // MARK: - 类别提取

    /// 从文本中提取类别
    private func extractCategory(from text: String) -> (cleanText: String, categoryName: String?) {
        let lowercaseText = text.lowercased()
        let cleanText = text
        var categoryName: String? = nil

        // 定义类别关键词映射
        let categoryMappings: [(keywords: [String], name: String)] = [
            // 工作
            (
                keywords: [
                    "工作", "上班", "会议", "开会", "项目", "任务", "客户", "报告", "邮件", "文档", "方案", "汇报", "讨论",
                    "评审",
                ], name: "工作"
            ),
            // 生活
            (
                keywords: [
                    "生活", "买菜", "做饭", "打扫", "购物", "家务", "缴费", "维修", "洗衣", "整理", "扔垃圾", "超市",
                ], name: "生活"
            ),
            // 学习
            (
                keywords: [
                    "学习", "读书", "看书", "复习", "预习", "作业", "考试", "课程", "培训", "练习", "背单词", "图书馆",
                ], name: "学习"
            ),
            // 健康
            (
                keywords: ["健康", "运动", "跑步", "健身", "锻炼", "瑜伽", "体检", "就医", "吃药", "散步", "游泳", "打球"],
                name: "健康"
            ),
            // 目标
            (keywords: ["目标", "计划", "规划", "梦想", "愿望", "年度", "月度", "周计划"], name: "目标"),
        ]

        // 按顺序检查每个类别
        for mapping in categoryMappings {
            for keyword in mapping.keywords {
                if lowercaseText.contains(keyword) {
                    categoryName = mapping.name
                    // 不从文本中移除类别关键词，因为它们通常是内容的一部分
                    return (cleanText, categoryName)
                }
            }
        }

        return (cleanText, nil)
    }

    // MARK: - 时间提取

    /// 从文本中提取日期时间
    private func extractDateTime(from text: String) -> (
        cleanText: String, date: Date?, timeText: String?
    ) {
        let calendar = Calendar.current
        let now = Date()
        var cleanText = text
        var resultDate: Date? = nil
        var timeText: String? = nil

        // 1. 检测相对日期（明天、后天、下周等）
        if let (relativeDate, matchedText) = extractRelativeDate(from: text, baseDate: now) {
            resultDate = relativeDate
            timeText = matchedText
            cleanText = cleanText.replacingOccurrences(of: matchedText, with: "")
        }

        // 2. 检测具体日期（12月25日、2024-01-01等）
        if resultDate == nil, let (specificDate, matchedText) = extractSpecificDate(from: text) {
            resultDate = specificDate
            timeText = matchedText
            cleanText = cleanText.replacingOccurrences(of: matchedText, with: "")
        }

        // 3. 如果有日期，尝试提取时间（早上、下午、晚上、具体时间）
        if let date = resultDate {
            if let (timeComponents, matchedTimeText) = extractTime(from: text) {
                // 合并日期和时间
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                var combined = DateComponents()
                combined.year = dateComponents.year
                combined.month = dateComponents.month
                combined.day = dateComponents.day
                combined.hour = timeComponents.hour
                combined.minute = timeComponents.minute

                if let combinedDate = calendar.date(from: combined) {
                    resultDate = combinedDate
                    timeText = (timeText ?? "") + " " + matchedTimeText
                    cleanText = cleanText.replacingOccurrences(of: matchedTimeText, with: "")
                }
            } else {
                // 没有具体时间，默认设置为9:00
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                var combined = DateComponents()
                combined.year = dateComponents.year
                combined.month = dateComponents.month
                combined.day = dateComponents.day
                combined.hour = 9
                combined.minute = 0

                if let combinedDate = calendar.date(from: combined) {
                    resultDate = combinedDate
                }
            }
        }

        // 清理文本
        cleanText =
            cleanText
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        return (cleanText, resultDate, timeText)
    }

    /// 提取相对日期
    private func extractRelativeDate(from text: String, baseDate: Date) -> (
        date: Date, matchedText: String
    )? {
        let calendar = Calendar.current
        let lowercaseText = text.lowercased()

        // 今天
        if lowercaseText.contains("今天") || lowercaseText.contains("today") {
            return (calendar.startOfDay(for: baseDate), "今天")
        }

        // 明天
        if lowercaseText.contains("明天") || lowercaseText.contains("tomorrow") {
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: baseDate) {
                return (calendar.startOfDay(for: tomorrow), "明天")
            }
        }

        // 后天
        if lowercaseText.contains("后天") {
            if let afterTomorrow = calendar.date(byAdding: .day, value: 2, to: baseDate) {
                return (calendar.startOfDay(for: afterTomorrow), "后天")
            }
        }

        // 下周
        if lowercaseText.contains("下周") || lowercaseText.contains("next week") {
            // 检测具体星期几
            let weekdays = [
                ("一", 2), ("周一", 2), ("星期一", 2), ("monday", 2),
                ("二", 3), ("周二", 3), ("星期二", 3), ("tuesday", 3),
                ("三", 4), ("周三", 4), ("星期三", 4), ("wednesday", 4),
                ("四", 5), ("周四", 5), ("星期四", 5), ("thursday", 5),
                ("五", 6), ("周五", 6), ("星期五", 6), ("friday", 6),
                ("六", 7), ("周六", 7), ("星期六", 7), ("saturday", 7),
                ("日", 1), ("周日", 1), ("星期日", 1), ("sunday", 1),
            ]

            for (keyword, weekday) in weekdays {
                if lowercaseText.contains(keyword) {
                    if let nextWeek = getNextWeekday(weekday, from: baseDate, nextWeek: true) {
                        return (calendar.startOfDay(for: nextWeek), "下周\(keyword)")
                    }
                }
            }

            // 如果没有指定具体星期几，默认下周一
            if let nextMonday = getNextWeekday(2, from: baseDate, nextWeek: true) {
                return (calendar.startOfDay(for: nextMonday), "下周")
            }
        }

        // 本周（星期几）
        let weekdays = [
            ("周一", 2), ("星期一", 2), ("monday", 2),
            ("周二", 3), ("星期二", 3), ("tuesday", 3),
            ("周三", 4), ("星期三", 4), ("wednesday", 4),
            ("周四", 5), ("星期四", 5), ("thursday", 5),
            ("周五", 6), ("星期五", 6), ("friday", 6),
            ("周六", 7), ("星期六", 7), ("saturday", 7),
            ("周日", 1), ("星期日", 1), ("sunday", 1),
        ]

        for (keyword, weekday) in weekdays {
            if lowercaseText.contains(keyword.lowercased()) && !lowercaseText.contains("下周") {
                if let date = getNextWeekday(weekday, from: baseDate, nextWeek: false) {
                    return (calendar.startOfDay(for: date), keyword)
                }
            }
        }

        return nil
    }

    /// 获取下一个指定的星期几
    private func getNextWeekday(_ targetWeekday: Int, from date: Date, nextWeek: Bool) -> Date? {
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: date)

        var daysToAdd = targetWeekday - currentWeekday
        if daysToAdd <= 0 || nextWeek {
            daysToAdd += 7
        }

        return calendar.date(byAdding: .day, value: daysToAdd, to: date)
    }

    /// 提取具体日期
    private func extractSpecificDate(from text: String) -> (date: Date, matchedText: String)? {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)

        // 正则表达式匹配日期格式
        // 格式1: 12月25日, 12-25
        let patterns = [
            // 中文格式：12月25日
            "([0-9]{1,2})月([0-9]{1,2})日?",
            // 数字格式：12-25, 12/25
            "([0-9]{1,2})[-/]([0-9]{1,2})",
            // 完整日期：2024-12-25, 2024/12/25
            "([0-9]{4})[-/]([0-9]{1,2})[-/]([0-9]{1,2})",
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                let match = regex.firstMatch(
                    in: text, options: [], range: NSRange(text.startIndex..., in: text))
            {

                let matchedText = String(text[Range(match.range, in: text)!])

                if match.numberOfRanges == 4 {  // 完整日期
                    let yearStr = String(text[Range(match.range(at: 1), in: text)!])
                    let monthStr = String(text[Range(match.range(at: 2), in: text)!])
                    let dayStr = String(text[Range(match.range(at: 3), in: text)!])

                    if let year = Int(yearStr), let month = Int(monthStr), let day = Int(dayStr) {
                        var components = DateComponents()
                        components.year = year
                        components.month = month
                        components.day = day

                        if let date = calendar.date(from: components) {
                            return (date, matchedText)
                        }
                    }
                } else if match.numberOfRanges == 3 {  // 月-日
                    let monthStr = String(text[Range(match.range(at: 1), in: text)!])
                    let dayStr = String(text[Range(match.range(at: 2), in: text)!])

                    if let month = Int(monthStr), let day = Int(dayStr) {
                        var components = DateComponents()
                        components.year = currentYear
                        components.month = month
                        components.day = day

                        if let date = calendar.date(from: components) {
                            // 如果日期已经过去，则设置为明年
                            if date < now {
                                components.year = currentYear + 1
                                if let futureDate = calendar.date(from: components) {
                                    return (futureDate, matchedText)
                                }
                            }
                            return (date, matchedText)
                        }
                    }
                }
            }
        }

        return nil
    }

    /// 提取时间
    private func extractTime(from text: String) -> (time: DateComponents, matchedText: String)? {
        let lowercaseText = text.lowercased()

        // 1. 优先检测具体时间（9点、9:30、09:00等）
        // let timePatterns = [
        //     // 24小时制：09:00, 9:30
        //     "([0-9]{1,2}):([0-9]{2})",
        //     // 中文：9点, 9点30分, 9点半
        //     "([0-9]{1,2})点([0-9]{1,2})?分?",
        //     "([0-9]{1,2})点半"
        // ]
        let timePatterns = [
            // 24小时制：09:00, 9:30
            "([0-9]{1,2}):([0-9]{2})",
            // 中文时间：九点、九点三十分、九点半、一点、十二点
            "([零〇一二三四五六七八九十]{1,3})点([零〇一二三四五六七八九十]{1,3})?分?",
            // 中文时间：九点半、一点半
            "([零〇一二三四五六七八九十]{1,3})点半",
            // 混合：9点30分、9点半
            "([0-9]{1,2})点([0-9]{1,2})?分?",
            "([0-9]{1,2})点半",
        ]

        for pattern in timePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                let match = regex.firstMatch(
                    in: text, options: [], range: NSRange(text.startIndex..., in: text))
            {

                let matchedText = String(text[Range(match.range, in: text)!])
                let hourStr = String(text[Range(match.range(at: 1), in: text)!])

                if let hour = Int(hourStr) {
                    var components = DateComponents()
                    var actualHour = hour

                    // 处理时间段修饰词
                    if hour >= 1 && hour <= 12 {
                        // 下午：如果是1-12点，加12小时变为13-24点（或0点）
                        if lowercaseText.contains("下午") || lowercaseText.contains("afternoon") {
                            if hour != 12 {  // 下午12点就是12点，不需要加
                                actualHour = hour + 12
                            }
                        }
                        // 晚上：如果是1-12点，加12小时
                        else if lowercaseText.contains("晚上") || lowercaseText.contains("evening") {
                            if hour != 12 {
                                actualHour = hour + 12
                            }
                        }
                        // 早上/上午：保持原值
                        else if lowercaseText.contains("早上") || lowercaseText.contains("上午")
                            || lowercaseText.contains("morning")
                        {
                            actualHour = hour
                        }
                        // 中午：12点
                        else if lowercaseText.contains("中午") || lowercaseText.contains("noon") {
                            actualHour = 12
                        }
                        // 智能推断：如果是1-7点且没有明确时间段，推断为下午
                        else if hour >= 1 && hour <= 7 {
                            actualHour = hour + 12
                        }
                    }

                    components.hour = actualHour

                    // 处理分钟
                    if pattern.contains("半") {
                        components.minute = 30
                    } else if match.numberOfRanges > 2 {
                        let minuteRange = match.range(at: 2)
                        if minuteRange.location != NSNotFound,
                            let range = Range(minuteRange, in: text)
                        {
                            let minuteStr = String(text[range])
                            components.minute = Int(minuteStr) ?? 0
                        } else {
                            components.minute = 0
                        }
                    } else {
                        components.minute = 0
                    }

                    return (components, matchedText)
                }
            }
        }

        // 2. 如果没有具体时间，检测时间段（早上、下午、晚上等）作为默认时间
        if lowercaseText.contains("早上") || lowercaseText.contains("上午")
            || lowercaseText.contains("morning")
        {
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            return (components, "早上")
        }

        if lowercaseText.contains("中午") || lowercaseText.contains("noon") {
            var components = DateComponents()
            components.hour = 12
            components.minute = 0
            return (components, "中午")
        }

        if lowercaseText.contains("下午") || lowercaseText.contains("afternoon") {
            var components = DateComponents()
            components.hour = 14
            components.minute = 0
            return (components, "下午")
        }

        if lowercaseText.contains("晚上") || lowercaseText.contains("evening") {
            var components = DateComponents()
            components.hour = 19
            components.minute = 0
            return (components, "晚上")
        }

        return nil
    }
}
