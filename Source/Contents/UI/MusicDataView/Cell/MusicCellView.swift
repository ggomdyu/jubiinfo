//
//  MusicCellView.swift
//  jubiinfo
//
//  Created by ggomdyu on 15/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

public class MusicCellView : UIView {
/**@section Variable */
    @IBOutlet weak var m_contentsView: UIView!
    @IBOutlet weak var m_difficultyColorView: UIView!
    @IBOutlet weak var m_jacketImageView: UIImageView!
    @IBOutlet weak var m_musicNameLabel: UILabel!
    @IBOutlet weak var m_musicArtistNameLabel: UILabel!
    @IBOutlet weak var m_excRankLabel: UIView!
    @IBOutlet weak var m_rankLabel: UILabel!
    @IBOutlet weak var m_scoreLabel: UILabel!
    @IBOutlet weak var m_fullComboLabel: UILabel!
    private var m_musicScoreData: MusicScoreData!
    private var m_onTouchCell: (() -> Void)?
    private var m_optMusicCellDetailView: UIView?
    private var m_tickTimer = TickTimer()
    private var m_isViewExpanded = false
    
/**@section Overrided method */
    override public var canBecomeFirstResponder: Bool { return true }
    
/**@section Method */
    public func initialize(musicScoreData: MusicScoreData, onTouchCell: (() -> Void)? = nil) {
        m_musicScoreData = musicScoreData
        m_onTouchCell = onTouchCell
        
        m_musicNameLabel.text = musicScoreData.name
        m_fullComboLabel.isHidden = !musicScoreData.isFullCombo
        m_excRankLabel.isHidden = !musicScoreData.isExcellent
        
        self.prepareTouchEvent()
        self.prepareMusicArtistNameLabel(musicScoreData: musicScoreData)
        self.prepareJacketImage(musicScoreData: musicScoreData)
        self.prepareJacketEdgeColor(musicScoreData: musicScoreData)
        self.prepareRankLabel(musicScoreData: musicScoreData)
        self.prepareScoreLabel(musicScoreData: musicScoreData)
        self.prepareBackgroundColor(musicScoreData: musicScoreData)
    }
    
