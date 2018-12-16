//
//  Algorithm.swift
//  jubiinfo
//
//  Created by 차준호 on 17/12/2018.
//  Copyright © 2018 차준호. All rights reserved.
//

import Foundation

public func createNumberWithComma(number: Int64) -> String {
    var needCommaCount: Int = 0;
    
    // Get the comma count
    var tempNumber = number;
    while tempNumber > 10000 {
        needCommaCount += 1
        tempNumber /= 10000
    }
    
    // Create number string that contains comma
    var ret: String = "";
    var charConcatCount = 0;
    let zeroUnicode = Int(("0" as UnicodeScalar).value)
    tempNumber = number
    
    while tempNumber > 0 {
        if (charConcatCount >= 4) {
            ret.insert(Character(","), at: String.Index(encodedOffset: 0))
            charConcatCount = 0
        }
        
        guard let unicodeScalar = UnicodeScalar(zeroUnicode + (Int(tempNumber % 10))) else {
            return ""
        }
        
        ret.insert(Character(unicodeScalar), at: String.Index(encodedOffset: 0))
        
        tempNumber /= 10
        charConcatCount += 1
    }
    
    return ret
}
