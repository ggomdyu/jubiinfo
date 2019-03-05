//
//  ProfileViewMenuController.swift
//  jubiinfo
//
//  Created by ggomdyu on 13/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Material

class ProfileViewMenuController : ViewController {
/**@section Variable */
    private var m_menuBackgroundColor = Color.init(red: 0.141176, green: 0.294117, blue: 0.262745, alpha: 1.0)
    private var m_nextButtonAddYPos: CGFloat = 60.0
    private var m_optThemeChangeEventObserver: EventObserver?
    private var m_menuButtonList: [FlatButton] = []
    
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
        
        let themeChangeEventObserver = EventObserver(releaseAfterDispatch: false) { [weak self] (param: Any?) in
            self?.prepareTheme()
        }
        m_optThemeChangeEventObserver = themeChangeEventObserver
        
        EventDispatcher.instance.subscribeEvent(eventType: "changeThemeComplete", eventObserver: themeChangeEventObserver)
    }
    
    private func prepareUI() {
        self.addButtonToStackView(title: "프로필", action: #selector(self.onTouchProfileViewButton))
        self.addButtonToStackView(title: "음악 데이터", action: #selector(self.onTouchMusicDataButton))
        self.addButtonToStackView(title: "엠블럼", action: #selector(self.onTouchEmblemButton))
        self.addButtonToStackView(title: "랭킹", action: #selector(onTouchRankingButton))
        self.addButtonToStackView(title: "로그아웃", action: #selector(self.onTouchLogOutButton))
        
        self.prepareTheme()
    }
    
    private func prepareTheme() {
        self.view.backgroundColor = getCurrentThemeColorTable().profileViewMenuBackgroundColor
        
        for menuButton in m_menuButtonList {
            menuButton.titleColor = getCurrentThemeColorTable().profileViewMenuLabelColor
            menuButton.pulseColor = getCurrentThemeColorTable().profileViewMenuLabelColor
        }
    }

    private func addButtonToStackView(title: String, action: Selector) {
        let button = FlatButton(title: title)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        view.layout(button).horizontally().top(m_nextButtonAddYPos)

        m_nextButtonAddYPos += button.frame.height + 3.0
        m_menuButtonList.append(button)
    }

/**@section Event handler */
    @objc private func onTouchProfileViewButton() {
        navigationDrawerController?.closeLeftView()
    }
    
    @objc private func onTouchMusicDataButton() {
        MusicDataViewController.show(currentViewController: self)
    }
    
    @objc private func onTouchRivalButton() {
        showOkPopup(self, "에러", "구현 예정")
    }
    
    @objc private func onTouchEmblemButton() {
        showOkPopup(self, "에러", "구현 예정")
    }
    
    @objc private func onTouchRankingButton() {
        showOkPopup(self, "에러", "구현 예정")
    }
    
    @objc private func onTouchLogOutButton() {
        showYesNoPopup(self, nil, "로그아웃 하시겠습니까?", {
            self.dismiss(animated: true)
        })
    }
}
