//
//  NewRecordMusicWidgetView.swift
//  jubiinfo
//
//  Created by ggomdyu on 18/04/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Material

public class NewRecordMusicWidgetView : WidgetView {
/**@section Variable */
    @IBOutlet weak var m_contentsView: UIView!
    @IBOutlet weak var m_contentsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var m_newRecordDoesNotExistLabel: UILabel!
    private var m_tickTimer = TickTimer()
    private let m_newRecordMusicWidgetCellHeight: CGFloat = 24.0
    private let m_maxVisibleCellCount = 300
    
/**@section Property */
    public override var lazyInitializeEventName: String {
        return "requestMyPlayDataPageCacheComplete"
    }
    override public var lazyInitializeParam: Any? {
        return DataStorage.instance.queryMyUserData().playDataPageCache
    }

/**@section Method */
    public override func initialize() {
        m_contentsView.alpha = 0.0
        m_contentsViewHeightConstraint.constant = 55
        m_newRecordDoesNotExistLabel.isHidden = true
        
        super.initialize()
    }
    
    public override func lazyInitialize(_ param: Any?) {
        super.lazyInitialize(param)
        
        let newRecordHistories = DataStorage.instance.queryNewRecordHistories()
        if let recentNewRecordHistories = newRecordHistories.value.dropLast().last {
            self.prepareNewRecordMusicCell(recentNewRecordHistories: &recentNewRecordHistories)
            
            (self.superview as? CustomStackView)?.setHeight(height: CGFloat(min(m_maxVisibleCellCount, newRecordHistories.value.count)) * m_newRecordMusicWidgetCellHeight)
            
            let prevWidgetHeightConstant = self.m_contentsViewHeightConstraint.constant
            m_tickTimer.initialize(0.15, { [weak self] (tickTime: Double) in
                guard let strongSelf = self else {
                    return
                }
                
                let interpolated = CGFloat(easeOutQuad(t: strongSelf.m_tickTimer.totalElapsedTime / strongSelf.m_tickTimer.duration))
                strongSelf.m_contentsViewHeightConstraint.constant = prevWidgetHeightConstant + (CGFloat(min(strongSelf.m_maxVisibleCellCount, gameCenterVisitHistories.value.count)) * strongSelf.m_newRecordMusicWidgetCellHeight) * interpolated
            })
        }
        else {
            m_newRecordDoesNotExistLabel.isHidden = false
        }
        
        m_contentsView.animate(.fadeIn)
    }
    
    private func prepareNewRecordMusicCell(recentNewRecordHistories: inout [MusicId: [(MusicScoreData.Difficulty, Int)]]) {
        var iterIndex = 0
        for (key, value) in recentNewRecordHistories {
            let musicScoreDatas = DataStorage.instance.queryMyUserData().musicScoreDataCaches.value.filter { (item: MusicScoreData) -> Bool in return key == item.id }
            if musicScoreDatas.count <= 0 {
                continue
            }
            
            for recentNewRecordHistory in value {
                guard let musicScoreData = musicScoreDatas.first(where: { (item: MusicScoreData) -> Bool in return item.difficulty == recentNewRecordHistory.0 }) else {
                    continue
                }
                
                let cell = self.createMusicNewRecordWidgetViewCell(musicScoreData: musicScoreData, newRecordData: recentNewRecordHistory)
                self.layout(cell).top(42.0 + (m_newRecordMusicWidgetCellHeight * CGFloat(iterIndex))).left(0.0).right(0.0)
            }
            
            
//            if i == recentNewRecordHistories.count - 1 {
//                cell.deactivateBottomLine()
//            }
//
//
//
//            iterIndex += 1
        }
    }
    
    private func createMusicNewRecordWidgetViewCell(musicScoreData: MusicScoreData) -> UIView {
        return UINib(nibName: "GameCenterVisitHistoryWidgetCellView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! GameCenterVisitHistoryWidgetCellView
    }
}
