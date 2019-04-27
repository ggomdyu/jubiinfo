//
//  StringTransform.swift
//  jubiinfo
//
//  Created by ggomdyu on 29/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation

public func transformJapaneseToLatin(sourceStr: String) -> String {
    let ret: NSMutableString = ""
    
    let token = CFStringTokenizerCreate(nil, sourceStr as CFString, CFRangeMake(0, sourceStr.count), kCFStringTokenizerUnitWord, CFLocaleCreate(kCFAllocatorDefault, CFLocaleIdentifier.init("Japanese" as CFString)))
    
    var result = CFStringTokenizerAdvanceToNextToken(token)
    while result != CFStringTokenizerTokenType(rawValue: 0) {
        let typeRef =  CFStringTokenizerCopyCurrentTokenAttribute(token, kCFStringTokenizerAttributeLatinTranscription)
        
        ret.appendFormat("%@", typeRef as! CVarArg)
        
        result = CFStringTokenizerAdvanceToNextToken(token);
        
    }
    
    return ret.copy() as! String
}

public func transformJapaneseToHiragana(sourceStr: String) -> String {
    let latinStr = transformJapaneseToLatin(sourceStr: sourceStr)
    
    return latinStr.applyingTransform(StringTransform.latinToHiragana, reverse: false) ?? sourceStr
}

public func transformJapaneseToKatakana(sourceStr: String) -> String {
    let latinStr = transformJapaneseToLatin(sourceStr: sourceStr)
    
    return latinStr.applyingTransform(StringTransform.latinToKatakana, reverse: false) ?? sourceStr
}

public func removeAccentCharacters(sourceStr: String) -> String {
    return sourceStr.applyingTransform(StringTransform.stripCombiningMarks, reverse: false) ?? sourceStr
}
