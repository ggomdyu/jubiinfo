//
//  UIUtility.swift
//  jubiinfo
//
//  Created by ggomdyu on 07/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

public func showOkPopup(_ viewControllerToPresent: UIViewController, _ title: String?, _ message: String?, _ optOnTouchOkButton: (() -> ())? = nil, _ optOnShowComplete: (() -> ())? = nil) {
    
    showAlertPopup(viewControllerToPresent, title, message, [("OK", UIAlertAction.Style.default,  {() -> Void in
        if let onTouchOkButton = optOnTouchOkButton {
            onTouchOkButton()
        }
    })], optOnShowComplete)
}

public func showAlertPopup(_ viewControllerToPresent: UIViewController, _ title: String?, _ message: String?, _ actionDescs: [(String, UIAlertAction.Style, (() -> Void)?)], _ optOnShowComplete: (() -> ())? = nil) {
    // Create a UIAlertController
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    
    // Add actions to controller
    for actionDesc in actionDescs {
        let buttonAction = UIAlertAction(title: actionDesc.0, style: actionDesc.1) {(result: UIAlertAction) -> Void in
            if let onTouchOkButton = actionDesc.2 {
                onTouchOkButton()
            }
        }
        alertController.addAction(buttonAction)
    }
    
    viewControllerToPresent.present(alertController, animated: true, completion: optOnShowComplete)
}

public func showLoadingIndicatorUI(_ viewControllerToPresent: UIViewController, _ message: String, _ onShowComplete: (() -> Void)? = nil) {
    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    
    let loadingIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    loadingIndicatorView.hidesWhenStopped = true
    loadingIndicatorView.style = UIActivityIndicatorView.Style.gray
    loadingIndicatorView.startAnimating();
    
    alertController.view.addSubview(loadingIndicatorView)
    
    viewControllerToPresent.present(alertController, animated: true, completion: onShowComplete)
}

public func hideLoadingIndicatorUI(_ viewControllerToPresent: UIViewController, _ onHideComplete: (() -> Void)? = nil) {
    viewControllerToPresent.dismiss(animated: false, completion: onHideComplete)
}
