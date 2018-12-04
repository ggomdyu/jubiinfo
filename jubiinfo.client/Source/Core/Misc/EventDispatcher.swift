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
    private var m_eventSubscriberTable = [EventType: Box<[EventObserver]>] ()

/**@section Constructor */
    private init() {
    }
    
/**@section Method */
    public func subscribeEvent(eventType: EventType, eventObserver: EventObserver) {
        let eventObservers = m_eventSubscriberTable[eventType] ?? Box<[EventObserver]> ([EventObserver] ())
        eventObservers.value.append(eventObserver)
        
        m_eventSubscriberTable.updateValue(eventObservers, forKey: eventType)
    }
    
    public func unsubscribeEvent(eventType: EventType, eventObserver: EventObserver) -> Bool {
        let optEventObservers = m_eventSubscriberTable[eventType]
        guard let eventObservers = optEventObservers else {
            return false
        }
        
        let optUnsubscribeTargetEventObserverIndex: Int? = eventObservers.value.firstIndex(where: { (eventObserver2: EventObserver) -> Bool in
            return eventObserver === eventObserver2
        })
        guard let unsubscribeTargetEventObserverIndex: Int = optUnsubscribeTargetEventObserverIndex else {
            return false
        }
        eventObservers.value.remove(at: unsubscribeTargetEventObserverIndex)
        
        return true
    }
    
    public func dispatchEvent(eventType: EventType, eventParam: Any? = nil) {
        let optEventObservers = m_eventSubscriberTable[eventType]
        guard let eventObservers = optEventObservers else {
            return
        }
        
        for eventObserver in eventObservers.value {
            eventObserver.eventHandler(eventParam)
        }
        
        eventObservers.value.removeAll { (eventObserver: EventObserver) -> Bool in
            return eventObserver.releaseAfterDispatch
        }
    }
}
