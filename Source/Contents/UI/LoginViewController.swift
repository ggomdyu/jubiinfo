//
//  LoginViewController.swift
//  jubiinfo
//
//  Created by ggomdyu on 13/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Material

class LoginViewController: ViewController {
    
    private var userEmailTextField = ErrorTextField()
    private var userPasswordTextField = ErrorTextField()
    private var jubeatWebSite = JubeatFestoWebSite()
    
    override func prepare() {
        super.prepare()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.prepareUserEmailTextField()
        self.prepareUserPasswordTextField()
        self.prepareLoginButton()
    }
}

extension LoginViewController: TextFieldDelegate {
    private func prepareUserEmailTextField() {
        userEmailTextField.placeholder = "Email"
        userEmailTextField.detail = "e-AMUSEMENT 계정의 이메일 주소를 입력해주세요."
        userEmailTextField.error = "이메일 주소가 입력되지 않았습니다."
        userEmailTextField.delegate = self
        userEmailTextField.isPlaceholderUppercasedWhenEditing = false
        userEmailTextField.placeholderAnimation = .hidden
        userEmailTextField.addTarget(self, action: #selector(onTextFieldPressEnter), for: UIControl.Event.editingDidEndOnExit)
        
        view.layout(userEmailTextField).center(offsetY: -35).left(50).right(50)
    }
    
    private func prepareUserPasswordTextField() {
        userPasswordTextField.placeholder = "Password"
        userPasswordTextField.detail = "비밀번호를 입력해주세요."
        userPasswordTextField.error = "비밀번호가 입력되지 않았습니다."
        userPasswordTextField.isPlaceholderUppercasedWhenEditing = false
        userPasswordTextField.placeholderAnimation = .hidden
        userPasswordTextField.isVisibilityIconButtonEnabled = true
        userPasswordTextField.addTarget(self, action: #selector(onTextFieldPressEnter), for: UIControl.Event.editingDidEndOnExit)
        
        view.layout(userPasswordTextField).center(offsetY: 45).left(50).right(50)
    }
    
    private func prepareLoginButton() {
        let button = RaisedButton(title: "로그인", titleColor: .white)
        button.pulseColor = .white
        button.backgroundColor = Color.blue.base
        button.addTarget(self, action: #selector(onTouchLoginButton), for: UIControl.Event.touchUpInside)
        
        view.layout(button).center(offsetY: 170).width(150).height(44)
    }
}

extension LoginViewController {
    
    @objc
    internal func onTextFieldPressEnter(textField: UITextField) {
        textField.resignFirstResponder()
        
        guard let errorTextField = textField as? ErrorTextField else {
            return
        }
        
        let isTextFieldInputComplete = checkTextFieldInputComplete(textField: errorTextField)
        errorTextField.isErrorRevealed = !isTextFieldInputComplete
    }
    
    @objc
    internal func onTouchLoginButton(button: UIButton) {
        userEmailTextField.resignFirstResponder()
        userPasswordTextField.resignFirstResponder()
        
        showLoadingIndicatorUI(self, "로그인 중...", {
            self.processLogin(onLoginSucceed: {(isLoginSucceed: Bool) -> () in
                
                if isLoginSucceed {
                    hideLoadingIndicatorUI(self, { self.processTransitionToProfileView() })
                }
                else {
                    hideLoadingIndicatorUI(self)
                    showOkPopup(self, "에러", "예기치 않은 오류로 로그인에 실패했습니다.")
                }
            })
        })
    }
}

extension LoginViewController {
    private func processLogin(onLoginSucceed: @escaping (Bool) -> ()) {
#if !DEBUG
        let emailInputComplete = checkTextFieldInputComplete(textField: userEmailTextField)
        userEmailTextField.isErrorRevealed = !emailInputComplete
        
        let passwordInputComplete = checkTextFieldInputComplete(textField: userPasswordTextField)
        userPasswordTextField.isErrorRevealed = !passwordInputComplete
        
        if (emailInputComplete || passwordInputComplete) == false {
            return
        }
#else
        userEmailTextField.text = 
        userPasswordTextField.text =
#endif
        
        removeCookies(url: URL(string:"https://p.eagate.573.jp/")!)
        
        jubeatWebSite.login(userId: userEmailTextField.text!, userPassword: userPasswordTextField.text!, onLoginComplete: { (isLoginSucceed: Bool) in
            
            onLoginSucceed(isLoginSucceed)
        })
    }
    
    private func processTransitionToProfileView() {
        
        showLoadingIndicatorUI(self, "플레이 데이터 로딩 중...", {
            self.jubeatWebSite.requestMyPlayData(onRequestComplete: {(optMyPlayDataPageCache: UserData.MyPlayDataPageCache?) in
                
                guard let myPlayDataPageCache = optMyPlayDataPageCache else {
                    assert(false)
                }
                
                // Insert my user info cache into the global storage
                let userDataStorage = GlobalUserDataStorage.instance
                userDataStorage.initialize(myRivalId: myPlayDataPageCache.rivalId, myUserData: UserData(myPlayDataPageCache.rivalId, myPlayDataPageCache))
                
                hideLoadingIndicatorUI(self, { self.transitionToProfileView() })
            })
        })
    }
    
    private func checkTextFieldInputComplete(textField: ErrorTextField) -> Bool {
        guard let textFieldStr = textField.text else {
            return false
        }
        
        let isTextFieldEmpty: Bool = textFieldStr.count <= 0
        return !isTextFieldEmpty;
    }
    
    private func transitionToProfileView() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController

        self.present(ProfileViewToolBarController(rootViewController: viewController), animated: true)
    }
}
