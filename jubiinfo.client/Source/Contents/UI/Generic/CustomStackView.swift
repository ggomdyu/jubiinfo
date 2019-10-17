//
//  CustomStackView.swift
//  jubiinfo
//
//  Created by ggomdyu on 12/01/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Material

public class CustomStackView : View {
/**@section Property */
    public var minViewHeight: CGFloat { return 0 }
    
/**@section Variable */
    private var m_topMarginView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0, height: 0))
    private var m_lastAddedView: UIView!
    private var m_lastMarginHeight: CGFloat = 0.0
    private var m_currViewHeight: CGFloat = 0.0
    private var m_currContentsViewHeight: CGFloat = 0.0
    public var m_heightConstraint: NSLayoutConstraint!
    
/**@section Method */
    override public func prepare() {
        super.prepare()
        self.prepareConstraints()
        
        m_lastAddedView = m_topMarginView
        self.addSubview(m_lastAddedView)
    }
    
    private func prepareConstraints() {
        for constraint in self.constraints {
            if constraint.firstAttribute == .height {
                m_heightConstraint = constraint
                break
            }
        }
        
        m_heightConstraint.constant = 0
    }
    
    public func setHeight(height: CGFloat) {
        m_currViewHeight = height
        
        self.refreshHeightConstraint()
    }
    
    public func addHeight(height: CGFloat) {
        m_currViewHeight += height
        
        self.refreshHeightConstraint()
    }
    
    public func getHeight() -> CGFloat {
        return m_currViewHeight
    }
    
    public func setMargin(margin: CGFloat) {
        m_currContentsViewHeight -= m_lastMarginHeight
        m_currContentsViewHeight += margin
        m_lastMarginHeight = margin
        
        self.refreshHeightConstraint()
    }
    
    public func addMargin(margin: CGFloat) {
        m_lastMarginHeight += margin
        m_currContentsViewHeight += margin
        
        self.refreshHeightConstraint()
    }
    
    public func addView(view: UIView) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.layout(view).centerX().width(420)
        }
        else {
            self.layout(view).left(15).right(15)
        }
        
        self.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: m_lastAddedView, attribute: .bottom, multiplier: 1, constant: m_lastMarginHeight))
        
        m_currContentsViewHeight += view.frame.height
        self.refreshHeightConstraint()
        
        m_lastAddedView = view
        m_lastMarginHeight = 0
    }
    
    /**@brief   The height value is calculated by adding viewHeight(height of CustomStackView itself) and contentsViewHeight(total height of contents in CustomStackView). */
    public func refreshHeightConstraint() {
        m_heightConstraint.constant = max(minViewHeight, m_currContentsViewHeight + m_currViewHeight)
    }
    
    public func resetStackView() {
        m_heightConstraint?.constant = minViewHeight
        m_currContentsViewHeight = 0.0
        m_lastMarginHeight = 0.0
        m_currViewHeight = 0.0
        
        let stackCellCount = self.subviews.count - 1
        for _ in 0..<stackCellCount {
            self.subviews[1].removeFromSuperview()
        }
        
        m_lastAddedView = m_topMarginView
        
        self.refreshHeightConstraint()
    }
}
