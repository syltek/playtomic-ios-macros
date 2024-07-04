//
//  Helper.swift
//
//
//  Created by Mohammad reza on 2.07.2024.
//

import Foundation


// Copied from PlaytomicFoundation

enum Nullable<T> {
    case none
    case value(T?)

    public func or(_ defValue: T?) -> T? {
        switch self {
        case .none: return defValue
        case let .value(value): return value
        }
    }
}

func ?? <T>(_ nullable: Nullable<T>, _ defValue: T?) -> T? {
    nullable.or(defValue)
}

