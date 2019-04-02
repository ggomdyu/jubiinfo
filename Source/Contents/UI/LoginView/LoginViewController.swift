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
    
/**@section Method */
    public static func show(currentViewController: UIViewController) {
        let viewController = self.create()
        currentViewController.present(viewController, animated: true)
    }
    
    public static func create() -> LoginViewController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginViewController.isMotionEnabled = true
        loginViewController.motionTransitionType = .autoReverse(presenting: .push(direction: .right))
        
        return loginViewController
    }
    
    override func prepare() {
        super.prepare()
        
        // Refresh UI
        self.prepareUserEmailTextField()
        self.prepareUserPasswordTextField()
        self.prepareLoginButton()
    }

    private func prepareUserEmailTextField() {
        m_userEmailTextField.placeholder = "Email"
        m_userEmailTextField.detail = "e-AMUSEMENT 계정의 이메일 주소를 입력해주세요."
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
        removeCookies(url: URL(string:"https://p.eagate.573.jp/")!)

        showLoadingIndicatorUI(self, "로그인 중...")

        JubeatWebServer.login(userId: m_userEmailTextField.text!, userPassword: m_userPasswordTextField.text!, onLoginComplete: { (loginStatus: JubeatWebServer.LoginStatus) in

            runTaskInMainThread {
                hideLoadingIndicatorUI(self, {
                    if loginStatus == .success {
                        let profileViewController = ProfileViewController.create()
                        self.present(profileViewController, animated: true)
                    }
                    else if loginStatus == .invalidEmailOrPassword {
                        showOkPopup(self, "오류", "올바른 이메일 계정이나 비밀번호를 입력해주세요.")
                    }
                    else {
                        showOkPopup(self, "오류", "예기치 않은 오류로 로그인에 실패했습니다.")
                    }
                })
            }
        })
    }
    
/**@section Event handler */
    @objc internal func onTextFieldPressEnter(textField: UITextField) {
        textField.resignFirstResponder()
        
        guard let errorTextField = textField as? ErrorTextField else {
            return
        }
        
        let isTextEmpty = errorTextField.text!.count <= 0
        errorTextField.isErrorRevealed = isTextEmpty
    }
    
    @objc internal func onTouchLoginButton(button: UIButton) {
        m_userEmailTextField.resignFirstResponder()
        m_userPasswordTextField.resignFirstResponder()
        
        var isErrorOccured = false
        
        let isEmailTextEmpty = m_userEmailTextField.text!.count <= 0
        if isEmailTextEmpty {
            m_userEmailTextField.error = "이메일 주소가 입력되지 않았습니다."
            m_userEmailTextField.isErrorRevealed = true
            isErrorOccured = true
        }
        
        let isEmailTextFormat = isEmailFormat(email: m_userEmailTextField.text!)
        if isEmailTextFormat == false {
            m_userEmailTextField.error = "유효하지 않은 이메일 주소 형식입니다."
            m_userEmailTextField.isErrorRevealed = true
            isErrorOccured = true
        }
        
        let isPasswordTextEmpty = m_userPasswordTextField.text!.count <= 0
        if isPasswordTextEmpty {
            m_userPasswordTextField.error = "비밀번호가 입력되지 않았습니다."
            m_userPasswordTextField.isErrorRevealed = true
            isErrorOccured = true
        }
        
        if isErrorOccured {
            return
        }
        
        self.startToLogin()
    }
}
