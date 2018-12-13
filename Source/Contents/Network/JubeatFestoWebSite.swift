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

private class ImageMatchProblemSolver {
/**@section Enum */
    private enum CharacterType {
        case Unknown
        case Bomberman
        case Girl
        case Goemon
        case Rabbit
        case Robot
    }
    
/**@section Variable */
    private var mainCharacterImageUrl: String
    private var subCharacterImageUrls: [String]
    private let rabbitIdentifierColor = Color3b(0, 220, 170)
    private let robotIdentifierColor = Color3b(40, 90, 180)
    private let girlIdentifierColor = Color3b(240, 90, 145)
    private let bombermanIdentifierColor = Color3b(255, 225, 170)
    private let goemonIdentifierColor = Color3b(230, 55, 35)
    
/**@section Constructor */
    public init(_ mainCharacterImageUrl: String, _ subCharacterImageUrls: [String]) {
        self.mainCharacterImageUrl = mainCharacterImageUrl;
        self.subCharacterImageUrls = subCharacterImageUrls
    }
    
/**@section Method */
    public func SolveProblem() -> [Int] {
        
        // 1. Download main character image and identify the type of character.
        var mainCharacterType = CharacterType.Unknown
        var mainCharacterTypeQueryComplete = false
        
        downloadImageAsync(imageUrl: self.mainCharacterImageUrl, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
            mainCharacterType = self.getMainCharacterType(optImage: image)
            mainCharacterTypeQueryComplete = true
        })
        
        // 2. Download sub character images together while requesting.
        //    The sub character images also has a type and we need to select an image that matched with the main character type.
        let subCharacterImageCount = 5;
        var downloadedSubCharacterImageCount: Int32 = 0;
        var subCharacterImages = [UIImage?](repeating: nil, count: subCharacterImageCount)
        for i in 0 ... 4 {
            downloadImageAsync(imageUrl: subCharacterImageUrls[i], onDownloadComplete: { (succeed: Bool, image: UIImage?) in
                if (succeed) {
                    subCharacterImages[i] = image
                }
                
                OSAtomicIncrement32(&downloadedSubCharacterImageCount)
            })
        }
        
        print("[DEBUG]: Wait until all images downloaded...")
        
        // 3. Wait until the above task finished
        SpinLock { () -> (Bool) in
            return mainCharacterTypeQueryComplete &&
                downloadedSubCharacterImageCount == subCharacterImageCount
        }
        
        // 4. Finally, Find all the matched character with main character.
        return self.getMatchedSubCharacterIndices(mainCharacterType: mainCharacterType, subCharacterImages: subCharacterImages);
    }
    
    private func getMainCharacterType(optImage: UIImage?) -> CharacterType {
        repeat {
            guard let image = optImage else {
                break
            }
            
            let characterTypeMatchConditionTable = [
                (Point<Int>(42, 19), bombermanIdentifierColor, CharacterType.Bomberman),
                (Point<Int>(55, 8), girlIdentifierColor, CharacterType.Girl),
                (Point<Int>(42, 58), goemonIdentifierColor, CharacterType.Goemon),
                (Point<Int>(48, 11), rabbitIdentifierColor, CharacterType.Rabbit),
                (Point<Int>(53, 22), robotIdentifierColor, CharacterType.Robot)
            ]
            
            for characterTypeMatchCondition in characterTypeMatchConditionTable {
                if (getImagePixel(image: image, point: characterTypeMatchCondition.0) == characterTypeMatchCondition.1)
                {
                    return characterTypeMatchCondition.2
                }
            }
        }
        while (false)
        
        return CharacterType.Unknown
    }
    
    private func getMatchedSubCharacterIndices(mainCharacterType: CharacterType, subCharacterImages: [UIImage?]) -> [Int] {
        
        print("[DEBUG]: ImageMatchProblemSolver begun to solve image match problem.")
        
        var characterTypeMatchConditionTable = [
            CharacterType.Bomberman: ([Point<Int>(49, 9), Point<Int>(48, 34), Point<Int>(57, 32), Point<Int>(51, 20), Point<Int>(31, 29)], bombermanIdentifierColor),
            CharacterType.Girl: ([Point<Int>(41, 15), Point<Int>(39, 10), Point<Int>(45, 13), Point<Int>(50, 14), Point<Int>(42, 11)], girlIdentifierColor),
            CharacterType.Goemon: ([Point<Int>(56, 51), Point<Int>(49, 49), Point<Int>(55, 60), Point<Int>(59, 68), Point<Int>(38, 72)], goemonIdentifierColor),
            CharacterType.Rabbit: ([Point<Int>(81, 9), Point<Int>(55, 11), Point<Int>(38, 5), Point<Int>(31, 18), Point<Int>(69, 4)], rabbitIdentifierColor),
            CharacterType.Robot: ([Point<Int>(37, 54), Point<Int>(68, 32), Point<Int>(27, 45), Point<Int>(27, 49), Point<Int>(48, 45)], robotIdentifierColor)
        ];
        
        var matchedSubCharacterIncides = [Int]()
        
        // Get the condition datas to check character type of UIImage
        var characterTypeMatchCondition = characterTypeMatchConditionTable[mainCharacterType]!;
        
        for i in 0 ... subCharacterImages.count - 1 {
            let subCharacterImage = subCharacterImages[i]
            for j in 0 ... characterTypeMatchCondition.0.count - 1 {
                if (getImagePixel(image: subCharacterImage!, point: characterTypeMatchCondition.0[j]) == characterTypeMatchCondition.1) {
                    matchedSubCharacterIncides.append(i)
                    break
                }
            }
        }
        
        print("[DEBUG]: ImageMatchProblemSolver finished to solve image match problem.")
        
        return matchedSubCharacterIncides
    }
}

