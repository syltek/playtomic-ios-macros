//
//  URLMacroTests.swift
//
//
//  Created by Mohammad reza on 2.07.2024.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.

#if canImport(PlaytomicMacrosSource)
import PlaytomicMacrosSource
private let macros = ["URL": URLMacro.self]
#else
private let macros = [:]
#endif

/**
 `[Acceptance Criteria]`
 - Macro should fail to compile if string is not a valid URL object
 - Only Static String type is allowd as input to the #URL
 */


final class URLMacroTests: XCTestCase {

    func testExpansionWithMalformedURLEmitsError() {
        assertMacroExpansion(
          """
          let invalid = #URL("https://not a url.com")
          """,
          expandedSource: """
            let invalid = #URL("https://not a url.com")
            """,
          diagnostics: [
            DiagnosticSpec(message: #"malformed url: https://not a url.com"#, line: 1, column: 15, severity: .error)
          ],
          macros: macros,
          indentationWidth: .spaces(2)
        )
    }

    func testExpansionWithStringInterpolationEmitsError() {
        assertMacroExpansion(
          #"""
          #URL("https://\(domain)/api/path")
          """#,
          expandedSource:
          #"""
          #URL("https://\(domain)/api/path")
          """#,
          diagnostics: [
            DiagnosticSpec(message: "'#URL' requires a static string literal", line: 1, column: 1, severity: .error)
          ],
          macros: macros,
          indentationWidth: .spaces(2)
        )
    }

    func testExpansionWithValidURL() {
        assertMacroExpansion(
          """
          let valid = #URL("https://swift.org/")
          """,
          expandedSource:
          """
          let valid = URL(string: "https://swift.org/")!
          """,
          macros: macros,
          indentationWidth: .spaces(2)
        )
    }

    func testExpansionWithValidFileURL() {
        assertMacroExpansion(
          """
          let valid = #URL("file://sample-file.pdf")
          """,
          expandedSource:
          """
          let valid = URL(string: "file://sample-file.pdf")!
          """,
          macros: macros,
          indentationWidth: .spaces(2)
        )
    }
}
