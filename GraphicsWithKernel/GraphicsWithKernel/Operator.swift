//
//  Operators.swift
//  Graphics
//
//  Created by Landon Teeter on 3/21/23.
//

import Metal

infix operator =& : AssignmentPrecedence
extension MTLBuffer?{
    static func =&<T>(lhs: inout Self, rhs: (MTLDevice, T)){
        let _ = withUnsafePointer(to: rhs.1){
            lhs = rhs.0.makeBuffer(bytes: $0, length: MemoryLayout<T>.size)
        }
    }
}
