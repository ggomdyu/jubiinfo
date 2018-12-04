//
//  AppDelegate.swift
//  jubiinfo
//
//  Created by ggomdyu on 13/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftSoup
import CoreGraphics
import Material

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.prepareUpdateCustomMusicDatas()
        self.prepareViewController()
        return true
    }
    
    private func prepareViewController() {
        window = UIWindow(frame: Screen.bounds)
        window!.rootViewController = self.createSuitableViewController()
        window!.makeKeyAndVisible()
    }
    
    private func createSuitableViewController() -> UIViewController? {
        if let autoLoginUserId = SettingDataStorage.instance.getConfig(key: "autoLoginUserId") as? String,
           let autoLoginUserPassword = SettingDataStorage.instance.getSecurityConfig(key: "autoLoginUserPassword") {
            if JubeatWebServer.isLoginSessionExpired() {
                removeCookies(url: URL(string: "https://p.eagate.573.jp/")!)
                
                let loginStatus = self.requestLoginSync(loginUserId: autoLoginUserId, loginUserPassword: autoLoginUserPassword)
                if loginStatus != .success {
                    if loginStatus == .invalidEmailOrPassword {
                        return LoginViewController.create()
                    }
                    else {
                        return LoginViewController.create()
                    }
                }
            }
            
            SettingDataStorage.instance.setActiveUserId(userId: autoLoginUserId)
            return ProfileViewController.create()
        }
        else {
            return LoginViewController.create()
        }
    }
    
    private func requestLoginSync(loginUserId: String, loginUserPassword: String) -> JubeatWebServer.LoginStatus {
        var optLoginStatus: JubeatWebServer.LoginStatus?
        JubeatWebServer.login(userId: loginUserId, userPassword: loginUserPassword) { (loginStatus: JubeatWebServer.LoginStatus) in
            optLoginStatus = loginStatus
        }
        
        SpinLock { return optLoginStatus != nil }
        
        return optLoginStatus!
    }
    
    private func prepareUpdateCustomMusicDatas() {
        JubeatWebServer.requestCMDChecksum { (isRequestSucceed: Bool, checksum: String?) in
            if isRequestSucceed {
                JubeatWebServer.requestCustomMusicDatas(serverCMDChecksum: checksum!, onRequestComplete: {(isRequestSucceed2: Bool, optCustomMusicDatas: [MusicId : MusicScoreData.CustomData]?) in
                    if let customMusicDatas = optCustomMusicDatas {
                        runTaskInMainThread {
                            DataStorage.instance.initCustomMusicDatas(customMusicDatas: customMusicDatas)
                            
                            EventDispatcher.instance.dispatchEvent(eventType: "requestCustomMusicDatasDataComplete", eventParam: customMusicDatas)
                        }
                    }
                })
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                    self?.prepareUpdateCustomMusicDatas();
                })
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        EventDispatcher.instance.dispatchEvent(eventType: "applicationEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
