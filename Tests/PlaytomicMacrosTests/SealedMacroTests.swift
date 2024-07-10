//
//  SealedMacroTests.swift
//
//
//  Created by Mohammad reza on 9.07.2024.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.

#if canImport(PlaytomicMacrosSource)
import PlaytomicMacrosSource
private let macros = ["Sealed": SealedMacro.self]
#else
private let macros = [:]
#endif

/**
 `[Acceptance Criteria]`
 - Macro should fail to compile if string is not a valid URL object
 - Only Static String type is allowd as input to the #URL
 */


final class SealedMacroTests: XCTestCase {

    func testEmptyClass() {
        assertMacroExpansion(
          """
          @Sealed
          class ViewAction { }
          """,
          expandedSource:
          """
          extension ViewAction { }
          """,
          macros: macros,
          indentationWidth: .spaces(2)
        )
    }

    func testSealedClass() {
        assertMacroExpansion(
          """
          @Sealed
          class LevelUpgradeViewAction: ViewAction {
              private init() {}

              class OnAppear: LevelUpgradeViewAction, LevelUpgradeEventAction {
                  override init() { super.init() }
              }

              class Upgrade: LevelUpgradeViewAction {
                  override init() { super.init() }
              }

              class OnUpgradeStarted: LevelUpgradeViewAction, LevelUpgradeEventAction {
                  let from: Decimal
                  let to: Decimal
                  init(from: Decimal, to: Decimal) {
                      self.from = from
                      self.to = to
                      super.init()
                  }
              }

              class OnUpgradeSuccess: LevelUpgradeViewAction, LevelUpgradeNavigationAction {
                  let from: Decimal
                  let to: Decimal
                  init(from: Decimal, to: Decimal) {
                      self.from = from
                      self.to = to
                      super.init()
                  }
              }

              class OnUpgradeError: LevelUpgradeViewAction, LevelUpgradeNavigationAction {
                  let error: String
                  init(error: String) {
                      self.error = error
                      super.init()
                  }
              }

              class OnUpgradeSkipped: LevelUpgradeViewAction, LevelUpgradeNavigationAction, LevelUpgradeEventAction {
                  override init() { super.init() }
              }
          }

          """,
          expandedSource:
          """
          extension LevelUpgradeViewAction { }
          """,
          macros: macros,
          indentationWidth: .spaces(4)
        )
    }

}
