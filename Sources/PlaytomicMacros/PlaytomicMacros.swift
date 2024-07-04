// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation


// MARK: - Freestanding expression rol

/**
 A macro that produces both a value and a string containing the
 source code that generated the value. For example,

 #stringify(x + y)

 produces a tuple `(x + y, "x + y")`.
 */
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "PlaytomicMacrosSource", type: "StringifyMacro")

/**
 `#URL` Creates a non-optional URL from a static string. The string is checked to
 be valid during compile time.
 */
@freestanding(expression)
public macro URL(_ stringLiteral: String) -> URL = #externalMacro(
    module: "PlaytomicMacrosSource", type: "URLMacro"
)

// MARK: - Freestanding declaration rol
@freestanding(declaration)
public macro warning(_ message: String) = #externalMacro(module: "PlaytomicMacrosSource", type: "WarningMacro")

// MARK: - Attach peers
@attached(peer, names: overloaded)
public macro addAsyncMacro() = #externalMacro(module: "PlaytomicMacrosSource", type: "AddAsyncMacro")

// MARK: - Attach member

/**
 `@Copyable` is a Swift syntax macro that generates a `copy` function for a class or struct,
 similar to the `copy` function in Android. This function allows you to create a copy of an instance
 with modified properties.
 */
@attached(member, names: arbitrary)
public macro Copyable() = #externalMacro(
    module: "PlaytomicMacrosSource", type: "CopyableMacro"
)

@attached(member, names: arbitrary)
public macro caseDetection() = #externalMacro(module: "PlaytomicMacrosSource", type: "CaseDetectionMacro")

// MARK: - Attach memberAttribute

/**
 Apply the specified attribute to each of the stored properties within the type or member to which the macro is attached.
 The string can be any attribute (without the `@`).
 */
@attached(memberAttribute)
public macro wrapStoredProperties(_ attributeName: String) = #externalMacro(module: "PlaytomicMacrosSource", type: "WrapStoredPropertiesMacro")

// MARK: - Attach accessor
@attached(accessor)
public macro storedAccess<T>(defaultValue: T, key: String? = nil, store: UserDefaults = UserDefaults.standard) = #externalMacro(module: "PlaytomicMacrosSource", type: "StoredAccessMacro")

// MARK: - Attach conformance
@attached(extension, conformances: Equatable)
public macro equatable() = #externalMacro(module: "PlaytomicMacrosSource", type: "EquatableMacro")

