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

class ProfileViewController : ViewController {
/**@section Variable */
    @IBOutlet weak var m_scrollView: UIScrollView!
    
/**@section Overrided method */
    open override func prepare() {
        super.prepare()
        
        m_scrollView.backgroundColor = UIColor(patternImage: UIImage(named:"background.jpg")!)
        
        JubeatWebServer.requestMyRivalList { (isRequestSucceed: Bool, rivalListPageCache: UserData.RivalListPageCache) in
            
            let myUserData = GlobalDataStorage.instance.queryMyUserData();
            myUserData.rivalListPageCache = rivalListPageCache
        }
        
        self.prepareWidget();
    }
    
/**@section Method */
    public static func show(currentViewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        let toolBarController = ProfileViewToolBarController(rootViewController: profileViewController)
        
        let navigationDrawerController = NavigationDrawerController(rootViewController: toolBarController, leftViewController: ProfileViewMenuController())
        navigationDrawerController.isMotionEnabled = true
        navigationDrawerController.motionTransitionType = .autoReverse(presenting: .push(direction: .left))
        
        currentViewController.present(navigationDrawerController, animated: true)
    }
    
    public func prepareWidget() {
//        var customMusicDatasJsonPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        customMusicDatasJsonPath.appendPathComponent("widget.json")
        
        
    }
}
