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

/**@brief   This parser does not execute DOM parsing for performance. */
class MusicDataPageParser {
    
    private var html: String
    private var lastParsedPos: String.Index
    
    public init(html: String) {
        self.html = html
        self.lastParsedPos = html.startIndex
    }
    
    public func parseNext() -> SimpleMusicData? {
        let optMusicFinder = html.range(of: "<td><span>", options: String.CompareOptions.caseInsensitive, range: self.lastParsedPos..<html.endIndex)
        guard let musicFinder = optMusicFinder else {
            return nil
        }
        
        // Parse the music ID
        let optMusicIdStartPosFinder = html.range(of: "mid=", options: String.CompareOptions.caseInsensitive, range: musicFinder.upperBound..<html.endIndex)
        guard let musicIdStartPosFinder = optMusicIdStartPosFinder else {
            return nil
        }
        
        let optMusicIdEndPosFinder = html.range(of: "\"", options: String.CompareOptions.caseInsensitive, range: musicIdStartPosFinder.upperBound..<html.endIndex)
        guard let musicIdEndPosFinder = optMusicIdEndPosFinder else {
            return nil
        }
        
        let musicId = Int(html[musicIdStartPosFinder.upperBound..<musicIdEndPosFinder.lowerBound]) ?? -1

        // Parse the music name
        let optMusicNameStartPosFinder = html.range(of: ">", options: String.CompareOptions.caseInsensitive, range: musicIdEndPosFinder.upperBound..<html.endIndex)
        guard let musicNameStartPosFinder = optMusicNameStartPosFinder else {
            return nil
        }
        
        let optMusicNameEndPosFinder = html.range(of: "<", options: String.CompareOptions.caseInsensitive, range: musicNameStartPosFinder.upperBound..<html.endIndex)
        guard let musicNameEndPosFinder = optMusicNameEndPosFinder else {
            return nil
        }
        
        let musicName = String(html[musicNameStartPosFinder.upperBound..<musicNameEndPosFinder.lowerBound])
        
        // Parse the music scores
        var musicScoreFinder: String.Index = musicNameEndPosFinder.upperBound
        var scores = [Int] ()
        for _ in 0...2 {
            let optMusicScoreStartPosFinder = html.range(of: "<td>", options: String.CompareOptions.caseInsensitive, range: musicScoreFinder..<html.endIndex)
            guard let musicScoreStartPosFinder = optMusicScoreStartPosFinder else {
                scores.append(-1)
                continue
            }
            
            let optMusicScoreEndPosFinder = html.range(of: "<", options: String.CompareOptions.caseInsensitive, range: musicScoreStartPosFinder.upperBound..<html.endIndex)
            guard let musicScoreEndPosFinder = optMusicScoreEndPosFinder else {
                scores.append(-1)
                continue
            }
            
            let scoreStr = String(html[musicScoreStartPosFinder.upperBound..<musicScoreEndPosFinder.lowerBound]).trimmingCharacters(in: .whitespaces)
            if (scoreStr != "-") {
                scores.append(Int(scoreStr) ?? -1)
            }
            else {
                scores.append(0)
            }
            
            musicScoreFinder = musicScoreStartPosFinder.upperBound
        }
        
        self.lastParsedPos = musicScoreFinder
        
        return SimpleMusicData(musicName: musicName, musicId: musicId, basicScore: scores[0], advancedScore: scores[1], extremeScore: scores[2])
    }
}

class LoginViewController: ViewController {
    
    private var userEmailTextField = ErrorTextField()
    private var userPasswordTextField = ErrorTextField()
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
        
        JubeatFestoWebSite.instance.login(userId: userEmailTextField.text!, userPassword: userPasswordTextField.text!, onLoginComplete: { (isLoginSucceed: Bool) in
            
            onLoginSucceed(isLoginSucceed)
        })
    }
    
    private func processTransitionToProfileView() {
        
//        showLoadingIndicatorUI(self, "플레이 데이터 로딩 중...", {
        
            let userDataStorage = GlobalUserDataStorage.instance
            
            // Load MY MUSIC DATAS....
//            var musicDatas = [SimpleMusicData] ()
//            var downloadedMusicPageCount: Int32 = 0
//            for i in 1...3 {
//                self.jubeatWebSite.requestMyMusicData(pageIndex: i, onRequestComplete: { (musicDatas2: [SimpleMusicData]) in
//                    OSAtomicIncrement32(&downloadedMusicPageCount)
//
//                    musicDatas.append(contentsOf: musicDatas2)
//                })
//            }
//
//            let defaults = UserDefaults.standard
//            defaults.set(25, forKey: "Age")
//            defaults.set(true, forKey: "UseTouchID")
//            defaults.set(CGFloat.pi, forKey: "Pi")
        
            // Wait until both loadings finished.
//            SpinLock { () -> (Bool) in
//                return isCompleteToRequestMyPlayDataPage && isCompleteToRequestMyRankDataPage && downloadedMusicPageCount >= 3
//            }
//
//            guard let myPlayDataPageCache = optMyPlayDataPageCache,
//                  let myRankDataPageCache = optMyRankDataPageCache else {
//                hideLoadingIndicatorUI(self, { showOkPopup(self, "에러", "") })
//                return
//            }
            
            // Insert my user data cache into the global storage
//            let myUserData = UserData(myPlayDataPageCache.rivalId, false, myPlayDataPageCache, myRankDataPageCache)
//            userDataStorage.initialize(myRivalId: myPlayDataPageCache.rivalId, myUserData: myUserData)
//            
//            myUserData.musicDataCaches = musicDatas
//
//            hideLoadingIndicatorUI(self, {
                ProfileViewController.show(currentView: self)
//            })
//        })
    }
    
    private func checkTextFieldInputComplete(textField: ErrorTextField) -> Bool {
        guard let textFieldStr = textField.text else {
            return false
        }
        
        let isTextFieldEmpty: Bool = textFieldStr.count <= 0
        return !isTextFieldEmpty;
    }
}
