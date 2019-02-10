//
//  EAmusement.swift
//  jubiinfo
//
//  Created by ggomdyu on 27/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftSoup
import CoreGraphics

public typealias Timestamp = Int64
public typealias MusicId = Int
public typealias MusicScore = Int

public class MusicScoreData : Comparable {
/**@section Enum */
    public enum Difficulty : Int {
        case Basic
        case Advanced
        case Extreme
    }
    
    public enum ScoreRank : Int {
        case EXC
        case SSS
        case SS
        case S
        case A
        case B
        case C
        case D
        case E
        case NotPlayedYet
        
        public func toString() -> String {
            switch self {
            case .EXC:
                return "EXC"
            case .SSS:
                return "SSS"
            case .SS:
                return "SS"
            case .S:
                return "S"
            case .A:
                return "A"
            case .B:
                return "B"
            case .C:
                return "C"
            case .D:
                return "D"
            case .E:
                return "E"
            default:
                return "Not played yet"
            }
        }
    }
    
/**@section Class */
    /**@brief   The below datas are parseable from here https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html?rival_id=(RIVAL_ID) */
    public struct SimpleData {
        public init(name: String, uppercasedRomajiName: String, id: Int, score: Int, difficulty: Difficulty, isFullCombo: Bool, scoreHistory: [(Timestamp, MusicScore)]? = nil) {
            self.name = name
            self.uppercasedRomajiName = uppercasedRomajiName
            self.id = id
            self.score = score
            self.difficulty = difficulty
            self.isFullCombo = isFullCombo
            self.scoreHistories = scoreHistory
        }
        
        public let name: String
        public let uppercasedRomajiName: String
        public let id: Int
        public let score: Int
        public let difficulty: Difficulty
        public let isFullCombo: Bool
        public var scoreHistories: [(Timestamp, MusicScore)]?
    }
    
    /**@brief   The below datas are parseable from here https://p.eagate.573.jp/game/jubeat/festo/playdata/music_detail.html?rival_id=(RIVAL_ID)&mid=(MUSIC_ID) */
    public class DetailData {
        public init(id: Int, difficulty: Difficulty, playTune: Int, clearCount: Int, fullComboCount: Int, excellentCount: Int, score: Int, musicRate: Float, ranking: Int) {
            self.id = id
            self.difficulty = difficulty
            self.playTune = playTune
            self.clearCount = clearCount
            self.fullComboCount = fullComboCount
            self.excellentCount = excellentCount
            self.score = score
            self.musicRate = musicRate
            self.ranking = ranking
        }
        
        public var id: Int
        public var difficulty: Difficulty
        public var playTune: Int
        public var clearCount: Int
        public var fullComboCount: Int
        public var excellentCount: Int
        public var score: Int
        public var musicRate: Float
        public var ranking: Int
    }
    
    /**@brief   The data which is not provided on the official site. */
    public struct CustomData {
        public let artistName: String
        public let uppercasedRomajiArtistName: String
        public let levels: [Int]
        public var isNewMusic: Bool { return levels[0] == CustomData.newMusicIndicateValue }
        private static let newMusicIndicateValue = 999
        
        public init(artistName: String, levels: [Int]) {
            self.artistName = artistName
            self.uppercasedRomajiArtistName = removeAccentCharacters(sourceStr: transformJapaneseToLatin(sourceStr: artistName).uppercased())
            self.levels = levels
        }
        
        public init() {
            self.init(artistName: "", levels: [CustomData.newMusicIndicateValue, CustomData.newMusicIndicateValue, CustomData.newMusicIndicateValue])
        }
    }
    
/**@section Constructor */
    public init(simpleData: SimpleData, customData: CustomData) {
        self.simpleData = simpleData
        self.customData = customData
    }
    
    public init() {
    }

/**@section Property */
    /**brief The below properties are usable after initialize SimpleData. */
    public var name: String { return simpleData?.name ?? "" }
    public var uppercasedRomajiName: String { return simpleData?.uppercasedRomajiName ?? "" }
    public var id: Int { return simpleData?.id ?? detailData?.id ?? 0 }
    public var score: Int { return simpleData?.score ?? detailData?.score ?? 0 }
    public var difficulty: Difficulty { return simpleData?.difficulty ?? detailData?.difficulty ?? Difficulty.Basic }
    public var isFullCombo: Bool { return simpleData?.isFullCombo ?? false }
    public var isExcellent: Bool { return self.score >= 1000000 }
    public var isNotPlayedYet: Bool { return self.score == -1 }
    public var musicScoreRank: ScoreRank {
        switch self.score {
        case 1000000:
            return .EXC
        case 980000..<1000000:
            return .SSS
        case 950000..<980000:
            return .SS
        case 900000..<950000:
            return .S
        case 850000..<900000:
            return .A
        case 800000..<850000:
            return .B
        case 700000..<800000:
            return .C
        case 500000..<700000:
            return .D
        case 0..<500000:
            return .E
        default:
            return .NotPlayedYet
        }
    }
    public var scoreHistories: [(Timestamp, MusicScore)]? {
        get { return simpleData?.scoreHistories }
        set { simpleData?.scoreHistories = newValue }
    }
    
    /**brief The below properties are usable after initialize DetailData. */
    public var playTune: Int { return detailData?.playTune ?? 0 }
    public var clearCount: Int { return detailData?.clearCount ?? 0 }
    public var fullComboCount: Int { return detailData?.fullComboCount ?? 0 }
    public var excellentCount: Int { return detailData?.excellentCount ?? 0 }
    public var musicRate: Float { return detailData?.musicRate ?? 0.0 }
    public var ranking: Int { return detailData?.ranking ?? 0 }
    
    /**brief The below properties are usable after initialize CustomData. */
    public var artistName: String { return customData?.artistName ?? "" }
    public var uppercasedRomajiArtistName: String { return customData?.uppercasedRomajiArtistName ?? "" }
    public var levels: [Int] { return customData?.levels ?? [Int] () }
    public var basicLevel: Int { return customData?.levels[0] ?? 0 }
    public var advancedLevel: Int { return customData?.levels[1] ?? 0 }
    public var extremeLevel: Int { return customData?.levels[2] ?? 0 }
    public var level: Int { return customData?.levels[simpleData?.difficulty.rawValue ?? 0] ?? 0 }
    public var isNewMusic: Bool { return customData?.isNewMusic ?? false }
    
/**@section Method */
    public func isDetailDataInitialized() -> Bool {
        return detailData != nil
    }
    
    public static func < (lhs: MusicScoreData, rhs: MusicScoreData) -> Bool {
        return lhs.name < rhs.name
    }
    
    public static func == (lhs: MusicScoreData, rhs: MusicScoreData) -> Bool {
        return lhs.name == rhs.name
    }

/**@section Variable */
    public var simpleData: SimpleData?
    public var detailData: DetailData?
    public var customData: CustomData?
}

