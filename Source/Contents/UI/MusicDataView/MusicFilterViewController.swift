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


public protocol MusicFilter {
    func filterOut(musicScoreData: MusicScoreData) -> Bool
}

public class MusicLevelFilter : MusicFilter {
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

public class MusicFullComboFilter : MusicFilter {
    public func filterOut(musicScoreData: MusicScoreData) -> Bool {
        return musicScoreData.isFullCombo
    }
}

public class MusicNotPlayedFilter : MusicFilter {
    public func filterOut(musicScoreData: MusicScoreData) -> Bool {
        return musicScoreData.isNotPlayedYet
    }
}

public class MusicScoreFilter : MusicFilter {
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
    
/**@section Method */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_filterTableView.delegate = self
        m_filterTableView.dataSource = self
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCellIdenfier")!
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
/**@section Event handler */
}
