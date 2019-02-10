//
//  MusicCellDetailScoreView.swift
//  jubiinfo
//
//  Created by 차준호 on 15/01/2019.
//  Copyright © 2019 차준호. All rights reserved.
//

import Foundation
import UIKit
import Charts

class MusicDetailScoreView : LazyInitializedView {
    @IBOutlet weak var m_contentsView: UIView!
    @IBOutlet weak var m_totalPlayCountLabel: UILabel!
    @IBOutlet weak var m_fullComboCountLabel: UILabel!
    @IBOutlet weak var m_excellentCountLabel: UILabel!
    @IBOutlet weak var m_rateLabel: UILabel!
    @IBOutlet weak var m_rankingLabel: UILabel!
    private var m_musicScoreData: MusicScoreData?

/**@section Method */
    public func initialize(musicScoreData: MusicScoreData) {
        super.initialize()
        
        m_musicScoreData = musicScoreData
        
        m_contentsView.alpha = 0.0
    }
    
/**@section Overrided method */
    open override func lazyInitialize(_ param: Any?) {
        super.lazyInitialize(param)
        
        let optMusicScoreData = param as? MusicScoreData
        guard let musicScoreData = optMusicScoreData, m_musicScoreData!.id == musicScoreData.id else {
            return
        }
        
        m_totalPlayCountLabel.text = "\(musicScoreData.playTune)회"
        m_fullComboCountLabel.text = "\(musicScoreData.fullComboCount)회"
        m_excellentCountLabel.text = "\(musicScoreData.excellentCount)회"
        
        let musicScoreRate = musicScoreData.musicRate < 0.0 ? 0.0 : musicScoreData.musicRate
        let musicJubility = (Float(musicScoreData.level) / 10.0 * 12.5 * 100.0 / 99.0) * (musicScoreRate / 100.0)
        let truncatedMusicJubility = Float(floor(pow(10.0, Float(1)) * musicJubility)/pow(10.0, Float(1)))
        m_rateLabel.text = "\(truncatedMusicJubility)(\(musicScoreRate)%)"
        
        let musicScoreRanking = Int(musicScoreData.ranking)
        if musicScoreRanking == -1 {
            m_rankingLabel.text =  "-"
        }
        else {
            m_rankingLabel.text =  "#\(musicScoreRanking)"
        }
        
        self.prepareScoreHistoryGraph(musicScoreData: musicScoreData);
        
        m_contentsView.animate(.fadeIn)
    }
    
    open override func getEventNameRequiredToLazyPrepare() -> String {
        return "requestDetailMusicScoreDataComplete"
    }

/**@section Method */
    private func prepareScoreHistoryGraph(musicScoreData: MusicScoreData) {
        
    }
}
