//
//  ProfileViewController.swift
//  jubiinfo
//
//  Created by ggomdyu on 13/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Foundation
import Material
import Motion

class ProfileViewController : ViewController, UIScrollViewDelegate {
/**@section Variable */
    @IBOutlet weak var m_scrollView: UIScrollView!
    @IBOutlet weak var m_profileView: CustomStackView!
    @IBOutlet weak var m_topEdgeView: UIView!
    @IBOutlet weak var m_bottomEdgeView: UIView!
    private var m_cachedWidgetView: [Int: WidgetView] = [:]
    private var m_optThemeChangeEventObserver: EventObserver?

/**@section Destructor */
    deinit {
        if let themeChangeEventObserver = m_optThemeChangeEventObserver {
            EventDispatcher.instance.unsubscribeEvent(eventType: "changeThemeComplete", eventObserver: themeChangeEventObserver)
            m_optThemeChangeEventObserver = nil
        }
    }
    
/**@section Method */
    public static func show(currentViewController: UIViewController) {
        let viewController = self.create()
        currentViewController.present(viewController, animated: true)
    }
    
    public static func create() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController

        let toolBarController = ProfileViewToolBarController(rootViewController: profileViewController, onEditComplete: profileViewController.onEditComplete)
        
        let navigationDrawerController = NavigationDrawerController(rootViewController: toolBarController, leftViewController: ProfileViewMenuController())
        navigationDrawerController.isHiddenStatusBarEnabled = false
        
        let snackBarController = SnackbarController(rootViewController: navigationDrawerController)
        snackBarController.isMotionEnabled = true
        snackBarController.motionTransitionType = .autoReverse(presenting: .push(direction: .left))
        snackBarController.modalPresentationStyle = .fullScreen
        
