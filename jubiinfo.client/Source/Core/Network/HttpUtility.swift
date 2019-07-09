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

#if DEBUG
public var g_networkDelayInSeconds: Double = 0.0
#endif

public func saveCookies<T>(dataResponse: DataResponse<T>) {
    guard let urlResponse = dataResponse.response else {
        return
    }
    
    let headerFields = urlResponse.allHeaderFields as! [String: String]
    let url = dataResponse.response?.url
    
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

public func downloadImageAsync(imageUrl: String, isWriteCache: Bool, isReadCache: Bool, onDownloadComplete: @escaping (Bool, UIImage?) -> Void) {
    
    let isUseImageCaching = isWriteCache || isReadCache
    if isUseImageCaching {
        let imageFormatStartIndex = imageUrl.lastIndex(of: ".")!
        let cachedImageFileName = "\(imageUrl.hash)\(imageUrl[imageFormatStartIndex..<imageUrl.endIndex])"
        
        var imageCachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        imageCachePath.appendPathComponent("\(cachedImageFileName)")
        
        if isReadCache {
            if FileManager.default.fileExists(atPath: imageCachePath.path) {
                do
                {
                    let imageData = try Data(contentsOf: imageCachePath)
                    if let image = UIImage(data: imageData) {
                        onDownloadComplete(true, image)
                        return
                    }
                } catch {}
            }
        }
        
        let queue = DispatchQueue.init(label: "com.imageDownload.queue")
        
        Alamofire.request(imageUrl).responseData(queue: queue) { (dataResponse: DataResponse<Data>) in
            guard let data = dataResponse.data else {
                Debug.log("[DEBUG]: Failed to download image. (\(imageUrl))")
                onDownloadComplete(false, nil)
                return
            }
            
            Debug.log("[DEBUG]: Succeed to download image. (\(imageUrl))")
            
            let optImage = UIImage(data: data)
            
            let isDownloadSucceed = optImage != nil
            if isDownloadSucceed {
                if isWriteCache {
                    do {
                        try data.write(to: URL(fileURLWithPath: imageCachePath.path))
                    }
                    catch {}
                }
                
                onDownloadComplete(true, optImage)
            }
            else {
                onDownloadComplete(false, nil)
            }
        }
    }
    else {
        let queue = DispatchQueue.init(label: "com.imageDownload.queue")
        
        Alamofire.request(imageUrl).responseData(queue: queue) { (dataResponse: DataResponse<Data>) in
            guard let data = dataResponse.data else {
                Debug.log("[DEBUG]: Failed to download image. (\(imageUrl))")
                onDownloadComplete(false, nil)
                return
            }
            
            Debug.log("[DEBUG]: Succeed to download image. (\(imageUrl))")
            
            onDownloadComplete(true, UIImage(data: data))
        }
    }
}

public func downloadImageSync(imageUrl: String, isWriteCache: Bool, isReadCache: Bool, onDownloadComplete: @escaping (Bool, UIImage?) -> ()) {
    
    var isDownloadSucceed: Bool = false
    var downloadedImage: UIImage? = nil
    
    var isImageDownloadPending: Bool = true
    downloadImageAsync(imageUrl: imageUrl, isWriteCache: isWriteCache, isReadCache: isReadCache, onDownloadComplete: {(isDownloadSucceed2: Bool, downloadedImage2: UIImage?) -> () in
        
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
        ]).responseData(queue: queue) { (dataResponse: DataResponse<Data>) in
#if DEBUG
            if g_networkDelayInSeconds > 0.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + g_networkDelayInSeconds, execute: {
                    Debug.log("Response wait complete!")
                    httpRequestHandler(url: url, onRequestComplete: onRequestComplete, dataResponse: dataResponse)
                })
            }
            else {
                httpRequestHandler(url: url, onRequestComplete: onRequestComplete, dataResponse: dataResponse)
            }
#else
            httpRequestHandler(url: url, onRequestComplete: onRequestComplete, dataResponse: dataResponse)
#endif
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
        ]).responseString(queue: queue, encoding: nil) { (dataResponse: DataResponse<String>) in
#if DEBUG
            if g_networkDelayInSeconds > 0.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + g_networkDelayInSeconds, execute: {
                    Debug.log("Response wait complete!")
                    httpRequestHandler(url: url, onRequestComplete: onRequestComplete, dataResponse: dataResponse)
                })
            }
            else {
                httpRequestHandler(url: url, onRequestComplete: onRequestComplete, dataResponse: dataResponse)
            }
#else
            httpRequestHandler(url: url, onRequestComplete: onRequestComplete, dataResponse: dataResponse)
#endif
        }
}

private func httpRequestHandler<T>(url: String, onRequestComplete: @escaping (Bool, T?) -> Void, dataResponse: DataResponse<T>) {
    saveCookies(dataResponse: dataResponse)
    
    let statusCode = dataResponse.response?.statusCode ?? 0
    
    let requestSucceed = (statusCode == 200) && (dataResponse.value != nil)
    if requestSucceed {
        onRequestComplete(true, dataResponse.value!)
        return
    }
    else {
        if statusCode == 0 {
            recordLastError(ErrorCode.ServerNotConnected, "Server not connected. (\(url))")
        }
        else if statusCode == 404 {
            recordLastError(ErrorCode.PageNotFound, "Page not found. (\(url))")
        }
        
        onRequestComplete(false, nil)
    }
}
