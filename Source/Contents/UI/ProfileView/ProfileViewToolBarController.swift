//
//  ProfileViewToolBarController.swift
//  jubiinfo
//
//  Created by ggomdyu on 02/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Material

public class ProfileViewToolBarController: ToolbarController {
/**@section Variable */
    private var m_toolBarColor = UIColor(red: 36 / 255, green: 75 / 255, blue: 67 / 255, alpha: 1)
    private var m_toolBarLabelColor = UIColor(red: 255 / 255, green: 253 / 255, blue: 228 / 255, alpha: 1)
    private var m_leftTabMenuButton: IconButton!
    private var m_rightTabSettingButton: IconButton!
    
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
        toolbar.title = "프로필"
        toolbar.titleLabel.textColor = m_toolBarLabelColor
        toolbar.backgroundColor = m_toolBarColor
    }
    
    private func prepareToolbarLeftIcon() {
        m_leftTabMenuButton = IconButton(image: Icon.cm.menu)
        m_leftTabMenuButton.tintColor = UIColor.white
        m_leftTabMenuButton.addTarget(self, action: #selector(onTouchMenuButton), for: .touchUpInside)
        toolbar.leftViews = [m_leftTabMenuButton]
    }
    
    private func prepareToolbarRightIcon() {
        m_rightTabSettingButton = IconButton(image: Icon.cm.settings)
        m_rightTabSettingButton.tintColor = UIColor.white
//        menuButton.addTarget(self, action: #selector(onTouchMenuButton), for: .touchUpInside)
        toolbar.rightViews = [m_rightTabSettingButton]
    }

/**@section Event handler */
    @objc private func onTouchMenuButton() {
        navigationDrawerController?.toggleLeftView()
    }
}