        return snackBarController
    }
    
    override func prepare() {
        super.prepare()
        
        self.requestMyPlayDataPageCache()
        self.requestMyRivalListPageCache()
        
        self.prepareUI()
        self.prepareEventObserver()
    }
    
    private func prepareUI() {
        m_cachedWidgetView.removeAll()
        
        m_scrollView.delegate = self
        m_scrollView.contentInsetAdjustmentBehavior = .never
        m_scrollView.insetsLayoutMarginsFromSafeArea = false
        
        m_topEdgeView.roundCorners(corners: [.topLeft, .topRight], radius: 11)
        m_bottomEdgeView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 11)
        
        self.prepareWidgetUI()
        self.prepareTheme()
    }
    
    private func prepareTheme() {
        m_scrollView.backgroundColor = getCurrentThemeColorTable().backgroundImageColor
        
        m_profileView.backgroundColor = getCurrentThemeColorTable().scrollViewBackgroundColor
        m_bottomEdgeView.backgroundColor = getCurrentThemeColorTable().scrollViewBackgroundColor
        m_topEdgeView.backgroundColor = getCurrentThemeColorTable().scrollViewBackgroundColor
    }
    
    private func prepareWidgetUI() {
        let activeWidgetList = SettingDataStorage.instance.getActiveWidgetList()

        let widgetCreatorDict: [WidgetType: () -> WidgetView] = [
            WidgetType.profile: { () in return self.createProfileWidgetView() },
            WidgetType.playData: { () in return self.createPlayDataWidgetView() },
            WidgetType.omikuji: { () in return self.createOmikujiWidgetView() },
            WidgetType.dailyRecommended: { () in return self.createDailyCallengeWidgetView() },
            WidgetType.rankDataGraphA: { () in return self.createRankDataGraphWidgetView() },
            WidgetType.gameCenterVisitHistory: { () in return self.createGameCenterVisitHistoryWidgetView() },
            WidgetType.newRecord: { () in return self.createNewRecordMusicWidgetView() }
        ]

        // Used to get request function that initialize the widget
        let widgetInitRequestFuncGetter = [
            "": { () -> Void in },
            "requestTopPageCacheComplete": { () -> Void in self.requestTopPageCache() },
            "requestMyRankDataPageCacheComplete": { () -> Void in self.requestMyRankDataPageCache() }
        ]
        var widgetInitEventNameBatch = Set<String>()
        
        m_profileView.addMargin(margin: 10.0)
        for activeWidget in activeWidgetList {
            guard let widgetCreator = widgetCreatorDict[activeWidget] else {
                continue
            }
            
            let widget = widgetCreator()
            
            // If the widget was not initialized, add a request into the batch.
            if widget.isNeedToLazyInitialize {
                widgetInitEventNameBatch.insert(widget.lazyInitializeEventName)
            }
            
            m_profileView.addMargin(margin: 10.0)
            m_profileView.addView(view: widget)
        }
        m_profileView.addMargin(margin: 20.0)
        
        for widgetInitEventName in widgetInitEventNameBatch {
            let widgetInitRequestFunc = widgetInitRequestFuncGetter[widgetInitEventName]
            widgetInitRequestFunc?()
        }
    }
    
    private func prepareEventObserver() {
        let themeChangeEventObserver = EventObserver(releaseAfterDispatch: false) { [weak self] (param: Any?) in
            self?.prepareTheme()
        }
        m_optThemeChangeEventObserver = themeChangeEventObserver
        
        EventDispatcher.instance.subscribeEvent(eventType: "changeThemeComplete", eventObserver: themeChangeEventObserver)
    }
    
    private func requestMyRivalListPageCache() {
        JubeatWebServer.requestMyRivalListPageCache { (isRequestSucceed: Bool, optHtml: String?, optRivalListPageCache: UserData.RivalListPageCache?) in
            
            if let html = optHtml {
                if html.range(of: "メンテナンス中") != nil {
                    showOkPopup(self, "오류", "현재 서버가 유지보수 중이므로 일부 기능을 이용할 수 없습니다.")
                }
            }
            
            let myUserData = DataStorage.instance.queryMyUserData();
            myUserData.rivalListPageCache = optRivalListPageCache
            
            runTaskInMainThread {
                EventDispatcher.instance.dispatchEvent(eventType: "requestMyRivalListPageCacheComplete", eventParam: optRivalListPageCache)
            }
        }
    }
    
    private func requestMyPlayDataPageCache() {
        JubeatWebServer.requestMyPlayDataPageCache { (isRequestSucceed: Bool, optMyPlayDataPageCache: UserData.MyPlayDataPageCache?) in
            guard let myPlayDataPageCache = optMyPlayDataPageCache else {
                return
            }
            
            let myUserData = DataStorage.instance.queryMyUserData()
            myUserData.rivalId = myPlayDataPageCache.rivalId
            myUserData.playDataPageCache = myPlayDataPageCache
            
            runTaskInMainThread {
                EventDispatcher.instance.dispatchEvent(eventType: "requestMyPlayDataPageCacheComplete", eventParam: myPlayDataPageCache)
            }
            
            self.requestMyMusicScoreData(serverMMSDChecksum: myPlayDataPageCache.playTuneCount)
        }
    }
    
    private func requestMyRankDataPageCache() {
        JubeatWebServer.requestMyRankDataPageCache { (isRequestSucceed: Bool, optMyRankDataPageCache: UserData.RankDataPageCache?) in
            guard let myRankDataPageCache = optMyRankDataPageCache else {
                return
            }
            
            DataStorage.instance.queryMyUserData().rankDataPageCache = myRankDataPageCache
            
            runTaskInMainThread {
                EventDispatcher.instance.dispatchEvent(eventType: "requestMyRankDataPageCacheComplete", eventParam: optMyRankDataPageCache)
            }
        }
    }
    
    private func requestMyMusicScoreData(serverMMSDChecksum: Int) {
        let isOldChecksum = JubeatWebServer.isMMSDChecksumOld(serverMMSDChecksum: serverMMSDChecksum)
        if isOldChecksum {
            runTaskInMainThread {
                self.showSnackbar(text: "음악 스코어 갱신 시작", showTime: 2.0)
            }
        }
        
        JubeatWebServer.requestMyMusicScoreData(serverMMSDChecksum: serverMMSDChecksum) { (isRequestSucceed: Bool, musicScoreDatas: Box<[MusicScoreData]>) in
            if isRequestSucceed {
                DataStorage.instance.queryMyUserData().musicScoreDataCaches = musicScoreDatas
                
                runTaskInMainThread {
                    EventDispatcher.instance.dispatchEvent(eventType: "requestMyMusicScoreDataComplete", eventParam: musicScoreDatas)
                    
                    if isOldChecksum {
                        self.showSnackbar(text: "음악 스코어 갱신 완료!", showTime: 2.0)
                    }
                }
            }
            else {
                if isOldChecksum {
                    runTaskInMainThread {
                        self.showSnackbar(text: "음악 스코어 갱신 실패", showTime: 2.0)
                    }
                }
            }
        }
    }
    
    private func requestTopPageCache() {
        JubeatWebServer.requestStartFullComboChallenge(onRequestComplete: { (isRequestSucceed: Bool) in
            if isRequestSucceed == false {
                return
            }
            
            JubeatWebServer.requestTopPageCache { (isRequestSucceed: Bool, topPageCache: UserData.TopPageCache?) in
                DataStorage.instance.queryMyUserData().topPageCache = topPageCache
                
                runTaskInMainThread {
                    EventDispatcher.instance.dispatchEvent(eventType: "requestTopPageCacheComplete", eventParam: topPageCache)
                }
            }
        })
    }
    
    private func createProfileWidgetView() -> WidgetView {
        var view: WidgetView! = m_cachedWidgetView[ProfileWidgetView.hash()]
        if view == nil {
            view = UINib(nibName: "ProfileWidgetView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? WidgetView
            view.initialize()
            
            m_cachedWidgetView[ProfileWidgetView.hash()] = view
        }
        return view
    }
    
    private func createPlayDataWidgetView() -> WidgetView {
        var view: WidgetView! = m_cachedWidgetView[PlayDataWidgetView.hash()]
        if view == nil {
            view = UINib(nibName: "PlayDataWidgetView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? WidgetView
            view.initialize()
            
            m_cachedWidgetView[PlayDataWidgetView.hash()] = view
        }
        return view
    }
    
    private func createRankDataGraphWidgetView() -> WidgetView {
        var view: WidgetView! = m_cachedWidgetView[RankDataGraphWidgetView.hash()]
        if view == nil {
            view = UINib(nibName: "RankDataGraphWidgetView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? WidgetView
            view.initialize()
            
            m_cachedWidgetView[RankDataGraphWidgetView.hash()] = view
        }
        return view
    }
    
    private func createOmikujiWidgetView() -> WidgetView {
        var view: WidgetView! = m_cachedWidgetView[OmikujiWidgetView.hash()]
        if view == nil {
            view = UINib(nibName: "OmikujiWidgetView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? WidgetView
            view.initialize()
            
            m_cachedWidgetView[OmikujiWidgetView.hash()] = view
        }
        return view
    }
    
    private func createDailyCallengeWidgetView() -> WidgetView {
        var view: WidgetView! = m_cachedWidgetView[DailyChallengeMusicWidgetView.hash()]
        if view == nil {
            view = UINib(nibName: "DailyChallengeMusicWidgetView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? WidgetView
            view.initialize()
            
            m_cachedWidgetView[DailyChallengeMusicWidgetView.hash()] = view
        }
        return view
    }
    
    private func createGameCenterVisitHistoryWidgetView() -> WidgetView {
        var view: WidgetView! = m_cachedWidgetView[GameCenterVisitHistoryWidgetView.hash()]
        if view == nil {
            view = UINib(nibName: "GameCenterVisitHistoryWidgetView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? WidgetView
            view.initialize()
            
            m_cachedWidgetView[GameCenterVisitHistoryWidgetView.hash()] = view
        }
        return view
    }
    
    private func createNewRecordMusicWidgetView() -> WidgetView {
        var view: WidgetView! = m_cachedWidgetView[NewRecordMusicWidgetView.hash()]
        if view == nil {
            view = UINib(nibName: "NewRecordMusicWidgetView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? WidgetView
            view.initialize()
            
            m_cachedWidgetView[NewRecordMusicWidgetView.hash()] = view
        }
        return view
    }
    
    private func showSnackbar(text: String, showTime: TimeInterval) {
        guard let snackbarController = getVisibleSnackbarController() else {
            return
        }
        
        snackbarController.snackbar.text = text

        snackbarController.animate(snackbar: .visible, delay: 0.0)
        snackbarController.animate(snackbar: .hidden, delay: showTime)
        
        snackbarController.view.endEditing(true)
    }
    
    private func getVisibleSnackbarController() -> SnackbarController? {
        guard var currPresentedViewController = self.presentedViewController else {
            return self.snackbarController
        }
        
        // Find the top-most presented view controller
        while true {
            guard let nextPresentedViewController = currPresentedViewController.presentedViewController else {
                break
            }
            
            currPresentedViewController = nextPresentedViewController
        }
        
        return currPresentedViewController.snackbarController
    }
    
/**@section Event handler */
    private func onEditComplete(isActiveWidgetChanged: Bool) {
        if isActiveWidgetChanged {
            m_profileView.resetStackView()
            m_scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
            
            self.prepareWidgetUI()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
}

public class ProfileViewToolBarController: ToolbarController {
/**@section Variable */
    private var m_toolBarColor = UIColor(red: 36 / 255, green: 75 / 255, blue: 67 / 255, alpha: 1)
    private var m_toolBarLabelColor = UIColor(red: 255 / 255, green: 253 / 255, blue: 228 / 255, alpha: 1)
    private var m_leftTabMenuButton: IconButton!
    private var m_rightTabSettingButton: IconButton!
    private var m_onEditComplete: ((Bool) -> Void)?
    private var m_optThemeChangeEventObserver: EventObserver?
    
/**@section Constructor */
    public init(rootViewController: UIViewController, onEditComplete: ((Bool) -> Void)?) {
        super.init(rootViewController: rootViewController)
        
        m_onEditComplete = onEditComplete
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
/**@section Destructor */
    deinit {
        if let themeChangeEventObserver = m_optThemeChangeEventObserver {
            EventDispatcher.instance.unsubscribeEvent(eventType: "changeThemeComplete", eventObserver: themeChangeEventObserver)
            m_optThemeChangeEventObserver = nil
        }
    }
    
/**@section Method */
    open override func prepare() {
        super.prepare()
        
        self.prepareUI()
        self.prepareEventObserver()
    }
    
    private func prepareUI() {
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
        toolbar.title = "프로필"
    }
    
    private func prepareToolbarLeftIcon() {
        m_leftTabMenuButton = IconButton(image: Icon.cm.menu)
        m_leftTabMenuButton.addTarget(self, action: #selector(onTouchMenuButton), for: .touchUpInside)
        toolbar.leftViews = [m_leftTabMenuButton]
    }
    
    private func prepareToolbarRightIcon() {
        m_rightTabSettingButton = IconButton(image: Icon.cm.settings)
        m_rightTabSettingButton.addTarget(self, action: #selector(onTouchEditButton), for: .touchUpInside)
        toolbar.rightViews = [m_rightTabSettingButton]
    }
    
    private func prepareTheme() {
        m_leftTabMenuButton.tintColor = getCurrentThemeColorTable().toolBarIconColor
        m_rightTabSettingButton.tintColor = getCurrentThemeColorTable().toolBarIconColor
        
        statusBar.backgroundColor = getCurrentThemeColorTable().toolBarBackgroundColor
        
        toolbar.titleLabel.textColor = getCurrentThemeColorTable().toolBarTitleLabelColor
        toolbar.backgroundColor = getCurrentThemeColorTable().toolBarBackgroundColor
    }
    
    private func prepareEventObserver() {
        let themeChangeEventObserver = EventObserver(releaseAfterDispatch: false) { [weak self] (param: Any?) in
            self?.prepareTheme()
        }
        m_optThemeChangeEventObserver = themeChangeEventObserver
        
        EventDispatcher.instance.subscribeEvent(eventType: "changeThemeComplete", eventObserver: themeChangeEventObserver)
    }
    
/**@section Event handler */
    @objc private func onTouchMenuButton() {
        navigationDrawerController?.toggleLeftView()
    }
    
    @objc private func onTouchEditButton() {
        ProfileViewEditController.show(currentViewController: navigationDrawerController!, onEditComplete: m_onEditComplete)
    }
}
