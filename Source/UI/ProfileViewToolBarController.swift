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
    
    open override func prepare() {
        super.prepare()

        self.prepareStatusBar()
        self.prepareToolbar()
        self.prepareTransition()
    }
}

extension ProfileViewToolBarController {
    
    private func prepareTransition() {
        isMotionEnabled = true
        transitionPush()
        return;
        
        // The below are sort of transition effect.
        //transitionPush,
        //transitionPush,
        //transitionPull,
        //transitionCover,
        //transitionUncover,
        //transitionSlide,
        //transitionZoomSlide,
        //transitionPageIn,
        //transitionPageOut,
        //transitionFade,
        //transitionZoom,
        //transitionZoomOut
    }
    
    private func transitionPush() {
        motionTransitionType = .autoReverse(presenting: .push(direction: .left))
    }
    
    private func prepareStatusBar() {
        statusBarStyle = .lightContent
        statusBar.backgroundColor = Color.blue.darken3
    }
    
    private func prepareToolbar() {
        toolbar.backgroundColor = Color.blue.darken2
        toolbar.title = "프로필"
        toolbar.titleLabel.textColor = Color.white
    }
}
