//
//  MusicDataViewController.swift
//  jubiinfo
//
//  Created by ggomdyu on 12/01/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
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
    @IBOutlet weak var m_topEdgeView: UIView!
    @IBOutlet weak var m_bottomEdgeView: UIView!
    @IBOutlet weak var m_bottomBackgroundHiderView: UIView!
    @IBOutlet weak var m_searchBarView: UIView!
    @IBOutlet weak var m_searchBar: UISearchBar!
    private var m_lastSearchedMusicName: String?
    private var m_isDeleteKeyEntered = false
    private var m_optScrollDetectTimer: Timer?
    private var m_optNetworkPendingIndicatorView: UIView?
    
/**@section Method */
    public static func show(currentViewController: UIViewController) {
        let controller = self.create()
        currentViewController.present(controller, animated: true)
        
        let viewController = ((controller.rootViewController as! NavigationDrawerController).rootViewController as! ToolbarController).rootViewController as! MusicDataViewController
        viewController.initialize()
    }
    
    public static func show(currentViewController: UIViewController, musicId: MusicId) {
        let controller = self.create()
        currentViewController.present(controller, animated: true)
        
        let viewController = ((controller.rootViewController as! NavigationDrawerController).rootViewController as! ToolbarController).rootViewController as! MusicDataViewController
        viewController.initialize(musicId: musicId)
    }
    
    private static func create() -> TransitionController  {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let musicDataViewController = storyboard.instantiateViewController(withIdentifier: "MusicDataViewController") as! MusicDataViewController
        
        let toolBarController = MusicDataViewToolBarController(rootViewController: musicDataViewController)
        
        let navigationDrawerController = NavigationDrawerController(rootViewController: toolBarController)
        navigationDrawerController.isHiddenStatusBarEnabled = false
        
        let snackbarController = SnackbarController(rootViewController: navigationDrawerController)
        snackbarController.motionTransitionType = .autoReverse(presenting: .push(direction: .left))
        snackbarController.isMotionEnabled = true
        snackbarController.modalPresentationStyle = .fullScreen
        
        return snackbarController
    }
    
    public func initialize() {
        self.prepareUI()
        
        m_musicDataSearchResultViewBottomConstraint.isActive = false
        
        let musicScoreDataCaches = DataStorage.instance.queryMyUserData().musicScoreDataCaches
        if musicScoreDataCaches.value.count <= 0 {
            EventDispatcher.instance.subscribeEvent(eventType: "requestMyMusicScoreDataComplete", eventObserver: EventObserver(releaseAfterDispatch: true) { [weak self] (param: Any?) -> Void in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.lazyInitialize()
                strongSelf.disableTouchBlockForLoading()
            })
            
            self.enableTouchBlockLoading()
        }
        else {
            self.lazyInitialize()
        }
    }
    
    public func initialize(musicId: MusicId) {
        self.prepareUI()
        
        m_musicDataSearchResultViewBottomConstraint.isActive = false
        
        let musicScoreDataCaches = DataStorage.instance.queryMyUserData().musicScoreDataCaches
        if musicScoreDataCaches.value.count <= 0 {
            EventDispatcher.instance.subscribeEvent(eventType: "requestMyMusicScoreDataComplete", eventObserver: EventObserver(releaseAfterDispatch: true) { [weak self] (param: Any?) -> Void in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.lazyInitialize(musicId: musicId)
                strongSelf.disableTouchBlockForLoading()
            })
            
            self.enableTouchBlockLoading()
        }
        else {
            self.lazyInitialize(musicId: musicId)
        }
    }
    
    private func lazyInitialize() {
        let musicScoreDataCaches = DataStorage.instance.queryMyUserData().musicScoreDataCaches
        
        m_musicDataView.initialize(musicScoreDatas: musicScoreDataCaches, musicSortMode: .level, musicSortOrder: .descending)
        m_musicDataView.loadMoreMusicDataCell()
        
        self.switchActiveMusicDataView(viewToActivate: m_musicDataView, viewBottomConstraint: m_musicDataViewBottomConstraint)
    }
    
    private func lazyInitialize(musicId: MusicId) {
        let musicScoreDataCaches = DataStorage.instance.queryMyUserData().musicScoreDataCaches
        // TODO: Optimize this code
        m_musicDataView.initialize(musicScoreDatas: musicScoreDataCaches, musicSortMode: .level, musicSortOrder: .descending)
        
        self.switchActiveMusicDataView(viewToActivate: m_musicDataView, viewBottomConstraint: m_musicDataViewBottomConstraint)
        
        // Initialize MusicDataSearchResultView
        if let musicScoreData = musicScoreDataCaches.value.first(where: { (item: MusicScoreData) -> Bool in
            return item.id == musicId
        }) {
            m_searchBar.text = musicScoreData.name
        }
        
        self.searchMusicById(musicId: musicId)
    }
    
    private func prepareUI() {
        m_topEdgeView.roundCorners(corners: [.topLeft, .topRight], radius: 11)
        m_bottomEdgeView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 11)
        
        self.prepareScrollView()
        self.prepareSearchBar()
        self.prepareTheme()
    }
    
    private func prepareScrollView() {
        m_scrollView.delegate = self
        m_scrollView.contentInsetAdjustmentBehavior = .never
        m_scrollView.insetsLayoutMarginsFromSafeArea = false
    }
    
    private func enableTouchBlockLoading() {
        let loadingIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 51, width: 100, height: 100))
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.style = .gray
        loadingIndicatorView.startAnimating();
        loadingIndicatorView.center = self.view.center
        loadingIndicatorView.center.y -= self.m_searchBar.frame.height
        
        m_musicDataView.addSubview(loadingIndicatorView)
        
        m_searchBar.isUserInteractionEnabled = false
        if let toolBar = self.toolbarController?.toolbar {
            for toolBarIcon in toolBar.rightViews {
                toolBarIcon.isUserInteractionEnabled = false
            }
        }
        
        m_optNetworkPendingIndicatorView = loadingIndicatorView
    }
    
    private func disableTouchBlockForLoading() {
        if let networkPendingIndicatorView = m_optNetworkPendingIndicatorView {
            networkPendingIndicatorView.removeFromSuperview()
            m_optNetworkPendingIndicatorView = nil
        }
        
        m_searchBar.isUserInteractionEnabled = true
        if let toolBar = self.toolbarController?.toolbar {
            for toolBarIcon in toolBar.rightViews {
                toolBarIcon.isUserInteractionEnabled = true
            }
        }
    }
    
    private func prepareSearchBar() {
        m_searchBar.delegate = self
    }
    
    private func prepareTheme() {
        m_scrollView.backgroundColor = getCurrentThemeColorTable().backgroundImageColor
        
        m_musicDataView.backgroundColor = getCurrentThemeColorTable().scrollViewBackgroundColor
        m_musicDataSearchResultView.backgroundColor = getCurrentThemeColorTable().scrollViewBackgroundColor
        
        m_searchBarView.backgroundColor = getCurrentThemeColorTable().scrollViewBackgroundColor
        
        m_topEdgeView.backgroundColor = getCurrentThemeColorTable().scrollViewBackgroundColor
        m_bottomEdgeView.backgroundColor = getCurrentThemeColorTable().scrollViewBackgroundColor
        m_bottomBackgroundHiderView.backgroundColor = getCurrentThemeColorTable().scrollViewBackgroundColor
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
        currActiveMusicDataView.initialize(musicScoreDatas: MusicScoreDataCaches(DataStorage.instance.queryMyUserData().musicScoreDataCaches.value.filter({ (item: MusicScoreData) -> Bool in
            return item.uppercasedRomajiName.contains(searchBarText)
        })), musicSortMode: m_musicDataView!.getCurrentMusicSortMode(), musicSortOrder: m_musicDataView!.getCurrentMusicSortOrder(), musicFilters: m_musicDataView!.getMusicFilters())
        
        self.loadMoreMusicDataCell()
    }
    
    private func searchMusicById(musicId: MusicId) {
        let currActiveMusicDataView = m_musicDataSearchResultView!
        self.switchActiveMusicDataView(viewToActivate: currActiveMusicDataView, viewBottomConstraint: m_musicDataSearchResultViewBottomConstraint)
        
        currActiveMusicDataView.initialize(musicScoreDatas: MusicScoreDataCaches(DataStorage.instance.queryMyUserData().musicScoreDataCaches.value.filter({ (item: MusicScoreData) -> Bool in
            return item.id == musicId
        })), musicSortMode: m_musicDataView!.getCurrentMusicSortMode(), musicSortOrder: m_musicDataView!.getCurrentMusicSortOrder())
        
        self.loadMoreMusicDataCell()
    }
    
