//
//  HttpUtility.swift
//  jubiinfo
//
//  Created by ggomdyu on 30/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import Alamofire

public func saveCookies<T>(response: DataResponse<T>) {
    guard let urlResponse = response.response else { return }
    
    let headerFields = urlResponse.allHeaderFields as! [String: String]
    let url = response.response?.url
    
    let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url!)
    Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookies(cookies, for: url, mainDocumentURL: nil);
}

public func removeCookies(url: URL) {
    let sharedCookieStorage = HTTPCookieStorage.shared;
    
    if let cookies = sharedCookieStorage.cookies(for: url) {
        for cookie in cookies {
            sharedCookieStorage.deleteCookie(cookie)
        }
    }
}

public func downloadImageAsync(imageUrl: String, onDownloadComplete: @escaping (Bool, UIImage?) -> ()) {
    
    URLSession.shared.dataTask(with: URL(string: imageUrl)!) { (data: Data?, response: URLResponse?, error: Error?) in
        if error != nil {
            onDownloadComplete(false, nil)
            return
        }
        
        print("[DEBUG]: Image download has been completed.")
        
        onDownloadComplete(true, UIImage(data: data!))
    }.resume();
}

public func downloadImageSync(imageUrl: String, onDownloadComplete: @escaping (Bool, UIImage?) -> ()) {
    
    var isDownloadSucceed: Bool = false
    var downloadedImage: UIImage? = nil
    
    var isImageDownloadPending: Bool = true
    downloadImageAsync(imageUrl: imageUrl, onDownloadComplete: {(isDownloadSucceed2: Bool, downloadedImage2: UIImage?) -> () in
        
        downloadedImage = downloadedImage2
        isDownloadSucceed = isDownloadSucceed2
        
        isImageDownloadPending = false
    })
    
    SpinLock { () -> (Bool) in
        return isImageDownloadPending == false
    }
    
    onDownloadComplete(isDownloadSucceed, downloadedImage)
}

public func httpRequestAsync(url: String, method: HTTPMethod, host: String, referer: String, onRequestComplete: @escaping (Int, String) -> Void) {
    httpRequestAsync(url: url, method: method, host: host, referer: referer, onRequestComplete: onRequestComplete, parameters: [String: String]())
}

public func httpRequestAsync(url: String, method: HTTPMethod, host: String, referer: String, onRequestComplete: @escaping (Int, String) -> Void, parameters: [String: String]) {
    
    let queue = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])

    Alamofire.request(
        url,
        method: method,
        parameters: parameters,
        encoding: URLEncoding.default,
        headers: [
            "Keep-Alive": "true",
            "Upgrade-Insecure-Requests": "1",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
            "Accept-Encoding": "sdch",
            "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
            "Referer": referer,
            "Host": host
        ]).responseString(queue: queue, encoding: nil) { (response: DataResponse<String>) in
            
            saveCookies(response: response)
            
            let html = response.description
            onRequestComplete(response.response!.statusCode, html);
    }
}
