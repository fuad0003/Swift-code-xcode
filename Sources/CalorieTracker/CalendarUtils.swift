import Foundation

public struct CalendarUtils {
    public init() {}

    public func generateDaysInMonth(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        return days
    }

    public func changeMonth(from date: Date, by value: Int) -> Date? {
        return Calendar.current.date(byAdding: .month, value: value, to: date)
    }

    public static func formatMonthYear(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    public static func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "E, MMM d, yyyy"
        return f.string(from: date)
    }

    public static func formatDateWithToday(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "E, MMM d, yyyy"
        return Calendar.current.isDateInToday(date) ? "Today " + f.string(from: date) : f.string(from: date)
    }
}
