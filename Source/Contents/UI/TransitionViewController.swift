//
//  TransitionViewController.swift
//  jubiinfo
//
//  Created by 차준호 on 02/12/2018.
//  Copyright © 2018 차준호. All rights reserved.
//

import Foundation
import UIKit
import Material
import Motion

public class TransitionViewController : UIViewController {
    public func transitionPush() {
        motionTransitionType = .autoReverse(presenting: .push(direction: .left))
    }
    
    public func transitionPull() {
        motionTransitionType = .autoReverse(presenting: .pull(direction: .right))
    }

    public func transitionCover() {
        motionTransitionType = .autoReverse(presenting: .cover(direction: .up))
    }

    public func transitionUncover() {
        motionTransitionType = .autoReverse(presenting: .uncover(direction: .down))
    }
        
    public func transitionSlide() {
        motionTransitionType = .autoReverse(presenting: .slide(direction: .right))
    }

    public func transitionZoomSlide() {
        motionTransitionType = .autoReverse(presenting: .zoomSlide(direction: .right))
    }

    public func transitionPageIn() {
        motionTransitionType = .autoReverse(presenting: .pageIn(direction: .left))
    }
        
    public func transitionPageOut() {
        motionTransitionType = .autoReverse(presenting: .pageOut(direction: .right))
    }

    public func transitionFade() {
        motionTransitionType = .autoReverse(presenting: .fade)
    }
        
    public func transitionZoom() {
        motionTransitionType = .autoReverse(presenting: .zoom)
    }
    
    public func transitionZoomOut() {
        motionTransitionType = .autoReverse(presenting: .zoomOut)
    }
}
