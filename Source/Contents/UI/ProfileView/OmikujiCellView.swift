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
        
        var omikujiDataJsonPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        omikujiDataJsonPath.appendPathComponent("omikujiData.json")
        
        let optOmikujiData = self.parseOmikujiData(omikujiDataJsonPath: omikujiDataJsonPath)
        if let omikujiData = optOmikujiData, omikujiData.omikujiResetTime > Timestamp(Date().timeIntervalSince1970) {
            m_contentsView.alpha = 1.0
            m_omikujiImageView1.isHidden = true
            m_omikujiImageView2.isHidden = true
            
            let optRandomPickedMusicData = GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches.first { (item: MusicScoreData) -> Bool in
                return item.id == omikujiData.randomPickedMusicId
            }
            if let randomPickedMusicData = optRandomPickedMusicData {
                self.prepareRandomMusicPickResultView(randomPickedMusicData: randomPickedMusicData)
            }
        }
        else {
            let tabGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTouchView))
            self.addGestureRecognizer(tabGestureRecognizer)
            
            m_contentsView.animate(.fadeIn)
        }
    }
    
    open override func getEventNameRequiredToLazyPrepare() -> String {
        return "requestMyMusicScoreDataComplete"
    }
    
/**@section Method */
    private func parseOmikujiData(omikujiDataJsonPath: URL) -> (omikujiResetTime: Timestamp, randomPickedMusicId: MusicId)? {
        var optJsonDict: [String: Any]?
        do {
            let jsonData = try Data(contentsOf: omikujiDataJsonPath)
            optJsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        }
        catch {}
        
        guard let jsonDict = optJsonDict else {
            return nil
        }
        
        let omikujiResetTime = jsonDict["resetTime"] as? Timestamp ?? 0
        let randomPickedMusicId = jsonDict["musicId"] as? MusicId ?? 0
        
        return (omikujiResetTime, randomPickedMusicId)
    }
    
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
    
    private func saveOmikujiDataToJson(randomPickedMusicData: MusicScoreData) {
        var omikujiDataJsonPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        omikujiDataJsonPath.appendPathComponent("omikujiData.json")
        
        let omikujiDataJson = "{\"resetTime\":\(Timestamp(Date.tomorrow.timeIntervalSince1970)),\"musicId\":\(randomPickedMusicData.id)}"
        do {
            try omikujiDataJson.write(to: omikujiDataJsonPath, atomically: false, encoding: .utf8)
        }
        catch {}
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
        
        self.saveOmikujiDataToJson(randomPickedMusicData: randomPickedMusicData)
    }
}
