//
//  SettingData.swift
//  jubiinfo
//
//  Created by ggomdyu on 13/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import CoreData
import Foundation

public class GlobalSettingDataStorage {
/**@section Constructor */
    private init() {
        let lastErrorCode = ErrorCode.Success
        lastErrorRecord = LastErrorRecord(lastErrorCode, lastErrorCode.description)
    }
 
/**@section Method */
    public func setConfig(key: String, value: Any?) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    public func getConfig(key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }
    
    public func removeConfig(key: String, value: Any?) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    public func setLastErrorRecord(_ lastErrorRecord: LastErrorRecord) {
        self.lastErrorRecord = lastErrorRecord
    }
    
    public func setLastErrorRecord() -> LastErrorRecord {
        return self.lastErrorRecord
    }
    
/**@section Variable */
    public static let instance = GlobalSettingDataStorage()
    private var lastErrorRecord: LastErrorRecord
    // widget order
    // music data
}