/**@brief   This parser does not execute DOM parsing for performance. */
class MusicScoreDataPageParser {
    
    private var html: String
    private var lastParsedPos: String.Index
    
    public init(html: String) {
        self.html = html
        self.lastParsedPos = html.startIndex
    }
    
    public func parseNext() -> [MusicScoreData]? {
        let optMusicFinder = html.range(of: "<td><span>", options: String.CompareOptions.caseInsensitive, range: self.lastParsedPos..<html.endIndex)
        guard let musicFinder = optMusicFinder else {
            return nil
        }
        
        // Parse the music ID
        let optMusicIdStartPosFinder = html.range(of: "mid=", options: String.CompareOptions.caseInsensitive, range: musicFinder.upperBound..<html.endIndex)
        guard let musicIdStartPosFinder = optMusicIdStartPosFinder else {
            return nil
        }
        
        let optMusicIdEndPosFinder = html.range(of: "\"", options: String.CompareOptions.caseInsensitive, range: musicIdStartPosFinder.upperBound..<html.endIndex)
        guard let musicIdEndPosFinder = optMusicIdEndPosFinder else {
            return nil
        }
        
        let musicId = Int(html[musicIdStartPosFinder.upperBound..<musicIdEndPosFinder.lowerBound]) ?? -1
        
        // Parse the music name
        let optMusicNameStartPosFinder = html.range(of: ">", options: String.CompareOptions.caseInsensitive, range: musicIdEndPosFinder.upperBound..<html.endIndex)
        guard let musicNameStartPosFinder = optMusicNameStartPosFinder else {
            return nil
        }
        
        let optMusicNameEndPosFinder = html.range(of: "<", options: String.CompareOptions.caseInsensitive, range: musicNameStartPosFinder.upperBound..<html.endIndex)
        guard let musicNameEndPosFinder = optMusicNameEndPosFinder else {
            return nil
        }
        
        let musicName = String(html[musicNameStartPosFinder.upperBound..<musicNameEndPosFinder.lowerBound])
        
        // Parse the music scores
        var musicScoreFinder: String.Index = musicNameEndPosFinder.upperBound
        var scoreDataTable = [(score: Int, isFullCombo: Bool)] ()
        for _ in 0...2 {
            let optMusicScoreStartPosFinder = html.range(of: "<td>", options: String.CompareOptions.caseInsensitive, range: musicScoreFinder..<html.endIndex)
            guard let musicScoreStartPosFinder = optMusicScoreStartPosFinder else {
                scoreDataTable.append((0, false))
                continue
            }
            
            let optMusicScoreEndPosFinder = html.range(of: "<", options: String.CompareOptions.caseInsensitive, range: musicScoreStartPosFinder.upperBound..<html.endIndex)
            guard let musicScoreEndPosFinder = optMusicScoreEndPosFinder else {
                scoreDataTable.append((0, false))
                continue
            }
            
            let optMusicFullComboFinder = html.range(of: "fc1", options: String.CompareOptions.caseInsensitive, range: musicScoreEndPosFinder.upperBound..<html.index(musicScoreEndPosFinder.upperBound, offsetBy: 16))
            let isFullCombo = optMusicFullComboFinder != nil
            
            let scoreStr = String(html[musicScoreStartPosFinder.upperBound..<musicScoreEndPosFinder.lowerBound]).trimmingCharacters(in: .whitespaces)
            if (scoreStr != "-") {
                scoreDataTable.append((Int(scoreStr) ?? 0, isFullCombo))
            }
            else {
                scoreDataTable.append((-1, false))
            }
            
            musicScoreFinder = musicScoreStartPosFinder.upperBound
        }
        
        self.lastParsedPos = musicScoreFinder
        
        let customMusicData = GlobalDataStorage.instance.queryCustomMusicData(musicId: musicId)
        let uppercasedRomajiMusicName = removeAccentCharacters(sourceStr: transformJapaneseToLatin(sourceStr: musicName).uppercased())
        
        return [
            MusicScoreData(
                simpleData: MusicScoreData.SimpleData(
                    name: musicName,
                    uppercasedRomajiName: uppercasedRomajiMusicName,
                    id: musicId,
                    score: scoreDataTable[0].score,
                    difficulty: .Basic,
                    isFullCombo: scoreDataTable[0].isFullCombo
                ),
                customData: customMusicData
            ),
            MusicScoreData(
                simpleData: MusicScoreData.SimpleData(
                    name: musicName,
                    uppercasedRomajiName: uppercasedRomajiMusicName,
                    id: musicId,
                    score: scoreDataTable[1].score,
                    difficulty: .Advanced,
                    isFullCombo: scoreDataTable[1].isFullCombo
                ),
                customData: customMusicData
            ),
            MusicScoreData(
                simpleData: MusicScoreData.SimpleData(
                    name: musicName,
                    uppercasedRomajiName: uppercasedRomajiMusicName,
                    id: musicId,
                    score: scoreDataTable[2].score,
                    difficulty: .Extreme,
                    isFullCombo: scoreDataTable[2].isFullCombo
                ),
                customData: customMusicData
            )
        ]
    }
}

public class JubeatWebServer {
/**@section Enum */
    public enum LoginStatus {
        case Succees
        case Failure
        case InvalidEmailOrPassword
    }
    
/**@section Method */
    public static func login(userId: String, userPassword: String, onLoginComplete: @escaping (LoginStatus) -> Void) {
        self.requestGenerateKcaptcha { (isRequestSucceed: Bool, response: Data?) in
            guard isRequestSucceed == true, let parsedData = self.parseKcaptchaJson(kcaptchaJson: response!) else {
                onLoginComplete(LoginStatus.Failure)
                return
            }
            
            var choiceCharacterImageUrls = [String] ()
            for choiceCharacterImageUrlKey in parsedData.choiceCharacterImageUrlKeys {
                choiceCharacterImageUrls.append("https://img-auth.service.konami.net/captcha/pic/\(choiceCharacterImageUrlKey)")
            }
            
            let captchaSolver = EAmusementCaptchaSolver(parsedData.correctPickCharacterImageUrl, choiceCharacterImageUrls)
            let matchedChoiceCharacterIndices = captchaSolver.SolveProblem()
            
            // Assemble captcha key
            var captchaKey = "k_\(parsedData.kcsess)"
            var captchaKeyUrlKeys = [String] (repeating: "_", count: parsedData.choiceCharacterImageUrlKeys.count)
            for matchedChoiceCharacterIndex in matchedChoiceCharacterIndices {
                captchaKeyUrlKeys[matchedChoiceCharacterIndex] += parsedData.choiceCharacterImageUrlKeys[matchedChoiceCharacterIndex]
            }
            
            for captchaKeyUrlKey in captchaKeyUrlKeys {
                captchaKey += captchaKeyUrlKey
            }
            
            self.requestLoginAuth(userId, userPassword, captchaKey) { (isRequestSucceed: Bool, response: String?) in
                let loginFailureCode = (response != nil) ? self.parseLoginAuthResponse(response: response!) : -1
                onLoginComplete(
                    loginFailureCode == 0 ? .Succees :
                    loginFailureCode == 200 ? .InvalidEmailOrPassword : .Failure
                )
            }
        }
    }
    
