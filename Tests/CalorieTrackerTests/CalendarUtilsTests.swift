import XCTest
@testable import CalorieTracker

final class CalendarUtilsTests: XCTestCase {
    let utils = CalendarUtils()

    // MARK: - generateDaysInMonth

    func testGenerateDaysInMonth_january2024() {
        // January 2024 starts on Monday (weekday 2 in gregorian calendar)
        var comps = DateComponents()
        comps.year = 2024
        comps.month = 1
        comps.day = 1
        let jan2024 = Calendar.current.date(from: comps)!

        let days = utils.generateDaysInMonth(for: jan2024)

        // January has 31 days
        // First weekday offset varies by locale; count non-nil entries
        let nonNilDays = days.compactMap { $0 }
        XCTAssertEqual(nonNilDays.count, 31)

        // First non-nil day should be Jan 1
        let firstDay = nonNilDays.first!
        XCTAssertEqual(Calendar.current.component(.day, from: firstDay), 1)
        XCTAssertEqual(Calendar.current.component(.month, from: firstDay), 1)

        // Last non-nil day should be Jan 31
        let lastDay = nonNilDays.last!
        XCTAssertEqual(Calendar.current.component(.day, from: lastDay), 31)
    }

    func testGenerateDaysInMonth_february2024Leap() {
        var comps = DateComponents()
        comps.year = 2024
        comps.month = 2
        comps.day = 1
        let feb2024 = Calendar.current.date(from: comps)!

        let days = utils.generateDaysInMonth(for: feb2024)
        let nonNilDays = days.compactMap { $0 }
        XCTAssertEqual(nonNilDays.count, 29) // Leap year
    }

    func testGenerateDaysInMonth_februaryNonLeap() {
        var comps = DateComponents()
        comps.year = 2023
        comps.month = 2
        comps.day = 1
        let feb2023 = Calendar.current.date(from: comps)!

        let days = utils.generateDaysInMonth(for: feb2023)
        let nonNilDays = days.compactMap { $0 }
        XCTAssertEqual(nonNilDays.count, 28)
    }

    func testGenerateDaysInMonth_hasLeadingNilsForOffset() {
        var comps = DateComponents()
        comps.year = 2024
        comps.month = 1
        comps.day = 1
        let jan2024 = Calendar.current.date(from: comps)!

        let days = utils.generateDaysInMonth(for: jan2024)
        let firstWeekday = Calendar.current.component(.weekday, from: jan2024)
        let leadingNils = firstWeekday - 1

        // Check that the first `leadingNils` entries are nil
        for i in 0..<leadingNils {
            XCTAssertNil(days[i], "Day at index \(i) should be nil (offset)")
        }
        // And the next one is not nil
        if leadingNils < days.count {
            XCTAssertNotNil(days[leadingNils])
        }
    }

    func testGenerateDaysInMonth_april30Days() {
        var comps = DateComponents()
        comps.year = 2024
        comps.month = 4
        comps.day = 1
        let apr2024 = Calendar.current.date(from: comps)!

        let days = utils.generateDaysInMonth(for: apr2024)
        let nonNilDays = days.compactMap { $0 }
        XCTAssertEqual(nonNilDays.count, 30)
    }

    // MARK: - changeMonth

    func testChangeMonth_forward() {
        var comps = DateComponents()
        comps.year = 2024
        comps.month = 1
        comps.day = 15
        let jan = Calendar.current.date(from: comps)!

        let feb = utils.changeMonth(from: jan, by: 1)
        XCTAssertNotNil(feb)
        XCTAssertEqual(Calendar.current.component(.month, from: feb!), 2)
        XCTAssertEqual(Calendar.current.component(.year, from: feb!), 2024)
    }

    func testChangeMonth_backward() {
        var comps = DateComponents()
        comps.year = 2024
        comps.month = 3
        comps.day = 15
        let mar = Calendar.current.date(from: comps)!

        let feb = utils.changeMonth(from: mar, by: -1)
        XCTAssertNotNil(feb)
        XCTAssertEqual(Calendar.current.component(.month, from: feb!), 2)
    }

    func testChangeMonth_yearRollover() {
        var comps = DateComponents()
        comps.year = 2024
        comps.month = 12
        comps.day = 15
        let dec = Calendar.current.date(from: comps)!

        let jan = utils.changeMonth(from: dec, by: 1)
        XCTAssertNotNil(jan)
        XCTAssertEqual(Calendar.current.component(.month, from: jan!), 1)
        XCTAssertEqual(Calendar.current.component(.year, from: jan!), 2025)
    }

    func testChangeMonth_yearRolloverBackward() {
        var comps = DateComponents()
        comps.year = 2024
        comps.month = 1
        comps.day = 15
        let jan = Calendar.current.date(from: comps)!

        let dec = utils.changeMonth(from: jan, by: -1)
        XCTAssertNotNil(dec)
        XCTAssertEqual(Calendar.current.component(.month, from: dec!), 12)
        XCTAssertEqual(Calendar.current.component(.year, from: dec!), 2023)
    }

    // MARK: - Formatters

    func testFormatMonthYear() {
        var comps = DateComponents()
        comps.year = 2024
        comps.month = 6
        comps.day = 15
        let date = Calendar.current.date(from: comps)!

        let result = CalendarUtils.formatMonthYear(date)
        XCTAssertEqual(result, "June 2024")
    }

    func testFormatDate() {
        var comps = DateComponents()
        comps.year = 2024
        comps.month = 1
        comps.day = 15
        let date = Calendar.current.date(from: comps)!

        let result = CalendarUtils.formatDate(date)
        XCTAssertTrue(result.contains("Jan"))
        XCTAssertTrue(result.contains("15"))
        XCTAssertTrue(result.contains("2024"))
    }

    func testFormatDateWithToday_todayHasPrefix() {
        let today = Date()
        let result = CalendarUtils.formatDateWithToday(today)
        XCTAssertTrue(result.hasPrefix("Today"))
    }

    func testFormatDateWithToday_pastDateNoPrefix() {
        var comps = DateComponents()
        comps.year = 2020
        comps.month = 1
        comps.day = 1
        let past = Calendar.current.date(from: comps)!

        let result = CalendarUtils.formatDateWithToday(past)
        XCTAssertFalse(result.hasPrefix("Today"))
    }
}
