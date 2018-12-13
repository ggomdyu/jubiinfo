//
//  ProfileViewMenuController.swift
//  jubiinfo
//
//  Created by 차준호 on 13/12/2018.
//  Copyright © 2018 차준호. All rights reserved.
//

import Foundation
import UIKit
import Material

class ProfileViewMenuController: UIViewController {

    private var menuBackgroundColor = Color.init(red: 0.141176, green: 0.294117, blue: 0.262745, alpha: 1.0)
    private var nextButtonAddYPos: CGFloat = 60.0
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = menuBackgroundColor
        
        self.addButtonToStackView(title: "프로필", action: #selector(self.onTouchProfileViewButton))
        self.addButtonToStackView(title: "음악 데이터", action: #selector(self.onTouchMusicDataButton))
        self.addButtonToStackView(title: "라이벌", action: #selector(self.onTouchRivalButton))
        self.addButtonToStackView(title: "엠블럼", action: #selector(self.onTouchEmblemButton))
//        self.addButtonToStackView(title: "칭호", action: #selector(onTouchProfileView))
        self.addButtonToStackView(title: "랭킹", action: #selector(onTouchRankingButton))
        self.addButtonToStackView(title: "로그아웃", action: #selector(self.onTouchLogOutButton))
    }
}

extension ProfileViewMenuController {
    
    private func addButtonToStackView(title: String, action: Selector) {
        let button = FlatButton(title: title, titleColor: .white)
        button.pulseColor = .white
        button.addTarget(self, action: action, for: .touchUpInside)
        
        view.layout(button).horizontally().top(nextButtonAddYPos)
        
        nextButtonAddYPos += button.frame.height + 3.0
    }
}

extension ProfileViewMenuController {
    @objc private func onTouchProfileViewButton() {
        showOkPopup(self, nil, "구현 예정")
    }
    
    @objc private func onTouchMusicDataButton() {
        showOkPopup(self, "에러", nil)
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
        showOkPopup(self, "에러", "구현 예정")
    }
}
