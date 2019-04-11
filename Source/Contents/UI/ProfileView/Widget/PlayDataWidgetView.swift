//
//  PlayDataWidgetView.swift
//  jubiinfo
//
//  Created by ggomdyu on 06/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Material
import Motion

class PlayDataWidgetView : WidgetView {
/**@section Variable */
    @IBOutlet weak var m_jubilityLabel: UILabel!
    @IBOutlet weak var m_totalScoreLabel: UILabel!
    @IBOutlet weak var m_playTuneCountLabel: UILabel!
    @IBOutlet weak var m_fullComboCountLabel: UILabel!
    @IBOutlet weak var m_excellentCountLabel: UILabel!
    @IBOutlet weak var m_contentsView: UIView!
    
/**@section Property */
    public override var lazyInitializeEventName: String {
        return "requestMyPlayDataPageCacheComplete"
    }
    override public var lazyInitializeParam: Any? { return DataStorage.instance.queryMyUserData().playDataPageCache }

/**@section Method */
    public override func initialize() {
        m_contentsView.alpha = 0.0
        
        super.initialize()
    }
    
    public override func lazyInitialize(_ param: Any?) {
        super.lazyInitialize(param)
        
        let myUserData = DataStorage.instance.queryMyUserData()
        guard let myPlayDataPageCache = myUserData.playDataPageCache as? UserData.MyPlayDataPageCache else {
            return
        }
        
        m_jubilityLabel.text = "\(myPlayDataPageCache.jubility)"
        m_jubilityLabel.textColor = self.getJubilityColor(jubility: myPlayDataPageCache.jubility)
        
        m_totalScoreLabel.text = "\(createNumberWithComma(number: myPlayDataPageCache.totalScore))(\(myPlayDataPageCache.ranking)位)"
        
        m_fullComboCountLabel.text = "\(myPlayDataPageCache.fullComboCount)회"
        
        m_excellentCountLabel.text = "\(myPlayDataPageCache.excellentCount)회"
        
        m_playTuneCountLabel.text = "\(myPlayDataPageCache.playTuneCount)회"
        
        m_contentsView.animate(.fadeIn)
    }
    
    private func getJubilityColor(jubility: Float) -> UIColor {
        // GOLD
        if jubility >= 9500 {
            return UIColor(red: 245 / 255, green: 210 / 255, blue: 68 / 255, alpha: 1)
        }
        // ORANGE
        else if jubility >= 8500 {
            return UIColor(red: 241 / 255, green: 145 / 255, blue: 81 / 255, alpha: 1)
        }
        // PINK
        else if jubility >= 7000 {
            return UIColor(red: 220 / 255, green: 126 / 255, blue: 197 / 255, alpha: 1)
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
        else if jubility >= 250 {
            return UIColor(red: 185 / 255, green: 204 / 255, blue: 74 / 255, alpha: 1)
        }
        
        return UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)
    }
}
