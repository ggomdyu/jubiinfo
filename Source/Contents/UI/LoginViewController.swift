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

class LoginViewController: ViewController {
    
    private var userEmailTextField = ErrorTextField()
    private var userPasswordTextField = ErrorTextField()
    private var jubeatWebSite = JubeatFestoWebSite()
    private var errorTextFieldDividerActiveColor = UIColor(red: 234 / 255, green: 139 / 255, blue: 61 / 255, alpha: 1.0)
    private var errorTextFieldTintColor = UIColor(red: 234 / 255, green: 139 / 255, blue: 61 / 255, alpha: 1.0)
    private var loginButtonColor = UIColor(red: 47 / 255, green: 100 / 255, blue: 90 / 255, alpha: 1)
    private var loginButtonLabelColor = UIColor(red: 255 / 255, green: 253 / 255, blue: 228 / 255, alpha: 1)
    
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
        userEmailTextField.tintColor = self.errorTextFieldTintColor
        userEmailTextField.dividerActiveColor = self.errorTextFieldDividerActiveColor
        userEmailTextField.isPlaceholderUppercasedWhenEditing = false
        userEmailTextField.placeholderAnimation = .hidden
        userEmailTextField.addTarget(self, action: #selector(onTextFieldPressEnter), for: UIControl.Event.editingDidEndOnExit)
        
        view.layout(userEmailTextField).top(200).left(50).right(50)
    }
    
    private func prepareUserPasswordTextField() {
        userPasswordTextField.placeholder = "Password"
        userPasswordTextField.detail = "비밀번호를 입력해주세요."
        userPasswordTextField.error = "비밀번호가 입력되지 않았습니다."
        userPasswordTextField.tintColor = self.errorTextFieldTintColor
        userPasswordTextField.dividerActiveColor = self.errorTextFieldDividerActiveColor
        userPasswordTextField.isPlaceholderUppercasedWhenEditing = false
        userPasswordTextField.placeholderAnimation = .hidden
        userPasswordTextField.isVisibilityIconButtonEnabled = true
        userPasswordTextField.addTarget(self, action: #selector(onTextFieldPressEnter), for: UIControl.Event.editingDidEndOnExit)
        
        view.layout(userPasswordTextField).top(280).left(50).right(50)
    }
    
    private func prepareLoginButton() {
        let button = RaisedButton(title: "로그인", titleColor: .white)
        button.pulseColor = .white
        button.backgroundColor = loginButtonColor
        button.titleLabel?.textColor = loginButtonLabelColor
        button.addTarget(self, action: #selector(onTouchLoginButton), for: UIControl.Event.touchUpInside)
        
        view.layout(button).center().top(395).width(150).height(44)
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
#endif
        
        removeCookies(url: URL(string:"https://p.eagate.573.jp/")!)
        
        jubeatWebSite.login(userId: userEmailTextField.text!, userPassword: userPasswordTextField.text!, onLoginComplete: { (isLoginSucceed: Bool) in
            
            onLoginSucceed(isLoginSucceed)
        })
    }
    
    private func processTransitionToProfileView() {
        
        showLoadingIndicatorUI(self, "플레이 데이터 로딩 중...", {

            let userDataStorage = GlobalUserDataStorage.instance
            
            // Load play data page
            var isCompleteToRequestMyPlayDataPage = false
            self.jubeatWebSite.requestMyPlayData { (optMyPlayDataPageCache2: UserData.MyPlayDataPageCache?) in
                if let myPlayDataPageCache = optMyPlayDataPageCache2 {
                    // Insert my user data cache into the global storage
                    userDataStorage.initialize(myRivalId: myPlayDataPageCache.rivalId, myUserData: UserData(myPlayDataPageCache.rivalId, myPlayDataPageCache))
                }
                
                isCompleteToRequestMyPlayDataPage = true
            }
            
            // Load rank data page
            var optMyRankDataPageCache: UserData.RankDataPageCache? = nil
            var isCompleteToRequestMyRankDataPage = false
            self.jubeatWebSite.requestMyRankData { (optMyRankDataPageCache2: UserData.RankDataPageCache?) in
                
                optMyRankDataPageCache = optMyRankDataPageCache2
                isCompleteToRequestMyRankDataPage = true
            }

            // Wait until both loadings finished.
            SpinLock(isLockFinish: { () -> (Bool) in
                return isCompleteToRequestMyPlayDataPage && isCompleteToRequestMyRankDataPage
            })
            
            if let myRankDataPageCache = optMyRankDataPageCache {
                // Insert my rank data cache into the global storage
                userDataStorage.queryMyUserData().rankDataPageCache = myRankDataPageCache
            }
            
            hideLoadingIndicatorUI(self, { self.transitionToProfileView() })
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
        let profileViewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        let toolBarController = ProfileViewToolBarController(rootViewController: profileViewController)

        let navigationDrawerController = NavigationDrawerController(rootViewController: toolBarController, leftViewController: ProfileViewMenuController())
        navigationDrawerController.isMotionEnabled = true
        navigationDrawerController.motionTransitionType = .autoReverse(presenting: .push(direction: .left))
        
        self.present(navigationDrawerController, animated: true)
    }
}
