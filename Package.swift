// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CalorieTracker",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "CalorieTracker", targets: ["CalorieTracker"])
    ],
    targets: [
        .target(
            name: "CalorieTracker",
            path: "Sources/CalorieTracker"
        ),
        .testTarget(
            name: "CalorieTrackerTests",
            dependencies: ["CalorieTracker"],
            path: "Tests/CalorieTrackerTests"
        )
    ]
)
