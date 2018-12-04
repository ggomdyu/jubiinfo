//
//  SpinLock.swift
//  jubiinfo
//
//  Created by ggomdyu on 27/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation

public func SpinLock(isLockFinish: @escaping () -> (Bool)) {
    while true {
        if isLockFinish() {
            break;
        }
        print() // DISABLE OPTIMIZATION OF SPINLOCK
    }
}
