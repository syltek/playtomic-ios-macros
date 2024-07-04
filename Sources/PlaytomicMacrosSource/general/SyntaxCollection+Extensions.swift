//
//  SyntaxCollection+Extensions.swift
//
//
//  Created by Manuel González Villegas on 8/2/24.
//

import SwiftSyntax

extension SyntaxCollection {
    mutating func removeLast() {
        self.remove(at: self.index(before: self.endIndex))
    }
}
