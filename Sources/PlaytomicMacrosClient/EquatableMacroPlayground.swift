//
//  EquatableMacroPlayground.swift
//
//
//  Created by Mohammad reza on 10.07.2024.
//

import Foundation
import PlaytomicMacros

@equatable
struct Match {
    let id: String
    let team: MatchTeam
}

@equatable
struct MatchTeam {
    let id: String
    let playerd: [String]
}

func runEquatableMacroPlayground() {
    let id1 = UUID().uuidString
    let match1 = Match(id: id1, team: MatchTeam(id: id1, playerd: []))
    let match2 = Match(id: id1, team: MatchTeam(id: id1, playerd: []))
    let match3 = Match(id: id1, team: MatchTeam(id: id1, playerd: [id1]))
    print("@Equatable - return true:", match1 == match2)
    print("@Equatable - return false:", match1 == match3)
}


