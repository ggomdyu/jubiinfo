//
//  ProfileViewEditController.swift
//  jubiinfo
//
//  Created by ggomdyu on 24/02/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import Material
import UIKit

public class ProfileViewEditController : EasyUITableViewController {
/**@section Variable */
    private var m_onEditComplete: ((Bool) -> Void)?
    private var m_optThemeChangeEventObserver: EventObserver?
    private let m_widgetCellDescs: [WidgetType: String] = [
        WidgetType.profile: "프로필",
        WidgetType.playData: "플레이 데이터",
        WidgetType.omikuji: "오미쿠지",
        WidgetType.dailyRecommended: "오늘의 추천곡",
        WidgetType.rankDataGraphA: "랭크 데이터 그래프",
        WidgetType.gameCenterVisitHistory: "방문 기록",
        WidgetType.newRecord: "신 기록"
    ]
    
/**@section Destructor */
    deinit {
        if let themeChangeEventObserver = m_optThemeChangeEventObserver {
            EventDispatcher.instance.unsubscribeEvent(eventType: "changeThemeComplete", eventObserver: themeChangeEventObserver)
            m_optThemeChangeEventObserver = nil
        }
    }
    
/**@section Method */
    public static func show(currentViewController: UIViewController, onEditComplete: ((Bool) -> Void)?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let profileViewEditController = storyboard.instantiateViewController(withIdentifier: "ProfileViewEditController") as! ProfileViewEditController
        
        let toolbarController = ProfileViewEditToolbarController(rootViewController: profileViewEditController, onTouchEditCompleteBtn: profileViewEditController.onEditComplete)
        profileViewEditController.initialize(onEditComplete: onEditComplete)
        
        let snackbarController = SnackbarController(rootViewController: toolbarController)
        snackbarController.isMotionEnabled = true
        snackbarController.motionTransitionType = .autoReverse(presenting: .push(direction: .up))
        snackbarController.modalPresentationStyle = .fullScreen
        
        currentViewController.present(snackbarController, animated: true)
    }
    
    public func initialize(onEditComplete: ((Bool) -> Void)?) {
        m_onEditComplete = onEditComplete
        
        tableView.setEditing(true, animated: false)
        
        self.prepareTheme()
        self.prepareEventObserver()
    }
    
    private func prepareTheme() {
        self.tableView.backgroundColor = getCurrentThemeColorTable().tableViewBackgroundColor
    }
    
    private func prepareEventObserver() {
        let themeChangeEventObserver = EventObserver(releaseAfterDispatch: false) { [weak self] (param: Any?) in
            self?.prepareTheme()
        }
        m_optThemeChangeEventObserver = themeChangeEventObserver
        
        EventDispatcher.instance.subscribeEvent(eventType: "changeThemeComplete", eventObserver: themeChangeEventObserver)
    }
    
    private func createActivatedWidgetRowDatas() -> [(rowType: RowType, initializer: (Any?) -> Void, param: Any?)] {
        let currActiveWidgetList = SettingDataStorage.instance.getActiveWidgetList()
        var ret: [(rowType: RowType, initializer: (Any?) -> Void, param: Any?)] = []
        for currActiveWidget in currActiveWidgetList {
            guard let widgetCellDesc = m_widgetCellDescs[currActiveWidget] else {
                continue
            }
            
            ret.append((RowType.basic, { (param: Any?) in
                let cell = param as! UITableViewCell
                cell.textLabel?.text = widgetCellDesc
            }, currActiveWidget))
        }
        
        return ret
    }

    private func createDeactivatedWidgetRowDatas() -> [(rowType: RowType, initializer: (Any?) -> Void, param: Any?)] {
        let currActiveWidgetList = SettingDataStorage.instance.getActiveWidgetList()
        let widgetCellDescs = m_widgetCellDescs.filter { (key: WidgetType, value: String) -> Bool in
            return currActiveWidgetList.contains(key) == false
        }
        
        var ret: [(rowType: RowType, initializer: (Any?) -> Void, param: Any?)] = []
        for widgetCellDesc in widgetCellDescs {
            ret.append((RowType.basic, { (param: Any?) in
                let cell = param as! UITableViewCell
                cell.textLabel?.text = widgetCellDesc.value
            }, widgetCellDesc.key
            ))
        }
        
        return ret
    }
    
    public override func createSectionDataTable() -> [(sectionTitle: String, [(rowType: RowType, initializer: (Any?) -> Void, param: Any?)])] {
        return [
            ("일반", [
                (RowType.detailPageBtn, { (param: Any?) in
                    let cell = param as! UITableViewCell
                    cell.textLabel?.text = "닉네임 변경"
                }, nil),
                (RowType.detailPageBtn, { (param: Any?) in
                    let cell = param as! UITableViewCell
                    cell.textLabel?.text = "테마 변경"
                }, nil)
            ]),
            ("활성화된 위젯",
                self.createActivatedWidgetRowDatas()
            ),
            ("비활성화된 위젯",
                self.createDeactivatedWidgetRowDatas()
            )
        ]
    }
    
