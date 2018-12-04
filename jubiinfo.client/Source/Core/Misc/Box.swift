//
//  Box.swift
//  jubiinfo
//
//  Created by ggomdyu on 03/02/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation

public final class Box<T> {
/**@section Variable */
    public var value: T
    
/**@section Constructor */
    public init(_ value: T) {
        self.value = value
    }
}

extension Box : Equatable where T: Equatable {
    public static func ==(lhs: Box<T>, rhs: Box<T>) -> Bool {
        return lhs.value == rhs.value
    }
}
