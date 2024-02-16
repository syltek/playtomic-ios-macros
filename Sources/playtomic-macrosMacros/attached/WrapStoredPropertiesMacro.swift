//
//  WrapStoredPropertiesMacro.swift
//  
//
//  Created by Manuel González Villegas on 14/2/24.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct WrapStoredPropertiesMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let property = member.as(VariableDeclSyntax.self),
              property.isStoredProperty
        else { return [] }

        guard case let .argumentList(arguments) = node.arguments,
              let firstElement = arguments.first,
              let stringLiteral = firstElement.expression.as(StringLiteralExprSyntax.self),
              stringLiteral.segments.count == 1,
              case let .stringSegment(wrapperName)? = stringLiteral.segments.first 
        else {
            throw PlaytomicMacrosError.message("macro requires a string literal containing the name of an attribute")
        }

        return [
            AttributeSyntax(
                attributeName: IdentifierTypeSyntax(
                    name: .identifier(wrapperName.content.text)
                )
            )
            .with(\.leadingTrivia, [.newlines(1), .spaces(2)])
        ]
    }
}

private extension VariableDeclSyntax {
    /// Determine whether this variable has the syntax of a stored property.
    ///
    /// This syntactic check cannot account for semantic adjustments due to,
    /// e.g., accessor macros or property wrappers.
    var isStoredProperty: Bool {
        if bindings.count != 1 {
            return false
        }

        let binding = bindings.first!
        switch binding.accessorBlock?.accessors {
        case .none:
            return true

        case .accessors(let node):
            for accessor in node {
                switch accessor.accessorSpecifier.tokenKind {
                case .keyword(.willSet), .keyword(.didSet):
                    // Observers can occur on a stored property.
                    break

                default:
                    // Other accessors make it a computed property.
                    return false
                }
            }

            return true

        case .getter:
            return false

        }
    }
}

private extension DeclGroupSyntax {
    /// Enumerate the stored properties that syntactically occur in this
    /// declaration.
    func storedProperties() -> [VariableDeclSyntax] {
        return memberBlock.members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  variable.isStoredProperty 
            else { return nil }

            return variable
        }
    }
}