    /**@brief Do GET Request to https://p.eagate.573.jp/game/jubeat/festo/playdata/index_other.html?rival_id= */
    public static func requestMyPlayData(onRequestComplete: @escaping (Bool, UserData.MyPlayDataPageCache?) -> Void) {
        self.requestMyPlayDataPageHtml { (isRequestSucceed: Bool, response: String?) in
            onRequestComplete(isRequestSucceed, response != nil ? self.parseMyPlayDataPageHtml(response: response!) : nil)
        }
    }
    
    /**@brief Do GET Request to https://p.eagate.573.jp/game/jubeat/festo/playdata/index.html?rival_id= */
    public static func requestPlayData(rivalId: String, onRequestComplete: @escaping (Bool, UserData.PlayDataPageCache?) -> Void) {
        self.requestPlayDataPageHtml(rivalId: rivalId) { (isRequestSucceed: Bool, response: String?) in
            onRequestComplete(isRequestSucceed, response != nil ? self.parsePlayDataPageHtml(response: response!) : nil)
        }
    }
    
    public static func requestMyRivalList(onRequestComplete: @escaping (Bool, UserData.RivalListPageCache) -> Void) {
        self.requestMyRivalListPageHtml { (isRequestSucceed: Bool, response: String?) in
            onRequestComplete(isRequestSucceed, self.parseMyRivalListPageHtml(response: response!))
        }
    }
    
    /**@brief Do GET Request to  */
    public static func requestCustomMusicDatas(serverCMDChecksum: String, onRequestComplete: @escaping (Bool, [MusicId: MusicScoreData.CustomData]?) -> ()) {
        var isOldChecksum = true
        let clientCMDhecksum = GlobalSettingDataStorage.instance.getConfig(key: "cmdChecksum") as? String ?? ""
        if clientCMDhecksum == serverCMDChecksum {
            isOldChecksum = false
        }
        
        var customMusicDatasJsonPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        customMusicDatasJsonPath.appendPathComponent("customMusicDatas.json")
        
        if isOldChecksum {
            self.requestCustomMusicDatasJson {(isRequestSucceed: Bool, response: Data?) in
                if isRequestSucceed {
                    do {
                        try response!.write(to: customMusicDatasJsonPath)
                        GlobalSettingDataStorage.instance.setConfig(key: "cmdChecksum", value: serverCMDChecksum)
                    }
                    catch {
                        recordLastError(ErrorCode.FileWriteError, "Failed to write CustomMusicDatas json file.")
                    }
                    
                    onRequestComplete(true, parseCustomMusicData(response: response!))
                }
                else {
                    onRequestComplete(false, nil)
                }
                
            }
        }
        else {
            var customMusicDatas: [MusicId: MusicScoreData.CustomData]?
            do {
                customMusicDatas = self.parseCustomMusicData(response: try Data(contentsOf: customMusicDatasJsonPath))
            }
            catch {
                recordLastError(ErrorCode.DataConversionError, "Failed to convert json string to Data.")
            }
            
            onRequestComplete(true, customMusicDatas ?? [MusicId: MusicScoreData.CustomData] ())
        }
    }
    
    public static func requestCMDChecksum(onRequestComplete: @escaping (Bool, String?) -> ()) {
        httpRequestAsync(
            queue: DispatchQueue.global(),
            url: "https://raw.githubusercontent.com/ggomdyu/jubiinfo/master/Resource/DataTable/customMusicDatasChecksum.txt",
            method: HTTPMethod.get,
            host: "raw.githubusercontent.com",
            referer: "",
            onRequestComplete: {(statusCode: Bool, response: String?) in
                onRequestComplete(statusCode, response)
        })
    }
    
    private static func isCMDChecksumOld(serverCMDChecksum: String) -> Bool {
        var isOldChecksum = true
        
        let clientCMDhecksum = GlobalSettingDataStorage.instance.getConfig(key: "cmdChecksum") as? String ?? ""
        if clientCMDhecksum == serverCMDChecksum {
            isOldChecksum = false
        }
        
        return isOldChecksum
    }
    