/**@section Event handler */
    public func onChangeMusicSortMode(musicSortMode: MusicSortMode, musicSortOrder: MusicSortOrder) -> Void {
        guard let currActiveMusicDataView = m_optCurrActiveMusicDataView else {
            return
        }
        
        let isSortModeChanged = (musicSortMode != currActiveMusicDataView.getCurrentMusicSortMode()) || (musicSortOrder != currActiveMusicDataView.getCurrentMusicSortOrder())
        if isSortModeChanged {
            m_scrollView.setContentOffset(CGPoint.zero, animated: false)
            
            currActiveMusicDataView.changeMusicSortMode(musicSortMode: musicSortMode, musicSortOrder: musicSortOrder)
        }
    }
    
    public func onApplyMusicFilter(musicFilters: [MusicFilter]) {
        m_scrollView.setContentOffset(CGPoint.zero, animated: false)
        
        m_musicDataView.applyMusicFilter(musicFilters: musicFilters)
        m_musicDataSearchResultView.applyMusicFilter(musicFilters: musicFilters)
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
        let prevActiveMusicDataViewFilters = currActiveMusicDataView.getMusicFilters()
        
        self.switchActiveMusicDataView(viewToActivate: m_musicDataView, viewBottomConstraint: m_musicDataViewBottomConstraint)
        
        if (prevActiveMusicDataViewSortMode != m_musicDataView.getCurrentMusicSortMode()) ||
           (prevActiveMusicDataViewSortOrder != m_musicDataView.getCurrentMusicSortOrder() ||
            m_musicDataView.getLoadedPageIndex() == 0 ||
            prevActiveMusicDataViewFilters.count > 0) {
            m_musicDataView.initialize(musicScoreDatas: DataStorage.instance.queryMyUserData().musicScoreDataCaches, musicSortMode: prevActiveMusicDataViewSortMode, musicSortOrder: prevActiveMusicDataViewSortOrder, musicFilters: prevActiveMusicDataViewFilters)
            
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
        UIMenuController.shared.setMenuVisible(false, animated: true)
        
        if m_optScrollDetectTimer != nil || m_optCurrActiveMusicDataView?.isAllPageLoaded() ?? true {
            return
        }
        
        // Set a timer to detect scroll position each frame, so that we can load the next music data page while scrolling.
        let scrollDetectTimer = Timer(timeInterval: 0.05, target: self, selector: #selector(self.onDraggingScrollView), userInfo: nil, repeats: true)
        m_optScrollDetectTimer = scrollDetectTimer
        RunLoop.main.add(scrollDetectTimer, forMode: RunLoop.Mode.common)
    }
    
    @objc private func onDraggingScrollView() {
        let currentOffset = m_scrollView.contentOffset.y
        let maximumOffset = m_scrollView.contentSize.height - m_scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 500.0 {
            self.loadMoreMusicDataCell()
        }
        
        if m_scrollView.isDragging == false {
            m_optScrollDetectTimer?.invalidate()
            m_optScrollDetectTimer = nil
        }
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
}

public class MusicDataViewToolBarController: ToolbarController {
/**@section Variable */
    private var m_leftTabPrevButton: IconButton!
    private var m_rightTabSortButton: IconButton!
    private var m_rightTabFilterButton: IconButton!
    private let m_sortIconImage = UIImage(named: "ic_sort_white")!.withRenderingMode(.alwaysTemplate)
    private let m_filterEnabledIconImage = UIImage(named: "ic_filter_white")!.withRenderingMode(.alwaysTemplate)
    private let m_filterDisabledIconImage = UIImage(named: "ic_filter2_white")!.withRenderingMode(.alwaysTemplate)
    private var m_isFilterActive = false
    
/**@section Method */
    open override func prepare() {
        super.prepare()
        
        self.prepareStatusBar()
        
        self.prepareToolbarTitle()
        self.prepareToolbarLeftIcon()
        self.prepareToolbarRightIcon()
        
        self.prepareTheme()
    }
    
    private func prepareStatusBar() {
        statusBarStyle = .lightContent
    }
    
    private func prepareToolbarTitle() {
        toolbar.title = "음악 데이터"
    }
    
    private func prepareToolbarLeftIcon() {
        m_leftTabPrevButton = IconButton(image: Icon.cm.arrowBack)
        m_leftTabPrevButton.addTarget(self, action: #selector(onTouchPrevButton), for: .touchUpInside)
        toolbar.leftViews = [m_leftTabPrevButton]
    }
    
    private func prepareToolbarRightIcon() {
        m_rightTabFilterButton = IconButton(image: m_filterDisabledIconImage)
        m_rightTabFilterButton.addTarget(self, action: #selector(onTouchFilterButton), for: .touchUpInside)

        m_rightTabSortButton = IconButton(image: m_sortIconImage)
        m_rightTabSortButton.addTarget(self, action: #selector(onTouchSortButton), for: .touchUpInside)

        toolbar.rightViews = [m_rightTabFilterButton, m_rightTabSortButton]
        
        toolbar.interimSpace = -18.0
    }
    
    private func prepareTheme() {
        statusBar.backgroundColor = getCurrentThemeColorTable().toolBarBackgroundColor
        
        toolbar.titleLabel.textColor = getCurrentThemeColorTable().toolBarTitleLabelColor
        toolbar.backgroundColor = getCurrentThemeColorTable().toolBarBackgroundColor
        
        m_leftTabPrevButton.tintColor = getCurrentThemeColorTable().toolBarIconColor
        
        m_rightTabFilterButton.tintColor = getCurrentThemeColorTable().toolBarIconColor
        m_rightTabSortButton.tintColor = getCurrentThemeColorTable().toolBarIconColor
    }

/**@section Event handler */
    @objc private func onTouchPrevButton() {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }
    
    @objc private func onTouchFilterButton() {
        self.view.endEditing(true)
        
        if m_isFilterActive {
            guard let parentViewController = self.rootViewController as? MusicDataViewController else {
                return
            }
            
            parentViewController.onApplyMusicFilter(musicFilters: [])
            
            m_rightTabFilterButton.image = m_filterDisabledIconImage
            
            self.m_isFilterActive = false
        }
        else {
            MusicFilterViewController.show(currentViewController: self) {
                musicFilters in
                guard let parentViewController = self.rootViewController as? MusicDataViewController else {
                    return
                }
                
                parentViewController.onApplyMusicFilter(musicFilters: musicFilters)
                
                self.m_rightTabFilterButton.image = self.m_filterEnabledIconImage
                
                self.m_isFilterActive = true
            }
        }
    }
    
    @objc private func onTouchSortButton() {
        self.view.endEditing(true)
        
        let musicDataViewController = self.rootViewController as! MusicDataViewController
        let optCurrActivatedMusicDataView = musicDataViewController.getCurrActiveMusicDataView()
        guard let currActivatedMusicDataView = optCurrActivatedMusicDataView else {
            return
        }
        
        MusicSortModeViewController.show(currentViewController: self, currMusicSortMode: currActivatedMusicDataView.getCurrentMusicSortMode(), currMusicSortOrder: currActivatedMusicDataView.getCurrentMusicSortOrder()) {
            musicSortMode, musicSortOrder in
            guard let parentViewController = self.rootViewController as? MusicDataViewController else {
                return
            }
            
            parentViewController.onChangeMusicSortMode(musicSortMode: musicSortMode, musicSortOrder: musicSortOrder)
        }
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
}
