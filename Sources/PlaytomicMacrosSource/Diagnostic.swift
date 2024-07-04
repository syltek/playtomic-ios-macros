//
//  Diagnostic.swift
//
//
//  Created by Mohammad reza on 2.07.2024.
//

import Foundation
import SwiftDiagnostics

internal protocol PlaytomicMacroError: CustomStringConvertible, LocalizedError, DiagnosticMessage {

    var message: String { get }

    var diagnosticID: MessageID { get }

    var severity: DiagnosticSeverity { get }

}

extension PlaytomicMacroError {

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
}
