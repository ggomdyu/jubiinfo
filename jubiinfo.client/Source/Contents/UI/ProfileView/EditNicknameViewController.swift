//
//  EditNicknameViewController.swift
//  jubiinfo
//
//  Created by ggomdyu on 02/03/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Material

class EditNicknameViewController : EasyUITableViewController, UITextFieldDelegate {
/**@section Variable */
    private let m_nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", "[0-9a-zA-Z.\\-*& ]+")
    private var m_nicknameTextFieldCell: TextFieldUITableViewCell!
    private var m_optNetworkPendingIndicatorView: UIActivityIndicatorView?
    
/**@section Method */
    public static func show(currentViewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "EditNicknameViewController") as! EditNicknameViewController
        
        let toolbarController = EditNicknameViewToolbarController(rootViewController: viewController, onTouchPrevBtn: viewController.onTouchPrevBtn, onTouchEditCompleteBtn: viewController.onTouchEditCompleteBtn)
        
        let snackbarController = SnackbarController(rootViewController: toolbarController)
        snackbarController.isMotionEnabled = true
        snackbarController.motionTransitionType = .autoReverse(presenting: .push(direction: .left))
        snackbarController.modalPresentationStyle = .fullScreen
        
        currentViewController.present(snackbarController, animated: true)
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
            ("닉네임 변경", [
                (RowType.textfield, self.initNicknameTextFieldCell, nil)
            ]),
            ("닉네임 변경 후 게임을 10회 플레이해야 재변경이 가능합니다.\n최대 8글자까지 입력 가능하며, 특수문자는 제한적으로 허용됩니다.\n\n사용 가능한 문자 목록\n• 숫자 (0, 1, 2, ..., 9)\n• 알파벳 (A, B, C, ..., Z)\n• 특수문자 (., -, *, &, 공백)", [])
        ]
    }
    
    public func initNicknameTextFieldCell(param: Any?) {
        let cell = param as! TextFieldUITableViewCell
        cell.textField.delegate = self
        
        self.m_nicknameTextFieldCell = cell
        
        // Is the Network request pending now?
        guard let playDataPageCache = DataStorage.instance.queryMyUserData().playDataPageCache else {
            let loadingIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicatorView.hidesWhenStopped = true
            loadingIndicatorView.style = .gray
            loadingIndicatorView.startAnimating();
            loadingIndicatorView.center = cell.center
            
            cell.addSubview(loadingIndicatorView)
            cell.isUserInteractionEnabled = false
            
            m_optNetworkPendingIndicatorView = loadingIndicatorView
            
            EventDispatcher.instance.subscribeEvent(eventType: "requestMyPlayDataPageCacheComplete", eventObserver: EventObserver(releaseAfterDispatch: true) { [weak self] (param: Any?) -> Void in
                runTaskInMainThread { [weak self] in
                    self?.lazyInitNicknameTextFieldCell(playDataPageCache: param as! UserData.PlayDataPageCache)
                }
            })
            return
        }
        
        self.lazyInitNicknameTextFieldCell(playDataPageCache: playDataPageCache)
        
    }
    
    public func lazyInitNicknameTextFieldCell(playDataPageCache: UserData.PlayDataPageCache) {
        if let networkPendingIndicatorView = m_optNetworkPendingIndicatorView {
            networkPendingIndicatorView.removeFromSuperview()
            m_optNetworkPendingIndicatorView = nil
            m_nicknameTextFieldCell.isUserInteractionEnabled = true
        }
        
        m_nicknameTextFieldCell.textField.text = playDataPageCache.nickname
    }
    
    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 55
        }
        return 125
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.onTouchEditCompleteBtn()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isRemovingLetter = string.count <= 0
        if isRemovingLetter {
            return true
        }
        
        let isTextFieldReachedMaxCharCount = textField.text!.count >= 8
        if isTextFieldReachedMaxCharCount {
            return false
        }
        
        return m_nicknamePredicate.evaluate(with: string)
    }
    
    private func onTouchPrevBtn() {
         self.m_nicknameTextFieldCell.endEditing(true)
    }
    
    private func onTouchEditCompleteBtn() {
        m_nicknameTextFieldCell.endEditing(true)
        
        let myUserData = DataStorage.instance.queryMyUserData()
        
        let nicknameTextFieldText = m_nicknameTextFieldCell.textField.text!.uppercased()
        if nicknameTextFieldText.count <= 0 || nicknameTextFieldText == myUserData.playDataPageCache?.nickname {
            return
        }
        
        showYesNoPopup(self, "닉네임을 변경하시겠습니까?", "이 후 게임을 10회 플레이해야 재변경이 가능합니다.", {
            
            showLoadingIndicatorUI(self, "닉네임 변경 중...")
            JubeatWebServer.requestChangeName(newNickname: nicknameTextFieldText, onRequestComplete: { (changeNameStatus: JubeatWebServer.ChangeNameStatus) in
                runTaskInMainThread {
                    hideLoadingIndicatorUI(self, {
                        if changeNameStatus == .success {
                            self.dismiss(animated: true)
                            
                            myUserData.playDataPageCache?.nickname = nicknameTextFieldText
                            
                            EventDispatcher.instance.dispatchEvent(eventType: "requestNicknameChangeComplete", eventParam: nicknameTextFieldText)
                        }
                        else {
                            if changeNameStatus == .needMoreGamePlay {
                                showOkPopup(self, nil, "게임을 10회 플레이한 후 다시 시도해주세요.")
                            }
                            else if changeNameStatus == .nicknameHasForbiddenLetter {
                                showOkPopup(self, nil, "닉네임에 금지된 단어가 포함되어 있습니다.")
                            }
                        }
                    })
                }
            })
        })
    }
}

