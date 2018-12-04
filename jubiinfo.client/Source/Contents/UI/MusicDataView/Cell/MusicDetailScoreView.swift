//
//  MusicCellDetailScoreView.swift
//  jubiinfo
//
//  Created by ggomdyu on 15/01/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Charts

class MusicDetailScoreView : UIView {
    @IBOutlet weak var m_contentsView: UIView!
    @IBOutlet weak var m_totalPlayCountLabel: UILabel!
    @IBOutlet weak var m_fullComboCountLabel: UILabel!
    @IBOutlet weak var m_excellentCountLabel: UILabel!
    @IBOutlet weak var m_rateLabel: UILabel!
    @IBOutlet weak var m_rankingLabel: UILabel!
    private var m_musicScoreData: MusicScoreData!

/**@section Method */
    public func initialize(musicScoreData: MusicScoreData) {
        m_musicScoreData = musicScoreData
        
        m_contentsView.alpha = 0.0
        
        self.prepareInitDetailData(musicScoreData: musicScoreData) { [weak self] in
            self?.lazyInitialize()
        }
    }
    
    private func prepareInitDetailData(musicScoreData: MusicScoreData, onPrepareComplate: @escaping () -> Void) {
        let isDetailDataInitialized = musicScoreData.isDetailDataInitialized()
        if isDetailDataInitialized == false {
            let myUserData = DataStorage.instance.queryMyUserData()

            var i = 0
            var musicScoreDataArray = [MusicScoreData?] (repeating: nil, count: 3)
            for item in myUserData.musicScoreDataCaches.value {
                if musicScoreData.id == item.id {
                    musicScoreDataArray[item.difficulty.rawValue] = item
                    i += 1
                    
                    if i >= 3 {
                        break
                    }
                }
            }
            
            guard let basicMusicScoreData = musicScoreDataArray[0],
                  let advancedMusicScoreData = musicScoreDataArray[1],
                  let extremeMusicScoreData = musicScoreDataArray[2] else {
                return
            }
            
            JubeatWebServer.requestDetailMusicScoreData(rivalId: myUserData.rivalId, musicId: musicScoreData.id, destBasicMusicScoreData: basicMusicScoreData, destAdvancedMusicScoreData: advancedMusicScoreData, extremeMusicScoreData: extremeMusicScoreData) { (isRequestSucceed: Bool, isParseSucceed: Bool) in
                runTaskInMainThread {
                    onPrepareComplate()
                }
            }
        }
        else {
            onPrepareComplate()
        }
    }
    
    private func lazyInitialize() {
        guard let musicScoreData = m_musicScoreData else {
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
        
        m_contentsView.animate(.fadeIn)
    }
}
