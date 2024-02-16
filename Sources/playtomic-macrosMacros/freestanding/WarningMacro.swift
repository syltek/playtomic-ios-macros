//
//  WarningMacro.swift
//
//
//  Created by Manuel González Villegas on 8/2/24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct WarningMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let messageExpr = node.argumentList.first?.expression.as(StringLiteralExprSyntax.self),
              messageExpr.segments.count == 1,
              let firstSegment = messageExpr.segments.first,
              case let .stringSegment(message) = firstSegment else {
            throw PlaytomicMacrosError.message("warning macro requires a non-interpolated string literal")
        }

        context.diagnose(Diagnostic(node: Syntax(node), message: PlaytomicDiagnosticMessage(
            message: message.description,
            diagnosticID: .init(domain: "playtomic", id: "warning"),
            severity: .warning)))
        return []
    }
}
