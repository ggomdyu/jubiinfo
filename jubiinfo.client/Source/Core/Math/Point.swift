//
//  Point.swift
//  jubiinfo
//
//  Created by ggomdyu on 27/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation

public struct Point<T> {
    public var x, y: T
    
    public init(_ x: T, _ y: T) {
        self.x = x;
        self.y = y;
    }
}
