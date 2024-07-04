//===----------------------------------------------------------------------===//
//
// This source file is inspired from the Swift.org open source project
// https://github.com/apple/swift-syntax/blob/main/Examples/Sources/MacroExamples/Implementation/Expression/URLMacro.swift
//
//  Created by Mohammad reza on 2.07.2024.
//
//===----------------------------------------------------------------------===//


import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

enum URLMacroDiagnostic: PlaytomicMacroError {
    case malformedURL(String)
    case invalidArgument

    var message: String {
        switch self {
        case .malformedURL(let value):
            return "malformed url: \(value)"
        case .invalidArgument:
            return "'#URL' requires a static string literal"
        }
    }
}

/**
 Creates a non-optional URL from a static string. The string is checked to
 be valid during compile time.
 */
public enum URLMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression,
              let stringLiteral = argument.as(StringLiteralExprSyntax.self),
              stringLiteral.segments.count == 1,
              let segment = stringLiteral.segments.first,
              case .stringSegment(let literalSegment) = segment
        else {
            throw URLMacroDiagnostic.invalidArgument
        }

        let urlString = literalSegment.content.text
        guard URL(string: urlString) != nil else {
            throw URLMacroDiagnostic.malformedURL(urlString)
        }

        return "URL(string: \(argument))!"
    }
}
