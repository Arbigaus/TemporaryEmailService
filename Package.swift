//
//  Package.swift
//  TemporaryEmailService
//
//  Created by Gerson Arbigaus on 29/06/23.
//
import PackageDescription

let package = Package(
    name: "YourFrameworkName",
    platforms: [
        .macOS(.v10_15), // Example platform
        .iOS(.v14),      // Example platform
    ],
    products: [
        .library(
            name: "YourFrameworkName",
            targets: ["YourFrameworkName"]),
    ],
    dependencies: [
        // Specify any dependencies your framework needs
        // .package(url: "https://github.com/example/dependency.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "YourFrameworkName",
            dependencies: []),
        .testTarget(
            name: "YourFrameworkNameTests",
            dependencies: ["YourFrameworkName"]),
    ]
)
