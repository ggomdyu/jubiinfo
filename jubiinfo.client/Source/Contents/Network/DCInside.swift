//
//  DCInside.swift
//  jubiinfo
//
//  Created by ggomdyu on 27/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.\

//

import Foundation
import Alamofire
import SwiftSoup

class DCInside : WebSite {
    
    public func login(userId: String, userPassword: String, onLoginComplete: @escaping (Bool) -> ()) {
        
        // 데일리 해시 키/밸류 값 요청
        self.queryDailyHash { (isQuerySucceed: Bool, dailyHashKey: String?, dailyHashValue: String?) in
            
            guard let dailyHashKey = dailyHashKey, let dailyHashValue = dailyHashValue, isQuerySucceed else {
                onLoginComplete(isQuerySucceed)
                return
            }
            
            // 로그인 시도 1
            self.queryFirstLogin(userId: userId, userPassword: userPassword, dailyHashKey: dailyHashKey, dailyHashValue: dailyHashValue, onCompleteCallback: { (isQuerySucceed: Bool) in
                
                if isQuerySucceed == false {
                    onLoginComplete(isQuerySucceed)
                    return
                }
                
                // 로그인 시도 2
                self.querySecondLogin(userId: userId, userPassword: userPassword, dailyHashKey: dailyHashKey, dailyHashValue: dailyHashValue, onCompleteCallback: { (isQuerySucceed: Bool) in
                    
                    onLoginComplete(isQuerySucceed)
                })
            })
        }
    }
    
    public func addGuestCommentToPost(galleryId: String, postId: Int, postMessage: String, userNickname: String, userPassword: String)
    {
        Alamofire.request(
            "http://gall.dcinside.com/board/forms/comment_submit",
            method: HTTPMethod.post,
            parameters: [
                "id": "\(galleryId)",
                "no": "\(postId)",
                "name": "\(userNickname)",
                "password": "\(userPassword)",
                "memo": "\(postMessage)",
                "cur_t": "0",
                "recommend": "0",
                "user_ip": "",
                "t_vch2": "",
                ],
            encoding: URLEncoding.default,
            headers: [
                "Keep-Alive": "true",
                "Upgrade-Insecure-Requests": "1",
                "User-Agent": "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:24.0) Gecko/20100101 Firefox/24.0",
                "Accept": "*/*",
                "Accept-Encoding": "gzip, deflate",
                "Accept-Language": "ko,en;q=0.9",
                "Host": "gall.dcinside.com",
                "Referer": "http://gall.dcinside.com/mgallery/board/view/?id=\(galleryId)&no=\(postId)",
                "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
                "X-Requested-With": "XMLHttpRequest"
            ]).responseString { (response: DataResponse<String>) in
                if response.error != nil {
                    print("[ERROR]: \(response.error.debugDescription)")
                    return;
                }
        }
    }
    
    public func addCommentToPost(galleryId: String, postId: Int, postMessage: String)
    {
        Alamofire.request(
            "http://gall.dcinside.com/board/forms/comment_submit",
            method: HTTPMethod.post,
            parameters: [
                "id": "\(galleryId)",
                "no": "\(postId)",
                "name": "ㅇㅇ",
                "memo": "\(postMessage)",
                "cur_t": "0",
                "recommend": "0",
                "user_ip": "",
                "t_vch2": "",
                ],
            encoding: URLEncoding.default,
            headers: [
                "Keep-Alive": "true",
                "Upgrade-Insecure-Requests": "1",
                "User-Agent": "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:24.0) Gecko/20100101 Firefox/24.0",
                "Accept": "*/*",
                "Accept-Encoding": "gzip, deflate",
                "Accept-Language": "ko,en;q=0.9",
                "Host": "gall.dcinside.com",
                "Referer": "http://gall.dcinside.com/mgallery/board/view/?id=\(galleryId)&no=\(postId)",
                "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
                "X-Requested-With": "XMLHttpRequest"
            ]).responseString { (response: DataResponse<String>) in
        }
    }
    
    private func queryDailyHash(onCompleteCallback: @escaping (Bool, String?, String?) -> ()) {
        Alamofire.request(
            "https://www.dcinside.com",
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
                "Host": "www.dcinside.com",
                ]).responseString { (response: DataResponse<String>) in
                    do {
                        let document = try SwiftSoup.parse(response.description)
                        let loginProcessElem = try document.select("form[id=login_process]").get(0)
                        let hashKeyValueElem = loginProcessElem.child(2);
                        
                        saveCookies(response: response)
                        
                        onCompleteCallback(true, try hashKeyValueElem.attr("name"), try hashKeyValueElem.val())
                    }
                    catch {
                        onCompleteCallback(false, nil, nil);
                    }
        }
    }
    
    private func queryFirstLogin(userId: String, userPassword: String, dailyHashKey: String, dailyHashValue: String, onCompleteCallback: @escaping (Bool) -> ()) {
        Alamofire.request(
            "https://dcid.dcinside.com/join/member_check.php",
            method: HTTPMethod.post,
            parameters: [
                "s_url": "%2F%2Fwww.dcinside.com%2F",
                "ssl": "Y",
                dailyHashKey: dailyHashValue,
                "user_id": userId,
                "password": userPassword
            ],
            encoding: URLEncoding.default,
            headers: [
                "Keep-Alive": "true",
                "Upgrade-Insecure-Requests": "1",
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
                "Accept-Encoding": "sdch",
                "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
                "Host": "dcid.dcinside.com",
                "Referer": "https://www.dcinside.com/",
                "Content-Type": "application/x-www-form-urlencoded",
                "X-Requested-With": "XMLHttpRequest",
                "Origin": "https://www.dcinside.com",
                "Cache-Control": "max-age=0"
            ]).responseString { (response: DataResponse<String>) in
                saveCookies(response: response)
                onCompleteCallback(true)
        }
    }
    
    private func querySecondLogin(userId: String, userPassword: String, dailyHashKey: String, dailyHashValue: String, onCompleteCallback: @escaping (Bool) -> ()) {
        Alamofire.request(
            "https://dcid.dcinside.com/join/member_check.php?ssoAttached=1",
            method: HTTPMethod.post,
            parameters: [
                "s_url": "%2F%2Fwww.dcinside.com%2F",
                "ssl": "Y",
                dailyHashKey: dailyHashValue,
                "user_id": userId,
                "password": userPassword
            ],
            encoding: URLEncoding.default,
            headers: [
                "Keep-Alive": "true",
                "Upgrade-Insecure-Requests": "1",
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
                "Accept-Encoding": "sdch",
                "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
                "Host": "dcid.dcinside.com",
                "Referer": "https://www.dcinside.com/",
                "Content-Type": "application/x-www-form-urlencoded",
                "X-Requested-With": "XMLHttpRequest",
                "Origin": "null",
                "Cache-Control": "max-age=0"
            ]).responseString { (response: DataResponse<String>) in
                saveCookies(response: response);
                onCompleteCallback(true);
        }
    }
}
