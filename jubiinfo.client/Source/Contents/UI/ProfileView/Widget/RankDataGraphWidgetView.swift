//
//  RankDataGraphWidgetView.swift
//  jubiinfo
//
//  Created by ggomdyu on 10/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Charts

public class RankDataGraphWidgetView : WidgetView {
/**@section Variable */
    @IBOutlet weak var m_excRankCountLabel: UILabel!
    @IBOutlet weak var m_sssRankCountLabel: UILabel!
    @IBOutlet weak var m_ssRankCountLabel: UILabel!
    @IBOutlet weak var m_sRankCountLabel: UILabel!
    @IBOutlet weak var m_aRankCountLabel: UILabel!
    @IBOutlet weak var m_bRankCountLabel: UILabel!
    @IBOutlet weak var m_cRankCountLabel: UILabel!
    @IBOutlet weak var m_notPlayedCountLabel: UILabel!
    @IBOutlet weak var m_contentsView: UIView!
    @IBOutlet weak var m_graphView: UIView!
    
/**@section Property */
    public override var lazyInitializeEventName: String {
        return "requestMyRankDataPageCacheComplete"
    }
    override public var lazyInitializeParam: Any? { return DataStorage.instance.queryMyUserData().rankDataPageCache }
    
/**@section Method */
    public override func initialize() {
        m_contentsView.alpha = 0.0
        
        super.initialize()
    }
    
    public override func lazyInitialize(_ param: Any?) {
        super.lazyInitialize(param)
        
        self.prepareRankCountLabels()
        self.prepareRankDataGraph()
        
        m_contentsView.animate(.fadeIn)
    }
    
    private func prepareRankCountLabels() {
        let myUserData = DataStorage.instance.queryMyUserData()
        guard let myRankDataPageCache = myUserData.rankDataPageCache else {
            return
        }
        
        let totalPlayCount = myRankDataPageCache.totalPlayCount
        let zeroRankCountTextColor = UIColor(red: 155 / 255, green: 155 / 255, blue: 155 / 255, alpha: 1.0)
        
        let excRankCount = myRankDataPageCache.excRankCount
        m_excRankCountLabel.text = "\(excRankCount)(\(String(format: "%.2f", (Float(excRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if excRankCount <= 0 {
            m_excRankCountLabel.textColor = zeroRankCountTextColor
        }
        
        let sssRankCount = myRankDataPageCache.sssRankCount
        m_sssRankCountLabel.text = "\(sssRankCount)(\(String(format: "%.2f", (Float(sssRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if sssRankCount <= 0 {
            m_sssRankCountLabel.textColor = zeroRankCountTextColor
        }
        
        let ssRankCount = myRankDataPageCache.ssRankCount
        m_ssRankCountLabel.text = "\(ssRankCount)(\(String(format: "%.2f", (Float(ssRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if ssRankCount <= 0 {
            m_ssRankCountLabel.textColor = zeroRankCountTextColor
        }
        
        let sRankCount = myRankDataPageCache.sRankCount
        m_sRankCountLabel.text = "\(sRankCount)(\(String(format: "%.2f", (Float(sRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if sRankCount <= 0 {
            m_sRankCountLabel.textColor = zeroRankCountTextColor
        }
        
        let aRankCount = myRankDataPageCache.aRankCount
        m_aRankCountLabel.text = "\(aRankCount)(\(String(format: "%.2f", (Float(aRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if aRankCount <= 0 {
            m_aRankCountLabel.textColor = zeroRankCountTextColor
        }
        
        let bRankCount = myRankDataPageCache.bRankCount
        m_bRankCountLabel.text = "\(bRankCount)(\(String(format: "%.2f", (Float(bRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if bRankCount <= 0 {
            m_bRankCountLabel.textColor = zeroRankCountTextColor
        }
        
        let cRankCount = myRankDataPageCache.cRankCount
        m_cRankCountLabel.text = "\(cRankCount)(\(String(format: "%.2f", (Float(cRankCount) / Float(totalPlayCount)) * 100.0))%)"
        if cRankCount <= 0 {
            m_cRankCountLabel.textColor = zeroRankCountTextColor
        }
        
        let notPlayedMusicCount = myRankDataPageCache.notPlayedMusicCount
        m_notPlayedCountLabel.text = "\(notPlayedMusicCount)(\(String(format: "%.2f", (Float(notPlayedMusicCount) / Float(totalPlayCount)) * 100.0))%)"
    }
    
    private func prepareRankDataGraph() {
        let myUserData = DataStorage.instance.queryMyUserData()
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
        
        let chartView = PieChartView(frame: CGRect(origin: CGPoint(x: -chartAdditionalWidth / 2, y: -chartAdditionalHeight / 2), size: CGSize(width: m_graphView.frame.width + chartAdditionalWidth, height: m_graphView.frame.height + chartAdditionalHeight)))
        chartView.data = PieChartData(dataSet: chartItemSet)
        chartView.isUserInteractionEnabled = false
        chartView.holeRadiusPercent = 0.45
        chartView.transparentCircleColor = UIColor.clear
        chartView.entryLabelColor = .white
        chartView.entryLabelFont = .systemFont(ofSize: 12, weight: .regular)
        chartView.legend.enabled = false
        chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        
        m_graphView.addSubview(chartView)
    }
}
