//
//  StoredAccessMacroPlayground.swift
//
//
//  Created by Mohammad reza on 10.07.2024.
//

import Foundation
import PlaytomicMacros

struct User {
    @storedAccess(defaultValue: "")
    var userId: String
}

func runStoredAccessMacroPlayground() {
    startRunner()
    defer { stopRunner() }
    var user = User()
    print(user.userId)
    user.userId = UUID.init().uuidString
    print(user.userId)
}
