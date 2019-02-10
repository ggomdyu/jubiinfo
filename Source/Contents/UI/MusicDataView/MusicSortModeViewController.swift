//
//  ChangeSizePopupContentViewController.swift
//  SBCardPopupExample
//
//  Created by Steve Barnegren on 22/06/2017.
//  Copyright © 2017 Steve Barnegren. All rights reserved.
//

import UIKit
import SBCardPopup

class MusicSortModeViewController : UIViewController, SBCardPopupContent, UIPickerViewDelegate, UIPickerViewDataSource {
    
/**@section Variable */
    var popupViewController: SBCardPopupViewController?
    var allowsTapToDismissPopupCard = true
    var allowsSwipeToDismissPopupCard = true
    
    @IBOutlet weak var m_sortModePickerView: UIPickerView!
    @IBOutlet weak var m_ascendingSortSwitch: UISwitch!
    @IBOutlet weak var m_okButton: UIButton!
    private var m_onChangeMusicSortMode: ((MusicSortMode, MusicSortOrder) -> Void)?
    private var m_sortModeTable = [
        ("레벨", MusicSortMode.Level),
        ("제목", MusicSortMode.Name),
        ("스코어", MusicSortMode.Score),
        ("아티스트", MusicSortMode.Artist)
    ]

/**@section Overrided method */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_sortModePickerView.delegate = self
        m_sortModePickerView.dataSource = self
    }

/**@section Method */
    public static func show(currentViewController: UIViewController, currMusicSortMode: MusicSortMode, currMusicSortOrder: MusicSortOrder, onChangeMusicSortMode: @escaping (MusicSortMode, MusicSortOrder) -> Void) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MusicSortModeViewController") as! MusicSortModeViewController
        
        let rootViewController = SBCardPopupViewController(contentViewController: viewController)
        rootViewController.show(onViewController: currentViewController)
        
        viewController.initialize(currMusicSortMode: currMusicSortMode, currMusicSortOrder: currMusicSortOrder, onChangeMusicSortMode: onChangeMusicSortMode)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return m_sortModeTable.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return m_sortModeTable[row].0
    }
    
    private func initialize(currMusicSortMode: MusicSortMode, currMusicSortOrder: MusicSortOrder, onChangeMusicSortMode: @escaping (MusicSortMode, MusicSortOrder) -> Void) {
        m_onChangeMusicSortMode = onChangeMusicSortMode
        
        // Select the index of picker view
        let pickerRowToSelect = m_sortModeTable.firstIndex { (musicSortModeStr: String, musicSortMode: MusicSortMode) -> Bool in
            return currMusicSortMode == musicSortMode
        } ?? 0
        m_sortModePickerView.selectRow(pickerRowToSelect, inComponent: 0, animated: false)
        
        // Change the toggle state of switch
        m_ascendingSortSwitch.isOn = (currMusicSortOrder == .Ascending)
    }
    
/**@section Event handler */
    @IBAction func onClickOkButton(_ sender: UIButton, forEvent event: UIEvent) {
        let selectedSortModeStr = m_sortModeTable[m_sortModePickerView.selectedRow(inComponent: 0)].1
        let selectedSortOrder = m_ascendingSortSwitch.isOn ? MusicSortOrder.Ascending : MusicSortOrder.Descending
        m_onChangeMusicSortMode?(selectedSortModeStr, selectedSortOrder)
        
        popupViewController?.close()
    }
}