public class JubeatFestoWebSite : WebSite {

/**@section Method */
    /**
     * @brief   Log into the e-Amusement site.
     * @warn    Note that the onLoginComplete closure called by main thread.
     */
    public func login(userId: String, userPassword: String, onLoginComplete: @escaping (Bool) -> Void) {
        
        self.requestLoginPage { (statusCode: Int, html: String) in
            
            repeat {
                let optParsedData = self.parseLoginPageHtml(html)
                guard let parsedData = optParsedData else {
                    break
                }
                
                let mainCharacterImageURL = parsedData.mainCharacterImageURL;
                let subCharacterImageUrls = parsedData.subCharacterImageURLs;
                let imageMatchProblemSolver = ImageMatchProblemSolver(mainCharacterImageURL, subCharacterImageUrls)
                
                let matchedSubCharacterIndices = imageMatchProblemSolver.SolveProblem();
                let optChkKeyValues = self.parseChkValue(parsedData.document, matchedSubCharacterIndices)
                guard let chkKeyValues = optChkKeyValues else {
                    break;
                }
                
                self.requestLogin(userId, userPassword, chkKeyValues.chk1Key, chkKeyValues.chk1Value, chkKeyValues.chk2Key, chkKeyValues.chk2Value, parsedData.kcsess) { (statusCode: Int, html: String) in
                    onLoginComplete(true)
                }
                return;
            }
            while (false)
            
            onLoginComplete(false)
        }
    }
    
    /**@brief Do GET Request for https://p.eagate.573.jp/game/jubeat/festo/playdata/index_other.html?rival_id= */
    public func requestMyPlayData(onRequestComplete: @escaping (UserData.MyPlayDataPageCache?) -> Void) {
        self.requestMyPlayDataPage { (statusCode: Int, html: String) in
            onRequestComplete(self.parseMyPlayDataPageHtml(html: html))
        }
    }
    
    /**@brief Do GET Request for https://p.eagate.573.jp/game/jubeat/festo/playdata/index.html?rival_id= */
    public func requestPlayData(rivalId: String, onRequestComplete: @escaping (UserData.PlayDataPageCache?) -> Void) {
        self.requestPlayDataPage(rivalId: rivalId) { (statusCode: Int, html: String) in
            onRequestComplete(self.parsePlayDataPageHtml(html: html))
        }
    }
    
    /**@brief Do GET Request for https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html?rival_id= */
    public func requestMyMusicData(pageIndex: Int, onRequestComplete: @escaping (UserData.MusicDataPageCache?) -> Void) {
        self.requestMusicData(rivalId: "", pageIndex: 1, onRequestComplete: onRequestComplete)
    }
    
    /**@brief Do GET Request for https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html?rival_id= */
    public func requestMusicData(rivalId: String, pageIndex: Int, onRequestComplete: @escaping (UserData.MusicDataPageCache?) -> Void) {
        
        self.requestMusicDataPage(rivalId: rivalId, pageIndex: pageIndex) { (statusCode: Int, html: String) in
            onRequestComplete(self.parseMusicDataPageHtml(html: html))
        }
    }
    
    
    /**@brief Do GET Request for https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html?rival_id= */
    public func requestMyRankData(onRequestComplete: @escaping (UserData.RankDataPageCache?) -> Void) {
        self.requestRankData(rivalId: "", onRequestComplete: onRequestComplete)
    }
    
