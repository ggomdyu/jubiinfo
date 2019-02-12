//
//  ProfileViewController.swift
//  jubiinfo
//
//  Created by ggomdyu on 12/01/2019.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Foundation
import Material
import Motion

class ProfileView : CustomStackView {
/**@section Method */
    override public func prepare() {
        super.prepare()
        
        self.prepareRequestDataPacket()
        self.prepareUI()
    }
    
    private func prepareUI() {
        self.addMargin(margin: 15.0)
        self.prepareProfileCell()
        self.addMargin(margin: 10.0)
        self.prepareDailyCallengeCell()
        self.addMargin(margin: 10.0)
        self.preparePlayDataACell()
        self.addMargin(margin: 10.0)
        self.prepareRankDataGraphCell()
        self.addMargin(margin: 10.0)
        self.prepareOmikujiCell()
        self.addMargin(margin: 15.0)
    }
    
    private func prepareRequestDataPacket() {
        self.requestMyPlayDataPageCache()
        self.requestMyRankDataPageCache()
    }
    
    private func requestMyPlayDataPageCache() {
        JubeatWebServer.requestMyPlayDataPageCache { (isRequestSucceed: Bool, optMyPlayDataPageCache: UserData.MyPlayDataPageCache?) in
            let myUserData = GlobalDataStorage.instance.queryMyUserData()
            myUserData.rivalId = (optMyPlayDataPageCache != nil) ? optMyPlayDataPageCache!.rivalId : ""
            myUserData.playDataPageCache = optMyPlayDataPageCache
            
            runTaskInMainThread {
                EventDispatcher.instance.dispatchEvent(eventType: "requestMyPlayDataPageCacheComplete", eventParam: optMyPlayDataPageCache)
            }
            
            self.requestMyMusicScoreData(serverMMSDChecksum: optMyPlayDataPageCache?.playTuneCount ?? 0)
        }
    }

    private func requestMyRankDataPageCache() {
        JubeatWebServer.requestMyRankDataPageCache { (isRequestSucceed: Bool, optMyRankDataPageCache: UserData.RankDataPageCache?) in
            guard let myRankDataPageCache = optMyRankDataPageCache else {
                return
            }
            
            GlobalDataStorage.instance.queryMyUserData().rankDataPageCache = myRankDataPageCache
                
            runTaskInMainThread {
                EventDispatcher.instance.dispatchEvent(eventType: "requestMyRankDataPageCacheComplete", eventParam: optMyRankDataPageCache)
            }
        }
    }
    
    private func requestMyMusicScoreData(serverMMSDChecksum: Int) {
        JubeatWebServer.requestMyMusicScoreData(serverMMSDChecksum: serverMMSDChecksum) { (isRequestSucceed: Bool, musicScoreDatas: [MusicScoreData]?) in
            if isRequestSucceed {
                GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches = musicScoreDatas!
                
                runTaskInMainThread {
                    EventDispatcher.instance.dispatchEvent(eventType: "requestMyMusicScoreDataComplete", eventParam: musicScoreDatas)
                }
            }
        }
    }
    
    private func prepareProfileCell() {
        let view = UINib(nibName: "ProfileCellView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ProfileCellView
        view.initialize()
        
        self.addView(view: view)
    }
    
    private func preparePlayDataACell() {
        let view = UINib(nibName: "PlayDataACellView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PlayDataACellView
        view.initialize()
        
        self.addView(view: view)
    }
    
    private func prepareRankDataGraphCell() {
        let view = UINib(nibName: "RankDataGraphCellView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! RankDataGraphCellView
        view.initialize()
        
        self.addView(view: view)
    }
    
    private func prepareOmikujiCell() {
        let view = UINib(nibName: "OmikujiCellView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! OmikujiCellView
        view.initialize()
        
        self.addView(view: view)
    }
    
    private func prepareDailyCallengeCell() {
        let view = UINib(nibName: "DailyChallengeMusicCellView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DailyChallengeMusicCellView
        view.initialize()
        
        self.addView(view: view)
    }
}

