//
//  LoginViewController.swift
//  jubiinfo
//
//  Created by ggomdyu on 13/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Alamofire
import Material

class LoginViewController: ViewController, TextFieldDelegate {
/**@section Variable */
    private let m_errorTextFieldDividerActiveColor = UIColor(red: 234 / 255, green: 139 / 255, blue: 61 / 255, alpha: 1.0)
    private let m_errorTextFieldTintColor = UIColor(red: 234 / 255, green: 139 / 255, blue: 61 / 255, alpha: 1.0)
    private let m_loginButtonColor = UIColor(red: 47 / 255, green: 100 / 255, blue: 90 / 255, alpha: 1)
    private let m_loginButtonLabelColor = UIColor(red: 255 / 255, green: 253 / 255, blue: 228 / 255, alpha: 1)
    private var m_userEmailTextField = ErrorTextField()
    private var m_userPasswordTextField = ErrorTextField()
    
/**@section Overrided method */
    override func prepare() {
        super.prepare()
        
        // Refresh UI
        self.prepareUserEmailTextField()
        self.prepareUserPasswordTextField()
        self.prepareLoginButton()
        
        // Refresh managed datas
        self.prepareUpdateCustomMusicDatas()
    }

/**@section Method */
    private func prepareUserEmailTextField() {
        m_userEmailTextField.placeholder = "Email"
        m_userEmailTextField.detail = "e-AMUSEMENT 계정의 이메일 주소를 입력해주세요."
        m_userEmailTextField.error = "이메일 주소가 입력되지 않았습니다."
        m_userEmailTextField.delegate = self
        m_userEmailTextField.tintColor = m_errorTextFieldTintColor
        m_userEmailTextField.dividerActiveColor = m_errorTextFieldDividerActiveColor
        m_userEmailTextField.isPlaceholderUppercasedWhenEditing = false
        m_userEmailTextField.placeholderAnimation = .hidden
        m_userEmailTextField.addTarget(self, action: #selector(onTextFieldPressEnter), for: UIControl.Event.editingDidEndOnExit)
        
        view.layout(m_userEmailTextField).top(200).left(50).right(50)
    }
    
    private func prepareUserPasswordTextField() {
        m_userPasswordTextField.placeholder = "Password"
        m_userPasswordTextField.detail = "비밀번호를 입력해주세요."
        m_userPasswordTextField.error = "비밀번호가 입력되지 않았습니다."
        m_userPasswordTextField.tintColor = m_errorTextFieldTintColor
        m_userPasswordTextField.dividerActiveColor = m_errorTextFieldDividerActiveColor
        m_userPasswordTextField.isPlaceholderUppercasedWhenEditing = false
        m_userPasswordTextField.placeholderAnimation = .hidden
        m_userPasswordTextField.isVisibilityIconButtonEnabled = true
        m_userPasswordTextField.addTarget(self, action: #selector(onTextFieldPressEnter), for: UIControl.Event.editingDidEndOnExit)
        
        view.layout(m_userPasswordTextField).top(280).left(50).right(50)
    }
    
    private func prepareLoginButton() {
        let button = RaisedButton(title: "로그인", titleColor: .white)
        button.pulseColor = .white
        button.backgroundColor = m_loginButtonColor
        button.titleLabel?.textColor = m_loginButtonLabelColor
        button.addTarget(self, action: #selector(onTouchLoginButton), for: UIControl.Event.touchUpInside)
        
        view.layout(button).center().top(395).width(150).height(44)
    }
    
    private func startToLogin() {
#if !DEBUG
        let isEmailInputComplete = checkTextFieldInputComplete(textField: userEmailTextField)
        userEmailTextField.isErrorRevealed = !emailInputComplete
        
        let isPasswordInputComplete = checkTextFieldInputComplete(textField: userPasswordTextField)
        userPasswordTextField.isErrorRevealed = !passwordInputComplete
        
        if (isEmailInputComplete || isPasswordInputComplete) == false {
            return
        }
#else
        m_userEmailTextField.text = "ggomdyu@gmail.com"
        m_userPasswordTextField.text = ""
#endif
        
        removeCookies(url: URL(string:"https://p.eagate.573.jp/")!)
        
        showLoadingIndicatorUI(self, "로그인 중...")
        
        JubeatWebServer.login(userId: m_userEmailTextField.text!, userPassword: m_userPasswordTextField.text!, onLoginComplete: { (loginStatus: JubeatWebServer.LoginStatus) in
        
            SpinLock { return GlobalDataStorage.instance.isCustomMusicDatasInitialized() }
        
            runTaskInMainThread {
                hideLoadingIndicatorUI(self, {
                    if loginStatus == .Succees {
                        ProfileViewController.show(currentViewController: self)
                    }
                    else if loginStatus == .InvalidEmailOrPassword {
                        showOkPopup(self, "에러", "올바른 이메일 계정이나 비밀번호를 입력해주세요.")
                    }
                    else {
                        showOkPopup(self, "에러", "예기치 않은 오류로 로그인에 실패했습니다.")
                    }
                })
            }
        })
    }
    
    private func isTextFieldInputComplete(textField: ErrorTextField) -> Bool {
        guard let textFieldStr = textField.text else {
            return false
        }
        
        let isTextFieldEmpty: Bool = textFieldStr.count <= 0
        return !isTextFieldEmpty;
    }
    
    private func prepareUpdateCustomMusicDatas() {
        JubeatWebServer.requestCMDChecksum { (isRequestSucceed: Bool, checksum: String?) in
            if isRequestSucceed {
                JubeatWebServer.requestCustomMusicDatas(serverCMDChecksum: checksum!, onRequestComplete: {(isRequestSucceed2: Bool, optCustomMusicDatas: [MusicId : MusicScoreData.CustomData]?) in
                    if let customMusicDatas = optCustomMusicDatas {
                        GlobalDataStorage.instance.initCustomMusicDatas(musicCustomDatas: customMusicDatas)
                        
                        EventDispatcher.instance.dispatchEvent(eventType: "requestCustomMusicDatasDataComplete", eventParam: customMusicDatas)
                    }
                })
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.prepareUpdateCustomMusicDatas();
                })
            }
        }
    }

/**@section Event handler */
    @objc internal func onTextFieldPressEnter(textField: UITextField) {
        textField.resignFirstResponder()
        
        guard let errorTextField = textField as? ErrorTextField else {
            return
        }
        
        let isTextFieldInputComplete = self.isTextFieldInputComplete(textField: errorTextField)
        errorTextField.isErrorRevealed = !isTextFieldInputComplete
    }
    
    @objc internal func onTouchLoginButton(button: UIButton) {
        m_userEmailTextField.resignFirstResponder()
        m_userPasswordTextField.resignFirstResponder()
        
        self.startToLogin()
    }
}
