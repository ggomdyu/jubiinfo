//
//  GlobalUserData.swift
//  jubiinfo
//
//  Created by 차준호 on 05/12/2018.
//  Copyright © 2018 차준호. All rights reserved.
//

import Foundation
import UIKit

public struct SimpleMusicData {
    var musicName: String
    var basicBestScore: Int
    var advancedBestScore: Int
    var extremeBestScore: Int
}

public struct DetailMusicData {
    var basicLevel: Int
    var basicPlayCount: Int
    var basicClearCount: Int
    var basicFullComboCount: Int
    var basicExcellentCount: Int
    var basicBestScore: Int
    var basicRanking: Int
    
    var advancedLevel: Int
    var advancedPlayCount: Int
    var advancedClearCount: Int
    var advancedFullComboCount: Int
    var advancedExcellentCount: Int
    var advancedBestScore: Int
    var advancedRanking: Int
    
    var extremeLevel: Int
    var extremePlayCount: Int
    var extremeClearCount: Int
    var extremeFullComboCount: Int
    var extremeExcellentCount: Int
    var extremeBestScore: Int
    var extremeRanking: Int
}

public class GlobalUserDataStorage {
/**@section Property */
    public static let instance = GlobalUserDataStorage()
//    public private(set) var instance = GlobalUserDataStorage()
    
/**@section Constructor */
    private init() {
    }
    
/**@section Method */
    public func initialize(myRivalId: String, myUserData: UserData) {
        self.myRivalId = myRivalId
        self.addUserData(rivalId: myRivalId, userData: myUserData)
    }
    
    public func addUserData(rivalId: String, userData: UserData) {
        userDataTable.updateValue(userData, forKey: rivalId)
    }
    
    public func queryUserData(rivalId: String) -> UserData {
        let optIter = userDataTable.index(forKey: rivalId)
        guard let iter = optIter else {
            return userDataTable.updateValue(UserData(rivalId), forKey: rivalId)!
        }
        
        return userDataTable[iter].value
    }
    
    public func queryMyUserData() -> UserData {
        return self.queryUserData(rivalId: myRivalId)
    }
    
/**@section Variable */
    private var myRivalId = String()
    private var userDataTable = [String: UserData]()
}

public class UserData {
/**@section Struct */
    /**@brief The parsed data from https://p.eagate.573.jp/game/jubeat/festo/playdata/index_other.html?rival_id= */
    public class PlayDataPageCache {
        public init(_ nickname: String, _ designation: String, _ rivalId: String, _ emblemImageURL: String, _ lastPlayedTime: String, _ lastPlayedLocation: String, _ ranking: Int, _  totalScore: Int64, _ playTuneCount: Int, _ fullComboCount: Int, _ excellentCount: Int)
        {
            self.emblemImage = nil
            self.nickname = nickname
            self.designation = designation
            self.rivalId = rivalId
            self.emblemImageURL = emblemImageURL
            self.lastPlayedTime = lastPlayedTime
            self.lastPlayedLocation = lastPlayedLocation
            self.ranking = ranking
            self.totalScore = totalScore
            self.playTuneCount = playTuneCount
            self.fullComboCount = fullComboCount
            self.excellentCount = excellentCount
            
            downloadImageSync(imageUrl: emblemImageURL, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
                if (isDownloadSucceed) {
                    self.emblemImage = image
                }
            })
        }
        
        public private(set) var nickname: String
        public private(set) var designation: String
        public private(set) var rivalId: String
        public private(set) var emblemImageURL: String
        public private(set) var emblemImage: UIImage?
        public private(set) var lastPlayedTime: String
        public private(set) var lastPlayedLocation: String
        public private(set) var ranking: Int
        public private(set) var totalScore: Int64
        public private(set) var playTuneCount: Int
        public private(set) var fullComboCount: Int
        public private(set) var excellentCount: Int
    }
    
    /**@brief The parsed data from https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html */
    public class RankDataPageCache {
        public init(_ notPlayedMusicCount: Int, _ eRankCount: Int, _ dRankCount: Int, _ cRankCount: Int, _ bRankCount: Int, _ aRankCount: Int, _ sRankCount: Int, _ ssRankCount: Int, _ sssRankCount: Int, _ excRankCount: Int)
        {
            self.notPlayedMusicCount = notPlayedMusicCount
            self.totalPlayCount = excRankCount + sssRankCount + ssRankCount + sRankCount + aRankCount + bRankCount + cRankCount + dRankCount + eRankCount + notPlayedMusicCount
            self.eRankCount = eRankCount
            self.dRankCount = dRankCount
            self.cRankCount = cRankCount
            self.bRankCount = bRankCount
            self.aRankCount = aRankCount
            self.sRankCount = sRankCount
            self.ssRankCount = ssRankCount
            self.sssRankCount = sssRankCount
            self.excRankCount = excRankCount
        }
        
        public private(set) var notPlayedMusicCount: Int
        public private(set) var totalPlayCount: Int
        public private(set) var eRankCount: Int
        public private(set) var dRankCount: Int
        public private(set) var cRankCount: Int
        public private(set) var bRankCount: Int
        public private(set) var aRankCount: Int
        public private(set) var sRankCount: Int
        public private(set) var ssRankCount: Int
        public private(set) var sssRankCount: Int
        public private(set) var excRankCount: Int
    }
    
    /**@brief The parsed data from https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html */
    public class MusicDataPageCache {
        public init(_ pageIndex: Int, _ simpleMusicDatas: [SimpleMusicData])
        {
            self.pageIndex = pageIndex
            self.simpleMusicDatas = simpleMusicDatas
        }
        
        public private(set) var pageIndex: Int
        public private(set) var simpleMusicDatas: [SimpleMusicData]
    }
    
    /**@brief The parsed data from https://p.eagate.573.jp/game/jubeat/festo/playdata/index.html?rival_id= */
    public class MyPlayDataPageCache : PlayDataPageCache {
        public init(_ nickname: String, _ designation: String, _ rivalId: String, _ emblemImageURL: String, _ jubility: Float, _ lastPlayedTime: String, _ lastPlayedLocation: String, _ ranking: Int, _  totalScore: Int64, _ playTuneCount: Int, _ fullComboCount: Int, _ excellentCount: Int)
        {
            self.jubility = jubility
            
            super.init(nickname, designation, rivalId, emblemImageURL, lastPlayedTime, lastPlayedLocation, ranking, totalScore, playTuneCount, fullComboCount, excellentCount)
        }
        
        public private(set) var jubility: Float
    }

/**@section Constructor */
    public init(_ rivalId: String, _ playDataPageCache: PlayDataPageCache? = nil, _ musicDataPageCache: MusicDataPageCache? = nil, _ rankDataPageCache: RankDataPageCache? = nil) {
        self.rivalId = rivalId
        self.playDataPageCache = playDataPageCache
        self.musicDataPageCache = musicDataPageCache
        self.rankDataPageCache = rankDataPageCache
    }
    
/**@section Method */

/**@section Variable */
    public let rivalId: String
    public var playDataPageCache: PlayDataPageCache?
    public var musicDataPageCache: MusicDataPageCache?
    public var rankDataPageCache: RankDataPageCache?
}