public class EditNicknameViewToolbarController : ToolbarController {
/**@section Variable */
    private let m_toolBarColor = UIColor(red: 36 / 255, green: 75 / 255, blue: 67 / 255, alpha: 1)
    private let m_toolBarLabelColor = UIColor(red: 255 / 255, green: 253 / 255, blue: 228 / 255, alpha: 1)
    private var m_leftTabPrevButton: Button!
    private var m_rightTabPrevButton: Button!
    private var m_onTouchPrevBtn: (() -> Void)?
    private var m_onTouchEditCompleteBtn: (() -> Void)?
    
    public init(rootViewController: UIViewController, onTouchPrevBtn: (() -> Void)?, onTouchEditCompleteBtn: @escaping () -> Void) {
        m_onTouchPrevBtn = onTouchPrevBtn
        m_onTouchEditCompleteBtn = onTouchEditCompleteBtn

        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
/**@section Method */
    open override func prepare() {
        super.prepare()
        
        self.prepareStatusBar()
        self.prepareToolbarTitle()
        self.prepareToolbarLeftIcon()
        self.prepareToolbarRightIcon()
        self.prepareTheme()
    }
    
    private func prepareStatusBar() {
        statusBarStyle = .lightContent
    }
    
    private func prepareToolbarTitle() {
        toolbar.title = "닉네임 변경"
    }
    
    private func prepareToolbarLeftIcon() {
        m_leftTabPrevButton = IconButton(image: Icon.cm.arrowBack)
        m_leftTabPrevButton.addTarget(self, action: #selector(onTouchPrevButton), for: .touchUpInside)
        toolbar.leftViews = [m_leftTabPrevButton]
    }
    
    private func prepareToolbarRightIcon() {
        m_rightTabPrevButton = IconButton(title: "완료")
        m_rightTabPrevButton.titleLabel?.fontSize = 17.0
        m_rightTabPrevButton.addTarget(self, action: #selector(onTouchEditCompleteBtn), for: .touchUpInside)
        toolbar.rightViews = [m_rightTabPrevButton]
    }
    
    private func prepareTheme() {
        m_leftTabPrevButton.tintColor = getCurrentThemeColorTable().toolBarIconColor
        m_rightTabPrevButton.titleColor = getCurrentThemeColorTable().toolBarIconColor
        
        toolbar.titleLabel.textColor = getCurrentThemeColorTable().toolBarTitleLabelColor
        toolbar.backgroundColor = getCurrentThemeColorTable().toolBarBackgroundColor
        
        statusBar.backgroundColor = getCurrentThemeColorTable().toolBarBackgroundColor
    }
    
/**@section Event handler */
    @objc private func onTouchPrevButton() {
        self.dismiss(animated: true)
        
        m_onTouchPrevBtn?()
    }
    
    @objc private func onTouchEditCompleteBtn() {
        m_onTouchEditCompleteBtn?()
    }
}

