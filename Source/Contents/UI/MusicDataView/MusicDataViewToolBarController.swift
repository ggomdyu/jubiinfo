//
//  MusicDataViewToolBarController.swift
//  jubiinfo
//
//  Created by ggomdyu on 15/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Material

public class MusicDataViewToolBarController: ToolbarController {
/**@section Variable */
    private let m_toolBarColor = UIColor(red: 36 / 255, green: 75 / 255, blue: 67 / 255, alpha: 1)
    private let m_toolBarLabelColor = UIColor(red: 255 / 255, green: 253 / 255, blue: 228 / 255, alpha: 1)
    private var m_leftTabPrevButton: IconButton!
    private var m_rightTabMoreButton: IconButton!
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
    
/**@section Overrided method */
    open override func prepare() {
        super.prepare()
        
        self.prepareStatusBar()
        self.prepareToolbar()
    }

/**@section Method */
    private func prepareStatusBar() {
        statusBarStyle = .lightContent
        statusBar.backgroundColor = m_toolBarColor
    }
    
    private func prepareToolbar() {
        self.prepareToolbarTitle()
        self.prepareToolbarLeftIcon()
        self.prepareToolbarRightIcon()
    }
    
    private func prepareToolbarTitle() {
        toolbar.title = "음악 데이터"
        toolbar.titleLabel.textColor = m_toolBarLabelColor
        toolbar.backgroundColor = m_toolBarColor
    }
    
    private func prepareToolbarLeftIcon() {
        m_leftTabPrevButton = IconButton(image: Icon.cm.arrowBack)
        m_leftTabPrevButton.tintColor = UIColor.white
        m_leftTabPrevButton.addTarget(self, action: #selector(onTouchPrevButton), for: .touchUpInside)
        toolbar.leftViews = [m_leftTabPrevButton]
    }
    
    private func prepareToolbarRightIcon() {
        m_rightTabMoreButton = IconButton(image: Icon.cm.menu)
        m_rightTabMoreButton.tintColor = UIColor.white
        m_rightTabMoreButton.addTarget(self, action: #selector(onTouchSortButton), for: .touchUpInside)
        toolbar.rightViews = [m_rightTabMoreButton]
    }
}

extension MusicDataViewToolBarController {
/**@section Event handler */
    @objc private func onTouchPrevButton() {
        self.dismiss(animated: true)
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
