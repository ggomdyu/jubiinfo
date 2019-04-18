//
//  SettingData.swift
//  jubiinfo
//
//  Created by ggomdyu on 13/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import CoreData
import Foundation
import Security
import UIKit

/**@warn DO NOT CHANGE THE ORDER OF THIS ENUMERATOR!! */
public enum WidgetType : Int {
    case profile
    case playData
    case visitHistory
    case rankDataGraphA
    case rankDataGraphB
    case omikuji
    case dailyRecommended
    case gameCenterVisitHistory
    case newRecord
}

public enum ThemeType : Int, CaseIterable {
    case festo
    case clan
    case qubell
    case prop
    case saucerFulfill
    case saucer
    case copious
    case knit
    case ripples
    case original
}

private class KeychainService {
    private static let keyChainServiceName = "com.ggomdyu.jubiinfo"
    
    private static let kSecClassValue = NSString(format: kSecClass)
    private static let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
    private static let kSecValueDataValue = NSString(format: kSecValueData)
    private static let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
    private static let kSecAttrServiceValue = NSString(format: kSecAttrService)
    private static let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
    private static let kSecReturnDataValue = NSString(format: kSecReturnData)
    private static let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
    
    public static func setSecurityConfig(key: String, value: String) {
        guard let data = value.data(using: .utf8, allowLossyConversion: false) else {
            return
        }
        
        let keychainQuery = NSMutableDictionary(
            objects: [
                KeychainService.kSecClassGenericPasswordValue,
                KeychainService.keyChainServiceName,
                key,
                data
            ],
            forKeys: [
                KeychainService.kSecClassValue,
                KeychainService.kSecAttrServiceValue,
                KeychainService.kSecAttrAccountValue,
                KeychainService.kSecValueDataValue
            ]
        )
        
        SecItemDelete(keychainQuery)
        SecItemAdd(keychainQuery, nil)
    }
    
