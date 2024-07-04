//
//  CopyableMacroTests.swift
//
//
//  Created by Mohammad reza on 2.07.2024.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(PlaytomicMacrosSource)
import PlaytomicMacrosSource
private let macros = ["Copyable": CopyableMacro.self]
#else
private let macros = [:]
#endif

/**
 `[Acceptance Criteria]`
    - The `@Copyable` macro can only be attached to `struct` or `class` declarations.
    - Optional property types should be transformed to use `Nullable<>` in the `copy` function.
    - If a `struct` or `class` has no properties, the macro should not add any `copy` function to the body.
    - The access level of the generated `copy` function should match the access level of the containing type.
    - Computed properties and static properties should not be included in the generated `copy` function.
 */

final class CopyableMacroTests: XCTestCase {

    func testEnum() {
        assertMacroExpansion(
            """
            @Copyable
            enum ViewAction {
            }
            """,
            expandedSource:
            """
            enum ViewAction {
            }
            """,
            diagnostics: [
                .init(
                    message: "'@Copyable' can only be applied to a struct or class",
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )
    }

    func testStructEmpty() {
        assertMacroExpansion(
            """
            @Copyable
            struct ViewState {
            }
            """,
            expandedSource:
            """
            struct ViewState {
            }
            """,
            macros: macros
        )
    }

    func testClasEmpty() {
        assertMacroExpansion(
            """
            @Copyable
            class Model {
            }
            """,
            expandedSource:
            """
            class Model {
            }
            """,
            macros: macros
        )
    }

    func testBasicStruct() {
        assertMacroExpansion(
            """
            @Copyable
            struct ViewState {
                let id: Int
                let name: String?
            }
            """,
            expandedSource:
            """
            struct ViewState {
                let id: Int
                let name: String?

                func copy(
                    id: Int? = nil,
                    name: Nullable<String> = .none
                ) -> ViewState {
                    return ViewState(
                        id: id ?? self.id,
                        name: name ?? self.name
                    )
                }
            }
            """,
            macros: macros
        )
    }

    func testBasicClass() {
        assertMacroExpansion(
            """
            @Copyable
            class Model {
                let id: Int
                let name: String?
            }
            """,
            expandedSource:
            """
            class Model {
                let id: Int
                let name: String?

                func copy(
                    id: Int? = nil,
                    name: Nullable<String> = .none
                ) -> Model {
                    return Model(
                        id: id ?? self.id,
                        name: name ?? self.name
                    )
                }
            }
            """,
            macros: macros
        )
    }

    func testInternalAccessLevel() {
        assertMacroExpansion(
            """
            @Copyable
            internal struct ViewState {
                let id: Int
            }
            """,
            expandedSource:
            """
            internal struct ViewState {
                let id: Int

                internal func copy(
                    id: Int? = nil
                ) -> ViewState {
                    return ViewState(
                        id: id ?? self.id
                    )
                }
            }
            """,
            macros: macros
        )
    }

    func testComputedProperty() {
        assertMacroExpansion(
            """
            @Copyable
            struct ViewState {
                let id: Int

                var isEnabled: Bool {
                    return true
                }
            }
            """,
            expandedSource:
            """
            struct ViewState {
                let id: Int

                var isEnabled: Bool {
                    return true
                }

                func copy(
                    id: Int? = nil
                ) -> ViewState {
                    return ViewState(
                        id: id ?? self.id
                    )
                }
            }
            """,
            macros: macros
        )
    }

    func testStaticProperty() {
        assertMacroExpansion(
            """
            @Copyable
            struct ViewState {
                let id: Int

                static var isEnabled: Bool = true
            }
            """,
            expandedSource:
            """
            struct ViewState {
                let id: Int

                static var isEnabled: Bool = true

                func copy(
                    id: Int? = nil
                ) -> ViewState {
                    return ViewState(
                        id: id ?? self.id
                    )
                }
            }
            """,
            macros: macros
        )
    }
}

