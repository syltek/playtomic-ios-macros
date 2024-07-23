//
//  AddInitMacroTests.swift
//
//
//  Created by Mohammad reza on 11.07.2024.
//

import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import PlaytomicMacros

#if canImport(PlaytomicMacrosSource)
import PlaytomicMacrosSource
private let macros = ["AddInit": AddInitMacro.self]
#else
private let macros = [:]
#endif

final class AddInitMacroTests: XCTestCase {

    func testEmpty() {
        assertMacroExpansion(
            """
            @AddInit
            struct State {
            }
            """,
            expandedSource:
            """
            struct State {

                init() {
                }
            }
            """,
            macros: macros
        )
    }

    func testBasicClass() {
        assertMacroExpansion(
            """
            @AddInit
            class Client {
                let id: Int
            }
            """,
            expandedSource:
            """
            class Client {
                let id: Int

                init(id: Int) {
                    self.id = id
                }
            }
            """,
            macros: macros
        )
    }

    func testInheritedEmptyClass() {
        assertMacroExpansion(
            """
            class Server { }
            @AddInit
            class Client: Server { 

            }
            """,
            expandedSource:
            """
            class Server { }
            class Client: Server { 

                override init() {
                }

            }
            """,
            macros: macros
        )
    }

    func testBasicStruct() {
        assertMacroExpansion(
            """
            @AddInit
            struct State {
                let id: Int
            }
            """,
            expandedSource:
            """
            struct State {
                let id: Int

                init(id: Int) {
                    self.id = id
                }
            }
            """,
            macros: macros
        )
    }

    func testInternalAccessLevel() {
        assertMacroExpansion(
            """
            @AddInit
            internal struct State {
                let id: Int
            }
            """,
            expandedSource:
            """
            internal struct State {
                let id: Int

                internal init(id: Int) {
                    self.id = id
                }
            }
            """,
            macros: macros
        )
    }

    func testComputedProperty() {
        assertMacroExpansion(
            """
            @AddInit
            struct State {
                let id: Int

                var isEnabled: Bool {
                    return true
                }
            }
            """,
            expandedSource:
            """
            struct State {
                let id: Int

                var isEnabled: Bool {
                    return true
                }

                init(id: Int) {
                    self.id = id
                }
            }
            """,
            macros: macros
        )
    }

    func testStaticProperty() {
        assertMacroExpansion(
            """
            @AddInit
            struct State {
                let id: Int

                static var isEnabled: Bool = true
            }
            """,
            expandedSource:
            """
            struct State {
                let id: Int

                static var isEnabled: Bool = true

                init(id: Int) {
                    self.id = id
                }
            }
            """,
            macros: macros
        )
    }
}
