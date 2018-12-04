//
//  SectionLineView.swift
//  jubiinfo
//
//  Created by ggomdyu on 15/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

public class SectionLineView : UIView {
/**@section Constructor */
    @IBOutlet weak var m_sectionText: UILabel!
    
/**@section Method */
    public func initialize(sectionText: String) {
        m_sectionText.text = sectionText
    }
}
