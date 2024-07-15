//
//  SealedMacroPlayground.swift
//
//
//  Created by Mohammad reza on 10.07.2024.
//

import Foundation
import PlaytomicMacros

protocol ViewAction { }

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
    public class OnAppear: LevelUpgradeViewAction, EventAction, ObserverAction { }

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
    return switch action.navigationActionType {
    case let .OnUpgradeSuccess(action): "Navigation: Upgrade success from \(action.from) to \(action.to)"
    case let .OnUpgradeError(action): "Navigation: Upgrade error: \(action.error)"
    case .OnUpgradeSkipped: "Navigation: Upgrade skipped"
    }
}

private func handleEventAction(_ action: LevelUpgradeViewAction.EventAction) -> String {
    return switch action.eventActionType {
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

    let x: LevelUpgradeViewAction = LevelUpgradeViewAction.OnAppear()

    // FIXME: How `navigationType` is appearing on LevelUpgradeViewAction? it is declared under LevelUpgradeViewAction.NavigationAction only...
    // Uncomment following line to see the crash
    //    print("x.navigationType: ", x.navigationActionType)
    // FIXME: same
    // Uncomment following line to see the crash
    // print("x.eventType: ", x.eventActionType)
}

