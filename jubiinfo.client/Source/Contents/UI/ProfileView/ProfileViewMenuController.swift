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
import MessageUI

class ProfileViewMenuController : ViewController, MFMailComposeViewControllerDelegate {
/**@section Variable */
    private var m_menuBackgroundColor = Color.init(red: 0.141176, green: 0.294117, blue: 0.262745, alpha: 1.0)
    private var m_nextButtonAddYPos: CGFloat = 0.0
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
        self.prepareEventObserver()
    }
    
    private func prepareUI() {
        m_nextButtonAddYPos = (self.view.frame.height / 667.0) * 60.0
        
        self.addButtonToStackView(title: "프로필", action: #selector(self.onTouchProfileViewButton))
        self.addButtonToStackView(title: "음악 데이터", action: #selector(self.onTouchMusicDataButton))
        self.addButtonToStackView(title: "대회", action: #selector(self.onTouchCompetitionButton))
//        self.addButtonToStackView(title: "랭킹", action: #selector(onTouchRankingButton))
        self.addButtonToStackView(title: "문의", action: #selector(self.onTouchSupport))
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
    
    private func prepareEventObserver() {
        let themeChangeEventObserver = EventObserver(releaseAfterDispatch: false) { [weak self] (param: Any?) in
            self?.prepareTheme()
        }
        m_optThemeChangeEventObserver = themeChangeEventObserver
        
        EventDispatcher.instance.subscribeEvent(eventType: "changeThemeComplete", eventObserver: themeChangeEventObserver)
    }

    private func addButtonToStackView(title: String, action: Selector) {
        let button = FlatButton(title: title)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        view.layout(button).leading().trailing().top(m_nextButtonAddYPos)

        m_nextButtonAddYPos += 32
        m_menuButtonList.append(button)
    }

/**@section Event handler */
    @objc private func onTouchProfileViewButton() {
        navigationDrawerController?.closeLeftView()
    }
    
    @objc private func onTouchMusicDataButton() {
        MusicDataViewController.show(currentViewController: self)
    }
    
    @objc private func onTouchCompetitionButton() {
        CompetitionViewController.show(currentViewController: self)
    }
    
    @objc private func onTouchEmblemButton() {
        showOkPopup(self, "에러", "구현 예정")
    }
    
    @objc private func onTouchRankingButton() {
        showOkPopup(self, "에러", "구현 예정")
    }
    
    @objc private func onTouchSupport() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setToRecipients(["ggomdyu@gmail.com"])
            mailComposer.mailComposeDelegate = self
            self.present(mailComposer, animated: true)
        }
        else {
            showOkPopup(self, "에러", "설정 앱에서 이메일 계정을 등록해주세요.")
        }
    }
    
    @objc private func onTouchLogOutButton() {
        showYesNoPopup(self, nil, "로그아웃 하시겠습니까?", {
            JubeatWebServer.logout()
            
            LoginViewController.show(currentViewController: self)
        })
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
