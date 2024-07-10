//
//  StringifyMacroPlayground.swift
//
//
//  Created by Mohammad reza on 10.07.2024.
//

import Foundation
import PlaytomicMacros

func runStringifyMacroPlayground() {
    let a = 17
    let b = 25
    let (result, code) = #stringify(a + b)
    print("#stringify:", result, code)
}
