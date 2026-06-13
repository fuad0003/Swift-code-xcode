import XCTest
@testable import CalorieTracker

final class CalculatorEngineTests: XCTestCase {

    // MARK: - Initial State

    func testInitialState() {
        let calc = CalculatorEngine()
        XCTAssertEqual(calc.displayValue, "0")
        XCTAssertEqual(calc.previousValue, 0)
        XCTAssertNil(calc.currentOperation)
        XCTAssertFalse(calc.isTypingNumber)
    }

    // MARK: - Append

    func testAppend_singleDigit() {
        let calc = CalculatorEngine()
        calc.append("5")
        XCTAssertEqual(calc.displayValue, "5")
        XCTAssertTrue(calc.isTypingNumber)
    }

    func testAppend_multipleDigits() {
        let calc = CalculatorEngine()
        calc.append("1")
        calc.append("2")
        calc.append("3")
        XCTAssertEqual(calc.displayValue, "123")
    }

    func testAppend_decimalPoint() {
        let calc = CalculatorEngine()
        calc.append(".")
        XCTAssertEqual(calc.displayValue, "0.")
    }

    func testAppend_decimalWithDigits() {
        let calc = CalculatorEngine()
        calc.append("3")
        calc.append(".")
        calc.append("5")
        XCTAssertEqual(calc.displayValue, "3.5")
    }

    func testAppend_leadingZeroReplacedByDigit() {
        let calc = CalculatorEngine()
        calc.append("0")
        // displayValue is "0" since first append with "0" sets it to "0" (not typing initially)
        // Actually: first append sets isTypingNumber to true, displayValue = "0"
        calc.append("5")
        // Now displayValue=="0" and number != "." and != "00", so displayValue = "5"
        XCTAssertEqual(calc.displayValue, "5")
    }

    func testAppend_doubleZero() {
        let calc = CalculatorEngine()
        calc.append("5")
        calc.append("00")
        XCTAssertEqual(calc.displayValue, "500")
    }

    func testAppend_doubleZeroOnEmpty() {
        let calc = CalculatorEngine()
        calc.append("00")
        // First append: not typing, so displayValue = "00"
        XCTAssertEqual(calc.displayValue, "00")
    }

    func testAppend_afterOperation_resetsDisplay() {
        let calc = CalculatorEngine()
        calc.append("5")
        calc.operationTapped(.add)
        // isTypingNumber is now false
        calc.append("3")
        XCTAssertEqual(calc.displayValue, "3")
    }

    // MARK: - Operations

    func testAddition() {
        let calc = CalculatorEngine()
        calc.append("1")
        calc.append("0")
        calc.operationTapped(.add)
        calc.append("5")
        calc.calculateResult()
        XCTAssertEqual(calc.displayValue, "15")
    }

    func testSubtraction() {
        let calc = CalculatorEngine()
        calc.append("2")
        calc.append("0")
        calc.operationTapped(.subtract)
        calc.append("7")
        calc.calculateResult()
        XCTAssertEqual(calc.displayValue, "13")
    }

    func testMultiplication() {
        let calc = CalculatorEngine()
        calc.append("6")
        calc.operationTapped(.multiply)
        calc.append("7")
        calc.calculateResult()
        XCTAssertEqual(calc.displayValue, "42")
    }

    func testDivision() {
        let calc = CalculatorEngine()
        calc.append("1")
        calc.append("0")
        calc.operationTapped(.divide)
        calc.append("4")
        calc.calculateResult()
        XCTAssertEqual(calc.displayValue, "2.5")
    }

    func testDivisionByZero() {
        let calc = CalculatorEngine()
        calc.append("1")
        calc.append("0")
        calc.operationTapped(.divide)
        calc.append("0")
        calc.calculateResult()
        XCTAssertEqual(calc.displayValue, "0")
    }

    // MARK: - Chained Operations

    func testChainedOperations() {
        let calc = CalculatorEngine()
        calc.append("5")
        calc.operationTapped(.add)
        calc.append("3")
        calc.operationTapped(.multiply)
        // At this point, 5+3=8 should be computed automatically
        XCTAssertEqual(calc.displayValue, "8")
        calc.append("2")
        calc.calculateResult()
        XCTAssertEqual(calc.displayValue, "16")
    }

    func testChainedSubtractAndAdd() {
        let calc = CalculatorEngine()
        calc.append("1")
        calc.append("0")
        calc.append("0")
        calc.operationTapped(.subtract)
        calc.append("3")
        calc.append("0")
        calc.operationTapped(.add)
        // 100 - 30 = 70
        XCTAssertEqual(calc.displayValue, "70")
        calc.append("1")
        calc.append("5")
        calc.calculateResult()
        // 70 + 15 = 85
        XCTAssertEqual(calc.displayValue, "85")
    }

    // MARK: - Clear

    func testClear() {
        let calc = CalculatorEngine()
        calc.append("1")
        calc.append("2")
        calc.append("3")
        calc.operationTapped(.add)
        calc.append("4")
        calc.clear()
        XCTAssertEqual(calc.displayValue, "0")
        XCTAssertEqual(calc.previousValue, 0)
        XCTAssertNil(calc.currentOperation)
        XCTAssertFalse(calc.isTypingNumber)
    }

    // MARK: - Backspace

    func testBackspace_removesLastDigit() {
        let calc = CalculatorEngine()
        calc.append("1")
        calc.append("2")
        calc.append("3")
        calc.backspace()
        XCTAssertEqual(calc.displayValue, "12")
    }

    func testBackspace_singleDigitResetsToZero() {
        let calc = CalculatorEngine()
        calc.append("5")
        calc.backspace()
        XCTAssertEqual(calc.displayValue, "0")
        XCTAssertFalse(calc.isTypingNumber)
    }

    func testBackspace_notTyping_doesNothing() {
        let calc = CalculatorEngine()
        calc.backspace()
        XCTAssertEqual(calc.displayValue, "0")
    }

    // MARK: - Decimal Operations

    func testDecimalAddition() {
        let calc = CalculatorEngine()
        calc.append("2")
        calc.append(".")
        calc.append("5")
        calc.operationTapped(.add)
        calc.append("3")
        calc.append(".")
        calc.append("7")
        calc.calculateResult()
        XCTAssertEqual(calc.displayValue, "6.2")
    }

    func testDecimalMultiplication() {
        let calc = CalculatorEngine()
        calc.append("1")
        calc.append(".")
        calc.append("5")
        calc.operationTapped(.multiply)
        calc.append("4")
        calc.calculateResult()
        XCTAssertEqual(calc.displayValue, "6")
    }

    // MARK: - Edge Cases

    func testCalculateResult_noOperationDoesNothing() {
        let calc = CalculatorEngine()
        calc.append("5")
        calc.calculateResult()
        XCTAssertEqual(calc.displayValue, "5")
    }

    func testLargeNumbers() {
        let calc = CalculatorEngine()
        calc.append("9")
        calc.append("9")
        calc.append("9")
        calc.operationTapped(.multiply)
        calc.append("9")
        calc.append("9")
        calc.append("9")
        calc.calculateResult()
        XCTAssertEqual(calc.displayValue, "998001")
    }

    func testResultResetsForNextOperation() {
        let calc = CalculatorEngine()
        calc.append("5")
        calc.operationTapped(.add)
        calc.append("3")
        calc.calculateResult()
        XCTAssertEqual(calc.displayValue, "8")
        XCTAssertFalse(calc.isTypingNumber)
        XCTAssertNil(calc.currentOperation)
        XCTAssertEqual(calc.previousValue, 8.0)
    }
}
