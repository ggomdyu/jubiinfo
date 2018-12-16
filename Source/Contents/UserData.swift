//
//  GlobalUserData.swift
//  jubiinfo
//
//  Created by 차준호 on 05/12/2018.
//  Copyright © 2018 차준호. All rights reserved.
//

import Foundation
import UIKit

public enum MusicDifficulty {
    case Extreme
    case Advanced
    case Basic
}

public struct MusicData {
    var musicName: String
    var musicId: Int
    var musicScore: Int
    var musicDifficulty: MusicDifficulty
}

public struct SimpleMusicData {
    var musicName: String
    var musicId: Int
    var basicScore: Int
    var advancedScore: Int
    var extremeScore: Int
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
/**@section Variable */
    public static let instance = GlobalUserDataStorage()
    
/**@section Constructor */
    private init() {
    }
    
/**@section Method */
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
        return myUserData
    }
    
/**@section Variable */
    private var myUserData = UserData()
    private var userDataTable = [String: UserData]()
}

public class UserData {
/**@section Struct */
    /**@brief The parsed data from https://p.eagate.573.jp/game/jubeat/festo/playdata/index_other.html?rival_id= */
    public class PlayDataPageCache {
        public init(_ nickname: String, _ designation: String, _ rivalId: String, _ emblemImageUrl: String, _ lastPlayedTime: String, _ lastPlayedLocation: String, _ ranking: Int, _  totalScore: Int64, _ playTuneCount: Int, _ fullComboCount: Int, _ excellentCount: Int)
        {
            self.nickname = nickname
            self.designation = designation
            self.rivalId = rivalId
            self.emblemImageUrl = emblemImageUrl
            self.emblemImage = nil
            self.lastPlayedTime = lastPlayedTime
            self.lastPlayedLocation = lastPlayedLocation
            self.ranking = ranking
            self.totalScore = totalScore
            self.playTuneCount = playTuneCount
            self.fullComboCount = fullComboCount
            self.excellentCount = excellentCount
        }
        
        public let nickname: String
        public let designation: String
        public let rivalId: String
        public let emblemImageUrl: String
        public var emblemImage: UIImage?
        public let lastPlayedTime: String
        public let lastPlayedLocation: String
        public let ranking: Int
        public let totalScore: Int64
        public let playTuneCount: Int
        public let fullComboCount: Int
        public let excellentCount: Int
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
        
        public let notPlayedMusicCount: Int
        public let totalPlayCount: Int
        public let eRankCount: Int
        public let dRankCount: Int
        public let cRankCount: Int
        public let bRankCount: Int
        public let aRankCount: Int
        public let sRankCount: Int
        public let ssRankCount: Int
        public let sssRankCount: Int
        public let excRankCount: Int
    }
    
    /**@brief The parsed data from https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html */
//    public class MusicDataPageCache {
//        public init(_ pageIndex: Int, _ simpleMusicDatas: [SimpleMusicData])
//        {
//            self.pageIndex = pageIndex
//            self.simpleMusicDatas = simpleMusicDatas
//        }
//
//        public private(set) var pageIndex: Int
//        public private(set) var simpleMusicDatas: [SimpleMusicData]
//    }
    
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
    public init(_ rivalId: String = "", _ isProfilePrivated: Bool = false, _ playDataPageCache: PlayDataPageCache? = nil, _ rankDataPageCache: RankDataPageCache? = nil) {
        self.rivalId = rivalId
        self.isProfilePrivated = isProfilePrivated
        self.playDataPageCache = playDataPageCache
        self.rankDataPageCache = rankDataPageCache
    }
    
/**@section Method */
    
/**@section Variable */
    public var rivalId: String
    public var isProfilePrivated: Bool
    public var playDataPageCache: PlayDataPageCache?
    public var rankDataPageCache: RankDataPageCache?
    public var musicDataCaches = [SimpleMusicData] ()
}
