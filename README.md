# CalorieTracker

A SwiftUI-based calorie tracking app with theme support, meal logging, workout tracking, and nutritional analytics.

## Project Structure

```
CalorieTracker/
├── Package.swift
├── Sources/
│   └── CalorieTracker/
│       ├── CalorieTracker.swift      # Main app code (views, models, logic)
│       ├── CalculatorEngine.swift    # Extracted calculator logic (testable)
│       ├── CalendarUtils.swift       # Date/calendar utility functions
│       └── IntakeAnalytics.swift     # Intake breakdown analytics logic
└── Tests/
    └── CalorieTrackerTests/
        ├── UserProfileTests.swift
        ├── HealthManagerTests.swift
        ├── CalculatorEngineTests.swift
        ├── CalendarUtilsTests.swift
        ├── IntakeAnalyticsTests.swift
        └── DataModelTests.swift
```

## Running Tests

Open in Xcode and run tests with `Cmd+U`, or via command line:

```bash
swift test
```

> Note: Tests require macOS 14+ or iOS 17+ due to SwiftUI and Charts dependencies.
