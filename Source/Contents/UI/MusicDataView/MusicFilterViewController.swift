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
import CoreActionSheetPicker

public class MusicFilter {
/**@section Method */
    public func filterOut(musicScoreData: MusicScoreData) -> Bool {
        return false
    }
}

public class LeftMarginRemovedUITableViewCell : UITableViewCell {
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        for subview in self.subviews {
            if String(describing: type(of: subview)).hasSuffix("SeparatorView") {
                subview.frame.size.width += 10.0
            }
            
            subview.frame.origin.x -= 10.0
        }
        
        self.separatorInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
    }
}

public class BaseFilterUITableViewCell : LeftMarginRemovedUITableViewCell {
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
    }
    
    public func createMusicFilter() -> MusicFilter {
        return MusicFilter()
    }
    
/**@section Event handler */
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.endEditing(true)
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
    private var m_currSelectedRow = 0
    private let m_versionStrDataSource = ["페스토", "클랜", "큐벨", "프롭", "소서 풀필", "소서", "코피어스", "니트", "리플즈", "오리지널"]
    private let m_versionDataSource: [MusicScoreData.Version] = [.festo, .clan, .qubell, .prop, .saucerFulfill, .saucer, .copious, .knit, .ripples, .original]
    
/**@section Method */
    public override func createMusicFilter() -> MusicFilter {
        return MusicVersionOnlyFilter(version: m_version)
    }

    @IBAction func onTouchVersionButton(_ sender: UIButton) {
        let pickerView = ActionSheetStringPicker(title: nil, rows: m_versionStrDataSource, initialSelection: m_currSelectedRow, doneBlock: {
            picker, selectedIndex, selectedValue in
            sender.titleLabel!.text = self.m_versionStrDataSource[selectedIndex]
            self.m_currSelectedRow = selectedIndex
        }, cancel: nil, origin: sender)!
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        pickerView.pickerTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 23.0), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        pickerView.show()
    }
}

public class DifficultyOnlyFilterUITableViewCell : BaseFilterUITableViewCell {
/**@section Class */
    public class DifficultyOnlyFilter : MusicFilter {
    /**@section Variable */
        private var m_difficulty: MusicScoreData.Difficulty
        
    /**@section Method */
        public init(difficulty: MusicScoreData.Difficulty) {
            m_difficulty = difficulty
        }
        
        public override func filterOut(musicScoreData: MusicScoreData) -> Bool {
            return musicScoreData.difficulty == m_difficulty
        }
    }
    
/**@section Variable */
    public static let cellIdenfierName = "difficultyOnlyFilterCellIdenfier"
    private var m_difficulty: MusicScoreData.Difficulty = .basic
    
/**@section Method */
    public override func createMusicFilter() -> MusicFilter {
        return DifficultyOnlyFilter(difficulty: m_difficulty)
    }
}

public class LevelOnlyFilterUITableViewCell : BaseFilterUITableViewCell {
/**@section Class */
    public class LevelOnlyFilter : MusicFilter {
    /**@section Variable */
        private var m_level: Int
        
    /**@section Method */
        public init(level: Int) {
            m_level = level
        }
        
        public override func filterOut(musicScoreData: MusicScoreData) -> Bool {
            return musicScoreData.level == m_level
        }
    }
    
/**@section Variable */
    public static let cellIdenfierName = "levelOnlyFilterCellIdenfier"
    private var m_currSelectedRow = 0
    @IBOutlet weak var m_levelLabel: UILabel!
    private let m_levelStrDataSource = ["10.9", "10.8", "10.7", "10.6", "10.5", "10.4", "10.3", "10.2", "10.1", "10.0", "9", "8", "7", "6", "5", "4", "3", "2", "1"]
    private let m_levelDataSource = [109, 108, 107, 106, 105, 104, 103, 102, 101, 100, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    private var m_tapGestureRecognizer: UITapGestureRecognizer!
    
/**@section Method */
    public override func createMusicFilter() -> MusicFilter {
        return LevelOnlyFilter(level: m_levelDataSource[m_currSelectedRow])
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        m_levelLabel.isUserInteractionEnabled = true
        
        if m_tapGestureRecognizer == nil {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTouchLabel))
            m_levelLabel.addGestureRecognizer(tapGestureRecognizer)
            
            m_tapGestureRecognizer = tapGestureRecognizer
        }
    }
    
    @objc private func onTouchLabel() {
        let pickerView = ActionSheetStringPicker(title: nil, rows: m_levelStrDataSource, initialSelection: m_currSelectedRow, doneBlock: {
            picker, selectedIndex, selectedValue in
            self.m_levelLabel.text = self.m_levelStrDataSource[selectedIndex]
            self.m_currSelectedRow = selectedIndex
        }, cancel: nil, origin: m_levelLabel)!
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        pickerView.pickerTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 23.0), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        pickerView.show()
    }
}

private enum MusicFilterType : Int {
    case score
    case versionOnly
    case difficultyOnly
    case levelOnly
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
                
            case .versionOnly:
                return tableView.dequeueReusableCell(withIdentifier: VersionOnlyFilterUITableViewCell.cellIdenfierName) as! BaseFilterUITableViewCell
                
            case .difficultyOnly:
                return tableView.dequeueReusableCell(withIdentifier: DifficultyOnlyFilterUITableViewCell.cellIdenfierName) as! BaseFilterUITableViewCell
                
            case .levelOnly:
                return tableView.dequeueReusableCell(withIdentifier: LevelOnlyFilterUITableViewCell.cellIdenfierName) as! BaseFilterUITableViewCell
                
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
        let tableViewCellHeight: CGFloat = 44
        
        if editingStyle == .delete {
            m_filterDataSource.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            if tableView.numberOfRows(inSection: 0) >= 5 {
                return
            }
            
            self.m_filterTableViewHeightConstraint.constant -= tableViewCellHeight
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.m_filterTableView.layoutIfNeeded()
                self.view.layoutIfNeeded()
            })
        }
        else if editingStyle == .insert {
            // Select a filter type which is not already in table view
            var i = 0
            while true {
                let optMusicFilterType = MusicFilterType(rawValue: i)
                guard let musicFilterType = optMusicFilterType else {
                    i = 0
                    break
                }
                
                if m_filterDataSource.contains(musicFilterType) == false {
                    break
                }
                
                i += 1
            }
            
            m_filterDataSource.append(MusicFilterType(rawValue: i)!)
            
            tableView.insertRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .top)
            if tableView.numberOfRows(inSection: 0) > 5 {
                return
            }
            
            self.m_filterTableViewHeightConstraint.constant += tableViewCellHeight

            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.m_filterTableView.layoutIfNeeded()
                self.view.layoutIfNeeded()
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
