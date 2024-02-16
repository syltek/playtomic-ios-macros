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

public struct StoredAccessMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self)
        else {
            context.diagnose(.init(
                node: node,
                message: PlaytomicDiagnosticMessage(
                    message: "Wrong argument",
                    diagnosticID: .init(domain: "playtomic", id: "storedAccess"),
                    severity: .warning
                )
            ))
            return []
        }

        guard let defaultValue = arguments.first(where: { syntax in
            syntax.label?.text == "defaultValue"
        }) else {
            context.diagnose(.init(
                node: node,
                message: PlaytomicDiagnosticMessage(
                    message: "Missing defaultValue",
                    diagnosticID: .init(domain: "playtomic", id: "storedAccess"),
                    severity: .warning
                )
            ))
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
                context.diagnose(.init(
                    node: node,
                    message: PlaytomicDiagnosticMessage(
                        message: "This type is not supported yet",
                        diagnosticID: .init(domain: "playtomic", id: "storedAccess"),
                        severity: .error
                    )
                ))
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
            context.diagnose(.init(
                node: node,
                message: PlaytomicDiagnosticMessage(
                    message: "",
                    diagnosticID: .init(domain: "playtomic", id: "storedAccess"),
                    severity: .warning
                )
            ))
            return []
        }
        guard let firstBindingSyntax = declationSyntax.first?.as(PatternBindingSyntax.self)?.pattern.as(IdentifierPatternSyntax.self) else {
            context.diagnose(.init(
                node: node,
                message: PlaytomicDiagnosticMessage(
                    message: "",
                    diagnosticID: .init(domain: "playtomic", id: "storedAccess"),
                    severity: .warning
                )
            ))
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
            context.diagnose(.init(
                node: node,
                message: PlaytomicDiagnosticMessage(
                    message: "Unsupported type",
                    diagnosticID: .init(domain: "playtomic", id: "storedAccess"),
                    severity: .error
                )
            ))
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
