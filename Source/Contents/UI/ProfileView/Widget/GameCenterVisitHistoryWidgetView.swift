//
//  GameCenterVisitHistoryWidgetView.swift
//  jubiinfo
//
//  Created by ggomdyu on 07/04/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Material

public class GameCenterVisitHistoryWidgetCellView : UIView {
/**@section Variable */
    @IBOutlet weak var m_gameCenterName: UILabel!
    @IBOutlet weak var m_detailLabel: UILabel!
    @IBOutlet weak var m_lineView: LineDashView!
    
/**@section Method */
    public func initialize(countryName: String, gameCenterName: String, visitDate: String, playTuneCount: Int) {
        m_gameCenterName.text = self.convertCountryNameToEmoji(countryName: countryName) + gameCenterName
        
        if playTuneCount == 0 {
            m_detailLabel.text = visitDate + "(0튠~)"
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
    
    public func deactivateBottomLine() {
        m_lineView.isHidden = true
    }
}

public class GameCenterVisitHistoryWidgetView : WidgetView {
/**@section Variable */
    @IBOutlet weak var m_contentsView: UIView!
    @IBOutlet weak var m_contentsViewHeightConstraint: NSLayoutConstraint!
    private var m_visitHistories: [(String, String, String, Int)] = []
    private var m_tickTimer = TickTimer()
    private let m_visitHistoryWidgetCellHeight: CGFloat = 24.0
    private let m_maxVisibleCellCount = 5
    private let m_visitHistoryMaxSaveCount = 15
    
/**@section Property */
    public override var lazyInitializeEventName: String {
        return "requestMyPlayDataPageCacheComplete"
    }
    override public var lazyInitializeParam: Any? { return DataStorage.instance.queryMyUserData().playDataPageCache }

/**@section Method */
    public override func initialize() {
        m_contentsView.alpha = 0.0
        m_contentsViewHeightConstraint.constant = 55
        
        super.initialize()
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
                    m_visitHistories[m_visitHistories.count - 1].3 = playDataPageCache.playTuneCount
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
        
        (self.superview as? CustomStackView)?.setHeight(height: CGFloat(min(m_maxVisibleCellCount, m_visitHistories.count)) * m_visitHistoryWidgetCellHeight)
        
        let prevWidgetHeightConstant = self.m_contentsViewHeightConstraint.constant
        m_tickTimer.initialize(0.15, { [weak self] (tickTime: Double) in
            guard let strongSelf = self else {
                return
            }
            
            let interpolated = CGFloat(easeOutQuad(t: strongSelf.m_tickTimer.totalElapsedTime / strongSelf.m_tickTimer.duration))
            strongSelf.m_contentsViewHeightConstraint.constant = prevWidgetHeightConstant + (CGFloat(min(strongSelf.m_maxVisibleCellCount, strongSelf.m_visitHistories.count)) * strongSelf.m_visitHistoryWidgetCellHeight) * interpolated
        })
        
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
        for i in max(0, visitHistories.count - m_visitHistoryMaxSaveCount)..<visitHistories.count {
            var visitHistory = visitHistories[i]
            jsonStr += "[\"\(visitHistory.0)\", \"\(visitHistory.1)\", \"\(visitHistory.2)\", \(visitHistory.3)],"
        }
        jsonStr.removeLast()
        jsonStr += "]"
        
        try? jsonStr.write(to: gameCenterVisitHistoryPath, atomically: false, encoding: .utf8)
    }
    
    private func prepareVisitHistoryCell(visitHistories: inout [(String, String, String, Int)]) {
        var iterIndex = 0
        for i in max(0, visitHistories.count - m_maxVisibleCellCount)..<visitHistories.count {
            let cell = self.createGameCenterVisitHistoryWidgetViewCell()
            
            let playTuneCount = visitHistories[i].3
            let prevPlayTuneCount = (i - 1 < 0) ? visitHistories[i].3 : visitHistories[i - 1].3
            
            cell.initialize(countryName: visitHistories[i].0, gameCenterName: visitHistories[i].1, visitDate: visitHistories[i].2, playTuneCount: playTuneCount - prevPlayTuneCount)
            
            if i == visitHistories.count - 1 {
                cell.deactivateBottomLine()
            }
            
            self.layout(cell).top(42.0 + (m_visitHistoryWidgetCellHeight * CGFloat(iterIndex))).left(0.0).right(0.0)
            
            iterIndex += 1
        }
    }
    
    private func createGameCenterVisitHistoryWidgetViewCell() -> GameCenterVisitHistoryWidgetCellView {
        return UINib(nibName: "GameCenterVisitHistoryWidgetCellView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! GameCenterVisitHistoryWidgetCellView
    }
}
