//
//  OmikujiWidgetSettingViewController.swift
//  jubiinfo
//
//  Created by jhcha on 12/04/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import SBCardPopup

class OmikujiWidgetSettingViewController : UIViewController, SBCardPopupContent, UIPickerViewDelegate, UIPickerViewDataSource {
/**@section Variable */
    var popupViewController: SBCardPopupViewController?
    var allowsTapToDismissPopupCard = true
    var allowsSwipeToDismissPopupCard = false

    private static let allLevel10IndicatorValue = 999
    private static let allLevel9IndicatorValue = 998
    private let m_levelStrDataSource = [("10레벨 전체", allLevel10IndicatorValue), ("10.9", 109), ("10.8", 108), ("10.7", 107), ("10.6", 106), ("10.5", 105), ("10.4", 104), ("10.3", 103), ("10.2", 102), ("10.1", 101), ("10.0", 100), ("9레벨 전체", allLevel9IndicatorValue), ("9.9", 99), ("9.8", 98), ("9.7", 97), ("9.6", 96), ("9.5", 95), ("9.4", 94), ("9.3", 93), ("9.2", 92), ("9.1", 91), ("9.0", 90), ("8", 80), ("7", 70), ("6", 60), ("5", 50), ("4", 40), ("3", 30), ("2", 20), ("1", 10)]
    @IBOutlet weak var m_levelPickerView: UIPickerView!
    private var m_onChangeFilterLevel: ((Int) -> Void)?
    
/**@section Method */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_levelPickerView.delegate = self
        m_levelPickerView.dataSource = self
    }
    
    private func initialize(onChangeFilterLevel: ((Int) -> Void)?) {
        m_onChangeFilterLevel = onChangeFilterLevel
    }
    
    public static func show(currentViewController: UIViewController, onChangeFilterLevel: ((Int) -> Void)? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "OmikujiWidgetSettingViewController") as! OmikujiWidgetSettingViewController
        
        let rootViewController = SBCardPopupViewController(contentViewController: viewController)
        rootViewController.show(onViewController: currentViewController)
        
        viewController.initialize(onChangeFilterLevel: onChangeFilterLevel)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return m_levelStrDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return m_levelStrDataSource[row].0
    }
    
/**@section Event handler */
    @IBAction func onTouchOkBtn(_ sender: Any) {
        m_onChangeFilterLevel?(m_levelStrDataSource[m_levelPickerView.selectedRow(inComponent: 0)].1)
        popupViewController?.close()
    }
}
