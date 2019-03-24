//
//  MusicScoreDataPageLoader.swift
//  jubiinfo
//
//  Created by ggomdyu on 01/01/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation

public enum MusicSortMode {
    case none
    case level
    case artist
    case score
    case name
    case version
}

public enum MusicSortOrder {
    case none
    case ascending
    case descending
}

public class MusicScoreDataPageLoader {
/**@section Variable */
    private var m_musicScoreDatas: Box<[MusicScoreData]>
    private var m_currMusicSortMode = MusicSortMode.none
    private var m_currMusicSortOrder = MusicSortOrder.none
    private let m_musicDataCountPerPage = 20
    private static let m_loadStartPageIndex = 0
    private var m_loadedPageIndex = MusicScoreDataPageLoader.m_loadStartPageIndex
    private var m_isAllPageLoaded = false
    
/**@section Constructor */
    public init(musicScoreDatas: Box<[MusicScoreData]>, musicSortMode: MusicSortMode = MusicSortMode.level, musicSortOrder: MusicSortOrder) {
        m_musicScoreDatas = musicScoreDatas
        
        self.sort(musicSortMode: musicSortMode, musicSortOrder: musicSortOrder)
    }
    
/**@section Method */
    /**@brief Sorts all the sroted music data through given algorithm. */
    public func sort(musicSortMode: MusicSortMode, musicSortOrder: MusicSortOrder) -> Bool {
        m_currMusicSortMode = musicSortMode
        m_currMusicSortOrder = musicSortOrder
        
        if m_musicScoreDatas.value.count <= 0 {
            return false
        }
        
        let isAscendingSort = (musicSortOrder == .ascending)
        switch musicSortMode {
        case .level:
            sortByLevel(isAscendingSort: isAscendingSort, musicScoreDatas: m_musicScoreDatas)
            break
        case .name:
            sortByName(isAscendingSort: isAscendingSort, musicScoreDatas: m_musicScoreDatas)
            break
        case .score:
            sortByScore(isAscendingSort: isAscendingSort, musicScoreDatas: m_musicScoreDatas)
            break;
        case .artist:
            sortByArtistName(isAscendingSort: isAscendingSort, musicScoreDatas: m_musicScoreDatas)
            break
        case .version:
            sortByVersion(isAscendingSort: isAscendingSort, musicScoreDatas: m_musicScoreDatas)
            break
        default:
            break
        }
        
        return true
    }
    
    public func loadNextPageCells() -> ArraySlice<MusicScoreData>? {
        let musicScoreDataStartIndex = m_musicDataCountPerPage * m_loadedPageIndex
        if musicScoreDataStartIndex >= m_musicScoreDatas.value.count {
            return nil
        }
        
        var musicScoreDataEndIndex = m_musicDataCountPerPage * (m_loadedPageIndex + 1)
        if musicScoreDataEndIndex >= m_musicScoreDatas.value.count {
            musicScoreDataEndIndex = m_musicScoreDatas.value.count
            m_isAllPageLoaded = true
        }
        
        m_loadedPageIndex += 1
        
        return m_musicScoreDatas.value[musicScoreDataStartIndex..<musicScoreDataEndIndex]
    }
    
    public func resetLoadedPage() {
        m_loadedPageIndex = MusicScoreDataPageLoader.m_loadStartPageIndex
        m_isAllPageLoaded = false
    }
    
    public func getLoadedPageIndex() -> Int {
        return m_loadedPageIndex
    }
    
    public func isAllPageLoaded() -> Bool {
        return m_isAllPageLoaded
    }
    
    public func getCurrentMusicSortMode() -> MusicSortMode {
        return m_currMusicSortMode
    }
    
    public func getCurrentMusicSortOrder() -> MusicSortOrder {
        return m_currMusicSortOrder
    }
    
    private func sortByLevel(isAscendingSort: Bool, musicScoreDatas: Box<[MusicScoreData]>) {
        // Sort music datas by level.
        m_musicScoreDatas = MusicScoreDataCaches(musicScoreDatas.value.sorted { (lhs: MusicScoreData, rhs: MusicScoreData) -> Bool in
            if lhs.level == rhs.level {
                if lhs.id == rhs.id {
                    return (lhs.difficulty.rawValue < rhs.difficulty.rawValue) == isAscendingSort
                }
                return lhs.uppercasedRomajiName < rhs.uppercasedRomajiName
            }
            
            return (lhs.level < rhs.level) == isAscendingSort
        })
    }
    
    private func sortByScore(isAscendingSort: Bool, musicScoreDatas: MusicScoreDataCaches) {
        m_musicScoreDatas = MusicScoreDataCaches(musicScoreDatas.value.sorted { (lhs: MusicScoreData, rhs: MusicScoreData) -> Bool in
            if lhs.score == rhs.score {
                if lhs.id == rhs.id {
                    return lhs.difficulty.rawValue > rhs.difficulty.rawValue
                }
            
                return lhs.uppercasedRomajiName < rhs.uppercasedRomajiName
            }
            
            return (lhs.score < rhs.score) == isAscendingSort
        })
    }
    
    private func sortByVersion(isAscendingSort: Bool, musicScoreDatas: MusicScoreDataCaches) {
        m_musicScoreDatas = MusicScoreDataCaches(musicScoreDatas.value.sorted { (lhs: MusicScoreData, rhs: MusicScoreData) -> Bool in
            if lhs.version == rhs.version {
                if lhs.id == rhs.id {
                    return lhs.difficulty.rawValue > rhs.difficulty.rawValue
                }
                
                return lhs.uppercasedRomajiName < rhs.uppercasedRomajiName
            }
            
            return (lhs.version.rawValue < rhs.version.rawValue) == isAscendingSort
        })
    }
    
    /**@brief   Sorts music data by music name that transformed to romaji. */
    private func sortByName(isAscendingSort: Bool, musicScoreDatas: MusicScoreDataCaches) {
        m_musicScoreDatas = MusicScoreDataCaches(musicScoreDatas.value.sorted { (lhs: MusicScoreData, rhs: MusicScoreData) -> Bool in
            if lhs.id == rhs.id {
                return lhs.difficulty.rawValue > rhs.difficulty.rawValue
            }
            
            return (lhs.uppercasedRomajiName < rhs.uppercasedRomajiName) == isAscendingSort
        })
    }
    
    /**@brief   Sorts music data by artist name that transformed to romaji. */
    private func sortByArtistName(isAscendingSort: Bool, musicScoreDatas: Box<[MusicScoreData]>) {
        m_musicScoreDatas = MusicScoreDataCaches(musicScoreDatas.value.sorted { (lhs: MusicScoreData, rhs: MusicScoreData) -> Bool in
            if lhs.id == rhs.id {
                return lhs.difficulty.rawValue > rhs.difficulty.rawValue
            }
            else {
                if lhs.uppercasedRomajiArtistName == rhs.uppercasedRomajiArtistName {
                    return (lhs.uppercasedRomajiName < rhs.uppercasedRomajiName) == isAscendingSort
                }
                else {
                    return (lhs.uppercasedRomajiArtistName < rhs.uppercasedRomajiArtistName) == isAscendingSort
                }
            }
        })
    }
}
