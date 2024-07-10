//
//  CopyableMacroPlayground.swift
//
//
//  Created by Mohammad reza on 10.07.2024.
//

import Foundation
import PlaytomicMacros

/**
 `@Copyable` is a Swift syntax macro that generates a `copy` function for a class or struct,
 similar to the `copy` function in Android. This function allows you to create a copy of an instance
 with modified properties.
 */
@Copyable
struct ExampleViewState {
    let title: String
    let count: Int?
}

func runCopyableMacroPlayground() {
    let x = ExampleViewState(title: "1", count: 2)
    print("@Copyable:", x)
    print("@Copyable:", x.copy(title: "2", count: .value(nil)))
}
