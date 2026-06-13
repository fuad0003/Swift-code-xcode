import XCTest
@testable import CalorieTracker

final class IntakeAnalyticsTests: XCTestCase {
    let analytics = IntakeAnalytics()

    // MARK: - categoryBreakdown

    func testCategoryBreakdown_emptyLogs() {
        let result = analytics.categoryBreakdown(from: [])
        XCTAssertTrue(result.isEmpty)
    }

    func testCategoryBreakdown_singleCategory() {
        let category = CategoryItem(name: "Lunch", emoji: "🥗")
        let logs = [
            MealLog(date: Date(), categoryItem: category, calories: 500),
            MealLog(date: Date(), categoryItem: category, calories: 300),
        ]
        let result = analytics.categoryBreakdown(from: logs)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].calories, 800.0, accuracy: 0.01)
        XCTAssertEqual(result[0].percentage, 100.0, accuracy: 0.01)
        XCTAssertEqual(result[0].categoryItem.name, "Lunch")
    }

    func testCategoryBreakdown_multipleCategories() {
        let breakfast = CategoryItem(name: "Breakfast", emoji: "🍞")
        let lunch = CategoryItem(name: "Lunch", emoji: "🥗")
        let dinner = CategoryItem(name: "Dinner", emoji: "🥩")

        let logs = [
            MealLog(date: Date(), categoryItem: breakfast, calories: 300),
            MealLog(date: Date(), categoryItem: lunch, calories: 600),
            MealLog(date: Date(), categoryItem: dinner, calories: 900),
        ]

        let result = analytics.categoryBreakdown(from: logs)
        XCTAssertEqual(result.count, 3)

        // Sorted by calories descending
        XCTAssertEqual(result[0].categoryItem.name, "Dinner")
        XCTAssertEqual(result[0].calories, 900.0, accuracy: 0.01)
        XCTAssertEqual(result[0].percentage, 50.0, accuracy: 0.01) // 900/1800

        XCTAssertEqual(result[1].categoryItem.name, "Lunch")
        XCTAssertEqual(result[1].calories, 600.0, accuracy: 0.01)
        XCTAssertEqual(result[1].percentage, 33.33, accuracy: 0.01) // 600/1800

        XCTAssertEqual(result[2].categoryItem.name, "Breakfast")
        XCTAssertEqual(result[2].calories, 300.0, accuracy: 0.01)
        XCTAssertEqual(result[2].percentage, 16.67, accuracy: 0.01) // 300/1800
    }

    func testCategoryBreakdown_percentagesSumTo100() {
        let breakfast = CategoryItem(name: "Breakfast", emoji: "🍞")
        let lunch = CategoryItem(name: "Lunch", emoji: "🥗")
        let snack = CategoryItem(name: "Snack", emoji: "🍪")

        let logs = [
            MealLog(date: Date(), categoryItem: breakfast, calories: 250),
            MealLog(date: Date(), categoryItem: lunch, calories: 650),
            MealLog(date: Date(), categoryItem: snack, calories: 100),
        ]

        let result = analytics.categoryBreakdown(from: logs)
        let totalPercentage = result.reduce(0) { $0 + $1.percentage }
        XCTAssertEqual(totalPercentage, 100.0, accuracy: 0.01)
    }

    func testCategoryBreakdown_zerocalorieLogs() {
        let category = CategoryItem(name: "Water", emoji: "💧")
        let logs = [
            MealLog(date: Date(), categoryItem: category, calories: 0),
        ]
        let result = analytics.categoryBreakdown(from: logs)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].calories, 0.0, accuracy: 0.01)
        XCTAssertEqual(result[0].percentage, 0.0, accuracy: 0.01)
    }

    // MARK: - dailyTotals

    func testDailyTotals_emptyLogs() {
        let result = analytics.dailyTotals(from: [])
        XCTAssertTrue(result.isEmpty)
    }

    func testDailyTotals_singleDay() {
        let category = CategoryItem(name: "Lunch", emoji: "🥗")
        let today = Date()
        let logs = [
            MealLog(date: today, categoryItem: category, calories: 300),
            MealLog(date: today, categoryItem: category, calories: 500),
        ]
        let result = analytics.dailyTotals(from: logs)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].calories, 800.0, accuracy: 0.01)
    }

    func testDailyTotals_multipleDays() {
        let category = CategoryItem(name: "Lunch", emoji: "🥗")
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let logs = [
            MealLog(date: today, categoryItem: category, calories: 500),
            MealLog(date: yesterday, categoryItem: category, calories: 700),
        ]
        let result = analytics.dailyTotals(from: logs)
        XCTAssertEqual(result.count, 2)
        // Sorted by date ascending, yesterday should come first
        XCTAssertEqual(result[0].calories, 700.0, accuracy: 0.01)
        XCTAssertEqual(result[1].calories, 500.0, accuracy: 0.01)
    }

    func testDailyTotals_sortedByDateAscending() {
        let category = CategoryItem(name: "Lunch", emoji: "🥗")
        let calendar = Calendar.current
        let today = Date()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!

        let logs = [
            MealLog(date: today, categoryItem: category, calories: 100),
            MealLog(date: threeDaysAgo, categoryItem: category, calories: 300),
            MealLog(date: twoDaysAgo, categoryItem: category, calories: 200),
        ]
        let result = analytics.dailyTotals(from: logs)
        XCTAssertEqual(result.count, 3)
        // Should be sorted: threeDaysAgo, twoDaysAgo, today
        XCTAssertEqual(result[0].calories, 300.0, accuracy: 0.01)
        XCTAssertEqual(result[1].calories, 200.0, accuracy: 0.01)
        XCTAssertEqual(result[2].calories, 100.0, accuracy: 0.01)
    }

    func testDailyTotals_aggregatesSameDay() {
        let category = CategoryItem(name: "Lunch", emoji: "🥗")
        let today = Date()
        let logs = [
            MealLog(date: today, categoryItem: category, calories: 200),
            MealLog(date: today, categoryItem: category, calories: 300),
            MealLog(date: today, categoryItem: category, calories: 150),
        ]
        let result = analytics.dailyTotals(from: logs)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].calories, 650.0, accuracy: 0.01)
    }
}
