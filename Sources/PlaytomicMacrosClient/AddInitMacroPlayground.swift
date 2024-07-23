//
//  AddInitMacroPlayground.swift
//
//
//  Created by Mohammad reza on 11.07.2024.
//

import Foundation
import PlaytomicMacros

@AddInit
class Object: CustomStringConvertible {
    let id: Int
    private let name: String

    var description: String {
        "id: \(id), name: \(name)"
    }
}

@AddInit
class Empty { 
    
}

@AddInit
class EmptyInherited: Empty {

}

@AddInit
fileprivate struct Model {
    let id: Int
    static let name: String = "Reza"
}

func runAddInitMacroPlayground() {
    startRunner()
    defer { stopRunner() }
    print(Empty.init())
    print(Object.init(id: 1, name: "reza"))
    print(Model.init(id: 2))
}
