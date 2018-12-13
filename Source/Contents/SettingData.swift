//
//  SettingData.swift
//  jubiinfo
//
//  Created by ggomdyu on 13/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation

public func recordLastError(_ errorCode: ErrorCode, _ optDescription: String? = nil, optLog: String? = nil) {
    SettingData.instance.setLastErrorRecord(LastErrorRecord(errorCode, optDescription))
    
#if DEBUG
    if let log = optLog {
        print("[DEBUG]: \(log)")
    }
    else if let description = optDescription {
        print("[DEBUG]: \(description)")
    }
    else {
        print("[DEBUG]: \(errorCode.description)")
    }
#endif
}

public enum ErrorCode : Int {
    case OK
    case ParseError
    case NotSupposedParameter
    
    public var description : String {
        switch self {
        case .OK: return "OK"
        case .ParseError: return "ParseError"
        case .NotSupposedParameter: return "NotSupposedValue"
        }
    }
}

public struct LastErrorRecord {
    public init(_ code: ErrorCode, _ description: String? = nil) {
        self.code = code
        self.detailDescription = description
    }
    
    var code: ErrorCode
    var detailDescription: String?
}

public class SettingData {
/**@section Constructor */
    private init() {
        let lastErrorCode = ErrorCode.OK
        lastErrorRecord = LastErrorRecord(lastErrorCode, lastErrorCode.description)
    }
 
/**@section Method */
    public func setLastErrorRecord(_ lastErrorRecord: LastErrorRecord) {
        self.lastErrorRecord = lastErrorRecord
    }
    
    public func setLastErrorRecord() -> LastErrorRecord {
        return self.lastErrorRecord
    }
    
/**@section Variable */
    public static let instance = SettingData()
    private var lastErrorRecord: LastErrorRecord
    // widget order
    // music data
}
