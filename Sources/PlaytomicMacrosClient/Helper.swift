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

func startRunner(file: String = #file) {
    let fileNameWithExtension = URL(string: file)!.lastPathComponent
    let fileNameWithoutExtension = fileNameWithExtension.replacingOccurrences(of: ".swift", with: "")
    print("\n### --- RUNNING \(fileNameWithoutExtension) --- ###\n")
}

func stopRunner(file: String = #file, function: String = #function) {
    let fileNameWithExtension = URL(string: file)!.lastPathComponent
    let fileNameWithoutExtension = fileNameWithExtension.replacingOccurrences(of: ".swift", with: "")
    print("\n### --- FINISHED \(fileNameWithoutExtension) --- ###\n")
}

