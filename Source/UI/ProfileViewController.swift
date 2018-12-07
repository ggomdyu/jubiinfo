//
//  ProfileViewController.swift
//  jubiinfo
//
//  Created by ggomdyu on 13/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import UIKit
import Foundation
import Material
import Motion
import Charts

class ProfileViewController: ViewController {

    private var uiViewStack = [UIView]()
    @IBOutlet weak var scrollView: UIScrollView!
    
    open override func prepare() {
        super.prepare()
        
        self.prepareProfileViewCell()
        self.preparePlayDataACell()
    }
}

extension ProfileViewController {
    
    private func prepareProfileViewCell() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewCellController") as! ProfileViewCellController

        let newView: UIView = viewController.view
        self.view.layout(newView).top(15).left(15).right(15)
        
        uiViewStack.append(newView)
    }
    
    private func preparePlayDataACell() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "PlayDataACellController") as! PlayDataACellController
        
        let newView: UIView = viewController.view
        view.layout(newView).top(0).left(15).right(15)
        
        uiViewStack.append(newView)
    }
    
    private func prepareCircularGraph() {
        let chartItems = [
            PieChartDataEntry(value: 138, label: "EXC"),
            PieChartDataEntry(value: 122, label: "SSS"),
            PieChartDataEntry(value: 13, label: "SS"),
            PieChartDataEntry(value: 6, label: "S"),
            PieChartDataEntry(value: 12, label: "A"),
            PieChartDataEntry(value: 8, label: "B"),
            PieChartDataEntry(value: 5, label: "C"),
        ]
        
        let chartItemColors: [UIColor] = [
            UIColor(red: 1, green: 0, blue: 0, alpha: 1),
            UIColor(red: 1, green: 1, blue: 0, alpha: 1),
            UIColor(red: 1, green: 1, blue: 0, alpha: 1),
            UIColor(red: 1, green: 1, blue: 0, alpha: 1),
            UIColor(red: 1, green: 0.5, blue: 0, alpha: 1),
            UIColor(red: 0, green: 0, blue: 1, alpha: 1),
            UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
        ]
        
        let chartItemSet = PieChartDataSet(values: chartItems, label: "BOIRU")
        chartItemSet.colors = chartItemColors;
        
        let chartView = PieChartView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 250, height: 250)))
        chartView.data = PieChartData(dataSet: chartItemSet)
        chartView.isUserInteractionEnabled = false
        chartView.holeRadiusPercent = 0.3
        chartView.transparentCircleColor = UIColor.clear
        chartView.entryLabelColor = .white
        chartView.entryLabelFont = .systemFont(ofSize: 12, weight: .light)
        chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        
        self.view.addSubview(chartView)
    }
}
