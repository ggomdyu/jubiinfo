//
//  MusicDataViewController.swift
//  jubiinfo
//
//  Created by ggomdyu on 15/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Material

public class MusicDataView : CustomStackView {
/**@section Property */
    public override var minViewHeight: CGFloat { return m_minStackViewHeight }
    
/**@section Variable */
    private var m_optMusicDataPageLoader: MusicScoreDataPageLoader?
    private var m_oldDivisionLineValue: Any = 0
    private var m_minStackViewHeight: CGFloat = 0.0
    
/**@section Method */
    public func initialize(musicScoreDatas: MusicScoreDataCaches, musicSortMode: MusicSortMode = MusicSortMode.level, musicSortOrder: MusicSortOrder, musicFilters: [MusicFilter] = []) {
        m_optMusicDataPageLoader = MusicScoreDataPageLoader(musicScoreDatas: musicScoreDatas, musicSortMode: musicSortMode, musicSortOrder: musicSortOrder, musicFilters: musicFilters)
        
        self.resetStackView()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let searchBarView = self.superview!.viewWithTag(1914)
        let searchBarViewHeight = (searchBarView != nil ? searchBarView!.frame.height : 69)
        m_minStackViewHeight = (self.superview!.superview!.frame.bounds.height - searchBarViewHeight) + 30
        
        self.refreshHeightConstraint()
    }
    
    public func sort(musicSortMode: MusicSortMode, musicSortOrder: MusicSortOrder) {
        m_optMusicDataPageLoader?.changeMusicSortMode(musicSortMode: musicSortMode, musicSortOrder: musicSortOrder)
    }
    
    public func loadMoreMusicDataCell() -> Bool {
        guard let musicDataPageLoader = m_optMusicDataPageLoader else {
            return false
        }
        
        let optMusicScoreDatas = musicDataPageLoader.loadNextPageCells()
        guard let musicScoreDatas = optMusicScoreDatas else {
            return false
        }
        
        for musicScoreData in musicScoreDatas {
            let createSectionDesc = self.getCreateMusicSectionDesc(musicScoreData: musicScoreData)
            if createSectionDesc.isNeedToCreate {
                self.addMusicSection(sectionText: createSectionDesc.sectionText!)
            }
            
            self.addMusicCell(musicScoreData: musicScoreData)
        }
        
        let isAllPageLoaded = musicDataPageLoader.isAllPageLoaded()
        if isAllPageLoaded {
            self.addMargin(margin: 15.0)
            return false
        }
        
        return true
    }
    
    private func getCreateMusicSectionDesc(musicScoreData: MusicScoreData) -> (isNeedToCreate: Bool, sectionText: String?) {
        guard let musicDataPageLoader = m_optMusicDataPageLoader else {
            return (false, nil)
        }
        
        switch musicDataPageLoader.getCurrentMusicSortMode() {
        case .name:
            let newDivisionLineValue = musicScoreData.uppercasedRomajiName.unicodeScalars.first!
            if newDivisionLineValue == (m_oldDivisionLineValue as? Unicode.Scalar) {
                return (false, nil)
            }
            
            m_oldDivisionLineValue = newDivisionLineValue
            return (true, String(newDivisionLineValue))
            
        case .level:
            let newDivisionLineValue = musicScoreData.level
            if newDivisionLineValue == (m_oldDivisionLineValue as? Int) {
                return (false, nil)
            }
            
            m_oldDivisionLineValue = newDivisionLineValue
            
            let isNewMusic = musicScoreData.isNewMusic
            if isNewMusic {
                return (true, "NEW")
            }
            else {
                let musicLevel = musicScoreData.level
                let sectionText = (musicLevel >= 90) ? String(Float(musicLevel) / 10) : String(musicLevel / 10)
                return (true, String(sectionText))
            }
            
        case .score:
            let newDivisionLineValue = musicScoreData.musicScoreRank
            if newDivisionLineValue == (m_oldDivisionLineValue as? MusicScoreRank) {
                return (false, nil)
            }
            
            m_oldDivisionLineValue = newDivisionLineValue
            
            return (true, newDivisionLineValue.toString())
            
        case .artist:
            let optNewDivisionLineValue = musicScoreData.uppercasedRomajiArtistName.unicodeScalars.first
            
            let newDivisionLineValue = (optNewDivisionLineValue != nil) ? optNewDivisionLineValue! : Unicode.Scalar(" ")!
            if newDivisionLineValue == (m_oldDivisionLineValue as? Unicode.Scalar) {
                return (false, nil)
            }
            
            m_oldDivisionLineValue = newDivisionLineValue
            
            return (true, optNewDivisionLineValue != nil ? String(optNewDivisionLineValue!) : String("Unknown artist"))
            
        case .version:
            let newDivisionLineValue = musicScoreData.version
            if newDivisionLineValue == (m_oldDivisionLineValue as? MusicVersion) {
                return (false, nil)
            }
            
            m_oldDivisionLineValue = newDivisionLineValue
            
            return (true, newDivisionLineValue.toString())
            
        default:
            return (false, nil)
        }
    }
    
    private func addMusicCell(musicScoreData: MusicScoreData) {
        let view = UINib(nibName: "MusicCellView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MusicCellView
        view.initialize(musicScoreData: musicScoreData)
        
        self.addView(view: view)
        self.addMargin(margin: 1.5)
    }
    
    private func addMusicSection(sectionText: String) {
        self.addMargin(margin: 15.0)
        
        let view = UINib(nibName: "SectionLineView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SectionLineView
        view.initialize(sectionText: sectionText)
        
        self.addView(view: view)
    }
    
    public override func resetStackView() {
        super.resetStackView()
        
        m_oldDivisionLineValue = 0
        m_optMusicDataPageLoader?.resetLoadedPage()
    }
    
    public func isAllPageLoaded() -> Bool {
        return m_optMusicDataPageLoader?.isAllPageLoaded() ?? false
    }
    
    public func getLoadedPageIndex() -> Int {
        return m_optMusicDataPageLoader!.getLoadedPageIndex()
    }
    
    public func getCurrentMusicSortMode() -> MusicSortMode {
        return m_optMusicDataPageLoader!.getCurrentMusicSortMode()
    }
    
    public func getCurrentMusicSortOrder() -> MusicSortOrder {
        return m_optMusicDataPageLoader!.getCurrentMusicSortOrder()
    }
    
    public func getMusicFilters() -> [MusicFilter] {
        return m_optMusicDataPageLoader!.getMusicFilters()
    }
    
    public func changeMusicSortMode(musicSortMode: MusicSortMode, musicSortOrder: MusicSortOrder) -> Void {
        self.resetStackView()
        
        m_optMusicDataPageLoader?.changeMusicSortMode(musicSortMode: musicSortMode, musicSortOrder: musicSortOrder)
        
        self.loadMoreMusicDataCell()
    }
    
    public func applyMusicFilter(musicFilters: [MusicFilter]) {
        self.resetStackView()
        
        m_optMusicDataPageLoader?.applyMusicFilter(musicFilters: musicFilters)
        
        self.loadMoreMusicDataCell()
    }
}
