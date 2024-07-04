//
//  CopyableMacro.swift
//  
//
//  Created by Mohammad reza on 2.07.2024.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftDiagnostics

enum CopyableMacroDiagnostic: PlaytomicMacroError {
    case notAStructOrClass

    var message: String {
        "'@Copyable' can only be applied to a struct or class"
    }
}

/**
 `CopyableMacro` is a Swift syntax macro that generates a `copy` function for a class or struct,
 similar to the `copy` function in Android. This function allows you to create a copy of an instance
 with modified properties.
 */
public enum CopyableMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.as(StructDeclSyntax.self) != nil || declaration.as(ClassDeclSyntax.self) != nil,
              let name = declaration.as(StructDeclSyntax.self)?.name ?? declaration.as(ClassDeclSyntax.self)?.name else {
            let diagnostic = Diagnostic(node: node, message: CopyableMacroDiagnostic.notAStructOrClass)
            context.diagnose(diagnostic)
            return []
        }

        let modifiers = declaration.modifiers
        let accessControlToken = modifiers.first?.name
        let membersBlock = declaration.memberBlock
        let members = membersBlock.members

        let variables = members.compactMap { member -> VariableDeclSyntax? in
            guard let property = member.decl.as(VariableDeclSyntax.self) else {
                return nil
            }

            guard !property.isComputed && !property.isStatic else {
                return nil
            }

            return property
        }
        let variablesName = variables.compactMap { $0.bindings.first?.pattern }
        let variablesType = variables.compactMap { $0.bindings.first?.typeAnnotation?.type }

        guard !variables.isEmpty else {
            return []
        }


        let function = try FunctionDeclSyntax(
            CopyableMacro.generateFunctionSignature(
                accessControl: accessControlToken?.text,
                variablesName: variablesName,
                variablesType: variablesType,
                returnType: name.trimmed
            )
        ) {

            """
            return \(name.trimmed)(
            \(raw: variablesName.map { propertyName -> String in
                "\(propertyName): \(propertyName) ?? self.\(propertyName)"
            }.joined(separator: ",\n"))
            )
            """
        }

        return [DeclSyntax(function)]
    }

    public static func generateFunctionSignature(
        accessControl: String?,
        variablesName: [PatternSyntax],
        variablesType: [TypeSyntax],
        returnType: TokenSyntax
    ) -> SyntaxNodeString {
        let accesssControlDefinition = "\((accessControl != nil) ? accessControl! : "")"
        let functionNameDefinition = "func copy"

        var arguments: [String] = []
        for (argumentName, argumentType) in zip(variablesName, variablesType) {
            let argumentTypeDescription = argumentType.description
            let isNullable = argumentTypeDescription.contains("?")
            let formattedType = isNullable ? "Nullable<\(argumentTypeDescription.replacingOccurrences(of: "?", with: ""))>" : "\(argumentType)?"
            arguments.append("\(argumentName): \(formattedType) = \(isNullable ? ".none" : "nil")")
        }

        let argumentsDefinition = "(\n\(arguments.joined(separator: ",\n"))\n)"

        let returnTypeDefinition = "-> \(returnType)"

        return SyntaxNodeString(
            // Could be resolved as \(public) \(func myFunctionName)\(a: Int, b: Bool, c: String) -> SelfType
            stringLiteral: "\(accesssControlDefinition) \(functionNameDefinition)\(argumentsDefinition) \(returnTypeDefinition)"
        )
    }
}
