//
//  ProfileWidgetView.swift
//  jubiinfo
//
//  Created by ggomdyu on 10/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Material
import Motion

class ProfileWidgetView : WidgetView {
/**@section Variable */
    @IBOutlet weak var m_emblemImageView: UIImageView!
    @IBOutlet weak var m_rivalIdLabel: UILabel!
    @IBOutlet weak var m_nicknameLabel: UILabel!
    @IBOutlet weak var m_designationLabel: UILabel!
    @IBOutlet weak var m_contentsView: UIView!
    private var m_optNicknameChangeEventObserver: EventObserver?

/**@section Property */
    override var canBecomeFirstResponder: Bool { return true }
    override public var lazyInitializeParam: Any? { return DataStorage.instance.queryMyUserData().playDataPageCache }
    
/**@section Variable */
    public override var lazyInitializeEventName: String {
        return "requestMyPlayDataPageCacheComplete"
    }
    
/**@section Destructor */
    deinit {
        if let nicknameChangeEventObserver = m_optNicknameChangeEventObserver {
            EventDispatcher.instance.unsubscribeEvent(eventType: self.lazyInitializeEventName, eventObserver: nicknameChangeEventObserver)
            m_optNicknameChangeEventObserver = nil
        }
    }
    
/**@section Method */
    public override func initialize() {
        m_contentsView.alpha = 0.0
        m_emblemImageView.alpha = 0.0
        
        super.initialize()
    }
    
    public override func lazyInitialize(_ param: Any?) {
        super.lazyInitialize(param)
        
        guard let myPlayDataPageCache = param as? UserData.MyPlayDataPageCache else {
            return
        }
        
        self.prepareEmblemImage(myPlayDataPageCache: myPlayDataPageCache)
        self.prepareTouchEvent()
        
        m_rivalIdLabel.text = "RIVAL ID: \(myPlayDataPageCache.rivalId)"
        m_nicknameLabel.text = myPlayDataPageCache.nickname
        m_designationLabel.text = myPlayDataPageCache.designation

        m_contentsView.animate(.fadeIn)
        
        if m_optNicknameChangeEventObserver == nil {
            self.prepareEventObserver()
        }
    }
    
    /**@brief   Download the emblem image and set it to the user cache. */
    private func prepareEmblemImage(myPlayDataPageCache: UserData.MyPlayDataPageCache) {
        downloadImageAsync(imageUrl: myPlayDataPageCache.emblemImageUrl, isWriteCache: true, isReadCache: false, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
            if isDownloadSucceed {
                runTaskInMainThread { [weak self] () in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    strongSelf.m_emblemImageView.image = image
                    strongSelf.m_emblemImageView.animate(.fadeIn)
                }
            }
            else {
                // If an server error ocurred, then use cached emblem image.
                downloadImageAsync(imageUrl: myPlayDataPageCache.emblemImageUrl, isWriteCache: false, isReadCache: true, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
                    if isDownloadSucceed {
                        runTaskInMainThread { [weak self] () in
                            guard let strongSelf = self else {
                                return
                            }
                            
                            strongSelf.m_emblemImageView.image = image
                            strongSelf.m_emblemImageView.animate(.fadeIn)
                        }
                    }
                })
            }
        })
    }
    
    private func prepareTouchEvent() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressCell))
        longPressGestureRecognizer.minimumPressDuration = 0.3
        self.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    private func prepareEventObserver() {
        let nicknameChangeEventObserver = EventObserver(releaseAfterDispatch: false, eventHandler: { [weak self] (param: Any?) in
            self?.m_nicknameLabel.text = param as? String
        })
        m_optNicknameChangeEventObserver = nicknameChangeEventObserver
        
        EventDispatcher.instance.subscribeEvent(eventType: "requestNicknameChangeComplete", eventObserver: nicknameChangeEventObserver)
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
        let myUserData = DataStorage.instance.queryMyUserData()
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
