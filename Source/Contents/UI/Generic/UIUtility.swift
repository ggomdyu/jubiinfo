//
//  UIUtility.swift
//  jubiinfo
//
//  Created by ggomdyu on 07/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

public func showActionSheet(_ viewControllerToPresent: UIViewController, _ title: String?, _ message: String?, _ actionDescs: [(String, UIAlertAction.Style, (() -> Void)?)], _ optOnShowComplete: (() -> ())? = nil) {
    // Create a UIAlertController
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
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


public func showOkPopup(_ viewControllerToPresent: UIViewController, _ title: String?, _ message: String?, _ optOnTouchCloseButton: (() -> ())? = nil, _ optOnShowComplete: (() -> ())? = nil) {
    
    showAlertPopup(viewControllerToPresent, title, message, [("닫기", .default,  {() -> Void in
        if let onTouchCloseButton = optOnTouchCloseButton {
            onTouchCloseButton()
        }
    })], optOnShowComplete)
}

public func showYesNoPopup(_ viewControllerToPresent: UIViewController, _ title: String?, _ message: String?, _ optOnTouchYesButton: (() -> ())? = nil, _ optOnTouchNoButton: (() -> ())? = nil, _ optOnShowComplete: (() -> ())? = nil) {
    
    showAlertPopup(viewControllerToPresent, title, message, [
        ("예", .default,  {() -> Void in optOnTouchYesButton?()}),
        ("아니오", .cancel,  {() -> Void in optOnTouchNoButton?()}
    )], optOnShowComplete)
}

public func showPopup(_ viewControllerToPresent: UIViewController, _ title: String?, _ message: String?, _ optOnShowComplete: (() -> ())? = nil) {
    
    showAlertPopup(viewControllerToPresent, title, message, [(String, UIAlertAction.Style, (() -> Void)?)] (), optOnShowComplete)
}

public func showAlertPopup(_ viewControllerToPresent: UIViewController, _ title: String?, _ message: String?, _ actionDescs: [(String, UIAlertAction.Style, (() -> Void)?)], _ optOnShowComplete: (() -> ())? = nil) {
    // Create a UIAlertController
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
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

public func showLoadingIndicatorUI(_ viewControllerToPresent: UIViewController, _ title: String, _ message: String, _ onShowComplete: (() -> Void)? = nil) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let loadingIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    loadingIndicatorView.hidesWhenStopped = true
    loadingIndicatorView.style = .gray
    loadingIndicatorView.startAnimating();
    
    alertController.view.addSubview(loadingIndicatorView)
    
    viewControllerToPresent.present(alertController, animated: true, completion: onShowComplete)
}

public func showLoadingIndicatorUI(_ viewControllerToPresent: UIViewController, _ title: String, _ onShowComplete: (() -> Void)? = nil) {
    showLoadingIndicatorUI(viewControllerToPresent, title, "", onShowComplete)
}

public func hideLoadingIndicatorUI(_ viewControllerToPresent: UIViewController, _ onHideComplete: (() -> Void)? = nil) {
    viewControllerToPresent.dismiss(animated: false, completion: onHideComplete)
}

public func showLoadingSpinnerUI(_ viewControllerToPresent: UIViewController, _ onShowComplete: (() -> Void)? = nil) {
    let spinnerViewController = UIViewController.init()
//    spinnerViewController.view = UIView.init(frame: viewControllerToPresent.view.bounds)
    spinnerViewController.view.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
    
    let loadingIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    loadingIndicatorView.hidesWhenStopped = true
    loadingIndicatorView.style = .gray
//    loadingIndicatorView.center = spinnerViewController.view.center
    loadingIndicatorView.startAnimating();
    
    spinnerViewController.view.addSubview(loadingIndicatorView)
    
    viewControllerToPresent.present(spinnerViewController, animated: true, completion: onShowComplete)
}

public func hideLoadingSpinnerUI(_ viewControllerToPresent: UIViewController, _ onHideComplete: (() -> Void)? = nil) {
    viewControllerToPresent.dismiss(animated: false, completion: onHideComplete)
}

//public func showPickerUI(_ viewControllerToPresent: UIViewController) {
//}
//
//public func hidePickerUI() {
//}