    public override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == 1) || (indexPath.section == 2)
    }
    
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == 1) || (indexPath.section == 2)
    }
    
    public override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section == sourceIndexPath.section {
            return proposedDestinationIndexPath
        }
        else {
            return sourceIndexPath
        }
    }
    
    public override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section == 1 {
            return .delete
        }
        else if indexPath.section == 2 {
            return .insert
        }
        else {
            return .none
        }
    }
    
    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToMove = sectionDataTable[1].1[indexPath.row]
            sectionDataTable[2].1.append(itemToMove)
            tableView.insertRows(at: [IndexPath(row: sectionDataTable[2].1.count - 1, section: 2)], with: .right)
            
            sectionDataTable[1].1.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
        else if editingStyle == .insert {
            let itemToMove = sectionDataTable[2].1[indexPath.row]
            sectionDataTable[2].1.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            
            sectionDataTable[1].1.append(itemToMove)
            tableView.insertRows(at: [IndexPath(row: sectionDataTable[1].1.count - 1, section: 1)], with: .left)
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                EditNicknameViewController.show(currentViewController: self)
            }
            else if indexPath.row == 1 {
                EditThemeViewController.show(currentViewController: self)
            }
        }
    }
    
/**@section Event handler */
    private func onEditComplete() {
        var newActiveWidgetTypes: [WidgetType] = []
        for rowData in self.sectionDataTable[1].1 {
            let newActiveWidgetType = rowData.param as! WidgetType
            newActiveWidgetTypes.append(newActiveWidgetType)
        }
        
        let prevActiveWidgetList = SettingDataStorage.instance.getActiveWidgetList()
        var isActiveWidgetChanged = newActiveWidgetTypes.count != prevActiveWidgetList.count
        if isActiveWidgetChanged == false {
            for i in 0..<newActiveWidgetTypes.count {
                if newActiveWidgetTypes[i] != prevActiveWidgetList[i] {
                    isActiveWidgetChanged = true
                    break;
                }
            }
        }
        
        if isActiveWidgetChanged {
            SettingDataStorage.instance.setActiveWidgetList(activeWidgetList: newActiveWidgetTypes)
        }
        
        m_onEditComplete?(isActiveWidgetChanged)
    }
}

public class ProfileViewEditToolbarController: ToolbarController {
/**@section Variable */
    private let m_toolBarColor = UIColor(red: 36 / 255, green: 75 / 255, blue: 67 / 255, alpha: 1)
    private let m_toolBarLabelColor = UIColor(red: 255 / 255, green: 253 / 255, blue: 228 / 255, alpha: 1)
    private var m_rightTabPrevButton: Button!
    private var m_onTouchEditCompleteBtn: (() -> Void)?
    private var m_optThemeChangeEventObserver: EventObserver?
    
/**@section Constructor */
    public init(rootViewController: UIViewController, onTouchEditCompleteBtn: (() -> Void)?) {
        super.init(rootViewController: rootViewController)
        
        m_onTouchEditCompleteBtn = onTouchEditCompleteBtn
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
/**@section Destructor */
    deinit {
        if let themeChangeEventObserver = m_optThemeChangeEventObserver {
            EventDispatcher.instance.unsubscribeEvent(eventType: "changeThemeComplete", eventObserver: themeChangeEventObserver)
            m_optThemeChangeEventObserver = nil
        }
    }
    
/**@section Method */
    open override func prepare() {
        super.prepare()
        
        self.prepareUI()
        self.prepareEventObserver()
    }
    
    private func prepareUI() {
        self.prepareStatusBar()
        self.prepareToolbarTitle()
        self.prepareToolbarRightIcon()
        self.prepareTheme()
    }
    
    private func prepareEventObserver() {
        let themeChangeEventObserver = EventObserver(releaseAfterDispatch: false) { [weak self] (param: Any?) in
            self?.prepareTheme()
        }
        m_optThemeChangeEventObserver = themeChangeEventObserver
        
        EventDispatcher.instance.subscribeEvent(eventType: "changeThemeComplete", eventObserver: themeChangeEventObserver)
    }
    
    private func prepareStatusBar() {
        statusBarStyle = .lightContent
    }
    
    private func prepareToolbarTitle() {
        toolbar.title = "설정"
    }
    
    private func prepareToolbarRightIcon() {
        m_rightTabPrevButton = IconButton(image: Icon.cm.check)
        m_rightTabPrevButton.addTarget(self, action: #selector(onTouchEditCompleteButton), for: .touchUpInside)
        toolbar.rightViews = [m_rightTabPrevButton]
    }
    
    private func prepareTheme() {
        toolbar.titleLabel.textColor = getCurrentThemeColorTable().toolBarTitleLabelColor
        toolbar.backgroundColor = getCurrentThemeColorTable().toolBarBackgroundColor
        
        statusBar.backgroundColor = getCurrentThemeColorTable().toolBarBackgroundColor
        
        m_rightTabPrevButton.tintColor = getCurrentThemeColorTable().toolBarIconColor
    }
    
    
/**@section Event handler */
    @objc private func onTouchEditCompleteButton() {
        m_onTouchEditCompleteBtn?()
        
        self.dismiss(animated: true)
    }
}
