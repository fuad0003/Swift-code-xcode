import XCTest
@testable import CalorieTracker

final class HealthManagerTests: XCTestCase {

    // MARK: - validateMacros

    func testValidateMacros_proteinOnly() async {
        let hm = HealthManager()
        // protein=25g, carbs=0, fiber=0, fat=0
        // (25*4) + (max(0,0-0)*4) + (0*9) = 100
        let result = await hm.validateMacros(protein: 25, carbs: 0, fiber: 0, fat: 0)
        XCTAssertEqual(result, 100.0, accuracy: 0.01)
    }

    func testValidateMacros_fatOnly() async {
        let hm = HealthManager()
        // fat=10g => 10*9 = 90
        let result = await hm.validateMacros(protein: 0, carbs: 0, fiber: 0, fat: 10)
        XCTAssertEqual(result, 90.0, accuracy: 0.01)
    }

    func testValidateMacros_carbsWithFiber() async {
        let hm = HealthManager()
        // protein=0, carbs=50, fiber=10, fat=0
        // (0*4) + (max(0, 50-10)*4) + (0*9) = 0 + 160 + 0 = 160
        let result = await hm.validateMacros(protein: 0, carbs: 50, fiber: 10, fat: 0)
        XCTAssertEqual(result, 160.0, accuracy: 0.01)
    }

    func testValidateMacros_fiberExceedsCarbs() async {
        let hm = HealthManager()
        // carbs=5, fiber=10 => max(0, 5-10) = 0
        // (0*4) + (0*4) + (0*9) = 0
        let result = await hm.validateMacros(protein: 0, carbs: 5, fiber: 10, fat: 0)
        XCTAssertEqual(result, 0.0, accuracy: 0.01)
    }

    func testValidateMacros_fullMeal() async {
        let hm = HealthManager()
        // protein=30, carbs=60, fiber=8, fat=15
        // (30*4) + (max(0, 60-8)*4) + (15*9)
        // = 120 + 208 + 135 = 463
        let result = await hm.validateMacros(protein: 30, carbs: 60, fiber: 8, fat: 15)
        XCTAssertEqual(result, 463.0, accuracy: 0.01)
    }

    func testValidateMacros_allZeros() async {
        let hm = HealthManager()
        let result = await hm.validateMacros(protein: 0, carbs: 0, fiber: 0, fat: 0)
        XCTAssertEqual(result, 0.0, accuracy: 0.01)
    }

    // MARK: - fetchMealEstimate

    func testFetchMealEstimate_calculatesBasedOnWeight() async {
        let hm = HealthManager()
        // Always returns weight * 2.4
        let result = await hm.fetchMealEstimate(name: "Chicken", weight: 250, cuisine: "Indian")
        XCTAssertEqual(result, 600.0, accuracy: 0.01)
    }

    func testFetchMealEstimate_zeroWeight() async {
        let hm = HealthManager()
        let result = await hm.fetchMealEstimate(name: "Nothing", weight: 0, cuisine: "Any")
        XCTAssertEqual(result, 0.0, accuracy: 0.01)
    }

    func testFetchMealEstimate_largeWeight() async {
        let hm = HealthManager()
        let result = await hm.fetchMealEstimate(name: "Feast", weight: 1000, cuisine: "Buffet")
        XCTAssertEqual(result, 2400.0, accuracy: 0.01)
    }

    // MARK: - Default Categories

    func testDefaultCategories() {
        let hm = HealthManager()
        XCTAssertEqual(hm.customCategories.count, 5)
        XCTAssertEqual(hm.customCategories[0].name, "Breakfast")
        XCTAssertEqual(hm.customCategories[1].name, "Lunch")
        XCTAssertEqual(hm.customCategories[2].name, "Dinner")
        XCTAssertEqual(hm.customCategories[3].name, "Snack")
        XCTAssertEqual(hm.customCategories[4].name, "Supplements")
    }

    // MARK: - Initial State