    /**@brief Do GET Request for https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html?rival_id= */
    public func requestRankData(rivalId: String, onRequestComplete: @escaping (UserData.RankDataPageCache?) -> Void) {
        self.requestRankDataPage(rivalId: rivalId) { (statusCode: Int, html: String) in
            onRequestComplete(self.parseRankDataPageHtml(html: html))
        }
    }
    
    
    private func parseChkValue(_ document: Document, _ matchedSubCharacterIndices: [Int]) -> (chk1Key: String, chk1Value: String, chk2Key: String, chk2Value: String)? {
        
        if (matchedSubCharacterIndices.count != 2) {
            recordLastError(ErrorCode.NotSupposedParameter, "Selected sub character count is not 2. (Currently \(matchedSubCharacterIndices.count)")
            return nil
        }
        
        do {
            let chk1Key = "chk_c\(matchedSubCharacterIndices[0])"
            let chk1Value = try document.select("#id_kcaptcha_c\(matchedSubCharacterIndices[0])").val()
            
            let chk2Key = "chk_c\(matchedSubCharacterIndices[1])"
            let chk2Value = try document.select("#id_kcaptcha_c\(matchedSubCharacterIndices[1])").val()
            
            return (chk1Key, chk1Value, chk2Key, chk2Value)
        }
        catch {
            recordLastError(ErrorCode.ParseError, "Failed to parse chk value.")
            return nil
        }
    }
    
    
    
    private func requestLogin(_ userEmail: String, _ userPassword: String, _ chk1Key: String, _ chk1Value: String, _ chk2Key: String, _ chk2Value: String, _ kcsess: String, _ onRequestComplete: @escaping (Int, String) -> Void) {
        print("[DEBUG]: Start to request login.")
    
        Alamofire.request(
            "https://p.eagate.573.jp/gate/p/login.html",
            method: HTTPMethod.post,
            parameters: [
                "KID": "\(userEmail)",
                "pass": "\(userPassword)",
                chk1Key: chk1Value,
                chk2Key: chk2Value,
                "kcsess": kcsess,
                "OTP": ""
            ],
            encoding: URLEncoding.default,
            headers: [
                "Keep-Alive": "true",
                "Upgrade-Insecure-Requests": "1",
                "User-Agent": "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:24.0) Gecko/20100101 Firefox/24.0",
                "Accept": "*/*",
                "Accept-Encoding": "gzip, deflate, br",
                "Accept-Language": "ko,en;q=0.9",
                "Host": "p.eagate.573.jp",
                "Referer": "https://p.eagate.573.jp/gate/p/login.html",
                "Content-Type": "application/x-www-form-urlencoded",
                "Origin": "https://p.eagate.573.jp",
                "Cache-Control": "max-age=0"
            ]).responseString { (response: DataResponse<String>) in
                
                if response.error != nil {
                    print("[ERROR]: \(response.error.debugDescription)")
                }
                
                saveCookies(response: response)
                
                print("[DEBUG]: Succeed to request login.")
                
                onRequestComplete(response.response!.statusCode, response.description)
        }
    }
    
    private func requestLoginPage(onRequestComplete: @escaping (Int, String) -> Void) {
        print("[DEBUG]: Start to request login page.")
        
        Alamofire.request(
            "https://p.eagate.573.jp/gate/p/login.html",
            method: HTTPMethod.get,
            parameters: [:],
            encoding: URLEncoding.default,
            headers: [
                "Keep-Alive": "true",
                "Upgrade-Insecure-Requests": "1",
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
                "Accept-Encoding": "sdch",
                "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
                "Host": "p.eagate.573.jp"
            ]).responseString { (response: DataResponse<String>) in
                print("[DEBUG]: Succeed to request login page.")
                
                onRequestComplete(response.response!.statusCode, response.description);
        }
    }
    
    private func parseLoginPageHtml(_ loginPageHtml: String) -> (document: Document, mainCharacterImageURL: String, subCharacterImageURLs: [String], kcsess: String)? {
        
        print("[DEBUG]: Start to parse login page html.")
        
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
            
            print("[DEBUG]: Succeed to parse login page html.")
            
            return (document, mainCharacterImageUrl, subCharacterImageUrls, kcsessValue)
        }
        catch {}
        
