//
//  MusicDataViewController.swift
//  jubiinfo
//
//  Created by 차준호 on 15/12/2018.
//  Copyright © 2018 차준호. All rights reserved.
//

import Foundation
import UIKit
import Material

public class MusicDataViewController : ViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var contentsView: UIScrollView!
    @IBOutlet weak var contentsViewHeightConstraint: NSLayoutConstraint!
    private var nextAddedCellYPos: CGFloat = 15.0
    private var loadedPageIndex = 0
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        contentsView.delegate = self
        
        self.loadMorePageCell()
    }
}

extension MusicDataViewController {
    
    public static func show(currentView: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let musicDataViewController = storyboard.instantiateViewController(withIdentifier: "MusicDataViewController") as! MusicDataViewController
        let toolBarController = MusicDataViewToolBarController(rootViewController: musicDataViewController)

        let navigationDrawerController = NavigationDrawerController(rootViewController: toolBarController) // , leftViewController: MusicDataViewMenuController()
        navigationDrawerController.isMotionEnabled = true
        navigationDrawerController.motionTransitionType = .autoReverse(presenting: .push(direction: .left))
        
        currentView.present(navigationDrawerController, animated: true)
    }
    
    private func loadMorePageCell() {
        
        self.addMusicLevelDivisionLine(level: 10.8)
        
        for i in ((loadedPageIndex * 50) ... (loadedPageIndex + 1) * 50) {
            let musicDataCache = GlobalUserDataStorage.instance.queryMyUserData().musicDataCaches[i]
            
            self.addMusicCell(musicDataCache: musicDataCache)
        }
        
        loadedPageIndex += 1
    }
    
    private func addMusicCell(musicDataCache: SimpleMusicData) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "MusicCellController") as! MusicCellController
        viewController.lazyInit(musicDataCache: musicDataCache)
        
        self.addCellToStackView(view: viewController.view)
        self.addMarginToStackView(margin: 1.5)
    }
    
    private func addMusicLevelDivisionLine(level: Float) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "MusicLevelDivisionLineController") as! MusicLevelDivisionLineController
        viewController.lazyInit(level: level)
        
        self.addCellToStackView(view: viewController.view)
    }

    private func addMarginToStackView(margin: CGFloat) {
        self.nextAddedCellYPos += margin
    }
    
    private func addCellToStackView(view: UIView) {
        
        self.contentsView.layout(view).top(nextAddedCellYPos).left(15).right(15)
        
        nextAddedCellYPos += view.frame.height
        
        contentsViewHeightConstraint.constant = nextAddedCellYPos
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
//            self.loadMore()
        }
    }
}
