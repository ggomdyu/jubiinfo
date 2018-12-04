//
//  PasteDisabledUITextField.swift
//  jubiinfo
//
//  Created by ggomdyu on 03/03/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

public class PasteDisabledUITextField : UITextField {
/**@section Method */
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
