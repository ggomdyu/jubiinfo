//
//  MusicScoreDataGraphView.swift
//  jubiinfo
//
//  Created by 차준호 on 30/01/2019.
//  Copyright © 2019 차준호. All rights reserved.
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
            return m_dateFormatter.string(from: Date(timeIntervalSince1970: value))
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
        m_lineChartView.extraTopOffset = CGFloat((m_musicScoreData.score >= 1000000) ? 22 : 0)
        m_lineChartView.extraLeftOffset = 5.0
        m_lineChartView.extraRightOffset = 15.0 + CGFloat((m_musicScoreData.score >= 1000000) ? 5 : 0)
        
        m_lineChartView.xAxis.gridLineDashLengths = [1.5, 1.5]
        m_lineChartView.xAxis.gridLineDashPhase = 0
        m_lineChartView.xAxis.labelPosition = .bottom
        m_lineChartView.xAxis.labelTextColor = UIColor(red: 152.0 / 255.0, green: 152.0 / 255.0, blue: 152.0 / 255.0, alpha: 1.0)
        m_lineChartView.xAxis.valueFormatter = DateValueFormatter(musicScoreData: m_musicScoreData)
        
        m_lineChartView.leftAxis.removeAllLimitLines()
        m_lineChartView.leftAxis.gridLineDashLengths = [1.5, 1.5]
        m_lineChartView.leftAxis.drawLimitLinesBehindDataEnabled = true
        m_lineChartView.leftAxis.labelTextColor = UIColor(red: 152.0 / 255.0, green: 152.0 / 255.0, blue: 152.0 / 255.0, alpha: 1.0)
        
        m_lineChartView.rightAxis.enabled = false
        
        let scoreHistories = m_musicScoreData.scoreHistories ?? [(Timestamp(Date().timeIntervalSince1970), m_musicScoreData.score)]
        self.prepareLineChartViewDataSet(scoreHistories: scoreHistories)
        
        m_lineChartView.xAxis.setLabelCount(scoreHistories.count, force: true)
        m_lineChartView.leftAxis.axisMaximum = Double(min(1000000, scoreHistories.last!.1 + 5000))
        m_lineChartView.leftAxis.axisMinimum = Double(max(0, scoreHistories.first!.1 - 5000))
        
        m_lineChartView.animate(yAxisDuration: 0)
    }
    
    func prepareLineChartViewDataSet(scoreHistories: [(Timestamp, MusicScore)]) {
        var chartDataEntries = [ChartDataEntry] ();
        for scoreHistory in scoreHistories {
            chartDataEntries.append(ChartDataEntry(x: Double(scoreHistory.0), y: Double(scoreHistory.1)))
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
        scoreDataSet.fill = Fill(color: UIColor.init(red: 250.0 / 255.0, green: 244.0 / 255.0, blue: 228.0 / 255.0, alpha: 1.0))
        scoreDataSet.drawFilledEnabled = true
        
        m_lineChartView.data = LineChartData(dataSet: scoreDataSet)
    }
}
