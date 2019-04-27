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
    public var isNeedToLazyInitialize: Bool { return lazyInitializeParam == nil }
    public var lazyInitializeParam: Any? { return nil }
    
/**@section Variable */
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
        if self.isNeedToLazyInitialize {
            self.subscribeLazyInitEventObserver()
        }
        else {
            self.lazyInitialize(self.lazyInitializeParam)
        }
    }
    
    public func lazyInitialize(_ param: Any?) {
    }
    
    private func subscribeLazyInitEventObserver() {
        if m_optEventObserver == nil {
            let eventObserver = EventObserver(releaseAfterDispatch: true) { [weak self] (param: Any?) -> Void in
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
