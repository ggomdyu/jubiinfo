//
//  ChangeSizePopupContentViewController.swift
//  SBCardPopupExample
//
//  Created by Steve Barnegren on 22/06/2017.
//  Copyright © 2017 Steve Barnegren. All rights reserved.
//

import UIKit
import SBCardPopup
import Material


public class BaseFilterUITableViewCell : UITableViewCell {
    public func initialize(text: String) {
        self.textLabel!.text = text
        
        // Add a disclosure button right side of textLabel
        let disclosureView = UITableViewCell()
        disclosureView.frame = CGRect(x: 0.0, y: 0.0, width: self.textLabel!.frame.origin.x + self.textLabel!.intrinsicContentSize.width + 25.0 + 35.0, height: self.frame.height)
        disclosureView.accessoryType = .disclosureIndicator
        disclosureView.isUserInteractionEnabled = false
        disclosureView.backgroundColor = UIColor.clear
        self.addSubview(disclosureView)

        // Add a line
        let divisionLineView = UIView(frame: CGRect(x: disclosureView.frame.width, y: 0.0, width: 1.0, height: self.frame.height))
        divisionLineView.backgroundColor = UIColor(red: 230.0 / 255.0, green: 230.0 / 255.0, blue: 230.0 / 255.0, alpha: 1.0)
        self.addSubview(divisionLineView)
       
//        let divisionLineView = UIView()
//        divisionLineView.backgroundColor = UIColor.red
//        self.layout(divisionLineView).top(0.0).left(disclosureView.frame.width).right(0.0).bottom(0.0)
    }
}

public class PickerFilterUITableViewCell : UITableViewCell {
    public func initialize(text: String) {
        self.textLabel!.text = text
        
        // Add a disclosure button right side of textLabel
        let disclosureView = UITableViewCell()
        disclosureView.frame = CGRect(x: 0.0, y: 0.0, width: self.textLabel!.frame.origin.x + self.textLabel!.intrinsicContentSize.width + 25.0 + 35.0, height: self.frame.height)
        disclosureView.accessoryType = .disclosureIndicator
        disclosureView.isUserInteractionEnabled = false
        disclosureView.backgroundColor = UIColor.clear
        self.addSubview(disclosureView)
        
        // Add a line
        let divisionLineView = UIView(frame: CGRect(x: disclosureView.frame.width, y: 0.0, width: 1.0, height: self.frame.height))
        divisionLineView.backgroundColor = UIColor(red: 230.0 / 255.0, green: 230.0 / 255.0, blue: 230.0 / 255.0, alpha: 1.0)
        self.addSubview(divisionLineView)
        
        //        let divisionLineView = UIView()
        //        divisionLineView.backgroundColor = UIColor.red
        //        self.layout(divisionLineView).top(0.0).left(disclosureView.frame.width).right(0.0).bottom(0.0)
    }
}


private enum MusicFilterType {
    case notPlayedYet
    case fullCombo
    case excellent
    case score
    case level
    case series
}

private protocol MusicFilter {
    func filterOut(musicScoreData: MusicScoreData) -> Bool
}

private class MusicLevelFilter : MusicFilter {
    private let m_minLevel: Int
    private let m_maxLevel: Int
    
    public init(minLevel: Int, maxLevel: Int) {
        m_minLevel = minLevel
        m_maxLevel = maxLevel
    }
    
    public func filterOut(musicScoreData: MusicScoreData) -> Bool {
        let musicLevel = musicScoreData.level
        return m_minLevel <= musicLevel && musicLevel <= m_maxLevel
    }
}

private class MusicFullComboFilter : MusicFilter {
    public func filterOut(musicScoreData: MusicScoreData) -> Bool {
        return musicScoreData.isFullCombo
    }
}

private class MusicNotPlayedFilter : MusicFilter {
    public func filterOut(musicScoreData: MusicScoreData) -> Bool {
        return musicScoreData.isNotPlayedYet
    }
}

private class MusicScoreFilter : MusicFilter {
    private let m_minScore: Int
    private let m_maxScore: Int
    
    public init(minScore: Int, maxScore: Int) {
        m_minScore = minScore
        m_maxScore = maxScore
    }
    
    public func filterOut(musicScoreData: MusicScoreData) -> Bool {
        let musicScore = musicScoreData.score
        return m_minScore <= musicScore && musicScore <= m_maxScore
    }
}

class MusicFilterViewController : UIViewController, SBCardPopupContent, UITableViewDelegate, UITableViewDataSource {
/**@section Variable */
    var popupViewController: SBCardPopupViewController?
    var allowsTapToDismissPopupCard = true
    var allowsSwipeToDismissPopupCard = true
    
    @IBOutlet weak var m_filterTableView: UITableView!
    @IBOutlet weak var m_okButton: UIButton!
    
    private var m_filterTableData: [MusicFilterType] = [
        MusicFilterType.fullCombo
    ]
    
/**@section Method */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_filterTableView.delegate = self
        m_filterTableView.dataSource = self
        
        m_filterTableView.setEditing(true, animated: false)
    }
    
    public static func show(currentViewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MusicFilterViewController") as! MusicFilterViewController
        
        let rootViewController = SBCardPopupViewController(contentViewController: viewController)
        rootViewController.show(onViewController: currentViewController)
        
        viewController.initialize()
    }
    
    private func initialize() {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCellIdenfier") as! BaseFilterUITableViewCell
        cell.initialize(text: "\(indexPath.row * 10)")
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            return .insert
        }
        else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        else if editingStyle == .insert {
//            tableView.insertRows(at: [IndexPath(row: sectionDataTable[1].1.count - 1, section: 1)], with: .left)
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
/**@section Event handler */
}
