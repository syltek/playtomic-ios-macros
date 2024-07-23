//
//  DefaultDiagnostic.swift
//
//
//  Created by Manuel González Villegas on 8/2/24.
//

import Foundation
import SwiftDiagnostics

struct DefaultDiagnostic: PlaytomicDiagnostic {
    let message: String
    let severity: DiagnosticSeverity

    init(
        _ message: String,
        severity: DiagnosticSeverity = DiagnosticSeverity.error
    ) {
        self.message = message
        self.severity = severity
    }
}
