//
//  MusicCellDetailView.swift
//  jubiinfo
//
//  Created by ggomdyu on 30/01/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

class MusicCellDetailView : UIView {
/**@section Property */
    public var detailScoreView: MusicDetailScoreView { return m_detailScoreView }
    public var scoreGraphView: MusicScoreGraphView { return m_scoreGraphView }
    public var rivalRankView: RivalRankView { return m_rivalRankView }
    
/**@section Variable */
    @IBOutlet weak var m_detailScoreView: MusicDetailScoreView!
    @IBOutlet weak var m_detailScoreViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var m_scoreGraphView: MusicScoreGraphView!
    @IBOutlet weak var m_rivalRankView: RivalRankView!

/**@section Method */
    public func initialize(musicScoreData: MusicScoreData) {
        m_detailScoreView.initialize(musicScoreData: musicScoreData)
        
        // Don't initialize score graph if the music not played yet
        if musicScoreData.scoreHistories != nil {
            m_scoreGraphView.initialize(musicScoreData: musicScoreData)
        }
        
        let myUserData = DataStorage.instance.queryMyUserData()
        if let rivalListPageCache = myUserData.rivalListPageCache, rivalListPageCache.simpleRivalDataList.count > 0 {
            m_rivalRankView.initialize(musicScoreData: musicScoreData)
            m_detailScoreViewTrailingConstraint.constant = self.frame.width * 0.4
        }
        else {
            m_detailScoreViewTrailingConstraint.constant = 0.0
        }
        
        self.layoutIfNeeded()
    }
}
