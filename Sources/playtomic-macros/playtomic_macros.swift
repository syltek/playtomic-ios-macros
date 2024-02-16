// The Swift Programming Language
// https://docs.swift.org/swift-book
/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.

import Foundation

// MARK: - Freestanding expression rol
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "playtomic_macrosMacros", type: "StringifyMacro")

// MARK: - Freestanding declaration rol
@freestanding(declaration)
public macro warning(_ message: String) = #externalMacro(module: "playtomic_macrosMacros", type: "WarningMacro")

// MARK: - Attach peers
@attached(peer, names: overloaded)
public macro addAsyncMacro() = #externalMacro(module: "playtomic_macrosMacros", type: "AddAsyncMacro")

// MARK: - Attach member
@attached(member, names: arbitrary)
public macro caseDetection() = #externalMacro(module: "playtomic_macrosMacros", type: "CaseDetectionMacro")

// MARK: - Attach memberAttribute
/// Apply the specified attribute to each of the stored properties within the type or member to which the macro is attached.
/// The string can be any attribute (without the `@`).
@attached(memberAttribute)
public macro wrapStoredProperties(_ attributeName: String) = #externalMacro(module: "playtomic_macrosMacros", type: "WrapStoredPropertiesMacro")

// MARK: - Attach accessor
@attached(accessor)
public macro storedAccess<T>(defaultValue: T, key: String? = nil, store: UserDefaults = UserDefaults.standard) = #externalMacro(module: "playtomic_macrosMacros", type: "StoredAccessMacro")

// MARK: - Attach conformance
@attached(extension, conformances: Equatable)
public macro equatable() = #externalMacro(module: "playtomic_macrosMacros", type: "EquatableMacro")

