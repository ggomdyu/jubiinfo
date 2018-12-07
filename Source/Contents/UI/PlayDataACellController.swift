//
//  PlayDataACellController.swift
//  jubiinfo
//
//  Created by ggomdyu on 06/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Material

class PlayDataACellController : ViewController {
    
    @IBOutlet weak var jubilityLabel: UILabel!
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var lastPlayedTimeLabel: UILabel!
    @IBOutlet weak var lastPlayedLocationLabel: UILabel!
    
    override func prepare() {
        super.prepare()
        
        let myUserData = GlobalUserDataStorage.instance.queryMyUserData()
        guard let myPlayDataPageCache = myUserData.playDataPageCache as? UserData.MyPlayDataPageCache else {
            return
        }
        
        jubilityLabel.text = "\(myPlayDataPageCache.jubility)"
        totalScoreLabel.text = self.createNumberWithComma(number: myPlayDataPageCache.totalScore)
        lastPlayedTimeLabel.text = myPlayDataPageCache.lastPlayedTime
        lastPlayedLocationLabel.text = myPlayDataPageCache.lastPlayedLocation
        rankingLabel.text = "#\(myPlayDataPageCache.ranking)"
    }
}

extension PlayDataACellController {
    
    private func createNumberWithComma(number: Int64) -> String {
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
}
