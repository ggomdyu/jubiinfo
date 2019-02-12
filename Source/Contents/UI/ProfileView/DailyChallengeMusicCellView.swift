//
//  DailyChallengeMusicCellView.swift
//  jubiinfo
//
//  Created by ggomdyu on 11/02/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

class DailyChallengeMusicCellView : LazyInitializedView {
/**@section Variable */
    @IBOutlet weak var m_dailyRecommendedMusicCoverImageView: UIImageView!
    @IBOutlet weak var m_dailyRecommendedMusicNameLabel: UILabel!
    @IBOutlet weak var m_dailyRecommendedMusicArtistNameLabel: UILabel!
    @IBOutlet weak var m_dailyFullComboChallengeMusicCoverImageView: UIImageView!
    @IBOutlet weak var m_dailyFullComboChallengeMusicNameLabel: UILabel!
    @IBOutlet weak var m_dailyFullComboChallengeMusicArtistNameLabel: UILabel!
    @IBOutlet weak var m_contentsView: UIView!
    
/**@section Overrided method */
    open override func initialize() {
        super.initialize()
        
        JubeatWebServer.requestStartFullComboChallenge(onRequestComplete: { (isRequestSucceed: Bool) in
            if isRequestSucceed == false {
                return
            }
            
            JubeatWebServer.requestTopPageCache { (isRequestSucceed: Bool, topPageCache: UserData.TopPageCache?) in
                let myUserData = GlobalDataStorage.instance.queryMyUserData()
                myUserData.topPageCache = topPageCache
                
                runTaskInMainThread {
                    EventDispatcher.instance.dispatchEvent(eventType: "requestTopPageCacheComplete", eventParam: topPageCache)
                }
            }
        })
        
        m_contentsView.alpha = 0.0
    }
    
    open override func lazyInitialize(_ param: Any?) {
        super.lazyInitialize(param)
        
        let myUserData = GlobalDataStorage.instance.queryMyUserData()
        guard let topPageCache = param as? UserData.TopPageCache else {
            return
        }
        
        myUserData.topPageCache = topPageCache
        
        DispatchQueue.global().async { [weak self] in
            var coverImageDownloadCount = 0
            
            // Initialize daily recommended music view
            if let dailyRecommendedChallengeMusicData = topPageCache.dailyRecommendedChallengeMusicData {
                downloadImageAsync(imageUrl: dailyRecommendedChallengeMusicData.coverImageUrl, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
                    runTaskInMainThread { [weak self] in
                        coverImageDownloadCount += 1
                        
                        guard let strongSelf = self else {
                            return
                        }
                        
                        if isDownloadSucceed {
                            strongSelf.m_dailyRecommendedMusicCoverImageView.image = image
                        }
                        strongSelf.m_dailyRecommendedMusicNameLabel.text = dailyRecommendedChallengeMusicData.name
                        strongSelf.m_dailyRecommendedMusicArtistNameLabel.text = dailyRecommendedChallengeMusicData.artistName
                    }
                })
            }
            
            // Initialize full combo challenge music view
            if let dailyFullComboChallengeMusicData = topPageCache.dailyFullComboChallengeMusicData {
                downloadImageAsync(imageUrl: dailyFullComboChallengeMusicData.coverImageUrl, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
                    runTaskInMainThread { [weak self] in
                        coverImageDownloadCount += 1
                        
                        guard let strongSelf = self else {
                            return
                        }
                        
                        if isDownloadSucceed {
                            strongSelf.m_dailyFullComboChallengeMusicCoverImageView.image = image
                        }
                        strongSelf.m_dailyFullComboChallengeMusicNameLabel.text = dailyFullComboChallengeMusicData.name
                        strongSelf.m_dailyFullComboChallengeMusicArtistNameLabel.text = dailyFullComboChallengeMusicData.artistName
                    }
                })
            }
            
            SpinLock { return coverImageDownloadCount >= 2 }
            
            runTaskInMainThread {
                self?.m_contentsView.animate(.fadeIn)
            }
        }
    }
    
    open override func getEventNameRequiredToLazyPrepare() -> String {
        return "requestTopPageCacheComplete"
    }
    
}
