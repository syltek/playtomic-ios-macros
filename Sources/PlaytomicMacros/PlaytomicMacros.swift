// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@attached(member, names: named(init))
public macro Init(
    defaults: [String: Any] = [:],
    wildcards: [String] = [],
    public: Bool = true
) = #externalMacro(
    module: "PlaytomicMacros",
    type: "InitMacro"
)
