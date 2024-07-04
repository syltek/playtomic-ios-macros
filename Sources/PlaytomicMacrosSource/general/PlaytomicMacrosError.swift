//
//  PlaytomicMacrosError.swift
//
//
//  Created by Manuel González Villegas on 8/2/24.
//

import Foundation

enum PlaytomicMacrosError: Error, CustomStringConvertible {
    case message(String)
    
    var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
}
