//
//  OmikujiCellView.swift
//  jubiinfo
//
//  Created by 차준호 on 08/02/2019.
//  Copyright © 2019 차준호. All rights reserved.
//

import Foundation
import UIKit

public class OmikujiCellView : LazyInitializedView {
    @IBOutlet weak var m_omikujiImageView1: UIImageView!
    @IBOutlet weak var m_omikujiImageView2: UIImageView!
    @IBOutlet weak var m_contentsView: UIView!
    @IBOutlet weak var m_randomMusicPickResultView: UIView!
    private var m_tickTimer = TickTimer()
    private var m_isOmikujiShaking = false
    @IBOutlet weak var m_randomPickedMusicCoverImageView: UIImageView!
    @IBOutlet weak var m_randomPickedMusicNameLabel: UILabel!
    @IBOutlet weak var m_randomPickedMusicArtistLabel: UILabel!

    /**@section Overrided method */
    override public func initialize() {
        super.initialize()
        
        m_contentsView.alpha = 0.0
    }
    
    override public func lazyInitialize(_ param: Any?) {
        super.lazyInitialize(param)
        
        let tabGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTouchView))
        self.addGestureRecognizer(tabGestureRecognizer)
        
        m_contentsView.animate(.fadeIn)
    }
    
    open override func getEventNameRequiredToLazyPrepare() -> String {
        return "requestMyMusicScoreDataComplete"
    }
    
/**@section Method */
    private func prepareRandomMusicPickResultView(randomPickedMusicData: MusicScoreData) {
        let musicCoverImageUrl = "https://p.eagate.573.jp/game/jubeat/festo/images/top/jacket/\(randomPickedMusicData.id / 10000000)/id\(randomPickedMusicData.id).gif"
        downloadImageAsync(imageUrl: musicCoverImageUrl, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
            if isDownloadSucceed {
                runTaskInMainThread {
                    self.m_randomPickedMusicCoverImageView.image = image
                    self.m_randomMusicPickResultView.animate(.fadeIn)
                }
            }
        })
        
        m_randomPickedMusicNameLabel.text = randomPickedMusicData.name
        m_randomPickedMusicArtistLabel.text = randomPickedMusicData.artistName
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
                        strongSelf.m_omikujiImageView2.animate(.fadeOut)
                        strongSelf.m_tickTimer.initialize(0.5, nil) {
                            strongSelf.onFinishOmikujiShakeAnim()
                        }
                    }
                }
        })
    }
    
    private func onFinishOmikujiShakeAnim() {
        let randomPickedMusicData = GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches.randomElement()!
        self.prepareRandomMusicPickResultView(randomPickedMusicData: randomPickedMusicData)
    }
    
    @IBAction func onRetryOmikuji(_ sender: Any) {
        m_omikujiImageView1.isHidden = false
        m_omikujiImageView1.alpha = 0.0
        m_omikujiImageView2.isHidden = true
        m_omikujiImageView2.alpha = 1.0
        m_randomMusicPickResultView.animate(.fadeOut)
        
        m_tickTimer.initialize(1.0, nil) { [weak self] in
            self?.m_omikujiImageView1.animate(.fadeIn)
            
            self?.m_isOmikujiShaking = false
        }
    }
}
