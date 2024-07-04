//
//  PlaytomicDiagnosticMessage.swift
//
//
//  Created by Manuel González Villegas on 8/2/24.
//

import Foundation
import SwiftDiagnostics

struct PlaytomicDiagnosticMessage: DiagnosticMessage {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
}

extension PlaytomicDiagnosticMessage: FixItMessage {
    var fixItID: MessageID { diagnosticID }
}
