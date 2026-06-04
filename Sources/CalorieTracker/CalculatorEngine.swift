import Foundation

public enum CalculatorOperator {
    case add, subtract, multiply, divide
}

public class CalculatorEngine {
    public private(set) var displayValue: String = "0"
    public private(set) var previousValue: Double = 0
    public private(set) var currentOperation: CalculatorOperator? = nil
    public private(set) var isTypingNumber: Bool = false

    public init() {}

    public func append(_ number: String) {
        if !isTypingNumber {
            displayValue = number == "." ? "0." : number
            isTypingNumber = true
        } else {
            if displayValue == "0" && number != "." && number != "00" {
                displayValue = number
            } else {
                displayValue += number
            }
        }
    }

    public func operationTapped(_ op: CalculatorOperator) {
        if isTypingNumber && currentOperation != nil {
            calculateResult()
        }
        if let current = Double(displayValue) {
            previousValue = current
        }
        currentOperation = op
        isTypingNumber = false
    }

    public func calculateResult() {
        guard let current = Double(displayValue), let op = currentOperation else { return }
        var result: Double = 0
        switch op {
        case .add: result = previousValue + current
        case .subtract: result = previousValue - current
        case .multiply: result = previousValue * current
        case .divide: result = current != 0 ? previousValue / current : 0
        }
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        displayValue = formatter.string(from: NSNumber(value: result)) ?? "0"
        previousValue = result
        currentOperation = nil
        isTypingNumber = false
    }

    public func clear() {
        displayValue = "0"
        previousValue = 0
        currentOperation = nil
        isTypingNumber = false
    }

    public func backspace() {
        if isTypingNumber {
            if displayValue.count > 1 {
                displayValue.removeLast()
            } else {
                displayValue = "0"
                isTypingNumber = false
            }
        }
    }
}
