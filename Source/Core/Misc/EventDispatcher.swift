//
//  EventDispatcher.swift
//  jubiinfo
//
//  Created by ggomdyu on 15/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation

public typealias EventType = String

public class EventObserver {
/**@section Constructor */
    public init(releaseAfterDispatch: Bool, eventHandler: @escaping (Any?) -> Void) {
        self.releaseAfterDispatch = releaseAfterDispatch
        self.eventHandler = eventHandler
    }
    
/**@section Variable */
    public let releaseAfterDispatch: Bool
    public let eventHandler: (Any?) -> Void
}

public class EventDispatcher {
/**@section Variable */
    public static let instance = EventDispatcher()
    private var eventSubscriberTable = [EventType: [EventObserver]] ()

/**@section Constructor */
    private init() {
    }
    
/**@section Method */
    public func subscribeEvent(eventType: EventType, eventObserver: EventObserver) {
        var eventObservers = eventSubscriberTable[eventType] ?? [EventObserver] ()
        eventObservers.append(eventObserver)
        
        eventSubscriberTable.updateValue(eventObservers, forKey: eventType)
    }
    
    public func unsubscribeEvent(eventType: EventType, eventObserver: EventObserver) -> Bool {
        let optEventObservers = eventSubscriberTable[eventType]
        guard var eventObservers = optEventObservers else {
            return false
        }
        
        let optUnsubscribeTargetEventObserverIndex: Int? = eventObservers.firstIndex(where: { (eventObserver2: EventObserver) -> Bool in
            return eventObserver === eventObserver2
        })
        guard let unsubscribeTargetEventObserverIndex: Int = optUnsubscribeTargetEventObserverIndex else {
            return false
        }
        eventObservers.remove(at: unsubscribeTargetEventObserverIndex)
        
        return true
    }
    
    public func dispatchEvent(eventType: EventType, eventParam: Any? = nil) {
        let optEventObservers = eventSubscriberTable[eventType]
        guard var eventObservers = optEventObservers else {
            return
        }
        
        for eventObserver in eventObservers {
            eventObserver.eventHandler(eventParam)
        }
        
        eventObservers.removeAll { (eventObserver: EventObserver) -> Bool in
            return eventObserver.releaseAfterDispatch
        }
    }
}
