//
//  DataStorage.swift
//  jubiinfo
//
//  Created by ggomdyu on 05/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

public typealias MusicNewRecordHistories = Box<[(Timestamp, [MusicId: [(MusicDifficulty, Int)]])]>
public typealias GameCenterVisitHistories = Box<[(String, String, String, Int)]>

public class DataStorage {
/**@section Variable */
    public static let instance = DataStorage()
    
/**@section Constructor */
    private init() {
    }
    
/**@section Method */
    public func initCustomMusicDatas(customMusicDatas: [MusicId: MusicScoreData.CustomData]) {
        m_customMusicDatas = customMusicDatas
    }
    
    public func isCustomMusicDatasInitialized() -> Bool {
        return m_customMusicDatas.count > 0
    }
    
    public func initNewRecordHistories(newRecordHistories: MusicNewRecordHistories) {
        m_newRecordHistories = newRecordHistories
    }
    
    public func initGameCenterVisitHistories(gameCenterVisitHistories: GameCenterVisitHistories) {
        m_gameCenterVisitHistories = gameCenterVisitHistories
    }
    
    public func queryCustomMusicData(musicId: MusicId) -> MusicScoreData.CustomData {
        let optMusicCustomData = m_customMusicDatas[musicId]
        guard let musicCustomData = optMusicCustomData else {
            let ret = MusicScoreData.CustomData()
            m_customMusicDatas[musicId] = ret
            return ret
        }
        
        return musicCustomData
    }
    
    public func queryNewRecordHistories() -> MusicNewRecordHistories {
        return m_newRecordHistories!
    }
    
    public func queryGameCenterVisitHistories() -> GameCenterVisitHistories {
        return m_gameCenterVisitHistories
    }
    
    public func queryCustomMusicDatas() -> [MusicId: MusicScoreData.CustomData] {
        return m_customMusicDatas
    }
    
    public func queryMusicLevel(musicScoreData: MusicScoreData) -> Int {
        let musicCustomData = self.queryCustomMusicData(musicId: musicScoreData.id)
        
        return musicCustomData.levels[musicScoreData.difficulty.rawValue]
    }
    
    public func queryMyUserData() -> MyUserData {
        return m_myUserData
    }
    
    public func queryOtherUserData(rivalId: String) -> UserData {
        let optIter = m_otherUserDatas.index(forKey: rivalId)
        guard let iter = optIter else {
            let ret = UserData(rivalId: rivalId)
            m_otherUserDatas[rivalId] = ret
            return ret
        }
        
        return m_otherUserDatas[iter].value
    }
    
/**@section Variable */
    private var m_myUserData = MyUserData()
    private var m_otherUserDatas = [String: UserData] ()
    private var m_customMusicDatas = [MusicId: MusicScoreData.CustomData] ()
    private var m_newRecordHistories: MusicNewRecordHistories!
    private var m_gameCenterVisitHistories: GameCenterVisitHistories!
}

public class UserData {
/**@section Class */
    public class TopPageCache {
        public struct DailyChallengeMusicData {
        /**@section Variable */
            public var coverImageUrl: String { return "https://p.eagate.573.jp/game/jubeat/festo/images/top/jacket/\(id / 10000000)/id\(id).gif" }
            public let id: MusicId
            public let name: String
            public let artistName: String
            
        /**@section Constructor */
//            public init() {
//                self.id = 0
//                self.name = ""
//                self.artistName = ""
//            }
        }
        
    /**@section Variable */
        public let dailyRecommendedChallengeMusicData: DailyChallengeMusicData?
        public let dailyFullComboChallengeMusicData: DailyChallengeMusicData?
        
    /**@section Constructor */
        public init(dailyRecommendedChallengeMusicData: DailyChallengeMusicData?, dailyFullComboChallengeMusicData: DailyChallengeMusicData?) {
            self.dailyRecommendedChallengeMusicData = dailyRecommendedChallengeMusicData
            self.dailyFullComboChallengeMusicData = dailyFullComboChallengeMusicData
        }
    }
    
    /**@brief The parsed data from https://p.eagate.573.jp/game/jubeat/festo/playdata/index_other.html?rival_id= */
    public class PlayDataPageCache : Codable {
    /**@section Variable */
        public var nickname: String
        public let designation: String
        public let rivalId: String
        public let emblemImageUrl: String
        public let lastPlayDate: String
        public var lastPlayedLocation: String
        public let lastPlayedCountry: String
        public let ranking: Int
        public let totalScore: Int64
        public var playTuneCount: Int
        public let fullComboCount: Int
        public let excellentCount: Int
        
