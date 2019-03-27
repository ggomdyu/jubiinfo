//
//  MusicFilterViewController.swift
//  jubiinfo
//
//  Created by ggomdyu on 03/23/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import UIKit
import SBCardPopup
import Material

public class MusicFilter {
/**@section Method */
    public func filterOut(musicScoreData: MusicScoreData) -> Bool {
        return false
    }
}

public class BaseFilterUITableViewCell : UITableViewCell {
/**@section Variable */
    @IBOutlet weak var m_button: UIButton!
    private var m_disclosureView: UIView!
    private var m_divisionLineView: UIView!
    
/**@section Method */
    override public func layoutSubviews() {
        super.layoutSubviews()
    
        // Add a disclosure button right side of textLabel
        if m_disclosureView == nil {
            let disclosureView = UITableViewCell()
            disclosureView.accessoryType = .disclosureIndicator
            disclosureView.isUserInteractionEnabled = false
            disclosureView.backgroundColor = UIColor.clear
            self.contentView.addSubview(disclosureView)
            
            m_disclosureView = disclosureView
        }
        
        let minusButtonWidth: CGFloat = 35.0
        m_disclosureView.frame = CGRect(x: 0.0, y: 0.0, width: m_button.frame.origin.x + m_button.titleLabel!.intrinsicContentSize.width + minusButtonWidth - 10.0, height: self.frame.height)
        
        // Add a line
        if m_divisionLineView == nil {
            let divisionLineView = UIView()
            divisionLineView.backgroundColor = UIColor(red: 207.0 / 255.0, green: 207.0 / 255.0, blue: 207.0 / 255.0, alpha: 1.0)
            self.contentView.addSubview(divisionLineView)
            
            m_divisionLineView = divisionLineView
        }
        m_divisionLineView.frame = CGRect(x: m_disclosureView.frame.width, y: 0.0, width: 0.5, height: self.frame.height)
        
        for subview in self.subviews {
            if String(describing: type(of: subview)).hasSuffix("SeparatorView") {
                subview.frame.size.width += 10.0
            }
            
            subview.frame.origin.x -= 10.0
        }
        
        self.separatorInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.endEditing(true)
    }
    
    public func createMusicFilter() -> MusicFilter {
        return MusicFilter()
    }
}

public class ScoreFilterUITableViewCell : BaseFilterUITableViewCell, UITextFieldDelegate {
/**@section Class */
    public class MusicScoreFilter : MusicFilter {
    /**@section Variable */
        private let m_minScore: Int
        private let m_maxScore: Int
        
    /**@section Constructor */
        public init(minScore: Int, maxScore: Int) {
            m_minScore = minScore
            m_maxScore = maxScore
        }
        
    /**@section Method */
        public override func filterOut(musicScoreData: MusicScoreData) -> Bool {
            let musicScore = musicScoreData.score
            return m_minScore <= musicScore && musicScore <= m_maxScore
        }
    }
    
/**@section Variable */
    public static let cellIdenfierName = "scoreFilterCellIdenfier"
    private var m_version: MusicScoreData.Version = .festo
    private var m_minScore: Int = 0
    private var m_maxScore: Int = 1000000
    @IBOutlet weak var m_minScoreTextField: UITextField!
    @IBOutlet weak var m_maxScoreTextField: UITextField!
    @IBOutlet weak var m_tildeLabel: UILabel!
    
/**@section Method */
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        m_minScoreTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        m_minScoreTextField.delegate = self
        
        m_maxScoreTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        m_maxScoreTextField.delegate = self
    }
    
    public override func createMusicFilter() -> MusicFilter {
        return MusicScoreFilter(minScore: m_minScore, maxScore: m_maxScore)
    }
    
