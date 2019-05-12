//
//  LineDashView.swift
//  jubiinfo
//
//  Created by ggomdyu on 16/02/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import UIKit
import Foundation

public class RoundLineDashView : UIView {
/**@section Property */
    @IBInspectable var dashColor: UIColor? {
        get {
            return UIColor(cgColor: m_shapeLayer.strokeColor!)
        }
        set {
            m_shapeLayer.strokeColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var dashSize: CGFloat {
        get {
            return m_shapeLayer.lineWidth
        }
        set {
            m_shapeLayer.lineWidth = newValue
        }
    }
    
    @IBInspectable var dashIntervalSpace: Float {
        get {
            return m_shapeLayer.lineDashPattern?[1].floatValue ?? 0.0
        }
        set {
            m_shapeLayer.lineDashPattern = [0, NSNumber(value: newValue)]
        }
    }
    
    @IBInspectable var isVertical: Bool {
        get {
            return m_isVertical
        }
        set {
            m_isVertical = newValue
        }
    }
    
/**@section Variable */
    private let m_shapeLayer = CAShapeLayer()
    private var m_isVertical = false
    
/**@section Method */
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        m_shapeLayer.lineCap = .round
        
        let path = CGMutablePath()
        let halfHeight = self.frame.height * 0.5
        path.addLines(between: [CGPoint(x: m_shapeLayer.lineWidth, y: halfHeight), CGPoint(x: self.frame.width, y: halfHeight)])
        
        m_shapeLayer.path = path
        self.layer.addSublayer(m_shapeLayer)
        
        if isVertical {
            self.transform = CGAffineTransform.init(rotationAngle: 3.14159265358 * 0.5)
        }
    }
}

public class SquareLineDashView : UIView {
/**@section Property */
    @IBInspectable var dashColor: UIColor? {
        get {
            return UIColor(cgColor: m_shapeLayer.strokeColor!)
        }
        set {
            m_shapeLayer.strokeColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var dashWidth: CGFloat {
        get {
            return m_shapeLayer.lineWidth
        }
        set {
            m_shapeLayer.lineWidth = newValue
        }
    }
    
    @IBInspectable var dashIntervalSpace: Float {
        get {
            return m_shapeLayer.lineDashPattern?[1].floatValue ?? 0.0
        }
        set {
            m_shapeLayer.lineDashPattern = [0, NSNumber(value: newValue)]
        }
    }
    
    @IBInspectable var isVertical: Bool {
        get {
            return m_isVertical
        }
        set {
            m_isVertical = newValue
        }
    }
    
/**@section Variable */
    private let m_shapeLayer = CAShapeLayer()
    private var m_isVertical = false
    
/**@section Method */
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        m_shapeLayer.lineCap = .square
        
        let path = CGMutablePath()
        let halfHeight = self.frame.height * 0.5
        path.addLines(between: [CGPoint(x: m_shapeLayer.lineWidth, y: halfHeight), CGPoint(x: self.frame.width, y: halfHeight)])
        
        m_shapeLayer.path = path
        self.layer.addSublayer(m_shapeLayer)
        
        if isVertical {
            self.transform = CGAffineTransform.init(rotationAngle: 3.141592 * 0.5)
        }
    }
}
