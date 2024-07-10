//
//  AddAsyncMacroPlayground.swift
//
//
//  Created by Mohammad reza on 10.07.2024.
//

import Foundation
import PlaytomicMacros

@addAsyncMacro
func sportsSelector(sports: [String], callback: @escaping (String) -> Void) -> Void {
    callback(sports.joined(separator: ", "))
}

func runAddAsyncMacroPlayground() async {
    let sport = await sportsSelector(sports: ["Padel", "Tenis", "Pickleball"])
    print("@addAsyncMacro:", sport)
}
