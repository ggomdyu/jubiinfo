//
//  OmikujiWidgetView.swift
//  jubiinfo
//
//  Created by ggomdyu on 08/02/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

public class OmikujiWidgetView : WidgetView {
/**@section Variable */
    @IBOutlet weak var m_omikujiImageView1: UIImageView!
    @IBOutlet weak var m_omikujiImageView1TopConstraint: NSLayoutConstraint!
    private var m_omikujiBoxDropStartYPos: CGFloat = -150.0
    private var m_omikujiBoxDropEndYPos: CGFloat = 0.0
    @IBOutlet weak var m_omikujiImageView2: UIImageView!
    @IBOutlet weak var m_contentsView: UIView!
    @IBOutlet weak var m_randomMusicPickResultView: UIView!
    private var m_tickTimer = TickTimer()
    private var m_isOmikujiShaking = false
    @IBOutlet weak var m_randomPickedMusicCoverImageView: UIImageView!
    @IBOutlet weak var m_randomPickedMusicNameLabel: UILabel!
    @IBOutlet weak var m_randomPickedMusicArtistLabel: UILabel!
    private var m_optRandomPickedMusicData: MusicScoreData?

/**@section Property */
    open override var lazyInitializeEventName: String {
        return "requestMyMusicScoreDataComplete"
    }
    
/**@section Method */
    override public func initialize() {
        m_omikujiBoxDropEndYPos = m_omikujiImageView1TopConstraint.constant
        m_omikujiImageView1TopConstraint.constant = m_omikujiBoxDropStartYPos
        
        if GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches.value.count > 0 {
            self.lazyInitialize(nil)
        }
        else {
            super.initialize()
        }
    }
    
    override public func lazyInitialize(_ param: Any?) {
        super.lazyInitialize(param)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchView)))
        
        m_randomPickedMusicCoverImageView.isUserInteractionEnabled = true
        m_randomPickedMusicCoverImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTouchMusicCoverView)))
        
        self.playOmikujiBoxDropAnim()
    }
    
    private func prepareRandomMusicPickResultView(randomPickedMusicData: MusicScoreData) {
        let musicCoverImageUrl = "https://p.eagate.573.jp/game/jubeat/festo/images/top/jacket/\(randomPickedMusicData.id / 10000000)/id\(randomPickedMusicData.id).gif"
        downloadImageAsync(imageUrl: musicCoverImageUrl, isWriteCache: true, isReadCache: true, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
            runTaskInMainThread {
                if isDownloadSucceed {
                    self.m_randomPickedMusicCoverImageView.image = image
                    self.m_randomMusicPickResultView.animate(.fadeIn)
                }
            }
        })
        
        m_randomPickedMusicNameLabel.text = randomPickedMusicData.name
        m_randomPickedMusicArtistLabel.text = randomPickedMusicData.artistName.isEmpty ? "-" : randomPickedMusicData.artistName
    }
    
    private func playOmikujiBoxDropAnim() {
        m_omikujiImageView1TopConstraint.constant = m_omikujiBoxDropStartYPos

        m_tickTimer.initialize(0.75, nil) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let tickTimerTimeDivisor = 2.0
            strongSelf.m_tickTimer.initialize(1.0 / tickTimerTimeDivisor, { [weak self] (tickTime: Double) in
                if let strongSelf = self {
                    strongSelf.m_omikujiImageView1TopConstraint.constant = strongSelf.m_omikujiBoxDropStartYPos + CGFloat(easeOutLowBounce(t: strongSelf.m_tickTimer.totalElapsedTime * tickTimerTimeDivisor)) * (strongSelf.m_omikujiBoxDropEndYPos - strongSelf.m_omikujiBoxDropStartYPos)
                }
                }, { [weak self] in
                    if let strongSelf = self {
                        strongSelf.m_isOmikujiShaking = false
                    }
            })
        }
    }
    
/**@section Event handler */
    @objc private func onTouchView(_ sender: Any) {
        if m_isOmikujiShaking {
            return
        }
        
        m_isOmikujiShaking = true
        
        let originImagePosX = self.m_omikujiImageView1.frame.origin.x
        let tau = 3.14159265358 * 2
        let shakeAnimEndTimeDivider = 4.0
        m_tickTimer.initialize(tau / shakeAnimEndTimeDivider, { [weak self] (timer: Double) in
            guard let strongSelf = self else {
                return
            }
            
            let velocity = 3.0 * shakeAnimEndTimeDivider
            let strength = 7.0
            strongSelf.m_omikujiImageView1.frame.origin.x = originImagePosX + CGFloat(sin(strongSelf.m_tickTimer.totalElapsedTime * velocity) * strength)
            }, { [weak self] () in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.m_tickTimer.initialize(0.25, nil) {
                    strongSelf.m_omikujiImageView1.isHidden = true
                    strongSelf.m_omikujiImageView2.isHidden = false
                    
                    strongSelf.m_tickTimer.initialize(0.25, nil) {
                        UIView.animate(withDuration: 0.25, animations: {
                            strongSelf.m_omikujiImageView2.alpha = 0.0
                        })
                        strongSelf.m_tickTimer.initialize(0.5, nil) {
                            strongSelf.onFinishOmikujiShakeAnim()
                        }
                    }
                }
        })
    }
    
    @objc private func onTouchMusicCoverView() {
        guard let randomPickedMusicData = m_optRandomPickedMusicData, let viewController = self.parentViewController else {
            return
        }

        MusicDataViewController.show(currentViewController: viewController, musicId: randomPickedMusicData.id)
    }
    
    private func onFinishOmikujiShakeAnim() {
        let randomPickedMusicData = GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches.value.randomElement()!
        self.prepareRandomMusicPickResultView(randomPickedMusicData: randomPickedMusicData)

        m_optRandomPickedMusicData = randomPickedMusicData
    }
    
    @IBAction func onRetryOmikuji(_ sender: Any) {
        m_omikujiImageView1.isHidden = false
        m_omikujiImageView2.isHidden = true
        m_omikujiImageView2.alpha = 1.0
        m_randomMusicPickResultView.animate(.fadeOut)
        
        self.playOmikujiBoxDropAnim()
    }
}
