//
//  SealedMacroPlayground.swift
//
//
//  Created by Mohammad reza on 10.07.2024.
//

import Foundation
import PlaytomicMacros

// Copied from Mozart
protocol ViewAction { }

protocol LevelUpgradeNavigationAction {}
protocol LevelUpgradeEventAction {}

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


// Usage example
private func handleViewAction(_ action: LevelUpgradeViewAction.SealedType) -> String {
    switch action {
    case .OnAppear: "On appear"
    case .Upgrade: "Upgrade"
    case let .OnUpgradeStarted(action): "Upgrade started from \(action.from) to \(action.to)"
    case let .OnUpgradeSuccess(action): "Upgrade success from \(action.from) to \(action.to)"
    case let .OnUpgradeError(action): "Upgrade error: \(action.error)"
    case .OnUpgradeSkipped: "Upgrade skipped"
    }
}

// Handling specific action types
private func handleNavigationAction(_ action: LevelUpgradeViewAction.NavigationSealedType) -> String {
    switch action {
    case let .OnUpgradeSuccess(action): "Navigation: Upgrade success from \(action.from) to \(action.to)"
    case let .OnUpgradeError(action): "Navigation: Upgrade error: \(action.error)"
    case .OnUpgradeSkipped: "Navigation: Upgrade skipped"
    }
}

private func handleEventAction(_ action: LevelUpgradeViewAction.EventSealedType) -> String {
    switch action {
    case .OnAppear: "Event: On appear"
    case let .OnUpgradeStarted(action): "Event: Upgrade started from \(action.from) to \(action.to)"
    case .OnUpgradeSkipped: "Event: Upgrade skipped"
    }
}

private func handle(_ action: LevelUpgradeViewAction) {
    if let viewAction = action.type {
        print("VIEW:", handleViewAction(viewAction))
    }

    if let navigationAction = action.navigationType {
        print("NAVIGATION:", handleNavigationAction(navigationAction))
    }

    if let eventAction = action.eventType {
        print("EVENT:", handleEventAction(eventAction))
    }
}

func runSealedMacroPlayground() {
    startRunner()
    defer { stopRunner() }
    handle(LevelUpgradeViewAction.OnUpgradeStarted(from: 1.0, to: 2.0))
    handle(LevelUpgradeViewAction.OnUpgradeSuccess(from: 1.0, to: 2.0))
    handle(LevelUpgradeViewAction.OnUpgradeStarted(from: 1.0, to: 2.0))
//    let x: LevelUpgradeViewAction = LevelUpgradeViewAction.OnAppear()
//    let y: LevelUpgradeEventAction = LevelUpgradeViewAction.OnAppear()
//    let z: LevelUpgradeNavigationAction = LevelUpgradeViewAction.OnUpgradeSkipped()
//    print(x.type)
//    print(x.navigationType)
//    print(x.eventType)
}
