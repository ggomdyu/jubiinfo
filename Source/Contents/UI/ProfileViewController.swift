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
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named:"background.jpg")!)
        
        self.prepareProfileCell()
        self.preparePlayDataACell()
        self.prepareScoreDataGraphCell()
    }
}

extension ProfileViewController {
    
    private func addCellToStackView(view: UIView) {
        
        self.contentsView.layout(view).top(nextAddedCellYPos).left(15).right(15)
        
        nextAddedCellYPos += view.frame.height + 15.0
        
        contentsViewHeightConstraint.constant = nextAddedCellYPos
    }
    
    private func prepareProfileCell() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewCellController") as! ProfileViewCellController

        self.addCellToStackView(view: viewController.view)
    }
    
    private func preparePlayDataACell() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "PlayDataACellController") as! PlayDataACellController
        
        self.addCellToStackView(view: viewController.view)
    }
    
    private func prepareScoreDataGraphCell() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "ScoreDataGraphCellController") as! ScoreDataGraphCellController
        
        self.addCellToStackView(view: viewController.view)
    }
}
