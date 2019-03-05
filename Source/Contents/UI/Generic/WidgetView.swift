//
//  LazyPreparedView.swift
//  jubiinfo
//
//  Created by ggomdyu on 17/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Material

/**@brief   The view that initialized after packet response. */
public class WidgetView : UIView {
/**@section Property */
    public var lazyInitializeEventName: String {
        return ""
    }
    public var isLazyInitialized: Bool {
        get {
            return m_isLazyInitialized
        }
        set {
            m_isLazyInitialized = newValue
        }
    }

/**@section Variable */
    private var m_isLazyInitialized: Bool = false
    private var m_optEventObserver: EventObserver?
    
/**@section Destructor */
    deinit {
        if let eventObserver = m_optEventObserver {
            EventDispatcher.instance.unsubscribeEvent(eventType: self.lazyInitializeEventName, eventObserver: eventObserver)
            m_optEventObserver = nil
        }
    }
    
/**@section Method */
    public func initialize() {
        if m_isLazyInitialized == false {
            self.subscribeLazyInitEventObserver()
        }
    }
    
    public func lazyInitialize(_ param: Any?) {
        m_isLazyInitialized = true
    }
    
    private func subscribeLazyInitEventObserver() {
        if m_optEventObserver == nil {
            let eventObserver = EventObserver(releaseAfterDispatch: false) { [weak self] (param: Any?) -> Void in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.lazyInitialize(param)
            }
            m_optEventObserver = eventObserver
            
            EventDispatcher.instance.subscribeEvent(eventType: self.lazyInitializeEventName, eventObserver: eventObserver)
        }
    }
}