    /**@brief Do GET Request to https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html?rival_id= */
    public static func requestMyMusicScoreData(serverMMSDChecksum: Int, onRequestComplete: @escaping (Bool, [MusicScoreData]?) -> Void) {
        let isOldChecksum = isMMSDChecksumOld(serverMMSDChecksum: serverMMSDChecksum)
        
        // mmsd is abbreviation of 'My music score data'!!
        var mmsdCachePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        mmsdCachePath.appendPathComponent("mmsdCache.json")
        
        // If the checksum is old, then we will refresh the score data via parsing the web data.
        // Also checksum will be refreshed too.
        if isOldChecksum {
            var newMusicScoreDatas = [MusicScoreData] ()
            
            // Start to request music score datas.
            var musicScoreDataRequestCompleteCount = 0;
            let musicScoreDataPageEndIndex = (GlobalDataStorage.instance.queryCustomMusicDatas().count / 50) + 1
            DispatchQueue.global().async {
                for i in 1...musicScoreDataPageEndIndex {
                    self.requestMusicScoreData(rivalId: "", pageIndex: i) { (isRequestSucceed: Bool, musicScoreDatas2: [MusicScoreData]?) in
                        if isRequestSucceed {
                            runTaskInMainThread {
                                newMusicScoreDatas.append(contentsOf: musicScoreDatas2!)
                                musicScoreDataRequestCompleteCount += 1
                            }
                        }
                    }
                    
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }
            
            var oldMusicScoreDatas: [MusicId: [MusicScoreData]]! = nil
            DispatchQueue.global().async {
                oldMusicScoreDatas = self.parseMMSDCacheDictionary(mmsdCachePath: mmsdCachePath) ?? [MusicId: [MusicScoreData]] ()
            }
            
            // Wait until all music data request have completed.
            SpinLock { return musicScoreDataRequestCompleteCount >= musicScoreDataPageEndIndex && oldMusicScoreDatas != nil }
            
            // Create a json that used to cache the music data received from the server.
            var mmsdJson = "{"
            mmsdJson.reserveCapacity(65536)
            
            for i in 0..<(newMusicScoreDatas.count / 3) {
                let musicScoreDataIndex = i * 3
                if let oldMusicScoreDatas = oldMusicScoreDatas[newMusicScoreDatas[musicScoreDataIndex].id] {
                    mmsdJson += "\"\(oldMusicScoreDatas[0].id)\":[\"\(oldMusicScoreDatas[0].name)\","

                    for j in 0...2 {
                        let oldMusicScoreData = oldMusicScoreDatas[j]
                        let newMusicScoreData = newMusicScoreDatas[musicScoreDataIndex + j]

                        mmsdJson += "[\(newMusicScoreData.score),\(newMusicScoreData.isFullCombo)"
                        
                        if newMusicScoreData.score != -1 {
                            let currUnixTime = Timestamp(Date().timeIntervalSince1970)
                            var scoreHistories = oldMusicScoreData.scoreHistories ?? [(Timestamp(currUnixTime), oldMusicScoreData.score)]
                            
                            mmsdJson += ",["
                            for item in scoreHistories {
                                mmsdJson += "[\(item.0),\(item.1)],"
                            }
                            
                            let isScoreNewRecord = newMusicScoreData.score > oldMusicScoreData.score
                            if isScoreNewRecord {
                                mmsdJson += "[\(currUnixTime),\(newMusicScoreData.score)]]"
                                scoreHistories.append((currUnixTime, newMusicScoreData.score))
                            }
                            else {
                                mmsdJson.removeLast()
                                mmsdJson += "]"
                            }
                            newMusicScoreData.scoreHistories = scoreHistories
                        }
                       
                        mmsdJson += "],"
                    }
                }
                else {
                    let currUnixTime = Timestamp(Date().timeIntervalSince1970)
                    
                    mmsdJson += "\"\(newMusicScoreDatas[musicScoreDataIndex].id)\":[\"\(newMusicScoreDatas[musicScoreDataIndex].name)\","
                    
                    for j in 0...2 {
                        let newMusicScoreData = newMusicScoreDatas[musicScoreDataIndex + j]
                        
                        mmsdJson += "[\(newMusicScoreData.score),\(newMusicScoreData.isFullCombo)"
                        if newMusicScoreData.score != -1 {
                            mmsdJson += ",[[\(currUnixTime), \(newMusicScoreData.score)]]],"
                        }
                        else {
                            mmsdJson += "],"
                        }
                    }
                }
                
                mmsdJson.removeLast()
                mmsdJson += "],"
            }
            mmsdJson.removeLast()
            mmsdJson += "}"

            do {
                try mmsdJson.write(to: mmsdCachePath, atomically: false, encoding: .utf16)
                GlobalSettingDataStorage.instance.setConfig(key: "mmsdChecksum", value: serverMMSDChecksum)
            }
            catch {}
            
            onRequestComplete(true, newMusicScoreDatas)
        }
        else {
            let musicScoreDatas = self.parseMMSDCacheArray(mmsdCachePath: mmsdCachePath)
            
            onRequestComplete(musicScoreDatas.count > 0, musicScoreDatas)
        }
    }
    
    public static func isMMSDChecksumOld(serverMMSDChecksum: Int) -> Bool {
        var isOldChecksum = true
        
        let clientMMSDChecksum = GlobalSettingDataStorage.instance.getConfig(key: "mmsdChecksum") as? Int ?? -1
        if clientMMSDChecksum == serverMMSDChecksum {
            isOldChecksum = false
        }
        
        return isOldChecksum
    }
    
    /**@brief Do GET Request to https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html?rival_id= */
    public static func requestMyMusicScoreData(pageIndex: Int, onRequestComplete: @escaping (Bool, [MusicScoreData]?) -> Void) {
        self.requestMusicScoreData(rivalId: "", pageIndex: pageIndex, onRequestComplete: onRequestComplete)
    }
    
    /**@brief Do GET Request to https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html?rival_id= */
    public static func requestMusicScoreData(rivalId: String, pageIndex: Int, onRequestComplete: @escaping (Bool, [MusicScoreData]?) -> Void) {
        self.requestMusicScoreDataPageHtml(rivalId: rivalId, pageIndex: pageIndex) { (isRequestSucceed: Bool, response: String?) in
            onRequestComplete(isRequestSucceed, response != nil ? self.parseMusicScoreDataPageHtml(response: response!) : nil)
        }
    }
    
    /**@brief Do GET Request to https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html?rival_id= */
    public static func requestMyRankData(onRequestComplete: @escaping (Bool, UserData.RankDataPageCache?) -> Void) {
        self.requestRankData(rivalId: "", onRequestComplete: onRequestComplete)
    }
    
    /**@brief Do GET Request to https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html?rival_id= */
    public static func requestRankData(rivalId: String, onRequestComplete: @escaping (Bool, UserData.RankDataPageCache?) -> Void) {
        self.requestRankDataPageHtml(rivalId: rivalId) { (isRequestSucceed: Bool, response: String?) in
            onRequestComplete(isRequestSucceed, response != nil ? self.parseRankDataPageHtml(response: response!) : nil)
        }
    }
    
    public static func requestDetailMusicScoreData(rivalId: String, musicId: Int, destBasicMusicScoreData: MusicScoreData, destAdvancedMusicScoreData: MusicScoreData, extremeAdvancedMusicScoreData: MusicScoreData, onRequestComplete: @escaping (Bool, Bool) -> Void) {
        self.requestDetailMusicScoreDataPageHtml(rivalId: rivalId, musicId: musicId) { (isRequestSucceed: Bool, optResponse: String?) in
            guard let response = optResponse else {
                onRequestComplete(false, false)
                return
            }
            
            let isProfilePrivated = !self.parseDetailMusicScorePageHtml(response: response, musicId: musicId, destBasicMusicScoreData: destBasicMusicScoreData, destAdvancedMusicScoreData: destAdvancedMusicScoreData, extremeAdvancedMusicScoreData: extremeAdvancedMusicScoreData);
            
            onRequestComplete(isRequestSucceed, isProfilePrivated)
        }
    }
}

/**@brief   Set of server request method */
extension JubeatWebServer {
    private static func requestGenerateKcaptcha(_ onRequestComplete: @escaping (Bool, Data?) -> Void) {
        httpRequestAsync(
            queue: DispatchQueue.global(),
            url: "https://p.eagate.573.jp/gate/p/common/login/api/kcaptcha_generate.html",
            method: HTTPMethod.post,
            host: "p.eagate.573.jp",
            referer: "https://p.eagate.573.jp/gate/p/login.html",
            onRequestComplete: { (isRequestSucceed: Bool, response: Data?) in
                onRequestComplete(isRequestSucceed, response)
        })
    }
    
    private static func requestLoginAuth(_ userEmail: String, _ userPassword: String, _ captchaKey: String, _ onRequestComplete: @escaping (Bool, String?) -> Void) {
        print("[DEBUG]: Start to request login. (userEmail: \(userEmail), userPassword: \(userPassword), captchaKey: \(captchaKey))")
        
        httpRequestAsync(
            queue: DispatchQueue.global(),
            url: "https://p.eagate.573.jp/gate/p/common/login/api/login_auth.html",
            method: HTTPMethod.post,
            host: "p.eagate.573.jp",
            referer: "https://p.eagate.573.jp/gate/p/login.html",
            onRequestComplete: {(isRequestSucceed: Bool, response: String?) in
                onRequestComplete(isRequestSucceed, response)
        },
            parameters: [
                "login_id": "\(userEmail)",
                "pass_word": "\(userPassword)",
                "otp": "",
                "resrv_url": "/gate/p/login_complete.html",
                "captcha": captchaKey,
                ]
        )
    }
    
