//
//  URLMacroPlayground.swift
//
//
//  Created by Mohammad reza on 10.07.2024.
//

import Foundation
import PlaytomicMacros

/**
 "#URL" macro provides compile time checked URL construction. If the URL is
 malformed an error is emitted. Otherwise a non-optional URL is expanded.
 */
func runURLMacroPlayground() {
    startRunner()
    defer { stopRunner() }
    print(#URL("https://playtomic.io/"))
}
