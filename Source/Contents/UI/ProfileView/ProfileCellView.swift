//
//  ProfileCellView.swift
//  jubiinfo
//
//  Created by ggomdyu on 10/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Material
import Motion

class ProfileCellView : LazyInitializedView {
/**@section Variable */
    @IBOutlet weak var m_emblemImageView: UIImageView!
    @IBOutlet weak var m_rivalIdLabel: UILabel!
    @IBOutlet weak var m_nicknameLabel: UILabel!
    @IBOutlet weak var m_designationLabel: UILabel!
    @IBOutlet weak var m_contentsView: UIView!

/**@section Overrided method */
    open override func initialize() {
        super.initialize()

        m_contentsView.alpha = 0.0
        m_emblemImageView.alpha = 0.0
    }
    
    open override func lazyInitialize(_ param: Any?) {
        super.lazyInitialize(param)
        
        let myUserData = GlobalDataStorage.instance.queryMyUserData()
        guard let myPlayDataPageCache = myUserData.playDataPageCache as? UserData.MyPlayDataPageCache else {
            return
        }
        
        self.prepareEmblemImage(myPlayDataPageCache: myPlayDataPageCache)
        self.prepareTouchEvent()
        
        m_rivalIdLabel.text = "RIVAL ID: \(myPlayDataPageCache.rivalId)"
        m_nicknameLabel.text = myPlayDataPageCache.nickname
        m_designationLabel.text = myPlayDataPageCache.designation

        m_contentsView.animate(.fadeIn)
    }
    
    open override func getEventNameRequiredToLazyPrepare() -> String {
        return "requestMyPlayDataPageCacheComplete"
    }
    
    override var canBecomeFirstResponder: Bool { return true }

/**@section Method */
    /**@brief   Download the emblem image and set it to the user cache. */
    private func prepareEmblemImage(myPlayDataPageCache: UserData.MyPlayDataPageCache) {
        downloadImageAsync(imageUrl: myPlayDataPageCache.emblemImageUrl, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
            if (isDownloadSucceed) {
                myPlayDataPageCache.emblemImage = image
                
                runTaskInMainThread {
                    self.m_emblemImageView.image = image
                    self.m_emblemImageView.animate(.fadeIn)
                }
            }
        })
    }
    
    private func prepareTouchEvent() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressCell))
        longPressGestureRecognizer.minimumPressDuration = 0.3
        self.addGestureRecognizer(longPressGestureRecognizer)
    }
    
/**@section Event handler */
    @objc private func onLongPressCell(_ sender: UILongPressGestureRecognizer) {
        guard let superView = self.superview, sender.state == .began else {
            return
        }
        
        self.becomeFirstResponder()
        
        UIMenuController.shared.menuItems = [
            UIMenuItem(title: "라이벌 아이디 복사", action: #selector(onTapCopyRivalIdMenuItem)),
            UIMenuItem(title: "닉네임 복사", action: #selector(onTapCopyNicknameMenuItem)),
            UIMenuItem(title: "칭호 복사", action: #selector(onTapCopyDesignationMenuItem))
        ]
        UIMenuController.shared.setTargetRect(self.frame, in: superView)
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
    
    @objc private func onTapCopyRivalIdMenuItem() {
        let myUserData = GlobalDataStorage.instance.queryMyUserData()
        if let myPlayDataPageCache = myUserData.playDataPageCache as? UserData.MyPlayDataPageCache {
            UIPasteboard.general.string = myPlayDataPageCache.rivalId
        }
        
        self.resignFirstResponder()
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
    
    @objc private func onTapCopyNicknameMenuItem() {
        if let nicknameText = m_nicknameLabel.text {
            UIPasteboard.general.string = nicknameText
        }
        
        self.resignFirstResponder()
    }
    
    @objc private func onTapCopyDesignationMenuItem() {
        if let designationText = m_designationLabel.text {
            UIPasteboard.general.string = designationText
        }
        
        self.resignFirstResponder()
    }
}
