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
    @IBOutlet weak var m_newScoreLabel: UILabel!
    @IBOutlet weak var m_fullComboLabel: UILabel!
    private var m_musicScoreData: MusicScoreData!
    private var m_onTouchCell: (() -> Void)?
    private var m_musicCellDetailView: MusicCellDetailView!
    private var m_tickTimer = TickTimer()
    private var m_isViewExpanded = false
    private static var topBarHeight: CGFloat!
    private static var isViewTouched: Bool = false
    
/**@section Property */
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
        self.prepareNewScoreLabel(musicScoreData: musicScoreData)
        self.prepareBackgroundColor(musicScoreData: musicScoreData)
    }
    
    private func prepareTouchEvent() {
        self.isExclusiveTouch = true
        
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
        
        downloadImageAsync(imageUrl: imageUrl, isWriteCache: true, isReadCache: true, onDownloadComplete: { [weak self] (isDownloadSucceed: Bool, image: UIImage?) in
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
    
    private func prepareNewScoreLabel(musicScoreData: MusicScoreData) {
        guard musicScoreData.isNotPlayedYet == false,
              let newRecordHistory = DataStorage.instance.queryNewRecordHistories().value.last,
              let newRecordInfo = newRecordHistory.1[musicScoreData.id]?.first(where: { (item: (MusicDifficulty, Int)) -> Bool in return item.0 == musicScoreData.difficulty })
        else {
            m_newScoreLabel.isHidden = true
            return
        }
        
        m_newScoreLabel.text = "+\(newRecordInfo.1)"
    }
    
    private func prepareMusicArtistNameLabel(musicScoreData: MusicScoreData) {
        m_musicArtistNameLabel.text = musicScoreData.artistName.isEmpty ? "-" : musicScoreData.artistName
        
        // Fit the artist name label's width to the target's left bound.
        // The 'target' will be the full combo label if it is visible, otherwise, score label.
        let artistNameTralingTarget = musicScoreData.isFullCombo ? m_fullComboLabel : m_scoreLabel
        self.addConstraint(NSLayoutConstraint(item: m_musicArtistNameLabel, attribute: .right, relatedBy: .equal, toItem: artistNameTralingTarget, attribute: .left, multiplier: 1, constant: -8.0))
    }

    private func prepareBackgroundColor(musicScoreData: MusicScoreData) {
        if musicScoreData.isExcellent {
            m_contentsView.backgroundColor = getCurrentThemeColorTable().musicCellViewExcBackgroundColor
        }
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
        else if (score >= 0) {
            return ("E", UIColor(red: 161 / 255, green: 161 / 255, blue: 161 / 255, alpha: 1))
        }
        else {
            return nil
        }
    }
    
    public func Expand() {
        self.prepareInitDetailDataView()
        
        // Finally, do view expand animation.
        let musicCellViewHeightConstraint = self.constraints.filter({ (item: NSLayoutConstraint) -> Bool in
            return item.firstAttribute == .height
        })[0]

        // HACK: If you change the heightConstraint's constant and add margin to MusicDataView in UIView.animate animation block at same time, the animation results wrong so you sholuld animte it with another way like below.
        let musicDataView = self.superview as! MusicDataView
        let prevMusicDataViewHeight = musicDataView.getHeight()
        let prevMusicCellViewHeightConstant = musicCellViewHeightConstraint.constant
        
        // Block touch event while playing view animation
        let scrollView = self.superview!.superview! as! UIScrollView
        scrollView.isUserInteractionEnabled = false
        
        var detailViewHeight = m_musicCellDetailView.frame.height
        if m_musicScoreData.isNotPlayedYet {
            detailViewHeight -= m_musicCellDetailView.scoreGraphView.frame.height
        }
        
        // Check the scroll view needs to scroll.
        let myScreenPos = self.superview?.convert(self.frame.origin, to: nil) ?? CGPoint(x: 0.0, y: 0.0)
        let screenHeight = UIApplication.shared.keyWindow!.frame.height
        let isNeedToScrollParentView = myScreenPos.y + self.frame.height + detailViewHeight > screenHeight
        let prevScrollViewContentsOffsetY = scrollView.contentOffset.y
        let scrollOffsetToAdd = (myScreenPos.y + self.frame.height + detailViewHeight) - screenHeight

        // Expand height of music data view which contains the music cell view
        let currViewHeight = detailViewHeight + prevMusicDataViewHeight
        musicDataView.setHeight(height: currViewHeight)
        
        func processExpandAnim(interpolated: CGFloat) {
            // Expand music cell view
            musicCellViewHeightConstraint.constant = (interpolated * detailViewHeight) + prevMusicCellViewHeightConstant
        }
        
        func processScrollAnim(interpolated: CGFloat) {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: prevScrollViewContentsOffsetY + (interpolated * (scrollOffsetToAdd + 20.0))), animated: false)
        }
        
        m_tickTimer.initialize(Double(0.5 * (detailViewHeight / m_musicCellDetailView.frame.height)), isNeedToScrollParentView ? { [weak self] (tickTime: Double) in
            guard let strongSelf = self else {
                return
            }
            
            let interpolated = CGFloat(easeOutQuad(t: strongSelf.m_tickTimer.totalElapsedTime / strongSelf.m_tickTimer.duration))
            processExpandAnim(interpolated: interpolated)
            processScrollAnim(interpolated: interpolated)
        } : { [weak self] (tickTime: Double) in
            guard let strongSelf = self else {
                return
            }
            
            let interpolated = CGFloat(easeOutQuad(t: strongSelf.m_tickTimer.totalElapsedTime / strongSelf.m_tickTimer.duration))
            processExpandAnim(interpolated: interpolated)
        }, {
           scrollView.isUserInteractionEnabled = true
            processExpandAnim(interpolated: 1.0)
        })
    }
    
    public func Shrink() {
        let musicCellViewHeightConstraint = self.constraints.filter({ (item: NSLayoutConstraint) -> Bool in
            return item.firstAttribute == .height
        })[0]
        
        // HACK: If you change the heightConstraint's constant and add margin to MusicDataView in UIView.animate animation block at same time, the animation results wrong so you sholuld animte it with another way like below.
        let musicDataView = self.superview as! MusicDataView
        let prevMusicDataViewHeight = musicDataView.getHeight()
        let prevMusicCellViewHeightConstant = musicCellViewHeightConstraint.constant
        
        // Block touch event while playing view animation
        let scrollView = self.superview!.superview! as! UIScrollView
        scrollView.isUserInteractionEnabled = false
        
        var detailViewHeight = m_musicCellDetailView.frame.height
        if self.m_musicScoreData.isNotPlayedYet {
            detailViewHeight -= m_musicCellDetailView.scoreGraphView.frame.height
        }
        
        // Check the scroll view needs to scroll.
        if MusicCellView.topBarHeight == nil {
            let toolBarController = (parentViewController!.parent as! MusicDataViewToolBarController)
            MusicCellView.topBarHeight = toolBarController.toolbar.frame.height + toolBarController.statusBar.frame.height
        }
        let myScreenPos = self.superview?.convert(self.frame.origin, to: nil) ?? CGPoint(x: 0.0, y: 0.0)
        let myClientPosY = myScreenPos.y - MusicCellView.topBarHeight
        let isNeedToScrollParentView = myClientPosY < -(self.frame.height - detailViewHeight)
        let prevScrollViewContentsOffsetY = scrollView.contentOffset.y

        func processShrinkAnim(interpolated: CGFloat) {
            // Expand height of music data view which contains the music cell view
            let currViewHeight = prevMusicDataViewHeight - (interpolated * detailViewHeight)
            musicDataView.setHeight(height: currViewHeight)
            
            // Expand music cell view
            musicCellViewHeightConstraint.constant = prevMusicCellViewHeightConstant - (interpolated * detailViewHeight)
        }
        
        func processScrollAnim(interpolated: CGFloat) {
            scrollView.setContentOffset(CGPoint(x: 0.0, y: max(0, prevScrollViewContentsOffsetY - (interpolated * detailViewHeight))), animated: false)
        }
        
        m_tickTimer.initialize(Double(0.5 * (detailViewHeight / m_musicCellDetailView.frame.height)), isNeedToScrollParentView ? { [weak self] (tickTime: Double) in
            guard let strongSelf = self else {
                return
            }
            
            let interpolated = CGFloat(easeOutQuad(t: strongSelf.m_tickTimer.totalElapsedTime / strongSelf.m_tickTimer.duration))
            processShrinkAnim(interpolated: interpolated)
            processScrollAnim(interpolated: interpolated)
        } : { [weak self] (tickTime: Double) in
            guard let strongSelf = self else {
                return
            }
            
            let interpolated = CGFloat(easeOutQuad(t: strongSelf.m_tickTimer.totalElapsedTime / strongSelf.m_tickTimer.duration))
            processShrinkAnim(interpolated: interpolated)
        }, {
            scrollView.isUserInteractionEnabled = true
            processShrinkAnim(interpolated: 1.0)
        })
    }
    
    private func prepareInitDetailDataView() {
        if m_musicCellDetailView == nil {
            // Create the detail view.
            let musicCellDetailView = UINib(nibName: "MusicCellDetailView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MusicCellDetailView
            m_musicCellDetailView = musicCellDetailView
            
            // And set its position to bottom of MusicCellView.
            musicCellDetailView.frame.origin.y += self.frame.height;
            
            musicCellDetailView.frame.size.width = self.frame.size.width
            
            m_contentsView.addSubview(musicCellDetailView)
            m_contentsView.layoutIfNeeded()
            
            musicCellDetailView.initialize(musicScoreData: m_musicScoreData)
        }
    }
    
/**@section Event handler */
    @objc private func onLongPressCell(_ sender: UILongPressGestureRecognizer) {
        guard let superView = self.superview, sender.state == .began else {
            return
        }
        
        self.becomeFirstResponder()
        
        // 아래 코드는 잠시 테스트용!!!
        m_onTouchCell?();
        
        if m_isViewExpanded {
            self.Shrink()
        }
        else {
            self.Expand()
        }
        
        m_isViewExpanded = !m_isViewExpanded
        
        UIMenuController.shared.setMenuVisible(false, animated: true)
        
//        UIMenuController.shared.menuItems = [
//            UIMenuItem(title: "음악 이름 복사", action: #selector(onTapCopyMusicNameMenuItem)),
//            UIMenuItem(title: "아티스트 이름 복사", action: #selector(onTapCopyMusicArtistNameMenuItem))
//        ]
//        UIMenuController.shared.setTargetRect(self.frame, in: superView)
//        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
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
    
    @objc private func onTapCopyMusicNameMenuItem() {
        UIPasteboard.general.string = m_musicScoreData.name
        
        self.resignFirstResponder()
    }
    
    @objc private func onTapCopyMusicArtistNameMenuItem() {
        UIPasteboard.general.string = m_musicScoreData.artistName
        
        self.resignFirstResponder()
    }
}