/**@section Event handler */
    /**@brief Use to handle the remove event */
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isRemoveText = string.count == 0
        if isRemoveText {
            // If textfield will be empty after changed
            if m_minScoreTextField.text!.count + m_maxScoreTextField.text!.count == 1 {
                m_tildeLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            }
        }
        
        return true
    }
    
    /**@brief Use to handle the input event */
    @objc private func textFieldDidChange(textField: UITextField) {
        guard let score = Int(textField.text!) else {
            return
        }

        if score > 1000000 {
            textField.text = "1000000"
        }
            
        else if score == 0 {
            // Prevent multiple input of 0
            textField.text = "0"
        }

        textField.invalidateIntrinsicContentSize()

        m_tildeLabel.textColor = .black
    }
}

public class VersionOnlyFilterUITableViewCell : BaseFilterUITableViewCell {
/**@section Class */
    public class MusicVersionOnlyFilter : MusicFilter {
    /**@section Variable */
        private var m_version: MusicScoreData.Version
        
    /**@section Method */
        public init(version: MusicScoreData.Version) {
            m_version = version
        }
        
        public override func filterOut(musicScoreData: MusicScoreData) -> Bool {
            return musicScoreData.version == m_version
        }
    }
    
/**@section Variable */
    public static let cellIdenfierName = "versionOnlyFilterCellIdenfier"
    private var m_version: MusicScoreData.Version = .festo
    
/**@section Method */
    public override func createMusicFilter() -> MusicFilter {
        return MusicVersionOnlyFilter(version: m_version)
    }
}

private enum MusicFilterType {
    case score
    case versionOnly
    case version
    case levelOnly
    case level
    case excellentOnly
    case excellent
    case fullComboOnly
    case fullCombo
    case notPlayedYetOnly
    case notPlayedYet
}

public class MusicLevelFilter : MusicFilter {
    private let m_minLevel: Int
    private let m_maxLevel: Int
    
    public init(minLevel: Int, maxLevel: Int) {
        m_minLevel = minLevel
        m_maxLevel = maxLevel
    }
    
    public override func filterOut(musicScoreData: MusicScoreData) -> Bool {
        let musicLevel = musicScoreData.level
        return m_minLevel <= musicLevel && musicLevel <= m_maxLevel
    }
}

public class MusicFullComboFilter : MusicFilter {
    public override func filterOut(musicScoreData: MusicScoreData) -> Bool {
        return musicScoreData.isFullCombo
    }
}

public class MusicNotPlayedFilter : MusicFilter {
    public override func filterOut(musicScoreData: MusicScoreData) -> Bool {
        return musicScoreData.isNotPlayedYet
    }
}

class MusicFilterViewController : UIViewController, SBCardPopupContent, UITableViewDelegate, UITableViewDataSource {
/**@section Variable */
    var popupViewController: SBCardPopupViewController?
    var allowsTapToDismissPopupCard = true
    var allowsSwipeToDismissPopupCard = false
    
    @IBOutlet weak var m_filterTableView: UITableView!
    @IBOutlet weak var m_okButton: UIButton!
    @IBOutlet weak var m_filterTableViewHeightConstraint: NSLayoutConstraint!
    
    
    private var m_filterDataSource: [MusicFilterType] = [
        MusicFilterType.score
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
        return m_filterDataSource.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == m_filterDataSource.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "insertCellIdenfier")!
            return cell
        }
        else {
            switch m_filterDataSource[indexPath.row] {
            case .score:
                return tableView.dequeueReusableCell(withIdentifier: ScoreFilterUITableViewCell.cellIdenfierName) as! BaseFilterUITableViewCell
                
            case .version:
                return tableView.dequeueReusableCell(withIdentifier: VersionOnlyFilterUITableViewCell.cellIdenfierName) as! BaseFilterUITableViewCell
                
            default:
                return tableView.dequeueReusableCell(withIdentifier: "")!
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == m_filterDataSource.count {
            return .insert
        }
        else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            m_filterDataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut], animations: {
                tableView.frame.size.height -= 44.0
                self.view.frame.size.height -= 44.0
            })
        }
        else if editingStyle == .insert {
            m_filterDataSource.append(.version)
            tableView.insertRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .top)
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.m_filterTableViewHeightConstraint.constant += 44
            })
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
/**@section Event handler */
}
