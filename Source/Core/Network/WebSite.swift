//
//  WebSite.swift
//  jubiinfo
//
//  Created by ggomdyu on 27/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import Alamofire

public protocol WebSite {
    func login(userId: String, userPassword: String, onLoginComplete: @escaping (Bool) -> ())
}