    private static func requestLoginPageHtml(onRequestComplete: @escaping (Bool, String?) -> Void) {
        httpRequestAsync(
            queue: DispatchQueue.global(),
            url: "https://p.eagate.573.jp/gate/p/login.html",
            method: HTTPMethod.get,
            host: "p.eagate.573.jp",
            referer: "",
            onRequestComplete: { (isRequestSucceed: Bool, response: String?) in
                onRequestComplete(isRequestSucceed, response)
        })
    }
    
    private static func requestMyPlayDataPageHtml(onRequestComplete: @escaping (Bool, String?) -> Void) {
        httpRequestAsync(
            queue: DispatchQueue.global(),
            url: "https://p.eagate.573.jp/game/jubeat/festo/playdata/index.html?rival_id=",
            method: HTTPMethod.get,
            host: "p.eagate.573.jp",
            referer: "",
            onRequestComplete: { (isRequestSucceed: Bool, response: String?) in
                onRequestComplete(isRequestSucceed, response)
        })
    }
    
    private static func requestMyRivalListPageHtml(onRequestComplete: @escaping (Bool, String?) -> Void) {
        httpRequestAsync(
            queue: DispatchQueue.global(),
            url: "https://p.eagate.573.jp/game/jubeat/festo/rival/index.html",
            method: HTTPMethod.get,
            host: "p.eagate.573.jp",
            referer: "",
            onRequestComplete: { (isRequestSucceed: Bool, response: String?) in
                onRequestComplete(isRequestSucceed, response)
        })
    }
    
    private static func requestPlayDataPageHtml(rivalId: String, onRequestComplete: @escaping (Bool, String?) -> Void) {
        httpRequestAsync(
            queue: DispatchQueue.global(),
            url: "https://p.eagate.573.jp/game/jubeat/festo/playdata/index_other.html?rival_id=\(rivalId)",
            method: HTTPMethod.get,
            host: "p.eagate.573.jp",
            referer: "",
            onRequestComplete: { (isRequestSucceed: Bool, response: String?) in
                onRequestComplete(isRequestSucceed, response)
        })
    }
    
    private static func requestCustomMusicDatasJson(onRequestComplete: @escaping (Bool, Data?) -> Void) {
        let queue = DispatchQueue.init(label: "com.cmd.queue")
        
        httpRequestAsync(
            queue: queue,
            url: "https://raw.githubusercontent.com/ggomdyu/jubiinfo/master/Resource/DataTable/customMusicDatas.json",
            method: HTTPMethod.get,
            host: "raw.githubusercontent.com",
            referer: "",
            onRequestComplete: {(isRequestSucceed: Bool, response: Data?) in
                onRequestComplete(isRequestSucceed, response)
        })
    }
    
    private static func requestMyMusicScoreDataPageHtml(pageIndex: Int, onRequestComplete: @escaping (Bool, String?) -> Void) {
        self.requestMusicScoreDataPageHtml(rivalId: "", pageIndex: pageIndex, onRequestComplete: onRequestComplete)
    }
    
    private static func requestMusicScoreDataPageHtml(rivalId: String, pageIndex: Int, onRequestComplete: @escaping (Bool, String?) -> Void) {
        let queue = DispatchQueue.init(label: "com.musicScoreData.queue")
        
        httpRequestAsync(
            queue: queue,
            url: "https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html?rival_id=\(rivalId)&sort=&page=\(pageIndex)",
            method: HTTPMethod.get,
            host: "p.eagate.573.jp",
            referer: "",
            onRequestComplete: { (isRequestSucceed: Bool, response: String?) in
                onRequestComplete(isRequestSucceed, response)
        })
    }
    
    private static func requestMyRankDataPageHtml(onRequestComplete: @escaping (Bool, String?) -> Void) {
        self.requestRankDataPageHtml(rivalId: "", onRequestComplete: onRequestComplete)
    }
    
    private static func requestRankDataPageHtml(rivalId: String, onRequestComplete: @escaping (Bool, String?) -> Void) {
        httpRequestAsync(
            queue: DispatchQueue.global(),
            url: "https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html?rival_id=\(rivalId)&sort=7&page=1",
            method: HTTPMethod.get,
            host: "p.eagate.573.jp",
            referer: "",
            onRequestComplete: { (isRequestSucceed: Bool, response: String?) in
                onRequestComplete(isRequestSucceed, response)
        })
    }
    
    public static func requestDetailMusicScoreDataPageHtml(rivalId: String, musicId: Int, onRequestComplete: @escaping (Bool, String?) -> Void ) {
        httpRequestAsync(
            queue: DispatchQueue.global(),
            url: "https://p.eagate.573.jp/game/jubeat/festo/playdata/music_detail.html?rival_id=\(rivalId)&mid=\(musicId)",
            method: HTTPMethod.get,
            host: "p.eagate.573.jp",
            referer: "",
            onRequestComplete: {(isRequestSucceed: Bool, response: String?) in
                onRequestComplete(isRequestSucceed, response)
        })
    }
}

/**@brief   Set of packet parsing method */
extension JubeatWebServer {
    private static func parseKcaptchaJson(kcaptchaJson: Data) -> (kcsess: String, correctPickCharacterImageUrl: String, choiceCharacterImageUrlKeys: [String])? {
        do {
            repeat
            {
                let optKcaptchaJsonDict = try JSONSerialization.jsonObject(with: kcaptchaJson, options: []) as? [String: Any]
                guard let kcaptchaJsonDict = optKcaptchaJsonDict else {
                    break
                }
                
                // Parse the correct pick character imae URL.
                let optDataElem = kcaptchaJsonDict["data"] as? [String: Any]
                guard var dataElem = optDataElem else {
                    break
                }
                
                let optCorrectPickCharacterImageUrl = dataElem["correct_pic"] as? String
                guard let correctPickCharacterImageUrl = optCorrectPickCharacterImageUrl else {
                    break
                }
                
                // Parse the kcsess value.
                let optKcsess = dataElem["kcsess"] as? String
                guard let kcsess = optKcsess else {
                    break
                }
                
                // Parse the choice list character image URL.
                let optChoiseListArrayElem = dataElem["choicelist"] as? [[String: Any]]
                guard let choiseListArrayElem = optChoiseListArrayElem else {
                    break
                }
                
                var choiceCharacterImageUrlKeys = [String] ()
                for choiseListElem in choiseListArrayElem {
                    if let choiceCharacterImageUrlKey = choiseListElem["key"] as? String {
                        if choiceCharacterImageUrlKey.isEmpty {
                            continue
                        }
                        
                        choiceCharacterImageUrlKeys.append(choiceCharacterImageUrlKey)
                    }
                }
                
                return (kcsess, correctPickCharacterImageUrl, choiceCharacterImageUrlKeys)
            }
            while (false)
            
        }
        catch {}
        
        recordLastError(ErrorCode.DataConversionError, "Failed to convert kcaptcha data to dictionary.")
        return nil
    }
    
