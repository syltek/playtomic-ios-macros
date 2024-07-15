//
//  AddInitMacro.swift
//
//
//  Created by Mohammad reza on 11.07.2024.
//


import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftDiagnostics

enum AddInitMacroDiagnostic: PlaytomicMacroError {

    case notAStructOrClass

    var message: String {
        return "'@AddInit' can only be applied to a struct or class"
    }
}

public enum AddInitMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
      guard declaration.isClass || declaration.isStruct else {
          let diagnostic = Diagnostic(node: node, message: AddInitMacroDiagnostic.notAStructOrClass)
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
          return [
            DeclSyntax(
                try InitializerDeclSyntax(SyntaxNodeString(
                    stringLiteral: "\(declaration.as(ClassDeclSyntax.self)?.inheritedClasssName != nil ? "override " : "")\((accessControlToken?.text != nil) ? "\(accessControlToken!.text) " : "")init()")
                ) { }
            )
          ]
      }

      let initializer = try InitializerDeclSyntax(
        generateInitialCode(
            accessControl: accessControlToken?.text,
            variablesName: variablesName,
            variablesType:variablesType
        )
      ) {
          for name in variablesName {
              ExprSyntax("self.\(name) = \(name)")
          }
      }

      return [DeclSyntax(initializer)]
  }

    private static func generateInitialCode(
        accessControl: String?,
        variablesName: [PatternSyntax],
        variablesType: [TypeSyntax]
    ) -> SyntaxNodeString {
        var initialCode: String = "\((accessControl != nil) ? accessControl! : "") init("
        for (name, type) in zip(variablesName, variablesType) {
            initialCode += "\(name): \(type), "
        }
        initialCode = String(initialCode.dropLast(2))
        initialCode += ")"
        return SyntaxNodeString(stringLiteral: initialCode)
    }
}
