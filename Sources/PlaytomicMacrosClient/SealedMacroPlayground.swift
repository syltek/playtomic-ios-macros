//
//  SealedMacroPlayground.swift
//
//
//  Created by Mohammad reza on 10.07.2024.
//

import Foundation
import PlaytomicMacros

// Imagine this is imported from Mozart xD
protocol ViewAction { }

@Sealed
class LevelUpgradeViewAction: ViewAction {
    private init() {}

    protocol NavigationAction {
        var navigationType: NavigationSealedType { get }
    }

    protocol EventAction {
        var eventType: EventSealedType { get }
    }

    protocol ObserverAction {
        var observerType: ObserverSealedType { get }
    }

    @AddInit
    class OnAppear: LevelUpgradeViewAction, EventAction, ObserverAction {
    }

    @AddInit
    class Upgrade: LevelUpgradeViewAction { }

    @AddInit
    class OnUpgradeStarted: LevelUpgradeViewAction, EventAction {
        let from: Decimal
        let to: Decimal
    }

    @AddInit
    class OnUpgradeSuccess: LevelUpgradeViewAction, NavigationAction {
        let from: Decimal
        let to: Decimal
    }

    @AddInit
    class OnUpgradeError: LevelUpgradeViewAction, NavigationAction {
        let error: String
    }

    @AddInit
    class OnUpgradeSkipped: LevelUpgradeViewAction, NavigationAction, EventAction { }
}



func handle(action: LevelUpgradeViewAction) {
    print("VIEW:", handleViewAction(action))

    if let action = action as? LevelUpgradeViewAction.EventAction {
        print("EVENT:", handleEventAction(action))
    }

    if let action = action as? LevelUpgradeViewAction.NavigationAction {
        print("NAVIGATION:", handleNavigationAction(action))
    }
}

// Usage example
private func handleViewAction(_ action: LevelUpgradeViewAction) -> String {
    return switch action.type {
    case .OnAppear: "On appear"
    case .Upgrade: "Upgrade"
    case let .OnUpgradeStarted(action): "Upgrade started from \(action.from) to \(action.to)"
    case let .OnUpgradeSuccess(action): "Upgrade success from \(action.from) to \(action.to)"
    case let .OnUpgradeError(action): "Upgrade error: \(action.error)"
    case .OnUpgradeSkipped: "Upgrade skipped"
    }
}

// Handling specific action types
private func handleNavigationAction(_ action: LevelUpgradeViewAction.NavigationAction) -> String {
    return switch action.navigationType {
    case let .OnUpgradeSuccess(action): "Navigation: Upgrade success from \(action.from) to \(action.to)"
    case let .OnUpgradeError(action): "Navigation: Upgrade error: \(action.error)"
    case .OnUpgradeSkipped: "Navigation: Upgrade skipped"
    }
}

private func handleEventAction(_ action: LevelUpgradeViewAction.EventAction) -> String {
    return switch action.eventType {
    case .OnAppear: "Event: On appear"
    case let .OnUpgradeStarted(action): "Event: Upgrade started from \(action.from) to \(action.to)"
    case .OnUpgradeSkipped: "Event: Upgrade skipped"
    }
}

func runSealedMacroPlayground() {
    startRunner()
    defer { stopRunner() }

    handle(action: LevelUpgradeViewAction.OnAppear())
    handle(action: LevelUpgradeViewAction.OnUpgradeStarted(from: 1.0, to: 2.0))
    handle(action: LevelUpgradeViewAction.OnUpgradeSuccess(from: 1.0, to: 2.0))
    handle(action: LevelUpgradeViewAction.OnUpgradeStarted(from: 1.0, to: 2.0))

//    let x: LevelUpgradeViewAction = LevelUpgradeViewAction.OnAppear()

}

/*

 //    let x: LevelUpgradeViewAction = LevelUpgradeViewAction.OnAppear()


 //    let y: LevelUpgradeViewAction.EventAction = LevelUpgradeViewAction.OnAppear()
 //    let z: LevelUpgradeViewAction.NavigationAction = LevelUpgradeViewAction.OnUpgradeSkipped()
 //    print("x.type: ", x.type)
 //
 //    // FIXME: How `navigationType` is appearing on LevelUpgradeViewAction? it is declared under LevelUpgradeViewAction.NavigationAction only...
 //    print("x.navigationType: ", x.navigationType)
 //    // FIXME: same
 //    print("x.eventType: ", x.eventType)

 */
