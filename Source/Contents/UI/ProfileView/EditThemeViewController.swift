//
//  EditThemeViewController.swift
//  jubiinfo
//
//  Created by ggomdyu on 03/03/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Material

class EditThemeViewController : EasyUITableViewController {
/**@section Variable */
    private var m_optPrevSelectedCell: UITableViewCell?
    private var m_prevSelectedTheme = ThemeType.festo
    
/**@section Method */
    public static func show(currentViewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "EditThemeViewController") as! EditThemeViewController
        let toolBarController = EditThemeViewToolBarController(rootViewController: viewController, onTouchEditCompleteBtn: viewController.onTouchEditCompleteBtn)
        toolBarController.isMotionEnabled = true
        toolBarController.motionTransitionType = .autoReverse(presenting: .push(direction: .left))
        
        currentViewController.present(toolBarController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareTheme()
    }
    
    private func prepareTheme() {
        self.tableView.backgroundColor = getCurrentThemeColorTable().tableViewBackgroundColor
    }
    
    public override func createSectionDataTable() -> [(sectionTitle: String, [(rowType: RowType, initializer: (Any?) -> Void, param: Any?)])] {
        return [
            ("테마 변경", [
                (RowType.basic, { (param: Any?) in
                    let cell = param as! UITableViewCell
                    cell.accessoryType = .none
                    cell.textLabel?.text = "페스토"
                }, ThemeType.festo),
                (RowType.basic, { (param: Any?) in
                    let cell = param as! UITableViewCell
                    cell.accessoryType = .none
                    cell.textLabel?.text = "클랜"
                }, ThemeType.clan),
                (RowType.basic, { (param: Any?) in
                    let cell = param as! UITableViewCell
                    cell.accessoryType = .none
                    cell.textLabel?.text = "큐벨"
                }, ThemeType.qubell)
            ])
        ]
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let currActiveTheme = GlobalSettingDataStorage.instance.getActiveTheme()
        if currActiveTheme.rawValue == indexPath.row {
            m_optPrevSelectedCell = cell
            m_prevSelectedTheme = sectionDataTable[0].1[currActiveTheme.rawValue].param as! ThemeType
            
            cell.accessoryType = .checkmark
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let prevSelectedCell = m_optPrevSelectedCell {
            prevSelectedCell.accessoryType = .none
        }
        
        let selectedCell = self.tableView.cellForRow(at: indexPath)
        selectedCell?.accessoryType = .checkmark
        m_optPrevSelectedCell = selectedCell
        m_prevSelectedTheme = sectionDataTable[0].1[indexPath.row].param as! ThemeType
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
/**@section Event handler */
    private func onTouchEditCompleteBtn() {
        if m_prevSelectedTheme == GlobalSettingDataStorage.instance.getActiveTheme() {
            return
        }
        
        GlobalSettingDataStorage.instance.setActiveTheme(themeType: m_prevSelectedTheme)
        EventDispatcher.instance.dispatchEvent(eventType: "changeThemeComplete")
    }
}

public class EditThemeViewToolBarController : ToolbarController {
/**@section Variable */
    private var m_leftTabPrevButton: Button!
    private var m_rightTabPrevButton: Button!
    private var m_onTouchEditCompleteBtn: (() -> Void)?
    
/**@section Constructor */
    public init(rootViewController: UIViewController, onTouchEditCompleteBtn: (() -> Void)?) {
        super.init(rootViewController: rootViewController)
        
        m_onTouchEditCompleteBtn = onTouchEditCompleteBtn
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
/**@section Method */
    open override func prepare() {
        super.prepare()
        
        self.prepareStatusBar()
        self.prepareToolbar()
    }
    
    private func prepareStatusBar() {
        statusBarStyle = .lightContent
    }
    
    private func prepareToolbar() {
        self.prepareToolbarTitle()
        self.prepareToolbarLeftIcon()
        self.prepareToolbarRightIcon()
        
        self.prepareTheme()
    }
    
    private func prepareToolbarTitle() {
        toolbar.title = "테마 변경"
    }
    
    private func prepareToolbarLeftIcon() {
        m_leftTabPrevButton = IconButton(image: Icon.cm.arrowBack)
        m_leftTabPrevButton.addTarget(self, action: #selector(onTouchPrevButton), for: .touchUpInside)
        toolbar.leftViews = [m_leftTabPrevButton]
    }
    
    private func prepareToolbarRightIcon() {
        m_rightTabPrevButton = IconButton(title: "완료")
        m_rightTabPrevButton.titleLabel?.fontSize = 17.0
        m_rightTabPrevButton.addTarget(self, action: #selector(onTouchEditCompleteButton), for: .touchUpInside)
        toolbar.rightViews = [m_rightTabPrevButton]
    }
    
    private func prepareTheme() {
        m_leftTabPrevButton.tintColor = getCurrentThemeColorTable().toolBarIconColor
        m_rightTabPrevButton.titleColor = getCurrentThemeColorTable().toolBarIconColor
        
        statusBar.backgroundColor = getCurrentThemeColorTable().toolBarBackgroundColor
        
        toolbar.titleLabel.textColor = getCurrentThemeColorTable().toolBarTitleLabelColor
        toolbar.backgroundColor = getCurrentThemeColorTable().toolBarBackgroundColor
    }
    
/**@section Event handler */
    @objc private func onTouchPrevButton() {
        self.dismiss(animated: true)
    }
    
    @objc private func onTouchEditCompleteButton() {
        m_onTouchEditCompleteBtn?()
        
        self.dismiss(animated: true)
    }
}

