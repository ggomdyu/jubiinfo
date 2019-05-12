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
    @IBOutlet weak var m_lineView: RoundLineDashView!
    
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
    private static let VisitHistoryWidgetCellHeight: CGFloat = 24.0
    private static let ContentsViewHeightOffset: CGFloat = 10.0
    private static let MaxVisibleCellCount = 5
    
    @IBOutlet weak var m_contentsView: UIView!
    @IBOutlet weak var m_contentsViewHeightConstraint: NSLayoutConstraint!
    private var m_tickTimer = TickTimer()
    
/**@section Property */
    public override var lazyInitializeEventName: String {
        return "requestMyPlayDataPageCacheComplete"
    }
    override public var lazyInitializeParam: Any? { return DataStorage.instance.queryMyUserData().playDataPageCache }

/**@section Method */
    public override func initialize() {
        m_contentsViewHeightConstraint.constant = 45
        
        super.initialize()
    }
    
    public override func lazyInitialize(_ param: Any?) {
        super.lazyInitialize(param)
        
        let gameCenterVisitHistories = DataStorage.instance.queryGameCenterVisitHistories()
        self.prepareVisitHistoryCell(gameCenterVisitHistories: gameCenterVisitHistories)
        
        let totalVisitHistoryCellHeight = CGFloat(min(GameCenterVisitHistoryWidgetView.MaxVisibleCellCount, gameCenterVisitHistories.value.count)) * GameCenterVisitHistoryWidgetView.VisitHistoryWidgetCellHeight
        
        DispatchQueue.main.async {
            runTaskInMainThread {
                (self.superview as? CustomStackView)?.addHeight(height: totalVisitHistoryCellHeight + GameCenterVisitHistoryWidgetView.ContentsViewHeightOffset)
            }
        }
        
        let prevWidgetHeightConstant = self.m_contentsViewHeightConstraint.constant
        m_tickTimer.initialize(0.15, { [weak self] (tickTime: Double) in
            guard let strongSelf = self else {
                return
            }
            
            let interpolated = CGFloat(easeOutQuad(t: strongSelf.m_tickTimer.totalElapsedTime / strongSelf.m_tickTimer.duration))
            strongSelf.m_contentsViewHeightConstraint.constant = prevWidgetHeightConstant + GameCenterVisitHistoryWidgetView.ContentsViewHeightOffset + totalVisitHistoryCellHeight * interpolated
        }, { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.m_contentsViewHeightConstraint.constant = prevWidgetHeightConstant + GameCenterVisitHistoryWidgetView.ContentsViewHeightOffset + totalVisitHistoryCellHeight
        })
    }
    
    private func prepareVisitHistoryCell(gameCenterVisitHistories: GameCenterVisitHistories) {
        var iterIndex = 0
        var lastAddedCell: GameCenterVisitHistoryWidgetCellView!
        
        for i in max(0, gameCenterVisitHistories.value.count - GameCenterVisitHistoryWidgetView.MaxVisibleCellCount)..<gameCenterVisitHistories.value.count {
            let cell = self.createGameCenterVisitHistoryWidgetViewCell()
            
            let playTuneCount = gameCenterVisitHistories.value[i].3
            let prevPlayTuneCount = (i - 1 < 0) ? gameCenterVisitHistories.value[i].3 : gameCenterVisitHistories.value[i - 1].3
            
            cell.initialize(countryName: gameCenterVisitHistories.value[i].0, gameCenterName: gameCenterVisitHistories.value[i].1, visitDate: gameCenterVisitHistories.value[i].2, playTuneCount: playTuneCount - prevPlayTuneCount)
            
            self.layout(cell).top(42.0 + (GameCenterVisitHistoryWidgetView.VisitHistoryWidgetCellHeight * CGFloat(iterIndex))).left(0.0).right(0.0)
            
            lastAddedCell = cell
            iterIndex += 1
        }
        
        lastAddedCell.deactivateBottomLine()
    }
    
    private func createGameCenterVisitHistoryWidgetViewCell() -> GameCenterVisitHistoryWidgetCellView {
        return UINib(nibName: "GameCenterVisitHistoryWidgetCellView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! GameCenterVisitHistoryWidgetCellView
    }
}
