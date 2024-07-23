//
//  PlaytomicDiagnostic.swift
//
//
//  Created by Mohammad reza on 2.07.2024.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax

internal protocol PlaytomicDiagnostic: CustomStringConvertible, LocalizedError, DiagnosticMessage {

    var message: String { get }

    var diagnosticID: MessageID { get }

    var severity: DiagnosticSeverity { get }

    var fixItID: MessageID { get }

    func diagnostic(node: some SyntaxProtocol) -> Diagnostic
}

extension PlaytomicDiagnostic {

    var description: String {
        return message
    }

    var errorDescription: String? {
        return message
    }

    var diagnosticID: MessageID {
        return MessageID(domain: "PlaytomicMacrosSource", id: message)
    }

    var severity: DiagnosticSeverity {
        return DiagnosticSeverity.error
    }

    var fixItID: MessageID {
        return diagnosticID
    }

    func diagnostic(node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: node, message: self)
    }
}
