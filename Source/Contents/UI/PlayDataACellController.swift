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
        jubilityLabel.textColor = self.getJubilityColor(jubility: myPlayDataPageCache.jubility)
        
        totalScoreLabel.text = self.createNumberWithComma(number: myPlayDataPageCache.totalScore)
        lastPlayedTimeLabel.text = myPlayDataPageCache.lastPlayedTime
        lastPlayedLocationLabel.text = myPlayDataPageCache.lastPlayedLocation
        rankingLabel.text = "#\(myPlayDataPageCache.ranking)"
    }
}

extension PlayDataACellController {
    
    private func getJubilityColor(jubility: Float) -> UIColor {
        
        // GOLD
        if jubility >= 9500 {
            return UIColor(red: 250 / 255, green: 215 / 255, blue: 73 / 255, alpha: 1)
        }
        // ORANGE
        else if jubility >= 8500 {
            return UIColor(red: 222 / 255, green: 162 / 255, blue: 91 / 255, alpha: 1)
        }
        // PINK
        else if jubility >= 7000 {
            return UIColor(red: 212 / 255, green: 168 / 255, blue: 238 / 255, alpha: 1)
        }
        // PURPLE
        else if jubility >= 5500 {
            return UIColor(red: 132 / 255, green: 131 / 255, blue: 240 / 255, alpha: 1)
        }
        // VIOLET
        else if jubility >= 4000 {
            return UIColor(red: 143 / 255, green: 132 / 255, blue: 207 / 255, alpha: 1)
        }
        // BLUE
        else if jubility >= 2500 {
            return UIColor(red: 101 / 255, green: 130 / 255, blue: 195 / 255, alpha: 1)
        }
        // LIGHT BLUE
        else if jubility >= 1500 {
            return UIColor(red: 171 / 255, green: 246 / 255, blue: 251 / 255, alpha: 1)
        }
        // GREEN
        else if jubility >= 750 {
            return UIColor(red: 111 / 255, green: 171 / 255, blue: 94 / 255, alpha: 1)
        }
        // YELLOW GREEN
        else if jubility >= 750 {
            return UIColor(red: 185 / 255, green: 204 / 255, blue: 74 / 255, alpha: 1)
        }
        
        return UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)
    }
    
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
