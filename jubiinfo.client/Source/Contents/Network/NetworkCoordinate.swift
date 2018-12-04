//
//  NetworkCoordinate.swift
//  jubiinfo
//
//  Created by jhcha on 15/05/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation

class NetworkCoordinate {
#if DEBUG
    private static let appModeName = "dev"
    public static let jubiinfoServerUrl = "http://127.0.0.1:8888"
#else
    private static let appModeName = "live"
    public static let jubiinfoServerUrl = "http://127.0.0.1:8888"
#endif
    
    public static let cmdUrl = "https://raw.githubusercontent.com/ggomdyu/jubiinfo/master/jubiinfo.client/Resource/DataTable/cmd_" + appModeName + ".json"
    public static let cmdChecksumUrl = "https://raw.githubusercontent.com/ggomdyu/jubiinfo/master/jubiinfo.client/Resource/DataTable/cmdChecksum_" + appModeName
}
