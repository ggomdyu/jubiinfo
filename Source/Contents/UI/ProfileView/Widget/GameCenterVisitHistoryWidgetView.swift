//
//  GameCenterVisitHistoryWidgetView.swift
//  jubiinfo
//
//  Created by ggomdyu on 07/04/2019.
//  Copyright © 2019 차준호. All rights reserved.
//

import Foundation
import UIKit
import Material

public class GameCenterVisitHistoryWidgetCellView : UIView {
/**@section Variable */
    @IBOutlet weak var m_gameCenterName: UILabel!
    @IBOutlet weak var m_detailLabel: UILabel!
    
/**@section Method */
    public func initialize(countryName: String, gameCenterName: String, visitDate: String, playTuneCount: Int) {
        m_gameCenterName.text = self.convertCountryNameToEmoji(countryName: countryName) + gameCenterName
        
        if playTuneCount == 0 {
            m_detailLabel.text = visitDate + "(0튠 이상)"
        }
        else {
            m_detailLabel.text = visitDate + "(\(playTuneCount)튠)"
        }
        
    }
    
    private func convertCountryNameToEmoji(countryName: String) -> String {
        switch countryName {
        case "大韓民国": // Republic of Korea
            return "🇰🇷"
        case "台湾": // Taiwan
            return "🇹🇼"
        case "香港": // Hong Kong
            return "🇭🇰"
        case "中国", "中國": // China
            return "🇨🇳"
        case "米国", "アメリカ": // USA
            return "🇺🇸"
        default: // Japan
            return "🇯🇵"
        }
    }
}

public class GameCenterVisitHistoryWidgetView : WidgetView {
    @IBOutlet weak var m_contentsView: UIView!
    private var m_visitHistories: [(String, String, String, Int)] = []
    
/**@section Variable */
    public override var lazyInitializeEventName: String {
        return "requestMyPlayDataPageCacheComplete"
    }

/**@section Method */
    public override func initialize() {
        super.initialize()
        
        m_contentsView.alpha = 0.0
    }
    
    public override func lazyInitialize(_ param: Any?) {
        super.lazyInitialize(param)
        
        guard let playDataPageCache = DataStorage.instance.queryMyUserData().playDataPageCache else {
            return
        }
        
        self.parseVisitHistories(parseDest: &m_visitHistories)
        
        var needToWriteJson = true
        if let recentVisitHistory = m_visitHistories.last {
            // If play tune count has changed
            let isDifferentPlayTuneCount = recentVisitHistory.3 != playDataPageCache.playTuneCount
            if isDifferentPlayTuneCount {
                // And location has not changed
                let isDifferentLocation = (recentVisitHistory.0 != playDataPageCache.lastPlayedCountry || recentVisitHistory.1 != playDataPageCache.lastPlayedLocation)
                let isDifferentPlayDate = recentVisitHistory.2 != playDataPageCache.lastPlayDate
                if isDifferentLocation || isDifferentPlayDate {
                    m_visitHistories.append((playDataPageCache.lastPlayedCountry, playDataPageCache.lastPlayedLocation, playDataPageCache.lastPlayDate, playDataPageCache.playTuneCount))
                }
                else {
                    needToWriteJson = false
                }
            }
            else {
                needToWriteJson = false
            }
        }
        else {
            m_visitHistories.append((playDataPageCache.lastPlayedCountry, playDataPageCache.lastPlayedLocation, playDataPageCache.lastPlayDate, playDataPageCache.playTuneCount))
        }
        
        if needToWriteJson {
            self.writeVisitHistoryJson(visitHistories: &m_visitHistories)
        }
        
        self.prepareVisitHistoryCell(visitHistories: &m_visitHistories)
        
        m_contentsView.animate(.fadeIn)
    }
    
    private func parseVisitHistories(parseDest: inout [(String, String, String, Int)]) {
        var gameCenterVisitHistoryPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        gameCenterVisitHistoryPath.appendPathComponent("\(SettingDataStorage.instance.getActiveUserId().hash)_gameCenterVisitHistory.json")
        
        guard let jsonData = try? Data(contentsOf: gameCenterVisitHistoryPath),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let visitHistories = jsonDict as? [[Any]] else {
            return
        }
        
        for visitHistory in visitHistories {
            parseDest.append((visitHistory[0] as! String, visitHistory[1] as! String, visitHistory[2] as! String, visitHistory[3] as! Int))
        }
    }
    
    private func writeVisitHistoryJson(visitHistories: inout [(String, String, String, Int)]) {
        var gameCenterVisitHistoryPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        gameCenterVisitHistoryPath.appendPathComponent("\(SettingDataStorage.instance.getActiveUserId().hash)_gameCenterVisitHistory.json")
        
        var jsonStr = "["
        for visitHistory in visitHistories {
            jsonStr += "[\"\(visitHistory.0)\", \"\(visitHistory.1)\", \"\(visitHistory.2)\", \(visitHistory.3)],"
        }
        jsonStr.removeLast()
        jsonStr += "]"
        
        try? jsonStr.write(to: gameCenterVisitHistoryPath, atomically: false, encoding: .utf8)
    }
    
    private func prepareVisitHistoryCell(visitHistories: inout [(String, String, String, Int)]) {
        for i in 0..<visitHistories.count {
            let cell = self.createGameCenterVisitHistoryWidgetViewCell()
            
            let playTuneCount = visitHistories[i].3
            let prevPlayTuneCount = (i - 1 < 0) ? visitHistories[i].3 : visitHistories[i - 1].3
            
            cell.initialize(countryName: visitHistories[i].0, gameCenterName: visitHistories[i].1, visitDate: visitHistories[i].2, playTuneCount: playTuneCount - prevPlayTuneCount)
            
            self.layout(cell).centerHorizontally().top(45.0 + (cell.frame.height * CGFloat(i))).left(0.0).right(0.0)
        }
    }
    
    private func createGameCenterVisitHistoryWidgetViewCell() -> GameCenterVisitHistoryWidgetCellView {
        return UINib(nibName: "GameCenterVisitHistoryWidgetCellView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! GameCenterVisitHistoryWidgetCellView
    }
}
