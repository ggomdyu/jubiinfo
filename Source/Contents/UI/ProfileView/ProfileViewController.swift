//
//  ProfileViewController.swift
//  jubiinfo
//
//  Created by ggomdyu on 13/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Foundation
import Material
import Motion
//import Charts

class ProfileViewController: ViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentsView: UIView!
    @IBOutlet weak var contentsViewHeightConstraint: NSLayoutConstraint!
    
    private var nextAddedCellYPos: CGFloat = 15.0
    
    open override func prepare() {
        super.prepare()
        
        // Start to create dummy widget.
        self.prepareProfileCell()
        self.preparePlayDataACell()
        self.prepareRankDataGraphCell()
        
        // Start to request packet. If pack
        self.requestDataPacket()
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named:"background.jpg")!)
    }
}

extension ProfileViewController {
    
    public static func show(currentView: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        let toolBarController = ProfileViewToolBarController(rootViewController: profileViewController)
        
        let navigationDrawerController = NavigationDrawerController(rootViewController: toolBarController, leftViewController: ProfileViewMenuController())
        navigationDrawerController.isMotionEnabled = true
        navigationDrawerController.motionTransitionType = .autoReverse(presenting: .push(direction: .left))
        
        currentView.present(navigationDrawerController, animated: true)
    }
    
    private func requestDataPacket() {
        
        let myUserData = GlobalUserDataStorage.instance.queryMyUserData()
        
        // Load play data page
        JubeatFestoWebSite.instance.requestMyPlayData { (optMyPlayDataPageCache: UserData.MyPlayDataPageCache?) in
            myUserData.rivalId = (optMyPlayDataPageCache != nil) ? optMyPlayDataPageCache!.rivalId : ""
            myUserData.playDataPageCache = optMyPlayDataPageCache
            
            runTaskInMainThread {
                EventDispatcher.instance.dispatchEvent(eventType: "requestMyPlayDataComplete", eventParam: optMyPlayDataPageCache)
            }
        }
        
        // Load rank data page
        JubeatFestoWebSite.instance.requestMyRankData { (optMyRankDataPageCache: UserData.RankDataPageCache?) in
            myUserData.rankDataPageCache = optMyRankDataPageCache
            
            runTaskInMainThread {
                EventDispatcher.instance.dispatchEvent(eventType: "requestMyRankDataComplete", eventParam: optMyRankDataPageCache)
            }
        }
    }
    
    private func addCellToStackView(view: UIView) {
        
        self.contentsView.layout(view).top(nextAddedCellYPos).left(15).right(15)
        
        nextAddedCellYPos += view.frame.height + 15.0
        
        contentsViewHeightConstraint.constant = nextAddedCellYPos
    }
    
    private func prepareProfileCell() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "ProfileCellController") as! ProfileCellController

        self.addCellToStackView(view: viewController.view)
    }
    
    private func preparePlayDataACell() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "PlayDataACellController") as! PlayDataACellController
        
        self.addCellToStackView(view: viewController.view)
    }
    
    private func prepareRankDataGraphCell() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "RankDataGraphCellController") as! RankDataGraphCellController
        
        self.addCellToStackView(view: viewController.view)
    }
}
