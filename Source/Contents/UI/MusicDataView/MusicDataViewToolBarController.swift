//
//  MusicDataViewToolBarController.swift
//  jubiinfo
//
//  Created by 차준호 on 15/12/2018.
//  Copyright © 2018 차준호. All rights reserved.
//

import UIKit
import Material

public class MusicDataViewToolBarController: ToolbarController {
    
    private var toolBarColor = UIColor(red: 36 / 255, green: 75 / 255, blue: 67 / 255, alpha: 1)
    private var toolBarLabelColor = UIColor(red: 255 / 255, green: 253 / 255, blue: 228 / 255, alpha: 1)
    
    private var menuButton: IconButton!
    
    open override func prepare() {
        super.prepare()
        
        self.prepareStatusBar()
        self.prepareToolbar()
    }
}

extension MusicDataViewToolBarController {
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
        toolbar.title = "음악 데이터"
        toolbar.titleLabel.textColor = self.toolBarLabelColor
        toolbar.backgroundColor = self.toolBarColor
    }
    
    private func prepareToolbarLeftIcon() {
        menuButton = IconButton(image: Icon.cm.arrowBack)
        menuButton.tintColor = UIColor.white
        menuButton.addTarget(self, action: #selector(onTouchPrevButton), for: .touchUpInside)
        toolbar.leftViews = [menuButton]
    }
    
    private func prepareToolbarRightIcon() {
    }
}

extension MusicDataViewToolBarController {
    @objc private func onTouchPrevButton() {
        self.dismiss(animated: true)
    }
}
