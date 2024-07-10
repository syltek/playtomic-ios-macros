//
//  Helper.swift
//
//
//  Created by Mohammad reza on 2.07.2024.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftDiagnostics

extension VariableDeclSyntax {
    var isComputed: Bool {
        guard let accessors = bindings.first?.accessorBlock?.accessors else {
            return false
        }

        switch accessors {
        case .accessors:
            return false
        case .getter:
            return true
        }
    }

    var isStatic: Bool {
        modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.static)
        }
    }
}

extension ClassDeclSyntax {

    var isContainProperty: Bool {
        memberBlock.members.first { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  !variable.isComputed,
                  !variable.isStatic
            else {
                return false
            }

            return true
        } != nil
    }
}

extension String {
    var wordsSeparatedByCapitalLetter: [String] {
        self.lazy
            .map({ $0.isUppercase ? " \($0)" : "\($0)" })
            .joined()
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .components(separatedBy: " ")
    }

    func diff(_ rhs: String) -> [String] {
        let lhsWords = wordsSeparatedByCapitalLetter
        let rhsWords = rhs.wordsSeparatedByCapitalLetter
        var differences: [String] = []

        let minLength = min(lhsWords.count, rhsWords.count)

        for i in 0..<minLength {
            if lhsWords[i] != rhsWords[i] {
                differences.append(rhsWords[i])
            }
        }

        if rhsWords.count > minLength {
            differences.append(contentsOf: rhsWords[minLength...])
        }

        return differences
    }
}
