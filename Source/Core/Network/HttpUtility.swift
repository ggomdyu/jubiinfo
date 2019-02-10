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
    guard let urlResponse = response.response else {
        return
    }
    
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

public func downloadImageAsync(imageUrl: String, onDownloadComplete: @escaping (Bool, UIImage?) -> Void) {
    let queue = DispatchQueue.init(label: "com.imageDownload.queue")
    
    Alamofire.request(imageUrl).responseData(queue: queue) { (data: DataResponse<Data>) in
        print("[DEBUG]: Image download has been completed. (\(imageUrl))")
        
        onDownloadComplete(true, UIImage(data: data.data!))
    }
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

public func httpRequestAsync(queue: DispatchQueue, url: String, method: HTTPMethod, host: String, referer: String, onRequestComplete: @escaping (Bool, Data?) -> Void) {
    httpRequestAsync(queue: queue, url: url, method: method, host: host, referer: referer, onRequestComplete: onRequestComplete, parameters: [String: String]())
}

public func httpRequestAsync(queue: DispatchQueue, url: String, method: HTTPMethod, host: String, referer: String, onRequestComplete: @escaping (Bool, Data?) -> Void, parameters: [String: String]) {
    
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
        ]).responseData(queue: queue) { (response: DataResponse<Data>) in
            httpRequestHandler(url: url, onRequestComplete: onRequestComplete, response: response)
        }
}


public func httpRequestAsync(queue: DispatchQueue, url: String, method: HTTPMethod, host: String, referer: String, onRequestComplete: @escaping (Bool, String?) -> Void) {
    httpRequestAsync(queue: queue, url: url, method: method, host: host, referer: referer, onRequestComplete: onRequestComplete, parameters: [String: String]())
}

public func httpRequestAsync(queue: DispatchQueue, url: String, method: HTTPMethod, host: String, referer: String, onRequestComplete: @escaping (Bool, String?) -> Void, parameters: [String: String]) {
    
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
            httpRequestHandler(url: url, onRequestComplete: onRequestComplete, response: response)
        }
}

private func httpRequestHandler<T>(url: String, onRequestComplete: @escaping (Bool, T?) -> Void, response: DataResponse<T>) {
    saveCookies(response: response)
    
    let statusCode = response.response?.statusCode ?? 0
    
    let requestSucceed = statusCode == 200
    if requestSucceed {
        onRequestComplete(true, response.value!)
        return
    }
    else if statusCode == 0 {
        recordLastError(ErrorCode.ServerNotConnected, "Server not connected. (\(url))")
    }
    else if statusCode == 404 {
        recordLastError(ErrorCode.PageNotFound, "Page not found. (\(url))")
    }
    
    onRequestComplete(false, nil)
}
