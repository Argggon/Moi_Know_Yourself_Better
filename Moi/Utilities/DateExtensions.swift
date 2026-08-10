import Foundation

public extension Date {
    /// Formats date into readable string based on language preference
    func formattedHeaderString(language: String = "en") -> String {
        let formatter = DateFormatter()
        if language == "zh" {
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "EEEE，M月d日"
        } else {
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "EEEE, MMMM d"
        }
        return formatter.string(from: self)
    }
    
    /// Short month & year string (e.g., "August 2026" / "2026年8月")
    func formattedMonthYear(language: String = "en") -> String {
        let formatter = DateFormatter()
        if language == "zh" {
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "yyyy年M月"
        } else {
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMMM yyyy"
        }
        return formatter.string(from: self)
    }
    
    /// Returns "YYYY_MM" format for story keys
    func formattedYearMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM"
        return formatter.string(from: self)
    }
    
    /// Returns day of month integer (1...31)
    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }
}
