import XCTest
@testable import CalorieTracker

final class DataModelTests: XCTestCase {

    // MARK: - CategoryItem

    func testCategoryItem_init() {
        let item = CategoryItem(name: "Breakfast", emoji: "🍞")
        XCTAssertEqual(item.name, "Breakfast")
        XCTAssertEqual(item.emoji, "🍞")
    }

    func testCategoryItem_initWithID() {
        let id = UUID()
        let item = CategoryItem(id: id, name: "Lunch", emoji: "🥗")
        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.name, "Lunch")
    }

    func testCategoryItem_hashable() {
        let a = CategoryItem(name: "Lunch", emoji: "🥗")
        let b = CategoryItem(name: "Lunch", emoji: "🥗")
        // Different UUIDs, so they shouldn't be equal by default
        XCTAssertNotEqual(a, b)

        // Same ID should be equal
        let id = UUID()
        let c = CategoryItem(id: id, name: "Lunch", emoji: "🥗")
        let d = CategoryItem(id: id, name: "Lunch", emoji: "🥗")
        XCTAssertEqual(c, d)
    }

    func testCategoryItem_codable() throws {
        let original = CategoryItem(name: "Snack", emoji: "🍪")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CategoryItem.self, from: data)
        XCTAssertEqual(decoded.name, "Snack")
        XCTAssertEqual(decoded.emoji, "🍪")
        XCTAssertEqual(decoded.id, original.id)
    }

    // MARK: - MealLog

    func testMealLog_init() {
        let category = CategoryItem(name: "Dinner", emoji: "🥩")
        let date = Date()
        let log = MealLog(date: date, categoryItem: category, calories: 750)
        XCTAssertEqual(log.date, date)
        XCTAssertEqual(log.categoryItem.name, "Dinner")
        XCTAssertEqual(log.calories, 750)
        XCTAssertNil(log.customName)
        XCTAssertNil(log.weightGrams)
        XCTAssertNil(log.cuisineType)
        XCTAssertNil(log.proteinGrams)
        XCTAssertNil(log.isSavedTemplate)
    }

    func testMealLog_initWithAllFields() {
        let category = CategoryItem(name: "Lunch", emoji: "🥗")
        let log = MealLog(
            date: Date(),
            categoryItem: category,
            customName: "Chicken Biryani",
            calories: 600,
            weightGrams: 350,
            cuisineType: "South Asian",
            proteinGrams: 30,
            carbsGrams: 70,
            fatGrams: 15,
            fiberGrams: 5,
            isSavedTemplate: true
        )
        XCTAssertEqual(log.customName, "Chicken Biryani")
        XCTAssertEqual(log.weightGrams, 350)
        XCTAssertEqual(log.cuisineType, "South Asian")
        XCTAssertEqual(log.proteinGrams, 30)
        XCTAssertEqual(log.carbsGrams, 70)
        XCTAssertEqual(log.fatGrams, 15)
        XCTAssertEqual(log.fiberGrams, 5)
        XCTAssertEqual(log.isSavedTemplate, true)
    }

    func testMealLog_codable() throws {
        let category = CategoryItem(name: "Breakfast", emoji: "🍞")
        let original = MealLog(
            date: Date(),
            categoryItem: category,
            customName: "Oatmeal",
            calories: 300,
            proteinGrams: 10,
            carbsGrams: 50,
            fatGrams: 8
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MealLog.self, from: data)
        XCTAssertEqual(decoded.categoryItem.name, "Breakfast")
        XCTAssertEqual(decoded.customName, "Oatmeal")
        XCTAssertEqual(decoded.calories, 300)
        XCTAssertEqual(decoded.proteinGrams, 10)
    }

    func testMealLog_equatable() {
        let category = CategoryItem(name: "Lunch", emoji: "🥗")
        let date = Date()
        let a = MealLog(date: date, categoryItem: category, calories: 500)
        let b = MealLog(date: date, categoryItem: category, calories: 500)
        // Different UUIDs by default
        XCTAssertNotEqual(a, b)
    }

    // MARK: - WorkoutLog

    func testWorkoutLog_init() {
        let date = Date()
        let log = WorkoutLog(date: date, workoutType: "Running", caloriesBurned: 450)
        XCTAssertEqual(log.date, date)
        XCTAssertEqual(log.workoutType, "Running")
        XCTAssertEqual(log.caloriesBurned, 450)
    }

    func testWorkoutLog_codable() throws {
        let original = WorkoutLog(date: Date(), workoutType: "Cycling", caloriesBurned: 300)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(WorkoutLog.self, from: data)
        XCTAssertEqual(decoded.workoutType, "Cycling")
        XCTAssertEqual(decoded.caloriesBurned, 300)
    }

    // MARK: - DailyEntry

    func testDailyEntry_mealEntry() {
        let entry = DailyEntry(
            date: Date(),
            isWorkout: false,
            title: "Lunch",
            subtitle: "Chicken",
            calories: 500,
            emoji: "🥗"
        )
        XCTAssertFalse(entry.isWorkout)
        XCTAssertEqual(entry.title, "Lunch")
        XCTAssertEqual(entry.subtitle, "Chicken")
        XCTAssertEqual(entry.calories, 500)
        XCTAssertEqual(entry.emoji, "🥗")
    }

    func testDailyEntry_workoutEntry() {
        let entry = DailyEntry(
            date: Date(),
            isWorkout: true,
            title: "Running",
            calories: 350,
            emoji: "🔥"
        )
        XCTAssertTrue(entry.isWorkout)
        XCTAssertNil(entry.subtitle)
        XCTAssertEqual(entry.calories, 350)
    }

    // MARK: - AppNotification

    func testAppNotification_init() {
        let notif = AppNotification(
            icon: "chart.bar",
            colorR: 0.5,
            colorG: 0.8,
            colorB: 0.3,
            title: "Test",
            text: "Body",
            date: Date()
        )
        XCTAssertEqual(notif.icon, "chart.bar")
        XCTAssertEqual(notif.colorR, 0.5)
        XCTAssertEqual(notif.colorG, 0.8)
        XCTAssertEqual(notif.colorB, 0.3)
        XCTAssertEqual(notif.title, "Test")
        XCTAssertEqual(notif.text, "Body")
    }

    func testAppNotification_codable() throws {
        let original = AppNotification(
            icon: "bell",
            colorR: 1.0,
            colorG: 0.0,
            colorB: 0.0,
            title: "Alert",
            text: "You have a notification",
            date: Date()
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AppNotification.self, from: data)
        XCTAssertEqual(decoded.icon, "bell")
        XCTAssertEqual(decoded.title, "Alert")
        XCTAssertEqual(decoded.text, "You have a notification")
    }

    // MARK: - AppTheme

    func testAppTheme_rawValues() {
        XCTAssertEqual(AppTheme.classicWhite.rawValue, "Classic White")
        XCTAssertEqual(AppTheme.muzliDark.rawValue, "Muzli Dark")
    }

    func testAppTheme_allCases() {
        XCTAssertEqual(AppTheme.allCases.count, 2)
        XCTAssertTrue(AppTheme.allCases.contains(.classicWhite))
        XCTAssertTrue(AppTheme.allCases.contains(.muzliDark))
    }

    func testAppTheme_initFromRawValue() {
        XCTAssertEqual(AppTheme(rawValue: "Classic White"), .classicWhite)
        XCTAssertEqual(AppTheme(rawValue: "Muzli Dark"), .muzliDark)
        XCTAssertNil(AppTheme(rawValue: "nonexistent"))
    }
}
