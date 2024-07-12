//
//  WarningMacroPlayground.swift
//
//
//  Created by Mohammad reza on 10.07.2024.
//

import Foundation
import PlaytomicMacros

func runWarningMacroPlayground() {
    startRunner()
    defer { stopRunner() }
#warning("This macro generates a message")
}
