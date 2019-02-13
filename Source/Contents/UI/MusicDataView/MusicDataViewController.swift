//
//  MusicDataViewController.swift
//  jubiinfo
//
//  Created by 차준호 on 12/01/2019.
//  Copyright © 2019 차준호. All rights reserved.
//

import Foundation
import UIKit
import Material

public class MusicDataViewController : ViewController, UIScrollViewDelegate, UISearchBarDelegate {
/**@section Variable */
    @IBOutlet weak var m_scrollView: UIScrollView!
    @IBOutlet weak var m_musicDataView: MusicDataView!
    @IBOutlet var m_musicDataViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var m_musicDataSearchResultView: MusicDataView!
    @IBOutlet var m_musicDataSearchResultViewBottomConstraint: NSLayoutConstraint!
    private var m_optCurrActiveMusicDataView: MusicDataView?
    private var m_optCurrActiveMusicDataViewBottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var m_bottomBackgroundHiderView: UIView!
    @IBOutlet weak var m_searchBar: UISearchBar!
    private var m_searchBarXButton: UIButton!
    private var m_lastSearchedMusicName: String?
    private var m_isDeleteKeyEntered = false
    private var m_optScrollDetectTimer: Timer?
    
/**@section Method */
    public static func show(currentViewController: UIViewController, musicId: MusicId) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let musicDataViewController = storyboard.instantiateViewController(withIdentifier: "MusicDataViewController") as! MusicDataViewController
        let toolBarController = MusicDataViewToolBarController(rootViewController: musicDataViewController, onChangeMusicSortMode: musicDataViewController.onChangeMusicSortMode)
        let navigationDrawerController = NavigationDrawerController(rootViewController: toolBarController)
        
        navigationDrawerController.isMotionEnabled = true
        navigationDrawerController.motionTransitionType = .autoReverse(presenting: .push(direction: .left))
        
        musicDataViewController.initialize(musicId: musicId)
        
        currentViewController.present(navigationDrawerController, animated: true)
    }
    
    public static func show(currentViewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let musicDataViewController = storyboard.instantiateViewController(withIdentifier: "MusicDataViewController") as! MusicDataViewController
        let toolBarController = MusicDataViewToolBarController(rootViewController: musicDataViewController, onChangeMusicSortMode: musicDataViewController.onChangeMusicSortMode)
        let navigationDrawerController = NavigationDrawerController(rootViewController: toolBarController)
        
        navigationDrawerController.isMotionEnabled = true
        navigationDrawerController.motionTransitionType = .autoReverse(presenting: .push(direction: .left))
        
        musicDataViewController.initialize()
        
        currentViewController.present(navigationDrawerController, animated: true)
    }
    
    public func initialize() {
        self.prepareScrollView()
        self.prepareSearchBar()
        
        m_musicDataSearchResultViewBottomConstraint.isActive = false
        
        m_musicDataView.initialize(musicScoreDatas: GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches, musicSortMode: .Level, musicSortOrder: .Descending)
        m_musicDataView.loadMoreMusicDataCell()
        
        self.switchActiveMusicDataView(viewToActivate: m_musicDataView, viewBottomConstraint: m_musicDataViewBottomConstraint)
    }
    
    public func initialize(musicId: MusicId) {
        self.prepareScrollView()
        self.prepareSearchBar()
        
        // Initialize MusicDataView
        m_musicDataSearchResultViewBottomConstraint.isActive = false
        
        m_musicDataView.initialize(musicScoreDatas: GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches, musicSortMode: .Level, musicSortOrder: .Descending)
        
        self.switchActiveMusicDataView(viewToActivate: m_musicDataView, viewBottomConstraint: m_musicDataViewBottomConstraint)
        
        // Initialize MusicDataSearchResultView
        let musicScoreDatas = GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches
        if let musicScoreData = musicScoreDatas.value.first(where: { (item: MusicScoreData) -> Bool in
            return item.id == musicId
        }) {
            m_searchBar.text = musicScoreData.name
        }
        
        self.searchMusicById(musicId: musicId)
    }
    
    private func prepareScrollView() {
        m_scrollView.backgroundColor = UIColor(patternImage: UIImage(named:"background.jpg")!)
        m_scrollView.delegate = self
    }
    
    private func prepareSearchBar() {
        m_searchBar.delegate = self
    }
    
    private func switchActiveMusicDataView(viewToActivate: MusicDataView, viewBottomConstraint: NSLayoutConstraint?) {
        m_optCurrActiveMusicDataView?.isHidden = true
        m_optCurrActiveMusicDataViewBottomConstraint?.isActive = false
        
        viewToActivate.isHidden = false
        viewBottomConstraint?.isActive = true
        
        m_optCurrActiveMusicDataView = viewToActivate
        m_optCurrActiveMusicDataViewBottomConstraint = viewBottomConstraint
    }
    
    private func loadMoreMusicDataCell() {
        let isAllPageLoaded = !(m_optCurrActiveMusicDataView?.loadMoreMusicDataCell() ?? true)
        if isAllPageLoaded {
            m_bottomBackgroundHiderView.isHidden = true
        }
        else {
            m_bottomBackgroundHiderView.isHidden = false
        }
    }
    
    public func getCurrActiveMusicDataView() -> MusicDataView? {
        return m_optCurrActiveMusicDataView
    }
    
    private func searchMusicByName(musicName: String) {
        // If text field is empty, then return to initial view.
        if musicName.isEmpty {
            self.switchActiveMusicDataView(viewToActivate: m_musicDataView, viewBottomConstraint: m_musicDataViewBottomConstraint)
            return
        }
        
        let currActiveMusicDataView = m_musicDataSearchResultView!
        self.switchActiveMusicDataView(viewToActivate: currActiveMusicDataView, viewBottomConstraint: m_musicDataSearchResultViewBottomConstraint)
        
        let searchBarText = transformJapaneseToLatin(sourceStr: musicName).uppercased()
        currActiveMusicDataView.initialize(musicScoreDatas: Box<[MusicScoreData]>(GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches.value.filter({ (item: MusicScoreData) -> Bool in
            return item.uppercasedRomajiName.contains(searchBarText)
        })), musicSortMode: m_musicDataView!.getCurrentMusicSortMode(), musicSortOrder: m_musicDataView!.getCurrentMusicSortOrder())
        
        self.loadMoreMusicDataCell()
    }
    
    private func searchMusicById(musicId: MusicId) {
        let currActiveMusicDataView = m_musicDataSearchResultView!
        self.switchActiveMusicDataView(viewToActivate: currActiveMusicDataView, viewBottomConstraint: m_musicDataSearchResultViewBottomConstraint)
        
        currActiveMusicDataView.initialize(musicScoreDatas: Box<[MusicScoreData]>(GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches.value.filter({ (item: MusicScoreData) -> Bool in
            return item.id == musicId
        })), musicSortMode: m_musicDataView!.getCurrentMusicSortMode(), musicSortOrder: m_musicDataView!.getCurrentMusicSortOrder())
        
        self.loadMoreMusicDataCell()
    }
    
