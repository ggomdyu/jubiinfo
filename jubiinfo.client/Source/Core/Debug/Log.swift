//
//  StringUtility.swift
//  jubiinfo
//
//  Created by ggomdyu on 15/03/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation

class Debug {
    public static func log(_ items: Any...) {
#if DEBUG
        print(items)
#endif
    }
}
