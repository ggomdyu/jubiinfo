//
//  LoginViewController.swift
//  jubiinfo
//
//  Created by ggomdyu on 13/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Material

class LoginViewController: UIViewController {
    
    private var userEmailTextField = ErrorTextField()
    private var userPasswordTextField = ErrorTextField()
    private var jubeatWebSite = JubeatFestoWebSite()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let iconView = UIImageView()
        iconView.image = Icon.email
        userEmailTextField.leftView = iconView
        
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
        
        let iconView = UIImageView()
        iconView.image = Icon.edit
        userPasswordTextField.leftView = iconView
        
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
        
        self.processLogin(onLoginSucceed: {(isLoginSucceed: Bool) -> () in
            if isLoginSucceed {
                self.processTransitionToProfileView();
            }
            else {
                assert(false)
            }
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
        
        self.showLoadingIndicatorUI(message: "로그인 중...")
        
        jubeatWebSite.login(userId: userEmailTextField.text!, userPassword: userPasswordTextField.text!, onLoginComplete: { (isLoginSucceed: Bool) in
            
            self.hideLoadingIndicatorUI()
            
            onLoginSucceed(isLoginSucceed)
        })
    }
    
    private func processTransitionToProfileView() {
        
        self.showLoadingIndicatorUI(message: "플레이 데이터 로딩 중...")
        
        self.jubeatWebSite.requestMyPlayData(onRequestComplete: {(optPlayDataPageCache: UserData.PlayDataPageCache?) in
            
            self.hideLoadingIndicatorUI()
            
            guard let playDataPageCache = optPlayDataPageCache else {
                assert(false)
            }
            
            // Insert my user info cache into the global storage
            let userDataStorage = GlobalUserDataStorage.instance
            userDataStorage.initialize(myRivalId: playDataPageCache.rivalId, myUserData: UserData(rivalId: playDataPageCache.rivalId, playDataPageCache: playDataPageCache))

            // The view transition must be processed in the UI Thread!!
            DispatchQueue.global().async {
                self.transitionToProfileView()
            }
        })
    }
    
    private func checkTextFieldInputComplete(textField: ErrorTextField) -> Bool {
        guard let textFieldStr = textField.text else {
            return false
        }
        
        let isTextFieldEmpty: Bool = textFieldStr.count <= 0
        return !isTextFieldEmpty;
    }
    
    private func showLoadingIndicatorUI(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let loadingIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.style = UIActivityIndicatorView.Style.gray
        loadingIndicatorView.startAnimating();
        
        alertController.view.addSubview(loadingIndicatorView)
        
        self.present(alertController, animated: true, completion: nil)
    }

    private func transitionToProfileView() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        self.present(ProfileViewToolBarController(rootViewController: viewController), animated: true)
    }
    
    private func hideLoadingIndicatorUI() {
        self.dismiss(animated: false, completion: nil)
    }
}