    private func prepareTouchEvent() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTouchCell(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressCell))
        longPressGestureRecognizer.minimumPressDuration = 0.3
        self.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    private func prepareJacketEdgeColor(musicScoreData: MusicScoreData) {
        m_difficultyColorView.backgroundColor = self.getMusicDifficultyColor(musicDifficulty: musicScoreData.difficulty)
    }
    
    private func prepareJacketImage(musicScoreData: MusicScoreData) {
#if USE_LOW_QUALITY_COVER_IMAGE
        let imageUrl = "https://p.eagate.573.jp/game/jubeat/festo/common/images/jacket/\(musicScoreData.id / 10000000)/id\(musicScoreData.id).gif"
#else
        let imageUrl = "https://p.eagate.573.jp/game/jubeat/festo/images/top/jacket/\(musicScoreData.id / 10000000)/id\(musicScoreData.id).gif"
#endif
        
        downloadImageAsync(imageUrl: imageUrl, onDownloadComplete: { [weak self] (isDownloadSucceed: Bool, image: UIImage?) in
            if isDownloadSucceed {
                runTaskInMainThread {
                    self?.m_jacketImageView.image = image
                }
            }
        })
    }
    
    private func prepareRankLabel(musicScoreData: MusicScoreData) {
        let optRankData = self.getRankDataByScore(score: musicScoreData.score)
        guard let rankData = optRankData else {
            m_rankLabel.isHidden = true
            return;
        }
        
        // If score rank is EXC, then show only EXC rank label.
        if musicScoreData.isExcellent {
            m_rankLabel.isHidden = true
            m_excRankLabel.isHidden = false
            return
        }
        // Otherwise, show the normal rank label which is solid color.
        else {
            m_rankLabel.text = rankData.0
            m_rankLabel.textColor = rankData.1
        }
    }
    
    private func prepareScoreLabel(musicScoreData: MusicScoreData) {
        if musicScoreData.isNotPlayedYet {
            m_scoreLabel.isHidden = true
            return
        }
        
        m_scoreLabel.text = "\(musicScoreData.score)"
    }
    
    private func prepareMusicArtistNameLabel(musicScoreData: MusicScoreData) {
        m_musicArtistNameLabel.text = musicScoreData.artistName
        
        // Fit the artist name label's width to the target's left bound.
        // The 'target' will be the full combo label if it is visible, otherwise, score label.
        let artistNameTralingTarget = musicScoreData.isFullCombo ? m_fullComboLabel : m_scoreLabel
        self.addConstraint(NSLayoutConstraint(item: m_musicArtistNameLabel, attribute: .right, relatedBy: .equal, toItem: artistNameTralingTarget, attribute: .left, multiplier: 1, constant: -8.0))
    }

    private func prepareBackgroundColor(musicScoreData: MusicScoreData) {
        if musicScoreData.isExcellent {
            m_contentsView.backgroundColor = UIColor(red: 1.0, green: 250 / 255, blue: 194 / 255, alpha: 1.0)
        }
    }
    
    private func getMusicDifficultyColor(musicDifficulty: MusicScoreData.Difficulty) -> UIColor {
        if musicDifficulty == .Extreme {
            return UIColor(red: 1.0, green: 0.0, blue: 10 / 255, alpha: 1.0)
        }
        else if musicDifficulty == .Advanced {
            return UIColor(red: 245 / 255, green: 190 / 255, blue: 15 / 255, alpha: 1.0)
        }
        else {
            return UIColor(red: 147 / 255, green: 230 / 255, blue: 33 / 255, alpha: 1.0)
        }
    }
    
    private func getRankDataByScore(score: Int) -> (String, UIColor)? {
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
        else if (score >= 1) {
            return ("E", UIColor(red: 161 / 255, green: 161 / 255, blue: 161 / 255, alpha: 1))
        }
        else {
            return nil
        }
    }
    
    public func Expand() {
        self.prepareInitDetailDataView()
        
        // Finally, do view expand animation.
        let heightConstraint = self.constraints.filter({ (item: NSLayoutConstraint) -> Bool in
            return item.firstAttribute == .height
        })[0]
        UIView.animate(withDuration: 0.5, animations: {
            if let musicCellDetailView = self.m_optMusicCellDetailView {
                heightConstraint.constant += musicCellDetailView.frame.height
                
                self.superview!.layoutIfNeeded()
            }
        })
        // HACK: If you change the heightConstraint's constant and add margin to MusicDataView in UIView.animate animation block at same time, the animation result will not be what I expected. so I seperated both animation logic, one of which is the below code.
        var prevAddedHeight = 0.0
        m_tickTimer.initialize(0.5, { (tickTime: Double) in
            guard let musicCellDetailView = self.m_optMusicCellDetailView else {
                return
            }
            
            let tempHeight = easeInOutSine(t: self.m_tickTimer.totalElapsedTime / self.m_tickTimer.duration) * Double(musicCellDetailView.frame.height)
            let heightToAdd = tempHeight - prevAddedHeight
            prevAddedHeight = tempHeight
            
            let castedView = self.superview as! MusicDataView
            castedView.addHeight(height: CGFloat(heightToAdd))
        })
    }
    
    public func Shrink() {
        let heightConstraint = self.constraints.filter({ (item: NSLayoutConstraint) -> Bool in
            return item.firstAttribute == .height
        })[0]
        
        // Do view shrink animation.
        UIView.animate(withDuration: 0.5, animations: {
            if let musicCellDetailView = self.m_optMusicCellDetailView {
                heightConstraint.constant -= musicCellDetailView.frame.height
                
                self.superview!.layoutIfNeeded()
            }
        })
        // HACK: If you change the heightConstraint's constant and add margin to MusicDataView in UIView.animate animation block at same time, the animation result will not be what I expected. so I seperated both animation logic, one of which is the below code.
        var prevAddedHeight = 0.0
        m_tickTimer.initialize(0.5, { (tickTime: Double) in
            guard let musicCellDetailView = self.m_optMusicCellDetailView else {
                return
            }
            
            let tempHeight = easeInOutSine(t: self.m_tickTimer.totalElapsedTime / self.m_tickTimer.duration) * Double(musicCellDetailView.frame.height)
            let heightToAdd = tempHeight - prevAddedHeight
            prevAddedHeight = tempHeight
            
            let castedView = self.superview as! MusicDataView
            castedView.addHeight(height: CGFloat(-heightToAdd))
        })
    }
    
    private func prepareInitDetailDataView() {
        if m_optMusicCellDetailView == nil {
            // Create the detail view.
            let musicCellDetailView = UINib(nibName: "MusicCellDetailView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MusicCellDetailView
            m_optMusicCellDetailView = musicCellDetailView
            
            // And set its position to bottom of MusicCellView.
            musicCellDetailView.frame.origin.y += self.frame.height;
            
            musicCellDetailView.frame.size.width = self.frame.size.width
            
            m_contentsView.addSubview(musicCellDetailView)
            m_contentsView.layoutIfNeeded()
            
            musicCellDetailView.initialize(musicScoreData: m_musicScoreData)
        }
        
        self.prepareInitDetailData()
    }
    
    private func prepareInitDetailData() {
        let isDetailDataInitialized = m_musicScoreData.isDetailDataInitialized()
        if isDetailDataInitialized == false {
            let myUserData = GlobalDataStorage.instance.queryMyUserData()
            let myRivalId = myUserData.rivalId
            
            let optDetailDataInitTargetIndex = myUserData.musicScoreDataCaches.firstIndex { (item: MusicScoreData) -> Bool in return m_musicScoreData.id == item.id }
            guard let detailDataInitTargetIndex = optDetailDataInitTargetIndex else {
                return
            }
            
            let basicMusicScoreData = myUserData.musicScoreDataCaches[detailDataInitTargetIndex]
            let advancedMusicScoreData = myUserData.musicScoreDataCaches[detailDataInitTargetIndex + 1]
            let extremeMusicScoreData = myUserData.musicScoreDataCaches[detailDataInitTargetIndex + 2]
            JubeatWebServer.requestDetailMusicScoreData(rivalId: myRivalId, musicId: m_musicScoreData.id, destBasicMusicScoreData: basicMusicScoreData, destAdvancedMusicScoreData: advancedMusicScoreData, extremeAdvancedMusicScoreData: extremeMusicScoreData) { [weak self] (isRequestSucceed: Bool, isParseSucceed: Bool) in
                runTaskInMainThread {
                    EventDispatcher.instance.dispatchEvent(eventType: "requestDetailMusicScoreDataComplete", eventParam: self?.m_musicScoreData)
                }
            }
        }
        else {
            EventDispatcher.instance.dispatchEvent(eventType: "requestDetailMusicScoreDataComplete", eventParam: m_musicScoreData)
        }
    }
    
/**@section Event handler */
    @objc func onTouchCell(_ sender: UITapGestureRecognizer) {
        m_onTouchCell?();

        if m_isViewExpanded {
            self.Shrink()
        }
        else {
            self.Expand()
        }

        m_isViewExpanded = !m_isViewExpanded
        
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
    
    @objc private func onLongPressCell(_ sender: UILongPressGestureRecognizer) {
        guard let superView = self.superview, sender.state == .began else {
            return
        }
        
        self.becomeFirstResponder()
        
        UIMenuController.shared.menuItems = [
            UIMenuItem(title: "음악 이름 복사", action: #selector(onTapCopyMusicNameMenuItem)),
            UIMenuItem(title: "아티스트 이름 복사", action: #selector(onTapCopyMusicArtistNameMenuItem))
        ]
        UIMenuController.shared.setTargetRect(self.frame, in: superView)
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
    
    @objc private func onTapCopyMusicNameMenuItem() {
        UIPasteboard.general.string = m_musicScoreData.name
        
        self.resignFirstResponder()
    }
    
    @objc private func onTapCopyMusicArtistNameMenuItem() {
        UIPasteboard.general.string = m_musicScoreData.artistName
        
        self.resignFirstResponder()
    }
}