    public static func getSecurityConfig(key: String) -> String? {
        let keychainQuery = NSMutableDictionary(
            objects: [
                KeychainService.kSecClassGenericPasswordValue,
                KeychainService.keyChainServiceName,
                key,
                kCFBooleanTrue,
                KeychainService.kSecMatchLimitOneValue
            ],
            forKeys: [
                KeychainService.kSecClassValue,
                KeychainService.kSecAttrServiceValue,
                KeychainService.kSecAttrAccountValue,
                KeychainService.kSecReturnDataValue,
                KeychainService.kSecMatchLimitValue
            ]
        )

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        if status == errSecSuccess {
            guard let data = dataTypeRef as? Data else {
                return nil
            }
            
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    public static func removeSecurityConfig(key: String) {
        let keychainQuery = NSMutableDictionary(
            objects: [
                KeychainService.kSecClassGenericPasswordValue,
                KeychainService.keyChainServiceName,
                key
            ],
            forKeys: [
                KeychainService.kSecClassValue,
                KeychainService.kSecAttrServiceValue,
                KeychainService.kSecAttrAccountValue
            ]
        )
        
        SecItemDelete(keychainQuery)
    }
}

public class SettingDataStorage {
/**@section Constructor */
    private init() {
        let lastErrorCode = ErrorCode.Success
        m_lastErrorRecord = LastErrorRecord(lastErrorCode, lastErrorCode.description)
    }
 
/**@section Method */
    public func setConfig(key: String, value: Any?) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    public func setSecurityConfig(key: String, value: String) {
        KeychainService.setSecurityConfig(key: key, value: value)
    }
    
    public func getConfig(key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }
    
    public func getSecurityConfig(key: String) -> String? {
        return KeychainService.getSecurityConfig(key: key)
    }
    
    public func removeConfig(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    public func removeSecurityConfig(key: String) {
        KeychainService.removeSecurityConfig(key: key)
    }
    
    public func setLastErrorRecord(_ lastErrorRecord: LastErrorRecord) {
        self.m_lastErrorRecord = lastErrorRecord
    }
    
    public func setLastErrorRecord() -> LastErrorRecord {
        return self.m_lastErrorRecord
    }
    
    public func setActiveWidgetList(activeWidgetList: [WidgetType]) {
        var activeWidgetDataJson = "["
        for activeWidget in activeWidgetList {
            activeWidgetDataJson += "{\"widgetType\":\(activeWidget.rawValue),"
                activeWidgetDataJson += "\"offlineCache\":{}"
            activeWidgetDataJson += "},"
        }
        activeWidgetDataJson.removeLast()
        activeWidgetDataJson += "]"
        
        var activeWidgetDataJsonPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        activeWidgetDataJsonPath.appendPathComponent("\(m_activeUserId)_activeWidgetData.json")
        do {
            try activeWidgetDataJson.write(to: activeWidgetDataJsonPath, atomically: false, encoding: .utf8)
        }
        catch {}
        
        m_optCachedActiveWidgetTypes = activeWidgetList
    }
    
    public func getActiveWidgetList() -> [WidgetType] {
        if let cachedActiveWidgetTypes = m_optCachedActiveWidgetTypes {
            return cachedActiveWidgetTypes
        }
        
        var activeWidgetDataJsonPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        activeWidgetDataJsonPath.appendPathComponent("\(m_activeUserId)_activeWidgetData.json")
        
        do {
            let activeWidgetDataJsonData = try Data(contentsOf: activeWidgetDataJsonPath)
            let jsonDict = try JSONSerialization.jsonObject(with: activeWidgetDataJsonData, options: []) as! [[String: Any]]
            
            var parsedWidgetTypes: [WidgetType] = []
            for widgetJsonObject in jsonDict {
                guard let parsedWidgetType = WidgetType(rawValue: widgetJsonObject["widgetType"] as? Int ?? -1) else {
                    continue
                }
                parsedWidgetTypes.append(parsedWidgetType)
            }
            
            return parsedWidgetTypes
        }
        catch {}
        
        // If failed to load or parse widget data
        var defaultWidgetTypes = [WidgetType.profile, WidgetType.playData, WidgetType.rankDataGraphA]
        if UIDevice.current.userInterfaceIdiom == .pad {
            defaultWidgetTypes.append(WidgetType.omikuji)
            defaultWidgetTypes.append(WidgetType.dailyRecommended)
        }
        
        SettingDataStorage.instance.setActiveWidgetList(activeWidgetList: defaultWidgetTypes)
        
        return defaultWidgetTypes
    }
    
    public func setActiveTheme(themeType: ThemeType, saveToFile: Bool = true) {
        if saveToFile {
            self.setConfig(key: "activeTheme", value: themeType.rawValue)
        }
        m_optCachedActiveThemeType = themeType
    }
    
    public func getActiveTheme() -> ThemeType {
        if let cachedActiveThemeType = m_optCachedActiveThemeType {
            return cachedActiveThemeType
        }
        
        guard let activeThemeType = self.getConfig(key: "activeTheme") else {
            let defaultActiveTheme = ThemeType.festo
            
            self.setActiveTheme(themeType: defaultActiveTheme)
            return defaultActiveTheme
        }
        
        return ThemeType.init(rawValue: activeThemeType as! Int)!
    }
    
    public func setActiveUserId(userId: String) {
        m_activeUserId = userId.lowercased()
    }
    
    public func getActiveUserId() -> String {
        return m_activeUserId
    }
    
    public func removeActiveUserId() {
        m_activeUserId.removeAll()
    }
    
    public func setRecentMusicFilters(recentMusicFilterCaches: [(MusicFilterType, Any?)]) {
        m_optCachedRecentMusicFilter = recentMusicFilterCaches
    }
    
    public func getRecentMusicFilters() -> [(MusicFilterType, Any?)] {
        if let cachedRecentMusicFilter = m_optCachedRecentMusicFilter {
            return cachedRecentMusicFilter
        }
       
        m_optCachedRecentMusicFilter = [(MusicFilterType.score, nil)]
        return m_optCachedRecentMusicFilter!
    }
    
/**@section Variable */
    public static let instance = SettingDataStorage()
    private var m_lastErrorRecord: LastErrorRecord
    private var m_optCachedActiveWidgetTypes: [WidgetType]?
    private var m_optCachedActiveThemeType: ThemeType?
    private var m_optCachedRecentMusicFilter: [(MusicFilterType, Any?)]?
    private var m_activeUserId: String = ""
}
