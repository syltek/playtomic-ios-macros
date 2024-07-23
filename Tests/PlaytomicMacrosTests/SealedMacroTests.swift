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
          class ViewAction { }
          """,
          macros: macros,
          indentationWidth: .spaces(2)
        )
    }

    func testSealedClass() {
        assertMacroExpansion(
          """
          @Sealed
          public class LevelUpgradeViewAction: ViewAction {
              private init() {}

              public protocol NavigationAction {
                  var navigationActionType: NavigationActionSealedType { get }
              }

              public protocol EventAction {
                  var eventActionType: EventActionSealedType { get }
              }

              public protocol ObserverAction {
                  var observerActionType: ObserverActionSealedType { get }
              }

              @AddInit
              public class OnAppear: LevelUpgradeViewAction, EventAction, ObserverAction {
              }

              @AddInit
              public class Upgrade: LevelUpgradeViewAction { }

              @AddInit
              public class OnUpgradeStarted: LevelUpgradeViewAction, EventAction {
                  let from: Decimal
                  let to: Decimal
              }

              @AddInit
              public class OnUpgradeSuccess: LevelUpgradeViewAction, NavigationAction {
                  let from: Decimal
                  let to: Decimal
              }

              @AddInit
              public class OnUpgradeError: LevelUpgradeViewAction, NavigationAction {
                  let error: String
              }

              @AddInit
              public class OnUpgradeSkipped: LevelUpgradeViewAction, NavigationAction, EventAction { }
          }
          """,
          expandedSource:
          #"""
          public class LevelUpgradeViewAction: ViewAction {
              private init() {}

              public protocol NavigationAction {
                  var navigationActionType: NavigationActionSealedType { get }
              }

              public protocol EventAction {
                  var eventActionType: EventActionSealedType { get }
              }

              public protocol ObserverAction {
                  var observerActionType: ObserverActionSealedType { get }
              }

              @AddInit
              public class OnAppear: LevelUpgradeViewAction, EventAction, ObserverAction {
              }

              @AddInit
              public class Upgrade: LevelUpgradeViewAction { }

              @AddInit
              public class OnUpgradeStarted: LevelUpgradeViewAction, EventAction {
                  let from: Decimal
                  let to: Decimal
              }

              @AddInit
              public class OnUpgradeSuccess: LevelUpgradeViewAction, NavigationAction {
                  let from: Decimal
                  let to: Decimal
              }

              @AddInit
              public class OnUpgradeError: LevelUpgradeViewAction, NavigationAction {
                  let error: String
              }

              @AddInit
              public class OnUpgradeSkipped: LevelUpgradeViewAction, NavigationAction, EventAction { }
          }

          public extension LevelUpgradeViewAction {
              enum EventActionSealedType {
                  case OnAppear
                  case OnUpgradeStarted(LevelUpgradeViewAction.OnUpgradeStarted)
                  case OnUpgradeSkipped
              }

              enum NavigationActionSealedType {
                  case OnUpgradeSuccess(LevelUpgradeViewAction.OnUpgradeSuccess)
                  case OnUpgradeError(LevelUpgradeViewAction.OnUpgradeError)
                  case OnUpgradeSkipped
              }

              enum SealedType {
                  case OnAppear
                  case Upgrade
                  case OnUpgradeStarted(LevelUpgradeViewAction.OnUpgradeStarted)
                  case OnUpgradeSuccess(LevelUpgradeViewAction.OnUpgradeSuccess)
                  case OnUpgradeError(LevelUpgradeViewAction.OnUpgradeError)
                  case OnUpgradeSkipped
              }

              enum ObserverActionSealedType {
                  case OnAppear
              }

          }

          public extension LevelUpgradeViewAction {
              var type: LevelUpgradeViewAction.SealedType {
                  switch self {
                  case is LevelUpgradeViewAction.OnAppear:
                      LevelUpgradeViewAction.SealedType.OnAppear
                  case is LevelUpgradeViewAction.Upgrade:
                      LevelUpgradeViewAction.SealedType.Upgrade
                  case is LevelUpgradeViewAction.OnUpgradeStarted:
                      LevelUpgradeViewAction.SealedType.OnUpgradeStarted(self as! LevelUpgradeViewAction.OnUpgradeStarted)
                  case is LevelUpgradeViewAction.OnUpgradeSuccess:
                      LevelUpgradeViewAction.SealedType.OnUpgradeSuccess(self as! LevelUpgradeViewAction.OnUpgradeSuccess)
                  case is LevelUpgradeViewAction.OnUpgradeError:
                      LevelUpgradeViewAction.SealedType.OnUpgradeError(self as! LevelUpgradeViewAction.OnUpgradeError)
                  case is LevelUpgradeViewAction.OnUpgradeSkipped:
                      LevelUpgradeViewAction.SealedType.OnUpgradeSkipped
                  default:
                      fatalError("Unknown type \(self) in LevelUpgradeViewAction.SealedType")
                  }
              }
          }

          public extension LevelUpgradeViewAction.EventAction {
              var eventActionType: LevelUpgradeViewAction.EventActionSealedType {
                  switch self {
                  case is LevelUpgradeViewAction.OnAppear:
                      LevelUpgradeViewAction.EventActionSealedType.OnAppear
                  case is LevelUpgradeViewAction.OnUpgradeStarted:
                      LevelUpgradeViewAction.EventActionSealedType.OnUpgradeStarted(self as! LevelUpgradeViewAction.OnUpgradeStarted)
                  case is LevelUpgradeViewAction.OnUpgradeSkipped:
                      LevelUpgradeViewAction.EventActionSealedType.OnUpgradeSkipped
                  default:
                      fatalError("Unknown type \(self) in LevelUpgradeViewAction.EventActionSealedType")
                  }
              }
          }

          public extension LevelUpgradeViewAction.NavigationAction {
              var navigationActionType: LevelUpgradeViewAction.NavigationActionSealedType {
                  switch self {
                  case is LevelUpgradeViewAction.OnUpgradeSuccess:
                      LevelUpgradeViewAction.NavigationActionSealedType.OnUpgradeSuccess(self as! LevelUpgradeViewAction.OnUpgradeSuccess)
                  case is LevelUpgradeViewAction.OnUpgradeError:
                      LevelUpgradeViewAction.NavigationActionSealedType.OnUpgradeError(self as! LevelUpgradeViewAction.OnUpgradeError)
                  case is LevelUpgradeViewAction.OnUpgradeSkipped:
                      LevelUpgradeViewAction.NavigationActionSealedType.OnUpgradeSkipped
                  default:
                      fatalError("Unknown type \(self) in LevelUpgradeViewAction.NavigationActionSealedType")
                  }
              }
          }

          public extension LevelUpgradeViewAction.ObserverAction {
              var observerActionType: LevelUpgradeViewAction.ObserverActionSealedType {
                  switch self {
                  case is LevelUpgradeViewAction.OnAppear:
                      LevelUpgradeViewAction.ObserverActionSealedType.OnAppear
                  default:
                      fatalError("Unknown type \(self) in LevelUpgradeViewAction.ObserverActionSealedType")
                  }
              }
          }
          """#,
          macros: macros,
          indentationWidth: .spaces(4)
        )
    }

}
