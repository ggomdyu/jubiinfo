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
        self.prepareUI()
        
        m_musicDataSearchResultViewBottomConstraint.isActive = false
        
        let musicScoreDataCaches = GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches
        if musicScoreDataCaches.value.count <= 0 {
            EventDispatcher.instance.subscribeEvent(eventType: "requestMyMusicScoreDataComplete", eventObserver: EventObserver(releaseAfterDispatch: true) { [weak self] (param: Any?) -> Void in
                self?.lazyInitialize()
            })
            return
        }
        else {
            self.lazyInitialize()
        }
        
        showLoadingSpinnerUI(self)
    }
    
    private func lazyInitialize() {
        let musicScoreDataCaches = GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches
        
        m_musicDataView.initialize(musicScoreDatas: musicScoreDataCaches, musicSortMode: .Level, musicSortOrder: .Descending)
        m_musicDataView.loadMoreMusicDataCell()
        
        self.switchActiveMusicDataView(viewToActivate: m_musicDataView, viewBottomConstraint: m_musicDataViewBottomConstraint)
    }
    
    public func initialize(musicId: MusicId) {
        self.prepareUI()
        
        // Initialize MusicDataView
        m_musicDataSearchResultViewBottomConstraint.isActive = false
        
        let musicScoreDataCaches = GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches
        // TODO: Optimize this code
        m_musicDataView.initialize(musicScoreDatas: musicScoreDataCaches, musicSortMode: .Level, musicSortOrder: .Descending)
        
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
        self.prepareScrollView()
        self.prepareSearchBar()
        self.prepareTheme()
    }
    
    private func prepareScrollView() {
        m_scrollView.delegate = self
    }
    
    private func prepareSearchBar() {
        m_searchBar.delegate = self
    }
    
    private func prepareTheme() {
        m_scrollView.backgroundColor = getCurrentThemeColorTable().backgroundImage
        
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
        currActiveMusicDataView.initialize(musicScoreDatas: MusicScoreDataCaches(GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches.value.filter({ (item: MusicScoreData) -> Bool in
            return item.uppercasedRomajiName.contains(searchBarText)
        })), musicSortMode: m_musicDataView!.getCurrentMusicSortMode(), musicSortOrder: m_musicDataView!.getCurrentMusicSortOrder())
        
        self.loadMoreMusicDataCell()
    }
    
    private func searchMusicById(musicId: MusicId) {
        let currActiveMusicDataView = m_musicDataSearchResultView!
        self.switchActiveMusicDataView(viewToActivate: currActiveMusicDataView, viewBottomConstraint: m_musicDataSearchResultViewBottomConstraint)
        
        currActiveMusicDataView.initialize(musicScoreDatas: MusicScoreDataCaches(GlobalDataStorage.instance.queryMyUserData().musicScoreDataCaches.value.filter({ (item: MusicScoreData) -> Bool in
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
            
            m_optCurrActiveMusicDataView?.onChangeMusicSortMode(musicSortMode: musicSortMode, musicSortOrder: musicSortOrder)
        }
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
        
        if maximumOffset - currentOffset <= 500.0 {
            self.loadMoreMusicDataCell()
        }
        
        if m_scrollView.isDragging == false {
            m_optScrollDetectTimer?.invalidate()
            m_optScrollDetectTimer = nil
        }
    }
}

public class MusicDataViewToolBarController: ToolbarController {
/**@section Variable */
    private let m_toolBarColor = UIColor(red: 36 / 255, green: 75 / 255, blue: 67 / 255, alpha: 1)
    private let m_toolBarLabelColor = UIColor(red: 255 / 255, green: 253 / 255, blue: 228 / 255, alpha: 1)
    private var m_leftTabPrevButton: IconButton!
    private var m_rightTabSortButton: IconButton!
//    private var m_rightTabFilterButton: IconButton!
    private var m_onChangeMusicSortMode: ((MusicSortMode, MusicSortOrder) -> Void)?
    
/**@section Constructor */
    public convenience init(rootViewController: UIViewController, onChangeMusicSortMode: @escaping (MusicSortMode, MusicSortOrder) -> ()) {
        self.init(rootViewController: rootViewController)
        
        m_onChangeMusicSortMode = onChangeMusicSortMode
    }
    
    private override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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
//        m_rightTabFilterButton = IconButton(image: UIImage(named: "ic_filter_white"))
//        m_rightTabFilterButton.addTarget(self, action: #selector(onTouchFilterButton), for: .touchUpInside)
        
        m_rightTabSortButton = IconButton(image: UIImage(named: "ic_sort_white")!.withRenderingMode(.alwaysTemplate))

        m_rightTabSortButton.addTarget(self, action: #selector(onTouchSortButton), for: .touchUpInside)
        //rightTabFilterButton,
        toolbar.rightViews = [m_rightTabSortButton]
        //        toolbar.interimSpace = -23.0
    }
    
    private func prepareTheme() {
        statusBar.backgroundColor = getCurrentThemeColorTable().toolBarBackgroundColor
        
        toolbar.titleLabel.textColor = getCurrentThemeColorTable().toolBarTitleLabelColor
        toolbar.backgroundColor = getCurrentThemeColorTable().toolBarBackgroundColor
        
        m_leftTabPrevButton.tintColor = getCurrentThemeColorTable().toolBarIconColor
//        m_rightTabFilterButton.tintColor = UIColor.white
        m_rightTabSortButton.tintColor = getCurrentThemeColorTable().toolBarIconColor
    }

/**@section Event handler */
    @objc private func onTouchPrevButton() {
        self.dismiss(animated: true)
    }
    
    @objc private func onTouchFilterButton() {
        MusicFilterViewController.show(currentViewController: self)
    }
    
    @objc private func onTouchSortButton() {
        let musicDataViewController = self.rootViewController as! MusicDataViewController
        let optCurrActivatedMusicDataView = musicDataViewController.getCurrActiveMusicDataView()
        guard let currActivatedMusicDataView = optCurrActivatedMusicDataView else {
            return
        }
        
        MusicSortModeViewController.show(currentViewController: self, currMusicSortMode: currActivatedMusicDataView.getCurrentMusicSortMode(), currMusicSortOrder: currActivatedMusicDataView.getCurrentMusicSortOrder(), onChangeMusicSortMode: m_onChangeMusicSortMode!)
    }
}
