// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let mainProjectName = "PlaytomicMacros"
let sourceProjectName = "\(mainProjectName)Source"
let clientProjectName = "\(mainProjectName)Client"
let testProjectName = "\(mainProjectName)Tests"

let package = Package(
    name: mainProjectName,
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(name: mainProjectName, targets: [mainProjectName]),
        .executable(name: clientProjectName, targets: [clientProjectName])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .macro(name: sourceProjectName, dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
        ]),
        .target(name: mainProjectName, dependencies: [Target.Dependency(stringLiteral: sourceProjectName)]),
        .executableTarget(name: clientProjectName, dependencies: [Target.Dependency(stringLiteral: mainProjectName)]),
        .testTarget(
            name: testProjectName,
            dependencies: [
                Target.Dependency(stringLiteral: sourceProjectName),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
