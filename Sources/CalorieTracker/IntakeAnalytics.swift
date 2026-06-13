import Foundation

public struct CategoryBreakdownItem {
    public let categoryItem: CategoryItem
    public let calories: Double
    public let percentage: Double

    public init(categoryItem: CategoryItem, calories: Double, percentage: Double) {
        self.categoryItem = categoryItem
        self.calories = calories
        self.percentage = percentage
    }
}

public struct DailyTotal {
    public let date: Date
    public let calories: Double

    public init(date: Date, calories: Double) {
        self.date = date
        self.calories = calories
    }
}

public struct IntakeAnalytics {
    public init() {}

    public func categoryBreakdown(from logs: [MealLog]) -> [CategoryBreakdownItem] {
        let total = logs.reduce(0) { $0 + $1.calories }
        let grouped = Dictionary(grouping: logs) { $0.categoryItem }
        return grouped.map { (key, logs) in
            let catTotal = logs.reduce(0) { $0 + $1.calories }
            let percent = total > 0 ? (catTotal / total) * 100 : 0
            return CategoryBreakdownItem(categoryItem: key, calories: catTotal, percentage: percent)
        }.sorted { $0.calories > $1.calories }
    }

    public func dailyTotals(from logs: [MealLog]) -> [DailyTotal] {
        return Dictionary(grouping: logs) { Calendar.current.startOfDay(for: $0.date) }
            .map { DailyTotal(date: $0.key, calories: $0.value.reduce(0) { $0 + $1.calories }) }
            .sorted { $0.date < $1.date }
    }
}
