//
//  RivalRankView.swift
//  jubiinfo
//
//  Created by ggomdyu on 05/02/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

public class RivalRankView : UIView {
/**@section Variable */
    @IBOutlet weak var m_contentsView: UIView!
    private var m_musicScoreData: MusicScoreData!
    
/**@section Method */
    public func initialize(musicScoreData: MusicScoreData) {
        m_musicScoreData = musicScoreData
        
        self.prepareRivalRankCellView(musicScoreData: musicScoreData)
    }
    
    private func getRivalMusicScoreDataCache(musicScoreData: MusicScoreData, rivalUserData: UserData) -> MusicScoreData? {
        return rivalUserData.musicScoreDataCaches.value.first(where: { (item: MusicScoreData) -> Bool in
            return musicScoreData.id == item.id && musicScoreData.difficulty == item.difficulty
        })
    }
    
    private func prepareRivalRankCellView(musicScoreData: MusicScoreData) {
        var requestCompleteCount = 0
        DispatchQueue.global().async {
            let myUserData = DataStorage.instance.queryMyUserData()
            SpinLock { return myUserData.rivalListPageCache != nil && myUserData.playDataPageCache != nil }
            
            var rivalRankCellDatas = [(score: Int, isProfilePrivated: Bool, nickname: String)] ()
            rivalRankCellDatas.append((musicScoreData.score, false, myUserData.playDataPageCache!.nickname))
            
            for simpleRivalData in myUserData.rivalListPageCache!.simpleRivalDataList {
                let rivalUserData = DataStorage.instance.queryOtherUserData(rivalId:
                    simpleRivalData.rivalId)
                
                let optRivalMusicScoreDataCache = self.getRivalMusicScoreDataCache(musicScoreData: musicScoreData, rivalUserData: rivalUserData)
                // Is the rival's score data cached or rival is private profile user?
                if optRivalMusicScoreDataCache != nil || rivalUserData.isProfilePrivated {
                    runTaskInMainThread {
                        rivalRankCellDatas.append((rivalUserData.isProfilePrivated ? -2 : optRivalMusicScoreDataCache!.score, rivalUserData.isProfilePrivated, simpleRivalData.nickname))
                        requestCompleteCount += 1
                        if requestCompleteCount == myUserData.rivalListPageCache!.simpleRivalDataList.count {
                            self.onRequestAllRivalMusicDataComplete(rivalRankCellDatas: &rivalRankCellDatas)
                        }
                    }
                }
                // Request rival's score data from the server, and cache it into the storage.
                else {
                    let musicScoreDatas = [MusicScoreData(), MusicScoreData(), MusicScoreData()]
                    
                    JubeatWebServer.requestDetailMusicScoreData(rivalId: simpleRivalData.rivalId, musicId: musicScoreData.id, destBasicMusicScoreData: musicScoreDatas[0], destAdvancedMusicScoreData: musicScoreDatas[1], extremeMusicScoreData: musicScoreDatas[2]) { (isRequestSucceed: Bool, isProfilePrivated: Bool) in
                        
                        runTaskInMainThread {
                            // Cache the user's music score data into the storage
                            if isProfilePrivated {
                                rivalRankCellDatas.append((-2, isProfilePrivated, simpleRivalData.nickname))
                                rivalUserData.isProfilePrivated = true
                            }
                            else {
                                rivalRankCellDatas.append((musicScoreDatas[musicScoreData.difficulty.rawValue].score, isProfilePrivated, simpleRivalData.nickname))
                                rivalUserData.musicScoreDataCaches.value.append(contentsOf: musicScoreDatas)
                            }
                            print("rivalId: \(simpleRivalData.nickname): \(musicScoreDatas[musicScoreData.difficulty.rawValue].score)" )
                            
                            requestCompleteCount += 1
                            if requestCompleteCount == myUserData.rivalListPageCache!.simpleRivalDataList.count {
                                self.onRequestAllRivalMusicDataComplete(rivalRankCellDatas: &rivalRankCellDatas)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func onRequestAllRivalMusicDataComplete(rivalRankCellDatas: inout [(score: Int, isProfilePrivated: Bool, nickname: String)]) {
        // Rival sort priority
        // 1. High score user
        // 2. Low score user
        // 3. Not played user
        // 4. Private profile user
        rivalRankCellDatas.sort(by: { (lhs: (Int, Bool, String), rhs: (Int, Bool, String)) -> Bool in
            return lhs.0 > rhs.0
        })
        
        for _ in 0..<(4 - rivalRankCellDatas.count) {
            rivalRankCellDatas.append((-1, true, "•••"))
        }
        
        self.lazyInitialize(rivalRankCellDatas: rivalRankCellDatas)
    }
    
    private func createRivalRankCellView(nickname: String, isProfilePrivated: Bool, ranking: Int = 0, score: Int = 0) -> RivalRankCellView {
        let rivalRankCellView = UINib(nibName: "RivalRankCellView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! RivalRankCellView
        rivalRankCellView.initialize(nickname: nickname, isProfilePrivated: isProfilePrivated, ranking: ranking, score: score)
        
        return rivalRankCellView
    }
    
    private func lazyInitialize(rivalRankCellDatas: [(Int, Bool, String)]) {
        var currRanking = 0
        var nextRanking = 0
        var optOldRivalRankCellData: (Int, Bool, String)?
        for i in 0..<rivalRankCellDatas.count {
            let rivalRankCellData = rivalRankCellDatas[i]
            
            if let oldRivalRankCellData = optOldRivalRankCellData {
                // If the current score is same with previous user's score, then use same color of the crown.
                if oldRivalRankCellData.0 != rivalRankCellData.0 {
                    currRanking += 1 + nextRanking
                    nextRanking = 0
                }
                else {
                    nextRanking += 1
                }
            }
            else {
                currRanking += 1
            }
            
            let rivalRankCellView = self.createRivalRankCellView(nickname: rivalRankCellData.2, isProfilePrivated: rivalRankCellData.1, ranking: currRanking, score: rivalRankCellData.0)
            let rivalRankCellStartYPos = (self.frame.height - (rivalRankCellView.frame.height * CGFloat(rivalRankCellDatas.count))) * 0.5
            m_contentsView.layout(rivalRankCellView).top(rivalRankCellStartYPos + (rivalRankCellView.frame.height * CGFloat(i))).left(0.0).right(0.0).height(rivalRankCellView.frame.height)
            
            optOldRivalRankCellData = rivalRankCellData
        }
        
        m_contentsView.animate(.fadeIn)
    }
}
