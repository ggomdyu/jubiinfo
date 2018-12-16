//
//  LazyPreparedViewController.swift
//  jubiinfo
//
//  Created by 차준호 on 17/12/2018.
//  Copyright © 2018 차준호. All rights reserved.
//

import Foundation
import Material

/**@brief   The view that initialized after packet response. */
public class LazyPreparedViewController : ViewController {
    
    override public func prepare() {
        super.prepare()
        
        self.subscribeLazyPrepareEventObserver()
    }
    
    open func lazyPrepare(_ param: Any?) {
    }
    
    private func subscribeLazyPrepareEventObserver() {
        EventDispatcher.instance.subscribeEvent(eventType: self.getEventNameRequiredToLazyPrepare(), eventObserver: EventObserver(releaseAfterDispatch: true) { (param: Any?) -> Void in
            
            self.lazyPrepare(param)
        })
    }
    
    open func getEventNameRequiredToLazyPrepare() -> String {
        return ""
    }
}
