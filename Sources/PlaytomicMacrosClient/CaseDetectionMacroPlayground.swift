//
//  CaseDetectionMacroPlayground.swift
//
//
//  Created by Mohammad reza on 10.07.2024.
//

import Foundation
import PlaytomicMacros

@caseDetection
enum ProfileViewState {
    case loading
    case loaded(userName: String)
}

func runCaseDetectionMacroPlayground() {
    startRunner()
    defer { stopRunner() }
    var state = ProfileViewState.loading
    print("@caseDetection: is the view state loading?: \(state.isLoading)")
    state = ProfileViewState.loaded(userName: "Random name")
    print("@caseDetection: is the view state loaded?: \(state.isLoaded)")
}
