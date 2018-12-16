//
//  RankDataGraphCellController.swift
//  jubiinfo
//
//  Created by ggomdyu on 10/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Charts

public class RankDataGraphView : UIView {

    public func lazyPrepare() {
        self.prepareRankDataGraph()
    }
    
    private func prepareRankDataGraph() {
        let myUserData = GlobalUserDataStorage.instance.queryMyUserData()
        guard let myRankDataPageCache = myUserData.rankDataPageCache else {
            return
        }
        
        let chartItems = [
            PieChartDataEntry(value: Double(myRankDataPageCache.excRankCount), label: (myRankDataPageCache.excRankCount > 0) ? "EXC" : nil),
            PieChartDataEntry(value: Double(myRankDataPageCache.sssRankCount), label: (myRankDataPageCache.sssRankCount > 0) ? "SSS" : nil),
            PieChartDataEntry(value: Double(myRankDataPageCache.ssRankCount), label: (myRankDataPageCache.ssRankCount > 0) ? "SS" : nil),
            PieChartDataEntry(value: Double(myRankDataPageCache.sRankCount), label: (myRankDataPageCache.sRankCount > 0) ? "S" : nil),
            PieChartDataEntry(value: Double(myRankDataPageCache.aRankCount), label: (myRankDataPageCache.aRankCount > 0) ? "A" : nil),
            PieChartDataEntry(value: Double(myRankDataPageCache.bRankCount), label: (myRankDataPageCache.bRankCount > 0) ? "B" : nil),
            PieChartDataEntry(value: Double(myRankDataPageCache.cRankCount), label: (myRankDataPageCache.cRankCount > 0) ? "C" : nil)
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
        chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        
        self.addSubview(chartView)
    }
}

public class RankDataGraphCellController : LazyPreparedViewController {
    
    @IBOutlet weak var excRankCountLabel: UILabel!
    @IBOutlet weak var sssRankCountLabel: UILabel!
    @IBOutlet weak var ssRankCountLabel: UILabel!
    @IBOutlet weak var sRankCountLabel: UILabel!
    @IBOutlet weak var aRankCountLabel: UILabel!
    @IBOutlet weak var bRankCountLabel: UILabel!
    @IBOutlet weak var cRankCountLabel: UILabel!
    @IBOutlet weak var notPlayedCountLabel: UILabel!
    @IBOutlet weak var rankDataGraphView: RankDataGraphView!
    @IBOutlet weak var contentsView: UIView!
    
    override public func prepare() {
        super.prepare()
        
        self.contentsView.alpha = 0.0
    }
    
    override public func lazyPrepare(_ param: Any?) {
        super.lazyPrepare(param)
        
        self.prepareRankCountLabels()
        self.prepareRankDataGraphView()
        
        self.contentsView.animate(.fadeIn)
    }
    
    open override func getEventNameRequiredToLazyPrepare() -> String {
        return "requestMyRankDataComplete"
    }
}

extension RankDataGraphCellController {
    private func prepareRankCountLabels() {
        let myUserData = GlobalUserDataStorage.instance.queryMyUserData()
        guard let myRankDataPageCache = myUserData.rankDataPageCache else {
            return
        }
        
        let totalPlayCount = myRankDataPageCache.totalPlayCount
        let zeroRankCountTextColor = UIColor(red: 155 / 255, green: 155 / 255, blue: 155 / 255, alpha: 1.0)
        
        let excRankCount = myRankDataPageCache.excRankCount
        excRankCountLabel.text = "\(excRankCount)(\(String(format: "%.2f", (Float(excRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if excRankCount <= 0 {
            excRankCountLabel.textColor = zeroRankCountTextColor
        }
        
        let sssRankCount = myRankDataPageCache.sssRankCount
        sssRankCountLabel.text = "\(sssRankCount)(\(String(format: "%.2f", (Float(sssRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if sssRankCount <= 0 {
            sssRankCountLabel.textColor = zeroRankCountTextColor
        }
        
        let ssRankCount = myRankDataPageCache.ssRankCount
        ssRankCountLabel.text = "\(ssRankCount)(\(String(format: "%.2f", (Float(ssRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if ssRankCount <= 0 {
            ssRankCountLabel.textColor = zeroRankCountTextColor
        }
        
        let sRankCount = myRankDataPageCache.sRankCount
        sRankCountLabel.text = "\(sRankCount)(\(String(format: "%.2f", (Float(sRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if sRankCount <= 0 {
            sRankCountLabel.textColor = zeroRankCountTextColor
        }
        
        let aRankCount = myRankDataPageCache.aRankCount
        aRankCountLabel.text = "\(aRankCount)(\(String(format: "%.2f", (Float(aRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if aRankCount <= 0 {
            aRankCountLabel.textColor = zeroRankCountTextColor
        }
        
        let bRankCount = myRankDataPageCache.bRankCount
        bRankCountLabel.text = "\(bRankCount)(\(String(format: "%.2f", (Float(bRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if bRankCount <= 0 {
            bRankCountLabel.textColor = zeroRankCountTextColor
        }
        
        let cRankCount = myRankDataPageCache.cRankCount
        cRankCountLabel.text = "\(cRankCount)(\(String(format: "%.2f", (Float(cRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if cRankCount <= 0 {
            cRankCountLabel.textColor = zeroRankCountTextColor
        }
        
        let notPlayedMusicCount = myRankDataPageCache.notPlayedMusicCount
        notPlayedCountLabel.text = "\(notPlayedMusicCount)(\(String(format: "%.2f", (Float(notPlayedMusicCount) / Float(totalPlayCount)) * 100.0))%)"
    }
    
    private func prepareRankDataGraphView() {
        rankDataGraphView.lazyPrepare()
    }
}
