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
    private var m_tickTimer = TickTimer()
    private let m_visitHistoryWidgetCellHeight: CGFloat = 24.0
    private let m_maxVisibleCellCount = 5
    
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
        
        let gameCenterVisitHistories = DataStorage.instance.queryGameCenterVisitHistories()
        self.prepareVisitHistoryCell(gameCenterVisitHistories: gameCenterVisitHistories)
        
        (self.superview as? CustomStackView)?.setHeight(height: CGFloat(min(m_maxVisibleCellCount, gameCenterVisitHistories.value.count)) * m_visitHistoryWidgetCellHeight)
        
        let prevWidgetHeightConstant = self.m_contentsViewHeightConstraint.constant
        m_tickTimer.initialize(0.15, { [weak self] (tickTime: Double) in
            guard let strongSelf = self else {
                return
            }
            
            let interpolated = CGFloat(easeOutQuad(t: strongSelf.m_tickTimer.totalElapsedTime / strongSelf.m_tickTimer.duration))
            strongSelf.m_contentsViewHeightConstraint.constant = prevWidgetHeightConstant + (CGFloat(min(strongSelf.m_maxVisibleCellCount, gameCenterVisitHistories.value.count)) * strongSelf.m_visitHistoryWidgetCellHeight) * interpolated
        })
        
        m_contentsView.animate(.fadeIn)
    }
    
    private func prepareVisitHistoryCell(gameCenterVisitHistories: GameCenterVisitHistories) {
        var iterIndex = 0
        for i in max(0, gameCenterVisitHistories.value.count - m_maxVisibleCellCount)..<gameCenterVisitHistories.value.count {
            let cell = self.createGameCenterVisitHistoryWidgetViewCell()
            
            let playTuneCount = gameCenterVisitHistories.value[i].3
            let prevPlayTuneCount = (i - 1 < 0) ? gameCenterVisitHistories.value[i].3 : gameCenterVisitHistories.value[i - 1].3
            
            cell.initialize(countryName: gameCenterVisitHistories.value[i].0, gameCenterName: gameCenterVisitHistories.value[i].1, visitDate: gameCenterVisitHistories.value[i].2, playTuneCount: playTuneCount - prevPlayTuneCount)
            
            if i == gameCenterVisitHistories.value.count - 1 {
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