    func testInitialState() {
        let hm = HealthManager()
        XCTAssertFalse(hm.isAuthorized)
        XCTAssertFalse(hm.isMissingVitalData)
        XCTAssertTrue(hm.workoutLogs.isEmpty)
        XCTAssertTrue(hm.notifications.isEmpty)
    }

    // MARK: - generateLocalWeeklyReport

    func testGenerateLocalWeeklyReport_emptyLogs() {
        let hm = HealthManager()
        hm.generateLocalWeeklyReport(from: [])
        // Report should still be generated (with 0 consumed)
        let expectation = XCTestExpectation(description: "Notification added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(hm.notifications.count, 1)
            XCTAssertEqual(hm.notifications.first?.title, "Weekly Data Report")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testGenerateLocalWeeklyReport_withCurrentWeekLogs() {
        let hm = HealthManager()
        let category = CategoryItem(name: "Lunch", emoji: "🥗")
        let today = Date()
        let logs = [
            MealLog(date: today, categoryItem: category, calories: 500),
            MealLog(date: today, categoryItem: category, calories: 700),
        ]
        hm.generateLocalWeeklyReport(from: logs)
        let expectation = XCTestExpectation(description: "Notification added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(hm.notifications.isEmpty)
            let notif = hm.notifications.first!
            XCTAssertEqual(notif.title, "Weekly Data Report")
            XCTAssertTrue(notif.text.contains("1200 kcal"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testGenerateLocalWeeklyReport_filtersOutTemplates() {
        let hm = HealthManager()
        let category = CategoryItem(name: "Lunch", emoji: "🥗")
        let today = Date()
        let logs = [
            MealLog(date: today, categoryItem: category, calories: 500, isSavedTemplate: false),
            MealLog(date: today, categoryItem: category, calories: 300, isSavedTemplate: true),
        ]
        hm.generateLocalWeeklyReport(from: logs)
        let expectation = XCTestExpectation(description: "Notification added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let notif = hm.notifications.first!
            // Only 500 kcal counted (template excluded)
            XCTAssertTrue(notif.text.contains("500 kcal"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testGenerateLocalWeeklyReport_identifiesTopCategory() {
        let hm = HealthManager()
        let breakfast = CategoryItem(name: "Breakfast", emoji: "🍞")
        let lunch = CategoryItem(name: "Lunch", emoji: "🥗")
        let today = Date()
        let logs = [
            MealLog(date: today, categoryItem: breakfast, calories: 300),
            MealLog(date: today, categoryItem: breakfast, calories: 400),
            MealLog(date: today, categoryItem: lunch, calories: 500),
        ]
        hm.generateLocalWeeklyReport(from: logs)
        let expectation = XCTestExpectation(description: "Notification added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let notif = hm.notifications.first!
            XCTAssertTrue(notif.text.contains("Breakfast"))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - fetchHealthData

    func testFetchHealthData_populatesWorkouts() {
        let hm = HealthManager()
        hm.fetchHealthData()
        XCTAssertEqual(hm.workoutLogs.count, 1)
        XCTAssertEqual(hm.workoutLogs.first?.workoutType, "Outdoor Run")
        XCTAssertEqual(hm.workoutLogs.first?.caloriesBurned, 450.0)
    }

    func testFetchHealthData_setsMissingVitalDataWhenNoWeight() {
        let hm = HealthManager()
        hm.profile.weightKg = nil
        hm.profile.heightCm = nil
        hm.fetchHealthData()
        // isMissingVitalData is set with animation, check after a moment
        let expectation = XCTestExpectation(description: "Missing data flagged")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(hm.isMissingVitalData)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchHealthData_noMissingDataWhenBothSet() {
        let hm = HealthManager()
        hm.profile.weightKg = 70.0
        hm.profile.heightCm = 175.0
        hm.fetchHealthData()
        let expectation = XCTestExpectation(description: "No missing data")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(hm.isMissingVitalData)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}
