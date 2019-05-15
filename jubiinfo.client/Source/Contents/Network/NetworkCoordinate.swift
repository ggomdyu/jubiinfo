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
    public static let cmdUrl = "https://raw.githubusercontent.com/ggomdyu/jubiinfo/master/jubiinfo.client/Resource/DataTable/customMusicDatas_dev.json"
    public static let cmdChecksumUrl = "https://raw.githubusercontent.com/ggomdyu/jubiinfo/master/jubiinfo.client/Resource/DataTable/customMusicDatasChecksum_dev.txt"
    public static let jubiinfoServerUrl = "http://127.0.0.1:8888"
#else
    public static let cmdUrl = "https://raw.githubusercontent.com/ggomdyu/jubiinfo/master/jubiinfo.client/Resource/DataTable/customMusicDatas_live.json"
    public static let cmdChecksumUrl = "https://raw.githubusercontent.com/ggomdyu/jubiinfo/master/jubiinfo.client/Resource/DataTable/customMusicDatasChecksum_live.txt"
    public static let jubiinfoServerUrl = "http://127.0.0.1:8888"
#endif
}
