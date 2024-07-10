//
//  WrapStoredPropertiesMacroPlayground.swift
//
//
//  Created by Mohammad reza on 10.07.2024.
//

import Foundation
import PlaytomicMacros

@wrapStoredProperties(#"available(*, deprecated, message: "hands off my data")"#)
struct OldStorage {
  var x: Int
}

func runWrapStoredPropertiesMacroPlayground() {

}
