//
//  EndEditScrollView.swift
//  jubiinfo
//
//  Created by ggomdyu on 25/03/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

public class EndEditTableView : UITableView {
    override public func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        super.touchesShouldBegin(touches, with: event, in: view)
        
        self.endEditing(true)
        
        return true
    }
}