    /**@section Constructor */
        public init(_ nickname: String, _ designation: String, _ rivalId: String, _ emblemImageUrl: String, _ lastPlayedTime: String, _ lastPlayedLocation: String, _ lastPlayedCountry: String, _ ranking: Int, _  totalScore: Int64, _ playTuneCount: Int, _ fullComboCount: Int, _ excellentCount: Int)
        {
            self.nickname = nickname
            self.designation = designation
            self.rivalId = rivalId
            self.emblemImageUrl = emblemImageUrl
            self.lastPlayDate = lastPlayedTime
            self.lastPlayedLocation = lastPlayedLocation
            self.lastPlayedCountry = lastPlayedCountry
            self.ranking = ranking
            self.totalScore = totalScore
            self.playTuneCount = playTuneCount
            self.fullComboCount = fullComboCount
            self.excellentCount = excellentCount
        }
    }
    
    /**@brief The parsed data from https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html */
    public struct RankDataPageCache {
    /**@section Variable */
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
        
    /**@section Constructor */
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
    }
    
    public class RivalListPageCache : Codable {
    /**@section Class */
        public struct SimpleRivalData : Codable {
            public let rivalId: String
            public let nickname: String
            public let designation: String
        }
    
    /**@section Constructor */
        public init(simpleRivalDataList: [SimpleRivalData] = [SimpleRivalData] ()) {
            self.simpleRivalDataList = simpleRivalDataList
        }
        
    /**@section Variable */
        public let simpleRivalDataList: [SimpleRivalData]
    }
    
    /**@brief The parsed data from https://p.eagate.573.jp/game/jubeat/festo/playdata/index.html?rival_id= */
    public class MyPlayDataPageCache : PlayDataPageCache {
        public enum MyPlayDataPageCacheCodingKey : String, CodingKey {
            case jubility
        }
        
    /**@section Variable */
        public let jubility: Float
        
    /**@section Constructor */
        public init(_ nickname: String, _ designation: String, _ rivalId: String, _ emblemImageUrl: String, _ jubility: Float, _ lastPlayedTime: String, _ lastPlayedLocation: String, _ lastPlayedCountry: String, _ ranking: Int, _  totalScore: Int64, _ playTuneCount: Int, _ fullComboCount: Int, _ excellentCount: Int)
        {
            self.jubility = jubility
            
            super.init(nickname, designation, rivalId, emblemImageUrl, lastPlayedTime, lastPlayedLocation, lastPlayedCountry, ranking, totalScore, playTuneCount, fullComboCount, excellentCount)
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: MyPlayDataPageCacheCodingKey.self)

            self.jubility = try container.decode(Float.self, forKey: .jubility)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: MyPlayDataPageCacheCodingKey.self)
            try container.encode(jubility, forKey: .jubility)
            
            try super.encode(to: encoder)
        }
    }

/**@section Constructor */
    public init(rivalId: String = "", isProfilePrivated: Bool = false, playDataPageCache: PlayDataPageCache? = nil, rankDataPageCache: RankDataPageCache? = nil, rivalListPageCache: RivalListPageCache? = nil) {
        self.rivalId = rivalId
        self.isProfilePrivated = isProfilePrivated
        self.playDataPageCache = playDataPageCache
        self.rankDataPageCache = rankDataPageCache
        self.rivalListPageCache = rivalListPageCache
    }
    
/**@section Variable */
    public var rivalId: String
    public var isProfilePrivated: Bool = false
    public var musicScoreDataCaches = MusicScoreDataCaches ([])
    public var playDataPageCache: PlayDataPageCache?
    public var rankDataPageCache: RankDataPageCache?
    public var rivalListPageCache: RivalListPageCache?
    public var topPageCache: TopPageCache?
}

public class MyUserData : UserData {
/**@section Constructor */
    public init(rivalId: String = "", playDataPageCache: PlayDataPageCache? = nil, rankDataPageCache: RankDataPageCache? = nil) {
        super.init(rivalId: rivalId, playDataPageCache: playDataPageCache, rankDataPageCache: rankDataPageCache)
        
        self.musicScoreDataCaches.value.reserveCapacity(2048)
    }
}

