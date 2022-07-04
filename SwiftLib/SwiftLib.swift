//
//  SwiftLib.swift
//  SwiftLib
//
//  Created by safetrust on 01/07/2022.
//

import Foundation

public final class SwiftLib {
    
    let name = "SwiftLib"
    
    public func add(a: Int, b: Int) -> Int {
        return a + b
    }
    
    public func sub(a: Int, b: Int) -> Int {
        return a - b
    }
    
    public func getVersion() -> String {
        return "0.0.5"
    }
}
