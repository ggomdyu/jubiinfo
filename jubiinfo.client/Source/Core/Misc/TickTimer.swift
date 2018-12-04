//
//  TickTimer.swift
//  jubiinfo
//
//  Created by ggomdyu on 03/02/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation

public class TickTimer {
/**@section Property */
    public var duration: Double { return m_duration }
    public var totalElapsedTime: Double { return m_totalElapsedTime }
    
/**@section Variable */
    private var m_duration: Double = 0.0
    private var m_oldTime: Double = 0.0
    private var m_totalElapsedTime: Double = 0.0
    private var m_optOnElapseTime: ((Double) -> Void)?
    private var m_optOnFinishTimer: (() -> Void)?
    private var m_optTimer: Timer?
    
/**@section Method */
    public func initialize(_ duration: Double, _ optOnElapseTime: ((Double) -> Void)? = nil, _ optOnFinishTimer: (() -> Void)? = nil) {
        if let timer = m_optTimer {
            timer.invalidate()
        }
        
        m_duration = duration
        m_optOnElapseTime = optOnElapseTime
        m_optOnFinishTimer = optOnFinishTimer
        m_oldTime = Date().timeIntervalSince1970
        m_totalElapsedTime = 0.0
        
        let timer = Timer(timeInterval: 0.0, target: self, selector: #selector(self.onTimeElapsed), userInfo: nil, repeats: true)
        m_optTimer = timer
        
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }
    
/**@section Event handler */
    @objc private func onTimeElapsed() {
        let currTime = Date().timeIntervalSince1970
        let tickTime = currTime - m_oldTime
        m_oldTime = currTime

        m_totalElapsedTime += tickTime
        if m_totalElapsedTime < m_duration {
            m_optOnElapseTime?(tickTime)
        }
        else {
            m_optOnElapseTime?(m_totalElapsedTime - m_duration)
            m_optTimer!.invalidate()
            m_optTimer = nil

            m_optOnFinishTimer?()
        }
    }
}