        recordLastError(ErrorCode.ParseError, "Failed to parse login page html.")
        return nil;
    }
    
    
    
    private func requestMyPlayDataPage(onRequestComplete: @escaping (Int, String) -> Void) {
        print("[DEBUG]: Start to request my play data page.")
        
        httpRequestAsync(
            url: "https://p.eagate.573.jp/game/jubeat/festo/playdata/index.html?rival_id=",
            method: HTTPMethod.get,
            host: "p.eagate.573.jp",
            onRequestComplete: {(statusCode: Int, html: String) in
                print("[DEBUG]: Succeed to request my play data page.")
                onRequestComplete(statusCode, html)
            }
        )
    }
    
    private func requestPlayDataPage(rivalId: String, onRequestComplete: @escaping (Int, String) -> Void) {
        
        print("[DEBUG]: Start to request play data page.")
        
        httpRequestAsync(
            url: "https://p.eagate.573.jp/game/jubeat/festo/playdata/index_other.html?rival_id=\(rivalId)",
            method: HTTPMethod.get,
            host: "p.eagate.573.jp",
            onRequestComplete: {(statusCode: Int, html: String) in
                print("[DEBUG]: Succeed to request play data page.")
                onRequestComplete(statusCode, html)
            }
        )
    }
    
    private func parseMyPlayDataPageHtml(html: String) -> UserData.MyPlayDataPageCache? {
        
        print("[DEBUG]: Start to parse my play data page html.")
        
        do {
            let document = try SwiftSoup.parse(html)
            
            // 라이벌 아이디 파싱
            let rivalIdElem = try document.select("#profile > div.number > div.sub").first()!
            let rivalIdStr = try rivalIdElem.text()
            
            // 닉네임 파싱
            let nicknameElem = try document.select("#main_name").first()!
            let nicknameStr = try nicknameElem.text()
            
            // 칭호 파싱
            let designationElem = try document.select("#sub_name").first()!
            let designationStr = try designationElem.text()
            
            // 엠블럼 이미지 URL 파싱
            let emblemImageUrlElem = try document.select("#emblem > img").first()!
            let emblemImageUrlStr = "https://p.eagate.573.jp\(try emblemImageUrlElem.attr("src"))"
            
            // 유빌리티 파싱
            let jubilityElem = try document.select("#profile > div:nth-child(2) > div.sub > span").first()!
            let jubility = Float(try jubilityElem.text())!
            
            // 마지막 플레이 시간 파싱
            let lastPlayedTimeElem = try document.select("#history > div.time").first()!
            let lastPlayedTimeSubStrs = try lastPlayedTimeElem.text().split(whereSeparator: { $0 == ":" || $0 == " " })
            let lastPlayedTimeStr = "\(lastPlayedTimeSubStrs[1]) \(lastPlayedTimeSubStrs[2]):\(lastPlayedTimeSubStrs[3])"
            
            // 마지막 플레이 장소 파싱
            let lastPlayedLocationElem = try document.select("#history > div.store").first()!
            let lastPlayedLocationStr = String(try lastPlayedLocationElem.text().split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)[1])
            
            // 누적 스코어 파싱
            let totalBestScoreElem = try document.select("#score > div.best").first()!
            let totalBestScoreSubStrs = try totalBestScoreElem.text().split(whereSeparator: { $0 == " " || $0 == "(" || $0 == ")" })
            let totalScore = Int64("\(totalBestScoreSubStrs[4])")!
            
            // 랭킹 파싱
            var rankStr: String.SubSequence = totalBestScoreSubStrs[5]
            rankStr.removeLast()
            let ranking = Int("\(rankStr)")!
            
            print("[DEBUG]: Succeed to parse my play data page html.")
            
            return UserData.MyPlayDataPageCache(nicknameStr, designationStr, rivalIdStr, emblemImageUrlStr, jubility, lastPlayedTimeStr, lastPlayedLocationStr, ranking, Int64(totalScore), 0, 0, 0)
        }
        catch {}
        
        recordLastError(ErrorCode.ParseError, "Failed to parse my play data page html.")
        return nil;
    }
    
    private func parsePlayDataPageHtml(html: String) -> UserData.PlayDataPageCache? {
        
        print("[DEBUG]: Start to parse play data page html.")
        
        do {
            let document = try SwiftSoup.parse(html)
            
            // 라이벌 아이디 파싱
            let rivalIdElem = try document.select("#profile > div.number > div.sub").first()!
            let rivalIdStr = try rivalIdElem.text()
            
            // 닉네임 파싱
            let nicknameElem = try document.select("#main_name").first()!
            let nicknameStr = try nicknameElem.text()
            
            // 엠블럼 이미지 URL 파싱
            let emblemImageUrlElem = try document.select("#emblem > img").first()!
            let emblemImageUrlStr = "https://p.eagate.573.jp\(try emblemImageUrlElem.attr("src"))"
            
            // 칭호 파싱
            let designationElem = try document.select("#sub_name").first()!
            let designationStr = try designationElem.text()
            
            // 마지막 플레이 시간 파싱
            let lastPlayedTimeElem = try document.select("#history > div.time").first()!
            let lastPlayedTimeSubStrs = try lastPlayedTimeElem.text().split(whereSeparator: { $0 == ":" || $0 == " " })
            let lastPlayedTimeStr = "\(lastPlayedTimeSubStrs[1]) \(lastPlayedTimeSubStrs[2]):\(lastPlayedTimeSubStrs[3])"
            
            // 마지막 플레이 장소 파싱
            let lastPlayedLocationElem = try document.select("#history > div.store").first()!
            let lastPlayedLocationStr = String(try lastPlayedLocationElem.text().split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)[1])
            
            // 랭킹 파싱
            let rankingElem = try document.select("#score > div:nth-child(1)").first()!
            let ranking = Int(try rankingElem.text().split(separator: " ")[0])!
            
            let totalBestScoreElem = try document.select("#score > div:nth-child(2)").first()!
            let totalScore = Int64(try totalBestScoreElem.text().split(separator: " ", omittingEmptySubsequences: false)[4])!
            
            print("[DEBUG]: Succeed to parse play data page html.")
            
            return UserData.PlayDataPageCache(nicknameStr, designationStr, rivalIdStr, emblemImageUrlStr, lastPlayedTimeStr, lastPlayedLocationStr, ranking, totalScore, 0, 0, 0)
        }
        catch {}
        
        recordLastError(ErrorCode.ParseError, "Failed to parse play data page html.")
        return nil;
    }
    
    
    
    private func requestMyMusicDataPage(pageIndex: Int, onRequestComplete: @escaping (Int, String) -> Void) {
        self.requestMusicDataPage(rivalId: "", pageIndex: pageIndex, onRequestComplete: onRequestComplete)
    }
    
    private func requestMusicDataPage(rivalId: String, pageIndex: Int, onRequestComplete: @escaping (Int, String) -> Void) {
        
        print("[DEBUG]: Start to request music data page.")
        
        Alamofire.request(
            "https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html?rival_id=\(rivalId)&sort=7&page=\(pageIndex)",
            method: HTTPMethod.get,
            parameters: [:],
            encoding: URLEncoding.default,
            headers: [
                "Keep-Alive": "true",
                "Upgrade-Insecure-Requests": "1",
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
                "Accept-Encoding": "sdch",
                "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
                "Host": "p.eagate.573.jp"
            ]).responseString { (response: DataResponse<String>) in
                
                print("[DEBUG]: Succeed to request music data page.")
                
                onRequestComplete(response.response!.statusCode, response.description);
        }
    }
    
    private func parseMusicDataPageHtml(html: String) -> UserData.MusicDataPageCache? {
        
        print("[DEBUG]: Start to parse music data page html.")
        
        recordLastError(ErrorCode.ParseError, "Failed to parse music data page html.")
        return nil;
    }
    
    
    
    private func requestMyRankDataPage(onRequestComplete: @escaping (Int, String) -> Void) {
        self.requestRankDataPage(rivalId: "", onRequestComplete: onRequestComplete)
    }
    
    private func requestRankDataPage(rivalId: String, onRequestComplete: @escaping (Int, String) -> Void) {
        
        print("[DEBUG]: Start to request rank data page.")
        
        httpRequestAsync(
            url: "https://p.eagate.573.jp/game/jubeat/festo/playdata/music.html?rival_id=\(rivalId)&sort=7&page=1",
            method: HTTPMethod.get,
            host: "p.eagate.573.jp",
            onRequestComplete: {(statusCode: Int, html: String) in
                print("[DEBUG]: Succeed to request rank data page.")
                onRequestComplete(statusCode, html)
            }
        )
    }
    
    private func parseRankDataPageHtml(html: String) -> UserData.RankDataPageCache? {
        
        print("[DEBUG]: Start to parse rank data page html.")
        
        do {
            let document = try SwiftSoup.parse(html)
            
            // 랭크 데이터 파싱
            let rankListElem = try document.select("#contents > table.music_rating > tbody > tr:nth-child(1)").first()!
            
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
            
            print("[DEBUG]: Succeed to parse rank data page html.")
            
            return UserData.RankDataPageCache(notPlayedCount, eRankCount, dRankCount, cRankCount, bRankCount, aRankCount, sRankCount, ssRankCount, sssRankCount, excRankCount)
        }
        catch {}
        
        recordLastError(ErrorCode.ParseError, "Failed to parse rank data page html.")
        return nil;
    }
}
