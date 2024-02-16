//
//  CaseDetectionMacro.swift
//
//
//  Created by Manuel González Villegas on 8/2/24.
//

import SwiftSyntax
import SwiftSyntaxMacros

public enum CaseDetectionMacro: MemberMacro {

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        declaration.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .map { $0.elements.first!.name }
            .map { ($0, $0.initialUppercased) }
            .map { original, uppercased in
                """
                var is\(raw: uppercased): Bool {
                  if case .\(raw: original) = self {
                    return true
                  }

                  return false
                }
                """
            }
    }

}

private extension TokenSyntax {
    var initialUppercased: String {
        let name = self.text
        guard let initial = name.first else {
            return name
        }

        return "\(initial.uppercased())\(name.dropFirst())"
    }
}
