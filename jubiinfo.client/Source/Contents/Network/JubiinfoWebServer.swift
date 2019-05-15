//
//  JubiinfoWebServer.swift
//  jubiinfo
//
//  Created by jhcha on 15/05/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import Alamofire

public struct CompetitionDesc {
    public var title: String
    public var subTitle: String
    public var endDate: Int
    public var musics: [(MusicId, MusicDifficulty)]
}

class JubiinfoWebServer {
    public static func requestFeaturedCompetition(onRequestComplete: @escaping (Bool, [CompetitionDesc]?) -> Void) {
        self.requestFeaturedCompetition { (isRequestSucceed: Bool, response: Data?) in
            var competitions: [CompetitionDesc] = []
            if isRequestSucceed {
                competitions = self.parseFeaturedCompetition(response: response!)
            }
            
            onRequestComplete(isRequestSucceed, competitions)
        }
    }
}

/**@brief   Set of server request method */
extension JubiinfoWebServer {
    private static func requestFeaturedCompetition(onRequestComplete: @escaping (Bool, Data?) -> Void) {
        httpRequestAsync(
            queue: DispatchQueue.global(),
            url: NetworkCoordinate.jubiinfoServerUrl + "http://127.0.0.1:8888/competition",
            method: HTTPMethod.get,
            host: NSURL(fileURLWithPath: NetworkCoordinate.jubiinfoServerUrl).host!,
            referer: NetworkCoordinate.jubiinfoServerUrl,
            onRequestComplete: { (isRequestSucceed: Bool, response: Data?) in
                onRequestComplete(isRequestSucceed, response)
        })
    }
}

/**@brief   Set of packet parsing method */
extension JubiinfoWebServer {
    private static func parseFeaturedCompetition(response: Data) -> [CompetitionDesc] {
        var optJsonDict: [String: Any]?
        do {
            optJsonDict = try JSONSerialization.jsonObject(with: response, options: []) as? [String: Any]
        }
        catch {}
        
        var ret: [CompetitionDesc] = []
        guard let jsonDict = optJsonDict else {
            return ret
        }
        
        for competition in jsonDict["list"] as! [[String: Any]] {
            let title = competition["title"] as! String
            let subTitle = competition["subTitle"] as! String
            let endDate = competition["endDate"] as! Int
            let musicCount = competition["musicCount"] as! Int
            
            var musics: [(MusicId, MusicDifficulty)] = []
            for i in 1...musicCount {
                let musicId = competition["music\(i)Id"] as! Int
                let musicDifficulty = MusicDifficulty(rawValue: competition["music\(i)Difficulty"] as! Int)!
                
                musics.append((musicId, musicDifficulty))
            }
            
            ret.append(CompetitionDesc(title: title, subTitle: subTitle, endDate: endDate, musics: musics))
        }
        
        return ret
    }
}
