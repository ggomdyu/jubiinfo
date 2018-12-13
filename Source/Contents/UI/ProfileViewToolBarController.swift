//
//  LoginViewToolBarController.swift
//  jubiinfo
//
//  Created by ggomdyu on 02/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Material

public class ProfileViewToolBarController: ToolbarController {
    
    private var toolBarColor = UIColor(red: 36 / 255, green: 75 / 255, blue: 67 / 255, alpha: 1)
    private var toolBarLabelColor = UIColor(red: 255 / 255, green: 253 / 255, blue: 228 / 255, alpha: 1)
    
    private var menuButton: IconButton!
    
    open override func prepare() {
        super.prepare()
        
        self.prepareStatusBar()
        self.prepareToolbar()
    }
}

extension ProfileViewToolBarController {
    private func prepareStatusBar() {
        statusBarStyle = .lightContent
        statusBar.backgroundColor = self.toolBarColor
    }
    
    private func prepareToolbar() {
        self.prepareToolbarTitle()
        self.prepareToolbarLeftIcon()
        self.prepareToolbarRightIcon()
    }
    
    private func prepareToolbarTitle() {
        toolbar.title = "프로필"
        toolbar.titleLabel.textColor = self.toolBarLabelColor
        toolbar.backgroundColor = self.toolBarColor
    }
    
    private func prepareToolbarLeftIcon() {
        menuButton = IconButton(image: Icon.cm.menu)
        menuButton.tintColor = UIColor.white
        menuButton.addTarget(self, action: #selector(onTouchMenuButton), for: .touchUpInside)
        toolbar.leftViews = [menuButton]
    }
    
    private func prepareToolbarRightIcon() {
    }
}

extension ProfileViewToolBarController {
    @objc private func onTouchMenuButton() {
        navigationDrawerController?.toggleLeftView()
    }
}
