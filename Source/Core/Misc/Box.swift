//
//  Box.swift
//  jubiinfo
//
//  Created by ggomdyu on 03/02/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation

final class Box<T> {
/**@section Variable */
    public var value: T
    
/**@section Constructor */
    public init(value: T) {
        self.value = value
    }
}

extension Box : Equatable where T: Equatable {
    static func ==(lhs: Box<T>, rhs: Box<T>) -> Bool {
        return lhs.value == rhs.value
    }
}
