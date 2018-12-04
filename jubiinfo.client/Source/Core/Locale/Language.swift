//
//  Language.swift
//  jubiinfo
//
//  Created by ggomdyu on 01/01/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation

public func isHiragana(character: Character) -> Bool {
    let characterValue =  character.unicodeScalars.first!.value
    return 0x3040 <= characterValue && characterValue <= 0x309F
}

public func isKatakana(character: Character) -> Bool {
    let characterValue =  character.unicodeScalars.first!.value
    return 0x30A0 <= characterValue && characterValue <= 0x30FF
}
