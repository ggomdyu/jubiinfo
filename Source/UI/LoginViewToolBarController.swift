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
    
    open override func prepare() {
        super.prepare()
        
        self.prepareStatusBar()
        self.prepareToolbar()
    }
}

fileprivate extension LoginViewToolBarController {
    private func prepareStatusBar() {
        statusBarStyle = .lightContent
        statusBar.backgroundColor = Color.blue.darken3
    }
    
    private func prepareToolbar() {
        toolbar.backgroundColor = Color.blue.darken2
        toolbar.title = "로그인"
        toolbar.titleLabel.textColor = Color.white
    }
}
