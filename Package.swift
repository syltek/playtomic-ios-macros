// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "PlaytomicMacros",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13)
    ],
    products: [
        .library(name: "PlaytomicMacros", targets: ["PlaytomicMacros"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax",
            from: "509.0.0"
        ),
    ],
    targets: [
        .target(
            name: "PlaytomicMacros",
            dependencies: [
                "PlaytomicMacrosSource"
            ]
        ),
        .macro(name: "PlaytomicMacrosSource", dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            .product(name: "SwiftDiagnostics", package: "swift-syntax")
        ])
    ]
)
