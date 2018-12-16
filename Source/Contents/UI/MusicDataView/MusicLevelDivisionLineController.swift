//
//  MusicLevelDivisionLineController.swift
//  jubiinfo
//
//  Created by 차준호 on 15/12/2018.
//  Copyright © 2018 차준호. All rights reserved.
//

import Foundation
import UIKit

public class MusicLevelDivisionLineController : UIViewController {
    
    @IBOutlet weak var levelLabel: UILabel!
    private var level: Float = 0.0
    
    public func lazyInit(level: Float) {
        self.level = level
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        levelLabel.text = String(level)
    }
}