/**@section Event handler */
    public func onChangeMusicSortMode(musicSortMode: MusicSortMode, musicSortOrder: MusicSortOrder) -> Void {
        m_scrollView.setContentOffset(CGPoint.zero, animated: false)
        
        m_optCurrActiveMusicDataView?.onChangeMusicSortMode(musicSortMode: musicSortMode, musicSortOrder: musicSortOrder)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        if m_lastSearchedMusicName == searchBar.text {
            return
        }
        
        m_lastSearchedMusicName = searchBar.text
        
        self.searchMusicByName(musicName: searchBar.text ?? "")
    }
    
    public func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        m_isDeleteKeyEntered = text.isEmpty
        return true
    }
    
    private func onClearTextInSearchBar() {
        m_lastSearchedMusicName?.removeAll()
        
        let currActiveMusicDataView = m_optCurrActiveMusicDataView!
        let prevActiveMusicDataViewSortMode = currActiveMusicDataView.getCurrentMusicSortMode()
        let prevActiveMusicDataViewSortOrder = currActiveMusicDataView.getCurrentMusicSortOrder()
        
        self.switchActiveMusicDataView(viewToActivate: m_musicDataView, viewBottomConstraint: m_musicDataViewBottomConstraint)
        
        if (prevActiveMusicDataViewSortMode != m_musicDataView.getCurrentMusicSortMode()) ||
           (prevActiveMusicDataViewSortOrder != m_musicDataView.getCurrentMusicSortOrder() ||
            m_musicDataView.getLoadedPageIndex() == 0) {
            m_musicDataView.initialize(musicScoreDatas: GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches, musicSortMode: prevActiveMusicDataViewSortMode, musicSortOrder: prevActiveMusicDataViewSortOrder)
            
            m_musicDataView.loadMoreMusicDataCell()
        }
        
        m_searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.0)
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let isXButtonClicked = searchText.isEmpty && !m_isDeleteKeyEntered
        if isXButtonClicked {
            self.onClearTextInSearchBar()
        }
        
        m_isDeleteKeyEntered = false
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if m_optScrollDetectTimer != nil || m_optCurrActiveMusicDataView?.isAllPageLoaded() ?? true {
            return
        }
        
        let scrollDetectTimer = Timer(timeInterval: 0.05, target: self, selector: #selector(self.onDraggingScrollView), userInfo: nil, repeats: true)
        m_optScrollDetectTimer = scrollDetectTimer
        
        RunLoop.main.add(scrollDetectTimer, forMode: RunLoop.Mode.common)
    }
    
    @objc private func onDraggingScrollView() {
        let currentOffset = m_scrollView.contentOffset.y
        let maximumOffset = m_scrollView.contentSize.height - m_scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 1000.0 {
            self.loadMoreMusicDataCell()
        }
        
        if m_scrollView.isDragging == false {
            m_optScrollDetectTimer?.invalidate()
            m_optScrollDetectTimer = nil
        }
    }
}
