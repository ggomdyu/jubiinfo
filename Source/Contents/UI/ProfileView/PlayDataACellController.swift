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
import Motion

class PlayDataACellController : LazyPreparedViewController {
    
    @IBOutlet weak var jubilityLabel: UILabel!
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var lastPlayedTimeLabel: UILabel!
    @IBOutlet weak var lastPlayedLocationLabel: UILabel!
    @IBOutlet weak var contentsView: UIView!
    
    override func prepare() {
        super.prepare()
        
        self.contentsView.alpha = 0.0
    }
    
    override func lazyPrepare(_ param: Any?) {
        super.lazyPrepare(param)
        
        let myUserData = GlobalUserDataStorage.instance.queryMyUserData()
        guard let myPlayDataPageCache = myUserData.playDataPageCache as? UserData.MyPlayDataPageCache else {
            return
        }
        
        // Jubility
        self.jubilityLabel.text = "\(myPlayDataPageCache.jubility)"
        self.jubilityLabel.textColor = self.getJubilityColor(jubility: myPlayDataPageCache.jubility)
        
        // Total score
        self.totalScoreLabel.text = createNumberWithComma(number: myPlayDataPageCache.totalScore)
        
        // Last played time
        self.lastPlayedTimeLabel.text = myPlayDataPageCache.lastPlayedTime
        
        // Last played location
        self.lastPlayedLocationLabel.text = myPlayDataPageCache.lastPlayedLocation
        
        // Ranking
        self.rankingLabel.text = "#\(myPlayDataPageCache.ranking)"
        
        self.contentsView.animate(.fadeIn)
    }
    
    open override func getEventNameRequiredToLazyPrepare() -> String {
        return "requestMyPlayDataComplete"
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
}
