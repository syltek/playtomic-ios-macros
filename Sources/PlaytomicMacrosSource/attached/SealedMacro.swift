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
    case notAStructOrClass

    var message: String {
        "'@Copyable' can only be applied to a struct or class"
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
        let accessControlToken = modifiers.first?.name
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

        let sealedTypesSynax = sealedTypes.keys.map { inheritedClassName in
            generateEnumType(
                typeName: typeIdentifier.diff(inheritedClassName + SEALED_TYPE_SUFFIX).joined(),
                onGenerateCases: {
                    generateEnumCases(
                        parenTypeName: typeIdentifier,
                        allCases: sealedTypes[inheritedClassName] ?? []
                    )
                }
            )
        }.joined(separator: "\n\n").appending("\n")

        let sealedTypesDefinitionExtensionSyntax = try ExtensionDeclSyntax(
            """
            extension \(type.trimmed) {
            \(raw: sealedTypesSynax)
            }
            """
        )


        let sealedTypesResolutionExtensionSyntaxes = try sealedTypes.keys
            .sorted(by: { lhs, rhs in lhs == typeIdentifier })
            .map { sealedType in
                try generateSealedTypesExtensions(
                    parenTypeName: typeIdentifier,
                    subTypeName: sealedType,
                    subActionTypeName: typeIdentifier.diff(sealedType).joined(),
                    allCases: sealedTypes[sealedType] ?? []
                )
            }.joined(separator: "\n\n")

        return [try ExtensionDeclSyntax(
            """
            extension \(type.trimmed) {
            \(raw: sealedTypesSynax)
            \(raw: sealedTypesResolutionExtensionSyntaxes)
            }
            """
        )]
    }

    private static func generateEnumType(
        typeName: String,
        onGenerateCases: @escaping () -> String
    ) -> String {
        """
        enum \(typeName) {
        \(onGenerateCases())
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

//    private static func generateTypeProperty(parenTypeName: String, allCases: [ClassDeclSyntax]) -> String {
//        let allCasesSyntax = allCases.map { eachCase in
//            let name = eachCase.name.text
//            return "case is \(parenTypeName).\(name): \(parenTypeName)\(SEALED_TYPE_SUFFIX).\(name)\(eachCase.isContainProperty ? "(self as! \(parenTypeName).\(name))" : "")"
//        }.joined(separator: "\n")
//
//        return """
//        var type: \(parenTypeName)\(SEALED_TYPE_SUFFIX) {
//        switch self {
//        \(allCasesSyntax)
//        default: fatalError("Unknown subclass")
//        }
//        }
//        """
//    }


    private static func generateSealedTypesExtensions(
        parenTypeName: String,
        subTypeName: String,
        subActionTypeName: String,
        allCases: [ClassDeclSyntax]
    ) -> String {
        let allCasesSyntax = allCases.map { eachCase in
            let name = eachCase.name.text
            return "case is \(parenTypeName).\(name): \(parenTypeName).\(subActionTypeName)\(SEALED_TYPE_SUFFIX).\(name)\(eachCase.isContainProperty ? "(self as! \(parenTypeName).\(name))" : "")"
        }.joined(separator: "\n")

        return
        """
        var \(subActionTypeName.isEmpty ? "type" : "\(subActionTypeName.lowercased())Type"): \(parenTypeName).\(subActionTypeName)\(SEALED_TYPE_SUFFIX)? {
        switch self {
        \(allCasesSyntax)
        default: nil
        }
        }
        """
    }

}
