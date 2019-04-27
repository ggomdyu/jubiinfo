//
//  LoginViewToolBarController.swift
//  jubiinfo
//
//  Created by ggomdyu on 02/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Material

class LoginViewToolBarController: ToolbarController {
/**@section Variable */
    private let toolBarColor = UIColor(red: 36 / 255, green: 75 / 255, blue: 67 / 255, alpha: 1)
    private let toolBarLabelColor = UIColor(red: 255 / 255, green: 253 / 255, blue: 228 / 255, alpha: 1)
    
/**@section Method */
    open override func prepare() {
        super.prepare()
        
        self.prepareStatusBar()
        self.prepareToolbar()
    }

/**@section Event handler */
    private func prepareStatusBar() {
        statusBarStyle = .lightContent
        statusBar.backgroundColor = toolBarColor
    }
    
    private func prepareToolbar() {
        toolbar.title = "로그인"
        toolbar.titleLabel.textColor = self.toolBarLabelColor
        toolbar.backgroundColor = self.toolBarColor
    }
}
