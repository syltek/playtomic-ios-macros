//
//  StoredAccessMacro.swift
//
//
//  Created by Manuel González Villegas on 15/2/24.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum StoredAccessMacroDiagnostic: PlaytomicDiagnostic {
    case wrongArgument
    case missingDefaultValue
    case notSupportedType
    case invalidDeclaration
    case unsupportedType

    var message: String {
        switch self {
        case .wrongArgument:
            "Wrong argument"
        case .missingDefaultValue:
            "Missing defaultValue"
        case .notSupportedType:
            "This type is not supported yet"
        case .invalidDeclaration:
            "Invalid declaration"
        case .unsupportedType:
            "Unsupported type"
        }
    }

    var severity: DiagnosticSeverity {
        switch self {
        case .wrongArgument, .missingDefaultValue, .invalidDeclaration:
            DiagnosticSeverity.warning
        case .notSupportedType, .unsupportedType:
            DiagnosticSeverity.error
        }
    }
}


public struct StoredAccessMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self)
        else {
            context.diagnose(
                StoredAccessMacroDiagnostic.wrongArgument.diagnostic(node: node)
            )
            return []
        }

        guard let defaultValue = arguments.first(where: { syntax in
            syntax.label?.text == "defaultValue"
        }) else {
            context.diagnose(
                StoredAccessMacroDiagnostic.missingDefaultValue.diagnostic(node: node)
            )
            return []
        }

        let defaultValueExpression = defaultValue.expression
        let defaultValueDescription = defaultValueExpression.description

        let propertyTypeExpression: String
        if let _ = defaultValueExpression.as(BooleanLiteralExprSyntax.self) {
            propertyTypeExpression = "Bool"
        } else if let _ = defaultValueExpression.as(IntegerLiteralExprSyntax.self) {
            propertyTypeExpression = "Int"
        } else if let _ = defaultValueExpression.as(StringLiteralExprSyntax.self) {
            propertyTypeExpression = "String"
        } else if let _ = defaultValueExpression.as(FloatLiteralExprSyntax.self) {
            propertyTypeExpression = "Float"
        } else {
            if let memberAccess = defaultValueExpression.as(MemberAccessExprSyntax.self),
               let base = memberAccess.base?.as(DeclReferenceExprSyntax.self) {
                propertyTypeExpression = base.baseName.text
            } else {
                context.diagnose(
                    StoredAccessMacroDiagnostic.notSupportedType.diagnostic(node: node)
                )
                return []
            }
        }

        let storeExpression: String
        if let storeValue = (arguments.first { syntax in
            syntax.label?.text == "store"
        }) {
            storeExpression = storeValue.expression.description
        } else {
            storeExpression = "UserDefaults.standard"
        }

        guard let declationSyntax = declaration.as(VariableDeclSyntax.self)?.bindings else {
            context.diagnose(
                StoredAccessMacroDiagnostic.invalidDeclaration.diagnostic(node: node)
            )
            return []
        }
        guard let firstBindingSyntax = declationSyntax.first?.as(PatternBindingSyntax.self)?.pattern.as(IdentifierPatternSyntax.self) else {
            context.diagnose(
                StoredAccessMacroDiagnostic.invalidDeclaration.diagnostic(node: node)
            )
            return []
        }

        let keySyntax = arguments.first { syntax in
            syntax.label?.text == "key"
        }

        let storeKeyValue = keySyntax?.expression.as(StringLiteralExprSyntax.self)?.description ?? "\"\(firstBindingSyntax.identifier.text)\""

        let getExpression: AccessorDeclSyntax
        let setExpression: AccessorDeclSyntax = """
                    \(raw: storeExpression).setValue(newValue, forKey: \(raw: storeKeyValue))
                    """

        if propertyTypeExpression == "Bool" {
            getExpression = """
                    \(raw: storeExpression).bool(forKey: \(raw: storeKeyValue))
                    """
        } else if propertyTypeExpression == "Int" {
            getExpression = """
                    \(raw: storeExpression).integer(forKey: \(raw: storeKeyValue))
                    """
        } else if propertyTypeExpression == "String" {
            getExpression = """
                    \(raw: storeExpression).string(forKey: \(raw: storeKeyValue)) ?? \(raw: defaultValueDescription)
                    """
        } else if propertyTypeExpression == "Float" {
            getExpression = """
                    \(raw: storeExpression).float(forKey: \(raw: storeKeyValue))
                    """
        } else {
            context.diagnose(
                StoredAccessMacroDiagnostic.unsupportedType.diagnostic(node: node)
            )
            return []
        }

        return [
                """
                get {
                    if \(raw: storeExpression).value(forKey: \(raw: storeKeyValue)) == nil {
                        return \(raw: defaultValueDescription)
                    }
                    return \(getExpression)
                }
                set {
                    \(setExpression)
                }
                """
        ]
    }
}
