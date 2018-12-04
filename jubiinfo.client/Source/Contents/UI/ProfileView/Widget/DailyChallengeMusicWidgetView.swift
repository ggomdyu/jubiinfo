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
    override public var lazyInitializeParam: Any? { return DataStorage.instance.queryMyUserData().topPageCache }
    
/**@section Method */
    public override func initialize() {
        m_contentsView.alpha = 0.0
        
        super.initialize()
    }
    
    public override func lazyInitialize(_ param: Any?) {
        super.lazyInitialize(param)
        
        let myUserData = DataStorage.instance.queryMyUserData()
        guard let topPageCache = param as? UserData.TopPageCache else {
            return
        }
        
        myUserData.topPageCache = topPageCache
        
        // Initialize daily recommended music view
        if let dailyRecommendedChallengeMusicData = topPageCache.dailyRecommendedChallengeMusicData {
            downloadImageAsync(imageUrl: dailyRecommendedChallengeMusicData.coverImageUrl, isWriteCache: true, isReadCache: true, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
                runTaskInMainThread { [weak self] in
                    if isDownloadSucceed {
                        self?.m_dailyRecommendedMusicCoverImageView.image = image
                    }
                }
            })
            
            self.m_dailyRecommendedMusicId = dailyRecommendedChallengeMusicData.id
            self.m_dailyRecommendedMusicNameLabel.text = dailyRecommendedChallengeMusicData.name
            self.m_dailyRecommendedMusicArtistNameLabel.text = dailyRecommendedChallengeMusicData.artistName
        }
        
        // Initialize full combo challenge music view
        if let dailyFullComboChallengeMusicData = topPageCache.dailyFullComboChallengeMusicData {
            downloadImageAsync(imageUrl: dailyFullComboChallengeMusicData.coverImageUrl, isWriteCache: true, isReadCache: true, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
                runTaskInMainThread { [weak self] in
                    if isDownloadSucceed {
                        self?.m_dailyFullComboChallengeMusicCoverImageView.image = image
                    }
                }
            })
            
            self.m_dailyFullComboChallengeMusicId = dailyFullComboChallengeMusicData.id
            self.m_dailyFullComboChallengeMusicNameLabel.text = dailyFullComboChallengeMusicData.name
            self.m_dailyFullComboChallengeMusicArtistNameLabel.text = dailyFullComboChallengeMusicData.artistName
        }
        
        self.m_dailyRecommendedMusicView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTouchRecommendedMusicView)))
        self.m_dailyFullComboChallengeMusicView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTouchFullComboChallengeMusicView)))
            
        self.m_contentsView.animate(.fadeIn)
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
