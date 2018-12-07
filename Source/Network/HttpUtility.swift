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
    var sharedCookieStorage = HTTPCookieStorage.shared;
    
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
