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

public class NewRecordMusicWidgetCellView : UIView {
/**@section Variable */
    @IBOutlet weak var m_difficultyColorView: UIView!
    @IBOutlet weak var m_musicCoverImageView: UIImageView!
    @IBOutlet weak var m_musicNameLabel: UILabel!
    @IBOutlet weak var m_musicExcRankLabelView: UIView!
    @IBOutlet weak var m_musicRankLabel: UILabel!
    @IBOutlet weak var m_musicNewRecordScoreLabel: UILabel!
    @IBOutlet weak var m_musicScoreLabel: UILabel!
    @IBOutlet weak var m_musicFullComboLabel: UILabel!
    @IBOutlet weak var m_lineView: RoundLineDashView!
    private var m_musicScoreData: MusicScoreData!
    
/**@section Method */
    public func initialize(musicScoreData: MusicScoreData, musicNewRecordData: (MusicDifficulty, Int)) {
        
        m_musicScoreData = musicScoreData
        
        // Initialize music name
        m_musicNameLabel.text = musicScoreData.name
        self.addConstraint(NSLayoutConstraint(item: m_musicNameLabel, attribute: .right, relatedBy: .equal, toItem: musicScoreData.isFullCombo ? m_musicFullComboLabel : m_musicScoreLabel, attribute: .left, multiplier: 1, constant: 3.0))
        
        // Initialize score label
        m_musicScoreLabel.text = "\(musicScoreData.score)"
        m_musicNewRecordScoreLabel.text = "(+\(musicNewRecordData.1))"
        
        // Initialize full combo label
        m_musicFullComboLabel.isHidden = !musicScoreData.isFullCombo
        
        // Initialize difficulty color view
        m_difficultyColorView.backgroundColor = self.getMusicDifficultyColor(musicDifficulty: musicNewRecordData.0)
        
        self.prepareRankLabel(musicScoreData: musicScoreData)
        self.prepareCoverImageView(musicScoreData: musicScoreData)
    }
    
    private func prepareRankLabel(musicScoreData: MusicScoreData) {
        if musicScoreData.score >= 1000000 {
            m_musicRankLabel.isHidden = true
            m_musicExcRankLabelView.isHidden = false
        }
        else {
            let rankData = getRankDataByScore(score: musicScoreData.score)
            m_musicRankLabel.text = rankData.0
            m_musicRankLabel.textColor = rankData.1
            
            m_musicExcRankLabelView.isHidden = true
        }
    }
    
    private func prepareCoverImageView(musicScoreData: MusicScoreData) {
        m_musicCoverImageView.alpha = 0.0
        
        let musicCoverImageUrl = "https://p.eagate.573.jp/game/jubeat/festo/images/top/jacket/\(musicScoreData.id / 10000000)/id\(musicScoreData.id).gif"
        downloadImageAsync(imageUrl: musicCoverImageUrl, isWriteCache: true, isReadCache: true, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
            runTaskInMainThread {
                if isDownloadSucceed {
                    self.m_musicCoverImageView.image = image
                }
                
                self.m_musicCoverImageView.animate(.fadeIn)
            }
        })
    }
    
    private func getMusicDifficultyColor(musicDifficulty: MusicDifficulty) -> UIColor {
        if musicDifficulty == .extreme {
            return UIColor(red: 255.0 / 255.0, green: 110.0 / 255.0, blue: 110.0 / 255.0, alpha: 1.0)
        }
        else if musicDifficulty == .advanced {
            return UIColor(red: 246.0 / 255.0, green: 190.0 / 255.0, blue: 66.0 / 255.0, alpha: 1.0)
        }
        else {
            return UIColor(red: 132 / 255, green: 225 / 255, blue: 69 / 255, alpha: 1.0)
        }
    }
    
    private func getRankDataByScore(score: Int)-> (String, UIColor) {
        if (score >= 1000000) {
            return ("EXC", UIColor(red: 147 / 255, green: 230 / 255, blue: 33 / 255, alpha: 1))
        }
        else if (score >= 980000) {
            return ("SSS", UIColor(red: 255 / 255, green: 216 / 255, blue: 83 / 255, alpha: 1))
        }
        else if (score >= 950000) {
            return ("SS", UIColor(red: 255 / 255, green: 216 / 255, blue: 83 / 255, alpha: 1))
        }
        else if (score >= 900000) {
            return ("S", UIColor(red: 255 / 255, green: 216 / 255, blue: 83 / 255, alpha: 1))
        }
        else if (score >= 850000) {
            return ("A", UIColor(red: 255 / 255, green: 124 / 255, blue: 124 / 255, alpha: 1))
        }
        else if (score >= 800000) {
            return ("B", UIColor(red: 69 / 255, green: 165 / 255, blue: 248 / 255, alpha: 1))
        }
        else if (score >= 700000) {
            return ("C", UIColor(red: 161 / 255, green: 161 / 255, blue: 161 / 255, alpha: 1))
        }
        else if (score >= 500000) {
            return ("D", UIColor(red: 161 / 255, green: 161 / 255, blue: 161 / 255, alpha: 1))
        }
        else {
            return ("E", UIColor(red: 161 / 255, green: 161 / 255, blue: 161 / 255, alpha: 1))
        }
    }
    
    public func deactivateBottomLine() {
        m_lineView.isHidden = true
    }
    
