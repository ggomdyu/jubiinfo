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
public class LazyInitializedView : UIView {
/**@section Method */
    open func initialize() {
        self.subscribeLazyPrepareEventObserver()
    }
    
    open func lazyInitialize(_ param: Any?) {
    }
    
    private func subscribeLazyPrepareEventObserver() {
        EventDispatcher.instance.subscribeEvent(eventType: self.getEventNameRequiredToLazyPrepare(), eventObserver: EventObserver(releaseAfterDispatch: true) { [weak self] (param: Any?) -> Void in
            
            self?.lazyInitialize(param)
        })
    }
    
    open func getEventNameRequiredToLazyPrepare() -> String {
        return ""
    }
}
