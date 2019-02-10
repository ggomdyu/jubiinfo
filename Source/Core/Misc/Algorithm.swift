//
//  Algorithm.swift
//  jubiinfo
//
//  Created by ggomdyu on 17/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
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

public func bubbleSort<T : Comparable>(range: Range<Int>, dataSrc: inout [T]) {
    bubbleSort(range: range, dataSrc: &dataSrc, predicate: { (lhs: T, rhs: T) -> Bool in
        return lhs > rhs
    })
}

public func bubbleSort<T : Comparable>(range: Range<Int>, dataSrc: inout [T], predicate: (T, T) -> Bool) {
    if dataSrc.count <= 1 {
        return
    }
    
    for i in range {
        for j in (i + 1)..<range.endIndex {
            if predicate(dataSrc[i], dataSrc[j]) {
                dataSrc.swapAt(i, j)
            }
        }
    }
}

public func quickSortPartition<T : Comparable>(range: Range<Int>, dataSrc: inout [T], predicate: @escaping (T, T) -> Bool) -> Int {
    var i = range.startIndex
    for j in (range.startIndex + 1)..<range.endIndex {
        if !predicate(dataSrc[j], dataSrc[range.startIndex]) {
            i += 1
            dataSrc.swapAt(i, j)
        }
    }
    dataSrc.swapAt(i, range.startIndex)
    
    return i
}

public func quickSort<T : Comparable>(range: Range<Int>, dataSrc: inout [T], predicate: @escaping (T, T) -> Bool) {    
    if range.count <= 0 {
        return
    }
    
    let pivotIndex = quickSortPartition(range: range, dataSrc: &dataSrc, predicate: predicate)
    
    quickSort(range: range.startIndex..<pivotIndex, dataSrc: &dataSrc, predicate: predicate)
    quickSort(range: (pivotIndex + 1)..<range.endIndex, dataSrc: &dataSrc, predicate: predicate)
}
