//
//  ErrorRecord.swift
//  jubiinfo
//
//  Created by ggomdyu on 20/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation

public enum ErrorCode : Int {
    case Success
    case Failure
    case ParseError
    case NotSupposedParameter
    case DataConversionError
    case ServerNotConnected
    case PageNotFound
    case FileReadError
    case FileWriteError
    
    public var description : String {
        switch self {
        case .Success: return "Success"
        case .Failure: return "Failure"
        case .ParseError: return "ParseError"
        case .NotSupposedParameter: return "NotSupposedParameter"
        case .DataConversionError: return "DataConversionError"
        case .ServerNotConnected: return "ServerNotConnected"
        case .PageNotFound: return "PageNotFound"
        case .FileReadError: return "FileReadError"
        case .FileWriteError: return "FileWriteError"
        }
    }
}

public func recordLastError(_ errorCode: ErrorCode, _ optDescription: String? = nil, optLog: String? = nil) {
    SettingDataStorage.instance.setLastErrorRecord(LastErrorRecord(errorCode, optDescription))
    
    if let log = optLog {
        Debug.log("[DEBUG]: \(log)")
    }
    else if let description = optDescription {
        Debug.log("[DEBUG]: \(description)")
    }
    else {
        Debug.log("[DEBUG]: \(errorCode.description)")
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
