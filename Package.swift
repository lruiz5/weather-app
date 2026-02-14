// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WeatherApp",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "WeatherKit",
            targets: ["WeatherKit"]
        ),
        .library(
            name: "WeatherUI",
            targets: ["WeatherUI"]
        )
    ],
    dependencies: [],
    targets: [
        // Core domain layer
        .target(
            name: "WeatherKit",
            dependencies: [],
            path: "Sources/WeatherKit"
        ),

        // UI layer
        .target(
            name: "WeatherUI",
            dependencies: ["WeatherKit"],
            path: "Sources/WeatherUI"
        ),

        // Tests
        .testTarget(
            name: "WeatherKitTests",
            dependencies: ["WeatherKit"],
            path: "Tests/WeatherKitTests"
        ),
        .testTarget(
            name: "WeatherUITests",
            dependencies: ["WeatherUI"],
            path: "Tests/WeatherUITests"
        )
    ]
)