    private static func parseLoginAuthResponse(response: String) -> Int {
        repeat {
            let optJsonData = response.data(using: .utf8)
            guard let jsonData = optJsonData else {
                break
            }
            
            do {
                guard let responseJsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                    break
                }
                
                return responseJsonDict["fail_code"] as? Int ?? 0
            }
            catch {}
        } while(false)
        
        recordLastError(ErrorCode.ParseError, "Failed to parse login auth response.")
        return 0
    }
    
    private static func parseLoginPageHtml(_ loginPageHtml: String) -> (document: Document, mainCharacterImageURL: String, subCharacterImageURLs: [String], kcsess: String)? {
        
        do {
            let document = try SwiftSoup.parse(loginPageHtml)
            let formElem = try document.select("#login_info > form > div.login_cont_LRbox > div.login_cont_Lbox > table > tbody > tr:nth-child(3) > td:nth-child(3) > div");
            
            // Find main character's image URL
            let mainCharacterImageElem = try formElem.select("div:nth-child(1) > div:nth-child(1) > img").first()
            let mainCharacterImageUrl = try mainCharacterImageElem!.attr("src");
            
            // Find sub characters' image URL
            var subCharacterImageUrls = [String] ()
            let subCharacterFormElem = try formElem.select("div:nth-child(2)")
            for i in 1...5 {
                let subCharacterImageElem = try subCharacterFormElem.select("div:nth-child(\(i)) > label > img").first()
                let subCharacterImageUrl = try subCharacterImageElem!.attr("src")
                
                subCharacterImageUrls.append(subCharacterImageUrl);
            }
            
            // Find kcsess
            let kcsessElem = try formElem.select("input[type=\"hidden\"]")
            let kcsessValue = try kcsessElem.val()
            
            return (document, mainCharacterImageUrl, subCharacterImageUrls, kcsessValue)
        }
        catch {}
        
        recordLastError(ErrorCode.ParseError, "Failed to parse login page html.")
        return nil;
    }
    
    private static func parseMyPlayDataPageHtml(response: String) -> UserData.MyPlayDataPageCache? {
        do {
            let document = try SwiftSoup.parse(response)
            
            // Parse rival ID
            let optRivalIdElem = try document.select("#profile > div.number > div.sub").first()
            guard let rivalIdElem = optRivalIdElem else {
                return nil
            }
            let rivalIdStr = try rivalIdElem.text()
            
            // Parse nickname
            let nicknameElem = try document.select("#main_name").first()!
            let nicknameStr = try nicknameElem.text()
            
            // Parse designation
            let designationElem = try document.select("#sub_name").first()!
            let designationStr = try designationElem.text()
            
            // Parse emblem image URL
            let emblemImageUrlElem = try document.select("#emblem > img").first()!
            let emblemImageUrlStr = "https://p.eagate.573.jp\(try emblemImageUrlElem.attr("src"))"
            
            // Parse jubility
            let jubilityElem = try document.select("#profile > div:nth-child(2) > div.sub > span").first()!
            let jubility = Float(try jubilityElem.text())!
            
            // Parse last played time
            let lastPlayedTimeElem = try document.select("#history > div.time").first()!
            let lastPlayedTimeSubStrs = try lastPlayedTimeElem.text().split(whereSeparator: { $0 == ":" || $0 == " " })
            let lastPlayedTimeStr = "\(lastPlayedTimeSubStrs[1]) \(lastPlayedTimeSubStrs[2]):\(lastPlayedTimeSubStrs[3])"
            
            // Parse last played location
            let lastPlayedLocationElem = try document.select("#history > div.store").first()!
            let lastPlayedLocationStr = String(try lastPlayedLocationElem.text().split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)[1])
            
            // Parse total play tune
            let playTuneCountElem = try document.select("#number > table > tbody > tr:nth-child(1) > td:nth-child(2)").first()!
            var playTuneCountStr = try playTuneCountElem.text()
            playTuneCountStr = String(playTuneCountStr[playTuneCountStr.startIndex..<playTuneCountStr.index(playTuneCountStr.endIndex, offsetBy: -4)])
            let playTuneCount = Int(playTuneCountStr) ?? 0
            
            // Parse full combo count
            let fullComboCountElem = try document.select("#number > table > tbody > tr:nth-child(2) > td:nth-child(2)").first()!
            var fullComboCountStr = try fullComboCountElem.text()
            fullComboCountStr = String(fullComboCountStr[fullComboCountStr.startIndex..<fullComboCountStr.index(fullComboCountStr.endIndex, offsetBy: -1)])
            let fullComboCount = Int(fullComboCountStr) ?? 0
            
            // Parse excellent count
            let excellentCountElem = try document.select("#number > table > tbody > tr:nth-child(3) > td:nth-child(2)").first()!
            var excellentCountStr = try excellentCountElem.text()
            excellentCountStr = String(excellentCountStr[excellentCountStr.startIndex..<excellentCountStr.index(excellentCountStr.endIndex, offsetBy: -1)])
            let excellentCount = Int(excellentCountStr) ?? 0
            
            // Parse total score
            let totalBestScoreElem = try document.select("#score > div.best").first()!
            let totalBestScoreSubStrs = try totalBestScoreElem.text().split(whereSeparator: { $0 == " " || $0 == "(" || $0 == ")" })
            let totalScore = Int64("\(totalBestScoreSubStrs[4])")!
            
            // Parse ranking
            var rankStr: String.SubSequence = totalBestScoreSubStrs[5]
            rankStr.removeLast()
            let ranking = Int("\(rankStr)")!
            
            return UserData.MyPlayDataPageCache(nicknameStr, designationStr, rivalIdStr, emblemImageUrlStr, jubility, lastPlayedTimeStr, lastPlayedLocationStr, ranking, Int64(totalScore), playTuneCount, fullComboCount, excellentCount)
        }
        catch {}
        
