//
//  Main.swift
//
//
//  Created by Manuel González Villegas on 12/9/23.
//

#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MyPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    StringifyMacro.self,
    WarningMacro.self,
    URLMacro.self,
    AddAsyncMacro.self,
    CaseDetectionMacro.self,
    CopyableMacro.self,
    WrapStoredPropertiesMacro.self,
    StoredAccessMacro.self,
    EquatableMacro.self,
  ]
}
#endif
 