/**@section Event handler */
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        MusicDataViewController.show(currentViewController: self.parentViewController!, musicId: m_musicScoreData.id)
    }
}

public class NewRecordMusicWidgetView : WidgetView {
/**@section Variable */
    private static let NewRecordMusicWidgetCellHeight: CGFloat = 24.0
    
    @IBOutlet weak var m_contentsView: UIView!
    @IBOutlet weak var m_contentsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var m_newRecordDoesNotExistLabel: UILabel!
    private var m_tickTimer = TickTimer()
    
/**@section Property */
    public override var lazyInitializeEventName: String {
        return "requestMyMusicScoreDataComplete"
    }
    override public var lazyInitializeParam: Any? {
        let ret = DataStorage.instance.queryMyUserData().musicScoreDataCaches
        return ret.value.count > 0 ? ret : nil
    }

/**@section Method */
    public override func initialize() {
        m_contentsViewHeightConstraint.constant = 45
        m_newRecordDoesNotExistLabel.isHidden = true
        
        super.initialize()
    }
    
    public override func lazyInitialize(_ param: Any?) {
        super.lazyInitialize(param)
        
        var contentsViewHeightOffset: CGFloat = 0.0
        let newRecordHistories = DataStorage.instance.queryNewRecordHistories()
        if var recentNewRecordHistories = newRecordHistories.value.last {
            self.prepareNewRecordMusicCell(recentNewRecordHistories: &recentNewRecordHistories.1)
            
            contentsViewHeightOffset = 10.0 + (CGFloat(recentNewRecordHistories.1.count) * NewRecordMusicWidgetView.NewRecordMusicWidgetCellHeight)
        }
        else {
            contentsViewHeightOffset = 30.0
            m_newRecordDoesNotExistLabel.isHidden = false
        }
        
        DispatchQueue.main.async {
            runTaskInMainThread {
                (self.superview as? CustomStackView)?.addHeight(height: contentsViewHeightOffset)
            }
        }
        
        let prevWidgetHeightConstant = self.m_contentsViewHeightConstraint.constant
        m_tickTimer.initialize(0.15, { [weak self] (tickTime: Double) in
            guard let strongSelf = self else {
                return
            }
            
            let interpolated = CGFloat(easeOutQuad(t: strongSelf.m_tickTimer.totalElapsedTime / strongSelf.m_tickTimer.duration))
            strongSelf.m_contentsViewHeightConstraint.constant = prevWidgetHeightConstant + contentsViewHeightOffset * interpolated
        }) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.m_contentsViewHeightConstraint.constant = prevWidgetHeightConstant + contentsViewHeightOffset
        }
    }
    
    private func prepareNewRecordMusicCell(recentNewRecordHistories: inout [MusicId: [(MusicDifficulty, Int)]]) {
        var iterIndex = 0
        let musicScoreDatas = DataStorage.instance.queryMyUserData().musicScoreDataCaches
        var lastAddedCell: NewRecordMusicWidgetCellView!
        
        for (key, value) in recentNewRecordHistories {
            for musicNewRecordData in value {
                guard let musicScoreData = musicScoreDatas.value.first(where: { (item: MusicScoreData) -> Bool in return item.id == key && item.difficulty == musicNewRecordData.0 }) else {
                    continue
                }
                
                let cell = self.createMusicNewRecordWidgetViewCell(musicScoreData: musicScoreData, musicNewRecordData: musicNewRecordData)
                
                self.layout(cell).top(42.0 + (NewRecordMusicWidgetView.NewRecordMusicWidgetCellHeight * CGFloat(iterIndex))).left(0.0).right(0.0).height(24.0)
                
                lastAddedCell = cell
                iterIndex += 1
            }
        }
        
        lastAddedCell?.deactivateBottomLine()
    }
    
    private func createMusicNewRecordWidgetViewCell(musicScoreData: MusicScoreData, musicNewRecordData: (MusicDifficulty, Int)) -> NewRecordMusicWidgetCellView {
         let ret = UINib(nibName: "NewRecordMusicWidgetCellView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! NewRecordMusicWidgetCellView
        ret.initialize(musicScoreData: musicScoreData, musicNewRecordData: musicNewRecordData)
        
        return ret
    }
}