        recordLastError(ErrorCode.ParseError, "Failed to parse my play data page html.")
        return nil;
    }
    
    private static func parsePlayDataPageHtml(response: String) -> UserData.PlayDataPageCache? {
        do {
            let document = try SwiftSoup.parse(response)
            
            // Parse rival ID
            let rivalIdElem = try document.select("#profile > div.number > div.sub").first()!
            let rivalIdStr = try rivalIdElem.text()
            
            // Parse nickname
            let nicknameElem = try document.select("#main_name").first()!
            let nicknameStr = try nicknameElem.text()
            
            // Parse emblem image URL
            let emblemImageUrlElem = try document.select("#emblem > img").first()!
            let emblemImageUrlStr = "https://p.eagate.573.jp\(try emblemImageUrlElem.attr("src"))"
            
            // Parse designation
            let designationElem = try document.select("#sub_name").first()!
            let designationStr = try designationElem.text()
            
            // Parse last played time
            let lastPlayedTimeElem = try document.select("#history > div.time").first()!
            let lastPlayedTimeSubStrs = try lastPlayedTimeElem.text().split(whereSeparator: { $0 == ":" || $0 == " " })
            let lastPlayedTimeStr = "\(lastPlayedTimeSubStrs[1]) \(lastPlayedTimeSubStrs[2]):\(lastPlayedTimeSubStrs[3])"
            
            // Parse last played location
            let lastPlayedLocationElem = try document.select("#history > div.store").first()!
            let lastPlayedLocationStr = String(try lastPlayedLocationElem.text().split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)[1])
            
            // Parse ranking
            let rankingElem = try document.select("#score > div:nth-child(1)").first()!
            let ranking = Int(try rankingElem.text().split(separator: " ")[0])!
            
            // Parse total score
            let totalBestScoreElem = try document.select("#score > div:nth-child(2)").first()!
            let totalScore = Int64(try totalBestScoreElem.text().split(separator: " ", omittingEmptySubsequences: false)[4])!
            
            return UserData.PlayDataPageCache(nicknameStr, designationStr, rivalIdStr, emblemImageUrlStr, lastPlayedTimeStr, lastPlayedLocationStr, ranking, totalScore, 0, 0, 0)
        }
        catch {}
        
        recordLastError(ErrorCode.ParseError, "Failed to parse play data page html.")
        return nil;
    }
    
    private static func parseMyRivalListPageHtml(response: String) -> UserData.RivalListPageCache {
        do {
            var simpleRivalDataList = [UserData.RivalListPageCache.SimpleRivalData] ()
            
            let document = try SwiftSoup.parse(response)
            
            let rivalListElem = try document.select("#rival_all").first()!
            for rivalListChildElem in rivalListElem.children() {
                // Parse rival id
                let hrefElem = try rivalListChildElem.select("a").first()!
                let rivalPageUrl = try hrefElem.attr("href")
                let rivalIdStartIndex = rivalPageUrl.range(of: "=")!.upperBound
                let rivalId = String(rivalPageUrl[rivalIdStartIndex..<rivalPageUrl.endIndex])
                
                // Parse nickname
                let nickname = try (hrefElem.select("div.data > div.name").first()!).text()
                
                // Parse designation
                let designation = try (hrefElem.select("div.data > div.title > span").first()!).text()
                
                simpleRivalDataList.append(UserData.RivalListPageCache.SimpleRivalData(rivalId: rivalId, nickname: nickname, designation: designation))
            }
            
            return UserData.RivalListPageCache(simpleRivalDataList: simpleRivalDataList)
        }
        catch {}
        
        recordLastError(ErrorCode.ParseError, "Failed to parse play data page html.")
        return UserData.RivalListPageCache();
    }
    
    private static func parseCustomMusicData(response: Data) -> [MusicId: MusicScoreData.CustomData]? {
        do {
            let optJsonDict = try JSONSerialization.jsonObject(with: response, options: []) as? [String: Any]
            guard let jsonDict = optJsonDict else {
                return nil
            }
            
            // Parse the MusicScoreData.CustomData
            let optMusicArrayElem = jsonDict["music"] as? [String: [Any]]
            guard let musicArrayElem = optMusicArrayElem else {
                return nil
            }
            
            var customMusicDatas = [MusicId : MusicScoreData.CustomData] ()
            for musicElem in musicArrayElem {
                
                let musicArtistName = musicElem.value[0] as? String ?? ""
                let musicBasicLevel = musicElem.value[1] as? Int ?? 0
                let musicAdvancedLevel = musicElem.value[2] as? Int ?? 0
                let musicExtremeLevel = musicElem.value[3] as? Int ?? 0
                
                customMusicDatas[Int(musicElem.key) ?? 0] = MusicScoreData.CustomData(
                    artistName: musicArtistName,
                    levels: [musicBasicLevel, musicAdvancedLevel, musicExtremeLevel]
                )
            }
            
            return customMusicDatas
        }
        catch {}
        
        return nil
    }
    
    private static func parseMusicScoreDataPageHtml(response: String) -> [MusicScoreData] {
        var musicScoreDatas = [MusicScoreData] ()
        let musicScoreDataPageParser = MusicScoreDataPageParser(html: response)
        repeat
        {
            let optParsedMusicScoreDatas = musicScoreDataPageParser.parseNext()
            guard let parsedMusicScoreDatas = optParsedMusicScoreDatas else {
                break
            }
            
            musicScoreDatas.append(contentsOf: parsedMusicScoreDatas)
        }
        while (true)
        
        return musicScoreDatas
    }
    
    private static func parseMMSDCacheArray(mmsdCachePath: URL) -> [MusicScoreData] {
        var ret = [MusicScoreData] ()
        self.parseMMSDCache(mmsdCachePath: mmsdCachePath) { (parseResult: MusicScoreData) in
            ret.append(parseResult)
        }
        return ret
    }
    
    private static func parseMMSDCacheDictionary(mmsdCachePath: URL) -> [MusicId: [MusicScoreData]] {
        var ret = [MusicId: [MusicScoreData]] ()
        
        var musicScoreDatas = [MusicScoreData] ()
        musicScoreDatas.reserveCapacity(3)
        
        self.parseMMSDCache(mmsdCachePath: mmsdCachePath) { (parseResult: MusicScoreData) in
            musicScoreDatas.append(parseResult)
            
            if musicScoreDatas.count >= 3 {
                ret.updateValue(musicScoreDatas, forKey: musicScoreDatas[0].id)
                musicScoreDatas.removeAll()
            }
        }
        return ret
    }
    
    private static func parseMMSDCache(mmsdCachePath: URL, parseResultHandler: (MusicScoreData) -> Void) {
        var optJsonDict: [String: [Any]]?
        do {
            let jsonData = try Data(contentsOf: mmsdCachePath)
            optJsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: [Any]]
        }
        catch {}
        
        guard let jsonDict = optJsonDict else {
            return
        }
        
        for jsonElem in jsonDict {
            let musicId = Int(jsonElem.key)!
            let musicName = jsonElem.value[0] as! String
            
            let customMusicData = GlobalDataStorage.instance.queryCustomMusicData(musicId: musicId)
            let uppercasedRomajiMusicName = removeAccentCharacters(sourceStr: transformJapaneseToLatin(sourceStr: musicName).uppercased())
            
            for i in 1...3 {
                var optMusicScoreHistories: [(Timestamp, MusicScore)]? = nil
                let musicScoreHistoryItems = jsonElem.value[i] as! [Any]
                if musicScoreHistoryItems.count >= 3 {
                    var musicScoreHistories = [(Timestamp, MusicScore)] ()
                    for musicScoreHistory in musicScoreHistoryItems[2] as! [[Any]] {
                        let timestamp = musicScoreHistory[0] as? Timestamp ?? 0
                        let musicScore = musicScoreHistory[1] as? MusicScore ?? 0
                        musicScoreHistories.append((timestamp, musicScore))
                    }
                    
                    optMusicScoreHistories = musicScoreHistories
                }
                
                let musicScore = musicScoreHistoryItems[0] as? Int ?? 0
                let isFullCombo = musicScoreHistoryItems[1] as? Bool ?? false
                parseResultHandler(MusicScoreData(
                    simpleData: MusicScoreData.SimpleData(
                        name: musicName,
                        uppercasedRomajiName: uppercasedRomajiMusicName,
                        id: musicId,
                        score: musicScore,
                        difficulty: MusicScoreData.Difficulty(rawValue: i - 1)!,
                        isFullCombo: isFullCombo,
                        scoreHistory: optMusicScoreHistories
                    ),
                    customData: customMusicData
                ))
            }
        }
    }

    private static func parseRankDataPageHtml(response: String) -> UserData.RankDataPageCache? {
        do {
            let document = try SwiftSoup.parse(response)
            
            let optRankListElem = try document.select("#contents > table.music_rating > tbody > tr:nth-child(1)").first()
            guard let rankListElem = optRankListElem else {
                return nil
            }
            
            let notPlayedCount = Int(try rankListElem.child(1).text())!
            let eRankCount = Int(try rankListElem.child(2).text())!
            let dRankCount = Int(try rankListElem.child(3).text())!
            let cRankCount = Int(try rankListElem.child(4).text())!
            let bRankCount = Int(try rankListElem.child(5).text())!
            let aRankCount = Int(try rankListElem.child(6).text())!
            let sRankCount = Int(try rankListElem.child(7).text())!
            let ssRankCount = Int(try rankListElem.child(8).text())!
            let sssRankCount = Int(try rankListElem.child(9).text())!
            let excRankCount = Int(try rankListElem.child(10).text())!
            
            return UserData.RankDataPageCache(notPlayedCount, eRankCount, dRankCount, cRankCount, bRankCount, aRankCount, sRankCount, ssRankCount, sssRankCount, excRankCount)
        }
        catch {}
        
        recordLastError(ErrorCode.ParseError, "Failed to parse rank data page html.")
        return nil;
    }
    
    private static func parseDetailMusicScorePageHtml(response: String, musicId: Int, destBasicMusicScoreData: MusicScoreData, destAdvancedMusicScoreData: MusicScoreData, extremeAdvancedMusicScoreData: MusicScoreData) -> Bool {

        var musicScoreDatas = [destBasicMusicScoreData, destAdvancedMusicScoreData, extremeAdvancedMusicScoreData];
        
        var levelItemPosFinder = response.startIndex
        for i in 0..<3 {
            let optLevelStartPosFinder = response.range(of: "LEVEL:", options: String.CompareOptions.caseInsensitive, range: levelItemPosFinder..<response.endIndex)
            guard let levelStartPosFinder = optLevelStartPosFinder else {
                return false
            }
            let optLevelEndPosFinder = response.range(of: "<", options: String.CompareOptions.caseInsensitive, range: levelStartPosFinder.upperBound..<response.endIndex)
            guard let levelEndPosFinder = optLevelEndPosFinder else {
                return false
            }
            
//            let musicLevel = Float(response[levelStartPosFinder.upperBound..<levelEndPosFinder.lowerBound]) ?? -1
            
            var scoreItemDatas = [Any] ()
            var scoreItemPosFinder = levelEndPosFinder.upperBound
            for j in 0..<7 {
                var optScoreItemStartPosFinder: Range<String.Index>?
                var optScoreItemEndPosFinder: Range<String.Index>?
                // Parse various play data, not contains score
                if j != 4 {
                    optScoreItemStartPosFinder = response.range(of: "</td>                <td>", options: String.CompareOptions.caseInsensitive, range: scoreItemPosFinder..<response.endIndex)
                    guard let scoreItemStartPosFinder = optScoreItemStartPosFinder else {
                        return false
                    }
                    
                    optScoreItemEndPosFinder = response.range(of: "<", options: String.CompareOptions.caseInsensitive, range: scoreItemStartPosFinder.upperBound..<response.endIndex)
                    guard let scoreItemEndPosFinder = optScoreItemEndPosFinder else {
                        return false
                    }
                    
                    if j != 5 {
                        let scoreItemData = Int(response[scoreItemStartPosFinder.upperBound..<response.index(scoreItemEndPosFinder.lowerBound, offsetBy: -1)]) ?? -1
                        scoreItemDatas.append(scoreItemData)
                    }
                    else  {
                        let scoreItemData = Float(response[scoreItemStartPosFinder.upperBound..<response.index(scoreItemEndPosFinder.lowerBound, offsetBy: -1)]) ?? -1
                        scoreItemDatas.append(scoreItemData)
                    }
                    
                    scoreItemPosFinder = scoreItemEndPosFinder.upperBound
                }
                // Parse score
                else {
                    scoreItemPosFinder = response.index(scoreItemPosFinder, offsetBy: 100)
                    
                    optScoreItemStartPosFinder = response.range(of: "<td colspan=\"2\">", options: String.CompareOptions.caseInsensitive, range: scoreItemPosFinder..<response.endIndex)
                    guard let scoreItemStartPosFinder = optScoreItemStartPosFinder else {
                        return false
                    }
                    
                    optScoreItemEndPosFinder = response.range(of: "<img", options: String.CompareOptions.caseInsensitive, range: scoreItemStartPosFinder.upperBound..<response.endIndex)
                    guard let scoreItemEndPosFinder = optScoreItemEndPosFinder else {
                        return false
                    }
                    
                    scoreItemPosFinder = scoreItemEndPosFinder.upperBound
                    
                    let scoreItemData = Int(response[scoreItemStartPosFinder.upperBound..<scoreItemEndPosFinder.lowerBound]) ?? -1
                    scoreItemDatas.append(scoreItemData)
                }
            }
            
            levelItemPosFinder = scoreItemPosFinder
            
            let musicScoreDetailData = MusicScoreData.DetailData(
                id: musicId,
                difficulty: MusicScoreData.Difficulty(rawValue: i)!,
                playTune: scoreItemDatas[0] as! Int,
                clearCount: scoreItemDatas[1] as! Int,
                fullComboCount: scoreItemDatas[2] as! Int,
                excellentCount: scoreItemDatas[3] as! Int,
                score: scoreItemDatas[4] as! Int,
                musicRate: scoreItemDatas[5] as! Float,
                ranking: scoreItemDatas[6] as! Int
            )
            musicScoreDatas[i].detailData = musicScoreDetailData
        }
        
        return true
    }
}
