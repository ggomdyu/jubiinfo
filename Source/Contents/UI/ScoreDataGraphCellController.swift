//
//  ScoreGraphCellController.swift
//  jubiinfo
//
//  Created by ggomdyu on 10/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Charts

public class ScoreDataGraphView : UIView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.prepareCircularGraph()
    }
}

extension ScoreDataGraphView {
    
    private func prepareCircularGraph() {
        
        let myUserData = GlobalUserDataStorage.instance.queryMyUserData()
        guard let myRankDataPageCache = myUserData.rankDataPageCache else {
            return
        }
        
        let excRankCount = myRankDataPageCache.excRankCount
        let sssRankCount = myRankDataPageCache.sssRankCount
        let ssRankCount = myRankDataPageCache.ssRankCount
        let sRankCount = myRankDataPageCache.sRankCount
        let aRankCount = myRankDataPageCache.aRankCount
        let bRankCount = myRankDataPageCache.bRankCount
        let cRankCount = myRankDataPageCache.cRankCount
        
        let chartItems = [
            PieChartDataEntry(value: Double(excRankCount), label: (excRankCount > 0) ? "EXC" : nil),
            PieChartDataEntry(value: Double(sssRankCount), label: (sssRankCount > 0) ? "SSS" : nil),
            PieChartDataEntry(value: Double(ssRankCount), label: (ssRankCount > 0) ? "SS" : nil),
            PieChartDataEntry(value: Double(sRankCount), label: (sRankCount > 0) ? "S" : nil),
            PieChartDataEntry(value: Double(aRankCount), label: (aRankCount > 0) ? "A" : nil),
            PieChartDataEntry(value: Double(bRankCount), label: (bRankCount > 0) ? "B" : nil),
            PieChartDataEntry(value: Double(cRankCount), label: (cRankCount > 0) ? "C" : nil)
        ]
        
        let chartItemColors: [UIColor] = [
            UIColor(red: 147 / 255, green: 230 / 255, blue: 33 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 216 / 255, blue: 83 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 201 / 255, blue: 78 / 255, alpha: 1),
            UIColor(red: 246 / 255, green: 191 / 255, blue: 68 / 255, alpha: 1),
            UIColor(red: 235 / 255, green: 53 / 255, blue: 93 / 255, alpha: 1),
            UIColor(red: 69 / 255, green: 165 / 255, blue: 248 / 255, alpha: 1),
            UIColor(red: 161 / 255, green: 161 / 255, blue: 161 / 255, alpha: 1)
        ]
        
        let chartItemSet = PieChartDataSet(values: chartItems, label: "")
        chartItemSet.colors = chartItemColors;
        chartItemSet.drawValuesEnabled = false
        
        let chartAdditionalWidth: CGFloat = 20.0
        let chartAdditionalHeight: CGFloat = 10.0
        
        let chartView = PieChartView(frame: CGRect(origin: CGPoint(x: -chartAdditionalWidth / 2, y: -chartAdditionalHeight / 2), size: CGSize(width: self.frame.width + chartAdditionalWidth, height: self.frame.height + chartAdditionalHeight)))
        chartView.data = PieChartData(dataSet: chartItemSet)
        chartView.isUserInteractionEnabled = false
        chartView.holeRadiusPercent = 0.5
        chartView.transparentCircleColor = UIColor.clear
        chartView.entryLabelColor = .white
        chartView.entryLabelFont = .systemFont(ofSize: 12, weight: .regular)
        chartView.legend.enabled = false
//        chartView.backgroundColor = UIColor.black
        chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        
        self.addSubview(chartView)
    }
}

public class ScoreDataGraphCellController : UIViewController {
    
    @IBOutlet weak var excRankCountLabel: UILabel!
    @IBOutlet weak var sssRankCountLabel: UILabel!
    @IBOutlet weak var ssRankCountLabel: UILabel!
    @IBOutlet weak var sRankCountLabel: UILabel!
    @IBOutlet weak var aRankCountLabel: UILabel!
    @IBOutlet weak var bRankCountLabel: UILabel!
    @IBOutlet weak var cRankCountLabel: UILabel!
    @IBOutlet weak var notPlayedCountLabel: UILabel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let myUserData = GlobalUserDataStorage.instance.queryMyUserData()
        guard let myRankDataPageCache = myUserData.rankDataPageCache else {
            return
        }
        
        let excRankCount = myRankDataPageCache.excRankCount
        let sssRankCount = myRankDataPageCache.sssRankCount
        let ssRankCount = myRankDataPageCache.ssRankCount
        let sRankCount = myRankDataPageCache.sRankCount
        let aRankCount = myRankDataPageCache.aRankCount
        let bRankCount = myRankDataPageCache.bRankCount
        let cRankCount = myRankDataPageCache.cRankCount
        let dRankCount = myRankDataPageCache.dRankCount
        let eRankCount = myRankDataPageCache.eRankCount
        let notPlayedMusicCount = myRankDataPageCache.notPlayedMusicCount
        let totalPlayCount = myRankDataPageCache.totalPlayCount
        let zeroCountRankTextColor = UIColor(red: 155 / 255, green: 155 / 255, blue: 155 / 255, alpha: 1.0)
        
        excRankCountLabel.text = "\(excRankCount)(\(String(format: "%.2f", (Float(excRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if excRankCount <= 0 {
            excRankCountLabel.textColor = zeroCountRankTextColor
        }
        
        sssRankCountLabel.text = "\(sssRankCount)(\(String(format: "%.2f", (Float(sssRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if sssRankCount <= 0 {
            sssRankCountLabel.textColor = zeroCountRankTextColor
        }
        
        ssRankCountLabel.text = "\(ssRankCount)(\(String(format: "%.2f", (Float(ssRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if ssRankCount <= 0 {
            ssRankCountLabel.textColor = zeroCountRankTextColor
        }
        
        sRankCountLabel.text = "\(sRankCount)(\(String(format: "%.2f", (Float(sRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if sRankCount <= 0 {
            sRankCountLabel.textColor = zeroCountRankTextColor
        }
        
        aRankCountLabel.text = "\(aRankCount)(\(String(format: "%.2f", (Float(aRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if aRankCount <= 0 {
            aRankCountLabel.textColor = zeroCountRankTextColor
        }
        
        bRankCountLabel.text = "\(bRankCount)(\(String(format: "%.2f", (Float(bRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if bRankCount <= 0 {
            bRankCountLabel.textColor = zeroCountRankTextColor
        }
        
        cRankCountLabel.text = "\(cRankCount)(\(String(format: "%.2f", (Float(cRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if cRankCount <= 0 {
            cRankCountLabel.textColor = zeroCountRankTextColor
        }
        
        notPlayedCountLabel.text = "\(notPlayedMusicCount)(\(String(format: "%.2f", (Float(notPlayedMusicCount) / Float(totalPlayCount)) * 100.0))%)"
    }
}
