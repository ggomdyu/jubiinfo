//
//  GlobalUserData.swift
//  jubiinfo
//
//  Created by 차준호 on 05/12/2018.
//  Copyright © 2018 차준호. All rights reserved.
//

import Foundation
import UIKit

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
    
    public class MyPlayDataPageCache : PlayDataPageCache {
        public init(_ nickname: String, _ designation: String, _ rivalId: String, _ emblemImageURL: String, _ jubility: Float, _ lastPlayedTime: String, _ lastPlayedLocation: String, _ ranking: Int, _  totalScore: Int64, _ playTuneCount: Int, _ fullComboCount: Int, _ excellentCount: Int)
        {
            self.jubility = jubility
            
            super.init(nickname, designation, rivalId, emblemImageURL, lastPlayedTime, lastPlayedLocation, ranking, totalScore, playTuneCount, fullComboCount, excellentCount)
        }
        
        public private(set) var jubility: Float
    }

/**@section Constructor */
    public init(_ rivalId: String) {
        self.rivalId = rivalId
    }
    
    public init(_ rivalId: String, _ playDataPageCache: PlayDataPageCache) {
        self.rivalId = rivalId
        self.playDataPageCache = playDataPageCache
    }
    
/**@section Method */

/**@section Variable */
    public let rivalId: String
    public var playDataPageCache: PlayDataPageCache?
}

