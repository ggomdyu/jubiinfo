//
//  DailyChallengeCellView.swift
//  jubiinfo
//
//  Created by 차준호 on 11/02/2019.
//  Copyright © 2019 차준호. All rights reserved.
//

import Foundation
import UIKit

class DailyChallengeCellView : LazyInitializedView {
/**@section Variable */
    @IBOutlet weak var m_dailyRecommendedMusicCoverImageView: UIImageView!
    @IBOutlet weak var m_dailyRecommendedMusicNameLabel: UILabel!
    @IBOutlet weak var m_dailyRecommendedMusicArtistNameLabel: UILabel!
    @IBOutlet weak var m_fullComboChallengeMusicCoverImageView: UIImageView!
    @IBOutlet weak var m_fullComboChallengeMusicNameLabel: UILabel!
    @IBOutlet weak var m_fullComboChallengeMusicArtistNameLabel: UILabel!
    @IBOutlet weak var m_contentsView: UIView!
    
/**@section Overrided method */
    open override func initialize() {
        super.initialize()
        
        JubeatWebServer.requestTopPageCache { (isRequestSucceed: Bool, topPageCache: UserData.TopPageCache?) in
            let myUserData = GlobalDataStorage.instance.queryMyUserData()
            myUserData.topPageCache = topPageCache
            
            runTaskInMainThread {
                EventDispatcher.instance.dispatchEvent(eventType: "requestTopPageCacheComplete", eventParam: topPageCache)
            }
        }
        
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
            let recommendedMusicCoverImageUrl = "https://p.eagate.573.jp/game/jubeat/festo/images/top/jacket/\(topPageCache.dailyRecommendedMusicId / 10000000)/id\(topPageCache.dailyRecommendedMusicId).gif"
            downloadImageAsync(imageUrl: recommendedMusicCoverImageUrl, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
                if isDownloadSucceed {
                    runTaskInMainThread { [weak self] in
                        if isDownloadSucceed {
                            self?.m_dailyRecommendedMusicCoverImageView.image = image
                        }
                        coverImageDownloadCount += 1
                    }
                }
            })
            
            // Initialize full combo challenge music view
            let fullComboMusicCoverImageUrl = "https://p.eagate.573.jp/game/jubeat/festo/images/top/jacket/\(topPageCache.dailyFullComboChallengeMusicId / 10000000)/id\(topPageCache.dailyFullComboChallengeMusicId).gif"
            downloadImageAsync(imageUrl: fullComboMusicCoverImageUrl, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
                runTaskInMainThread { [weak self] in
                    if isDownloadSucceed {
                        self?.m_fullComboChallengeMusicCoverImageView.image = image
                    }
                    coverImageDownloadCount += 1
                }
            })
            
            SpinLock { return myUserData.musicScoreDataCaches.count > 0 }
            
            runTaskInMainThread { [weak self] in
                if let recommendedMusicData = myUserData.musicScoreDataCaches.first(where: { (item: MusicScoreData) -> Bool in return item.id == topPageCache.dailyRecommendedMusicId }) {
                    self?.m_dailyRecommendedMusicNameLabel.text = recommendedMusicData.name
                    self?.m_dailyRecommendedMusicArtistNameLabel.text = recommendedMusicData.artistName
                }
                
                if let fullComboChallenegMusicData = myUserData.musicScoreDataCaches.first(where: { (item: MusicScoreData) -> Bool in return item.id == topPageCache.dailyFullComboChallengeMusicId }) {
                    self?.m_fullComboChallengeMusicNameLabel.text = fullComboChallenegMusicData.name
                    self?.m_fullComboChallengeMusicArtistNameLabel.text = fullComboChallenegMusicData.artistName
                }
            }
            
            SpinLock { return coverImageDownloadCount >= 2 }
            
            self?.m_contentsView.animate(.fadeIn)
        }
    }
    
    open override func getEventNameRequiredToLazyPrepare() -> String {
        return "requestTopPageCacheComplete"
    }
    
}
