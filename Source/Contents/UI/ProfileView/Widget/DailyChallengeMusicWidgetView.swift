//
//  DailyChallengeMusicWidgetView.swift
//  jubiinfo
//
//  Created by ggomdyu on 11/02/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

class DailyChallengeMusicWidgetView : WidgetView {
/**@section Variable */
    @IBOutlet weak var m_dailyRecommendedMusicView: UIView!
    @IBOutlet weak var m_dailyRecommendedMusicCoverImageView: UIImageView!
    @IBOutlet weak var m_dailyRecommendedMusicNameLabel: UILabel!
    @IBOutlet weak var m_dailyRecommendedMusicArtistNameLabel: UILabel!
    private var m_dailyRecommendedMusicId: MusicId = 0
    @IBOutlet weak var m_dailyFullComboChallengeMusicView: UIView!
    @IBOutlet weak var m_dailyFullComboChallengeMusicCoverImageView: UIImageView!
    @IBOutlet weak var m_dailyFullComboChallengeMusicNameLabel: UILabel!
    @IBOutlet weak var m_dailyFullComboChallengeMusicArtistNameLabel: UILabel!
    private var m_dailyFullComboChallengeMusicId: MusicId = 0
    @IBOutlet weak var m_contentsView: UIView!

/**@section Property */
    public override var lazyInitializeEventName: String {
        return "requestTopPageCacheComplete"
    }
    
/**@section Method */
    public override func initialize() {
        super.initialize()
        
        m_contentsView.alpha = 0.0
    }
    
    public override func lazyInitialize(_ param: Any?) {
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
                downloadImageAsync(imageUrl: dailyRecommendedChallengeMusicData.coverImageUrl, isWriteCache: true, isReadCache: true, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
                    runTaskInMainThread { [weak self] in
                        coverImageDownloadCount += 1
                        
                        guard let strongSelf = self else {
                            return
                        }
                        
                        if isDownloadSucceed {
                            strongSelf.m_dailyRecommendedMusicCoverImageView.image = image
                        }
                        strongSelf.m_dailyRecommendedMusicId = dailyRecommendedChallengeMusicData.id
                        strongSelf.m_dailyRecommendedMusicNameLabel.text = dailyRecommendedChallengeMusicData.name
                        strongSelf.m_dailyRecommendedMusicArtistNameLabel.text = dailyRecommendedChallengeMusicData.artistName
                    }
                })
            }
            
            // Initialize full combo challenge music view
            if let dailyFullComboChallengeMusicData = topPageCache.dailyFullComboChallengeMusicData {
                downloadImageAsync(imageUrl: dailyFullComboChallengeMusicData.coverImageUrl, isWriteCache: true, isReadCache: true, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
                    runTaskInMainThread { [weak self] in
                        guard let strongSelf = self else {
                            return
                        }
                        
                        coverImageDownloadCount += 1
                        if coverImageDownloadCount >= 2 {
                            strongSelf.m_dailyRecommendedMusicView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(strongSelf.onTouchRecommendedMusicView)))
                            strongSelf.m_dailyFullComboChallengeMusicView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(strongSelf.onTouchFullComboChallengeMusicView)))
                            
                            strongSelf.m_contentsView.animate(.fadeIn)
                        }
                        
                        if isDownloadSucceed {
                            strongSelf.m_dailyFullComboChallengeMusicCoverImageView.image = image
                        }
                        strongSelf.m_dailyFullComboChallengeMusicId = dailyFullComboChallengeMusicData.id
                        strongSelf.m_dailyFullComboChallengeMusicNameLabel.text = dailyFullComboChallengeMusicData.name
                        strongSelf.m_dailyFullComboChallengeMusicArtistNameLabel.text = dailyFullComboChallengeMusicData.artistName
                    }
                })
            }
        }
    }
    
/**@section Event handler */
    @objc private func onTouchRecommendedMusicView() {
        guard let viewController = self.parentViewController else {
            return
        }
        
        MusicDataViewController.show(currentViewController: viewController, musicId: m_dailyRecommendedMusicId)
    }
    
    @objc private func onTouchFullComboChallengeMusicView() {
        guard let viewController = self.parentViewController else {
            return
        }
        
        MusicDataViewController.show(currentViewController: viewController, musicId: m_dailyFullComboChallengeMusicId)
    }
}
