//
//  Color.swift
//  jubiinfo
//
//  Created by ggomdyu on 27/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation

public struct Color3b {
    public var r, g, b: UInt8
    
    public init(_ r: UInt8, _ g: UInt8, _ b: UInt8) {
        self.r = r;
        self.g = g;
        self.b = b;
    }
    
    public static func +(lhs: Color3b, rhs: Color3b) -> Color3b {
        return Color3b(lhs.r + rhs.r, lhs.g + rhs.g, lhs.b + rhs.b)
    }
    
    public static func -(lhs: Color3b, rhs: Color3b) -> Color3b {
        return Color3b(lhs.r - rhs.r, lhs.g - rhs.g, lhs.b - rhs.b)
    }
    
    public static func ==(lhs: Color3b, rhs: Color3b) -> Bool {
        return lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b
    }
    
    public static func !=(lhs: Color3b, rhs: Color3b) -> Bool {
        return !(lhs == rhs)
    }
}
