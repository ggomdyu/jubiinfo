//
//  MusicScoreDataGraphView.swift
//  jubiinfo
//
//  Created by ggomdyu on 30/01/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Charts

class MusicScoreGraphView : UIView, ChartViewDelegate {
/**@section Class */
    private class DateValueFormatter: NSObject, IAxisValueFormatter {
        /**@section Variable */
        private let m_musicScoreData: MusicScoreData
        private let m_dateFormatter = DateFormatter()
        
        /**@section Constructor */
        public init(musicScoreData: MusicScoreData) {
            m_musicScoreData = musicScoreData
            m_dateFormatter.dateFormat = "MM.dd"
            
            super.init()
        }
        
        /**@section Method */
        public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            var scoreHistoryIndex = Int(value)
            if scoreHistoryIndex >= m_musicScoreData.scoreHistories!.count {
                scoreHistoryIndex = m_musicScoreData.scoreHistories!.count - 1
            }
            else if scoreHistoryIndex < 0 {
                scoreHistoryIndex = 0
            }
            
            return m_dateFormatter.string(from: Date(timeIntervalSince1970: Double(m_musicScoreData.scoreHistories![scoreHistoryIndex].0)))
        }
    }
    
/**@section Variable */
    @IBOutlet weak var m_lineChartView: LineChartView!
    private var m_musicScoreData: MusicScoreData!
    
/**@section Method */
    public func initialize(musicScoreData: MusicScoreData) {
        m_musicScoreData = musicScoreData
        
        self.prepareLineChartView()
    }
    
    private func prepareLineChartView() {
        m_lineChartView.delegate = self
        m_lineChartView.chartDescription?.enabled = false
        m_lineChartView.dragEnabled = true
        m_lineChartView.setScaleEnabled(false)
        m_lineChartView.pinchZoomEnabled = false
        m_lineChartView.legend.enabled = false
        m_lineChartView.drawLineAboveFillRange = true
        
        let scoreHistories = m_musicScoreData.scoreHistories ?? [(Timestamp(Date().timeIntervalSince1970), m_musicScoreData.score)]
        self.prepareLineChartViewDataSet(scoreHistories: scoreHistories)
        
        // Extra margin
        m_lineChartView.extraTopOffset = (m_musicScoreData.score >= 995000) ? 22.0 : 0.0
        m_lineChartView.extraLeftOffset = 2.0 + 5.0
        m_lineChartView.extraRightOffset = 15.0 + 5.0
        
        // xAxis
        m_lineChartView.xAxis.gridLineDashLengths = [1.5, 1.5]
        m_lineChartView.xAxis.gridLineDashPhase = 0
        m_lineChartView.xAxis.labelPosition = .bottom
        m_lineChartView.xAxis.labelTextColor = UIColor(red: 152.0 / 255.0, green: 152.0 / 255.0, blue: 152.0 / 255.0, alpha: 1.0)
        m_lineChartView.xAxis.valueFormatter = DateValueFormatter(musicScoreData: m_musicScoreData)
        m_lineChartView.xAxis.setLabelCount(scoreHistories.count, force: true)
        m_lineChartView.xAxis.drawGridLinesEnabled = false
        
        // leftAxis
        let axisMaximum = Double((min(1000000, scoreHistories.last!.1 + 5000) / 1000) * 1000)
        let axisMinimum = Double((max(0, scoreHistories.first!.1 - 5000) / 1000) * 1000)
        m_lineChartView.leftAxis.axisMaximum = axisMaximum
        m_lineChartView.leftAxis.axisMinimum = axisMinimum
        m_lineChartView.leftAxis.setLabelCount(6, force: true)
        m_lineChartView.leftAxis.removeAllLimitLines()
        m_lineChartView.leftAxis.gridLineDashLengths = [1.5, 1.5]
        m_lineChartView.leftAxis.drawLimitLinesBehindDataEnabled = true
        m_lineChartView.leftAxis.labelTextColor = UIColor(red: 152.0 / 255.0, green: 152.0 / 255.0, blue: 152.0 / 255.0, alpha: 1.0)
        
        // rightAxis
        m_lineChartView.rightAxis.enabled = false
        
        m_lineChartView.animate(yAxisDuration: 0)
    }
    
    func prepareLineChartViewDataSet(scoreHistories: [(Timestamp, MusicScore)]) {
        var chartDataEntries = [ChartDataEntry] ();
        for i in 0..<scoreHistories.count {
            let scoreHistory = scoreHistories[i]
            chartDataEntries.append(ChartDataEntry(x: Double(i), y: Double(scoreHistory.1)))
        }
        
        let scoreDataSet = LineChartDataSet(values: chartDataEntries, label: nil)
        scoreDataSet.drawIconsEnabled = false
        scoreDataSet.setColor(UIColor(red: 182.0 / 255.0, green: 182.0 / 255.0, blue: 182.0 / 255.0, alpha: 1.0))
        scoreDataSet.setCircleColor(UIColor(red: 182.0 / 255.0, green: 182.0 / 255.0, blue: 182.0 / 255.0, alpha: 1.0))
        scoreDataSet.lineWidth = 3
        scoreDataSet.circleRadius = 7
        scoreDataSet.drawCircleHoleEnabled = true
        scoreDataSet.valueFont = .systemFont(ofSize: 9)
        scoreDataSet.formLineDashLengths = [5, 2.5]
        scoreDataSet.formLineWidth = 1
        scoreDataSet.formSize = 15
        scoreDataSet.highlightEnabled = false
        scoreDataSet.fillAlpha = 1.0
        scoreDataSet.fill = Fill(color: getCurrentThemeColorTable().musicCellViewGraphFillColor)
        scoreDataSet.drawFilledEnabled = true
        
        m_lineChartView.data = LineChartData(dataSet: scoreDataSet)
    }
}
