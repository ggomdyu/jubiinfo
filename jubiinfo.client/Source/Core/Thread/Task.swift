//
//  Task.swift
//  jubiinfo
//
//  Created by ggomdyu on 11/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation

public func runTaskInMainThread(task: @escaping () -> Void) {
    if Thread.isMainThread {
        task()
    }
    else {
        DispatchQueue.main.sync {
            task()
        }
    }
}
