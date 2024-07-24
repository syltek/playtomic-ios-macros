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
        .library(name: "PlaytomicMacros", targets: ["PlaytomicMacros"]),
        .executable(name: "PlaytomicMacrosClient", targets: ["PlaytomicMacrosClient"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            // Must be in sync with xcode and playtomic-ios SWIFT_VERSION and swift tools version on top of this file
            // It could stall the CI job forever if swift version mismatch playtomic-ios repo
            exact: "509.0.0"
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
        ]),
        .testTarget(
            name: "PlaytomicMacrosTests",
            dependencies: [
                "PlaytomicMacrosSource",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        .executableTarget(
            name: "PlaytomicMacrosClient",
            dependencies: [
                "PlaytomicMacros"
            ]
        )
    ]
)
