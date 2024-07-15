//
//  SealedMacro.swift
//
//
//  Created by Mohammad reza on 8.07.2024.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum SealedMacroDiagnostic: PlaytomicMacroError {
    case noName

    var message: String {
        switch self {
        case .noName:
            "'@Sealed' can only be applied to a type with name"
        }
    }
}

private let SEALED_TYPE_SUFFIX = "SealedType"

public enum SealedMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {

        guard let typeIdentifier = type.as(IdentifierTypeSyntax.self)?.name.trimmed.text else {
            return []
        }

        let modifiers = declaration.modifiers
        let accessControl = modifiers.first?.name.text
        let membersBlock = declaration.memberBlock
        let members = membersBlock.members

        var sealedTypes: [String: [ClassDeclSyntax]] = [:]

        members.forEach { member in
            guard
                let classDecl = member.decl.as(ClassDeclSyntax.self),
                // Check if the member class inherit from parent type
                classDecl.inheritanceClause?.inheritedTypes.contains(where: { (inheritedType) in
                    inheritedType.type.as(IdentifierTypeSyntax.self)?.name.trimmed.text == typeIdentifier
                }) == true
            else {
                return
            }


            // Add member class name to each inherited type
            classDecl.inheritanceClause?.inheritedTypes.forEach { (inheritedType) in
                if let inheritedClassIdentifierSyntax: IdentifierTypeSyntax = inheritedType.type.as(IdentifierTypeSyntax.self) {
                    let inheritedClassName = inheritedClassIdentifierSyntax.name.trimmed.text
                    if sealedTypes[inheritedClassName] == nil {
                        sealedTypes[inheritedClassName] = [classDecl]
                    } else {
                        sealedTypes[inheritedClassName]?.append(classDecl)
                    }
                }
            }
        }

        guard !sealedTypes.isEmpty else { return [] }

        let sealedTypesSynax = sealedTypes.keys.map { sealedTypeName in
            generateEnumType(
                typeName: (sealedTypeName == typeIdentifier ? "" : sealedTypeName) + SEALED_TYPE_SUFFIX,
                caseBuilder: {
                    generateEnumCases(
                        parenTypeName: typeIdentifier,
                        allCases: sealedTypes[sealedTypeName] ?? []
                    )
                }
            )
        }.joined(separator: "\n\n").appending("\n")

        let sealedTypesDefinitionExtensionSyntax = try ExtensionDeclSyntax(
            """
            \(raw:accessControl ?? "") extension \(type.trimmed) {
            \(raw: sealedTypesSynax)
            }
            """
        )


        let sealedTypesResolutionExtensionSyntaxes = try sealedTypes.keys
            .sorted(by: { lhs, rhs in lhs == typeIdentifier })
            .map { sealedType in
                try generateSealedTypesExtensions(
                    accessControl: accessControl ?? "",
                    parenTypeName: typeIdentifier,
                    sealedTypeName: typeIdentifier == sealedType ? "" : sealedType,
                    allCases: sealedTypes[sealedType] ?? []
                )
            }

        return [sealedTypesDefinitionExtensionSyntax] + sealedTypesResolutionExtensionSyntaxes
    }

    private static func generateEnumType(
        typeName: String,
        caseBuilder: @escaping () -> String
    ) -> String {
        """
        enum \(typeName) {
        \(caseBuilder())
        }
        """
    }

    private static func generateEnumCases(parenTypeName: String, allCases: [ClassDeclSyntax]) -> String {
        return allCases.map { eachCase in
            let name = eachCase.name.text
            return "case \(name)\(eachCase.isContainProperty ? "(\(parenTypeName).\(name))" : "")"
        }
        .joined(separator: "\n")
    }

    private static func generateSealedTypesExtensions(
        accessControl: String,
        parenTypeName: String,
        sealedTypeName: String,
        allCases: [ClassDeclSyntax]
    ) throws -> ExtensionDeclSyntax {
        let allCasesSyntax = allCases.map { eachCase in
            let name = eachCase.name.text
            let caseStatementType: String = "\(parenTypeName).\(sealedTypeName)\(SEALED_TYPE_SUFFIX).\(name)"
            let caseStatementArgument: String = eachCase.isContainProperty ? "(self as! \(parenTypeName).\(name))" : ""
            return """
            case is \(parenTypeName).\(name):
            \(caseStatementType)\(caseStatementArgument)
            """
        }.joined(separator: "\n")


        let enumName: String = "\(parenTypeName)\(sealedTypeName.isEmpty ? "" : ".\(sealedTypeName)")"
        let variableName: String = sealedTypeName.isEmpty ? "type" : "\(sealedTypeName.lowerCasedFirstWord)Type"
        let variableType: String = "\(parenTypeName).\(sealedTypeName)\(SEALED_TYPE_SUFFIX)"
        let defaultCaseStatement: String = #"fatalError("Unknown type \(self) in "# + variableType + #"")"#

        return try ExtensionDeclSyntax(
        """
        \(raw: accessControl) extension \(raw: enumName) {
            var \(raw: variableName): \(raw: variableType) {
                switch self {
                \(raw: allCasesSyntax)
                default: 
                    \(raw: defaultCaseStatement)
                }
            }
        }
        """
        )
    }

}
