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
/**@section Variable */
    public var m_layoutInitialized = false

/**@section Method */
    override public func layoutSubviews() {
        super.layoutSubviews()
         
        if m_layoutInitialized == false {
            self.initializeLayout()
            m_layoutInitialized = true
        }
    }
    
    private func initializeLayout() {
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
/**@section Property */
    public var isNeedToCreateDisclosureView : Bool { return true }
    public var musicFilterType : MusicFilterType { return MusicFilterType.score }
    
/**@section Variable */
    @IBOutlet weak var m_button: UIButton!
    private var m_disclosureView: UIView!
    private var m_divisionLineView: UIView!
    fileprivate var m_filterTypeBtn: UIButton!
    fileprivate var m_dataSource: Any?
    
/**@section Method */
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if m_filterTypeBtn == nil {
            m_filterTypeBtn = self.contentView.viewWithTag(449) as? UIButton
            m_filterTypeBtn.addTarget(self, action: #selector(onTouchEditFilterType), for: .touchUpInside)
        }
    
        if isNeedToCreateDisclosureView {
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
                m_divisionLineView.frame = CGRect(x: m_disclosureView.frame.width, y: 0.0, width: 0.5, height: self.frame.height)
            }
        }
    }
    
    public func createMusicFilter() -> MusicFilter {
        return MusicFilter()
    }
    
    public func getFilterData() -> Any? {
        return nil
    }
    
/**@section Event handler */
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.endEditing(true)
    }
    
    @objc public func onTouchEditFilterType() {
        guard let controller = self.parentViewController as? MusicFilterViewController else {
            return
        }
        
        controller.onTouchEditFilterType(tableViewCell: self)
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
            // Consider not played music
            m_minScore = (minScore == 0) ? -1 : minScore
            m_maxScore = maxScore
        }
        
    /**@section Method */
        public override func filterOut(musicScoreData: MusicScoreData) -> Bool {
            let musicScore = musicScoreData.score
            return !(m_minScore <= musicScore && musicScore <= m_maxScore)
        }
    }
    
/**@section Property */
    public override var musicFilterType : MusicFilterType { return MusicFilterType.score }
    
/**@section Variable */
    public static let cellIdenfierName = "scoreFilterCellIdenfier"
    @IBOutlet weak var m_minScoreTextField: UITextField!
    @IBOutlet weak var m_maxScoreTextField: UITextField!
    @IBOutlet weak var m_tildeLabel: UILabel!
    
/**@section Method */
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if m_minScoreTextField.delegate == nil {
            m_minScoreTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            m_minScoreTextField.delegate = self
        }
        
        if m_maxScoreTextField.delegate == nil {
            m_maxScoreTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            m_maxScoreTextField.delegate = self
        }
    }
    
    public override func createMusicFilter() -> MusicFilter {
        let minScore = m_minScoreTextField.text == nil ? 0 : Int(m_minScoreTextField.text!) ?? 0
        let maxScore = m_maxScoreTextField.text == nil ? 1000000 : Int(m_maxScoreTextField.text!) ?? 1000000
        
        return MusicScoreFilter(minScore: minScore, maxScore: maxScore)
    }
    
    public override func getFilterData() -> Any? {
        let minScore = m_minScoreTextField.text == nil ? 0 : Int(m_minScoreTextField.text!) ?? 0
        let maxScore = m_maxScoreTextField.text == nil ? 1000000 : Int(m_maxScoreTextField.text!) ?? 1000000
        
        return (minScore, maxScore)
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
        else {
            let isCanConvertToInt = Int(string) != nil
            if isCanConvertToInt == false {
                return false
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
        else {
            textField.text = "\(score)"
        }

        textField.invalidateIntrinsicContentSize()

        m_tildeLabel.textColor = .black
    }
}

public class VersionFilterUITableViewCell : BaseFilterUITableViewCell {
/**@section Class */
    public class MusicVersionFilter : MusicFilter {
    /**@section Variable */
        private var m_version: MusicVersion
        
    /**@section Method */
        public init(version: MusicVersion) {
            m_version = version
        }
        
        public override func filterOut(musicScoreData: MusicScoreData) -> Bool {
            return !(musicScoreData.version == m_version)
        }
    }
    
/**@section Property */
    public override var musicFilterType : MusicFilterType { return MusicFilterType.version }
    
/**@section Variable */
    public static let cellIdenfierName = "versionFilterCellIdenfier"
    private var m_currSelectedRow = 0
    private let m_versionStrDataSource = ["페스토", "클랜", "큐벨", "프롭", "소서 풀필", "소서", "코피어스", "니트", "리플즈", "오리지널"]
    private let m_versionDataSource: [MusicVersion] = [.festo, .clan, .qubell, .prop, .saucerFulfill, .saucer, .copious, .knit, .ripples, .original]
    @IBOutlet weak var m_versionBtn: UIButton!
    
/**@section Method */
    public override func createMusicFilter() -> MusicFilter {
        return MusicVersionFilter(version: m_versionDataSource[m_currSelectedRow])
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        m_versionBtn.setTitle(self.m_versionStrDataSource[m_currSelectedRow], for: .normal)
    }

    public override func getFilterData() -> Any? {
        return m_currSelectedRow
    }
    
/**@section Event handler */
    @IBAction func onTouchVersionButton(_ sender: UIButton) {
        let pickerView = ActionSheetStringPicker(title: nil, rows: m_versionStrDataSource, initialSelection: m_currSelectedRow, doneBlock: {
            picker, selectedIndex, selectedValue in
            sender.setTitle(self.m_versionStrDataSource[selectedIndex], for: .normal)
            self.m_currSelectedRow = selectedIndex
        }, cancel: nil, origin: sender)!
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        pickerView.pickerTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 23.0), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        pickerView.show()
    }
}

public class DifficultyFilterUITableViewCell : BaseFilterUITableViewCell {
/**@section Class */
    public class DifficultyFilter : MusicFilter {
    /**@section Variable */
        private var m_difficulty: MusicDifficulty
        
    /**@section Method */
        public init(difficulty: MusicDifficulty) {
            m_difficulty = difficulty
        }
        
        public override func filterOut(musicScoreData: MusicScoreData) -> Bool {
            return !(musicScoreData.difficulty == m_difficulty)
        }
    }
    
/**@section Property */
    public override var musicFilterType : MusicFilterType { return MusicFilterType.difficulty }
    
/**@section Variable */
    public static let cellIdenfierName = "difficultyFilterCellIdenfier"
    @IBOutlet weak var m_difficultySegmentedControl: UISegmentedControl!
    
/**@section Method */
    public override func createMusicFilter() -> MusicFilter {
        return DifficultyFilter(difficulty: MusicDifficulty(rawValue: m_difficultySegmentedControl.selectedSegmentIndex)!)
    }
    
    public override func getFilterData() -> Any? {
        return m_difficultySegmentedControl.selectedSegmentIndex
    }
}

public class LevelFilterUITableViewCell : BaseFilterUITableViewCell {
/**@section Class */
    public class LevelFilter : MusicFilter {
    /**@section Variable */
        private var m_level: Int
        
    /**@section Method */
        public init(level: Int) {
            m_level = level
        }
        
        public override func filterOut(musicScoreData: MusicScoreData) -> Bool {
            if m_level == allLevel10IndicatorValue {
                return !(100 <= musicScoreData.level && musicScoreData.level <= 109)
            }
            else if m_level == allLevel9IndicatorValue {
                return !(90 <= musicScoreData.level && musicScoreData.level <= 99)
            }
            else {
                return !(musicScoreData.level == m_level)
            }
        }
    }
    
/**@section Property */
    public override var musicFilterType : MusicFilterType { return MusicFilterType.level }
    
/**@section Variable */
    public static let cellIdenfierName = "levelFilterCellIdenfier"
    private static let allLevel10IndicatorValue = 999
    private static let allLevel9IndicatorValue = 998
    private var m_currSelectedRow = 0
    @IBOutlet weak var m_levelBtn: UIButton!
    private let m_levelStrDataSource = ["10레벨 전체", "10.9", "10.8", "10.7", "10.6", "10.5", "10.4", "10.3", "10.2", "10.1", "10.0", "9레벨 전체", "9.9", "9.8", "9.7", "9.6", "9.5", "9.4", "9.3", "9.2", "9.1", "9.0", "8", "7", "6", "5", "4", "3", "2", "1"]
    private let m_levelDataSource = [allLevel10IndicatorValue, 109, 108, 107, 106, 105, 104, 103, 102, 101, 100, allLevel9IndicatorValue, 99, 98, 97, 96, 95, 94, 93, 92, 91, 90, 80, 70, 60, 50, 40, 30, 20, 10]
    private var m_tapGestureRecognizer: UITapGestureRecognizer!
    
/**@section Method */
    public override func createMusicFilter() -> MusicFilter {
        return LevelFilter(level: m_levelDataSource[m_currSelectedRow])
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        m_levelBtn.setTitle(self.m_levelStrDataSource[m_currSelectedRow], for: .normal)
    }
    
    public override func getFilterData() -> Any? {
        return m_currSelectedRow
    }
    
/**@section Event handler */
    @IBAction func onTouchLevelBtn(_ sender: Any) {
        let pickerView = ActionSheetStringPicker(title: nil, rows: m_levelStrDataSource, initialSelection: m_currSelectedRow, doneBlock: {
            picker, selectedIndex, selectedValue in
            self.m_levelBtn.setTitle(self.m_levelStrDataSource[selectedIndex], for: .normal)
            self.m_currSelectedRow = selectedIndex
        }, cancel: nil, origin: sender)!
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        pickerView.pickerTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 23.0), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        pickerView.show()
    }
}

public class FullComboFilterUITableViewCell : BaseFilterUITableViewCell {
/**@section Class */
    public class FullComboFilter : MusicFilter {
    /**@section Variable */
        private var isFilterOutFullCombo: Bool
        
    /**@section Constructor */
        public init(isFilterOutFullCombo: Bool) {
            self.isFilterOutFullCombo = isFilterOutFullCombo
        }
        
    /**@section Method */
        public override func filterOut(musicScoreData: MusicScoreData) -> Bool {
            return !musicScoreData.isFullCombo
        }
    }

/**@section Property */
    public override var musicFilterType : MusicFilterType { return MusicFilterType.fullCombo }
    
/**@section Variable */
    public static let cellIdenfierName = "fullComboFilterCellIdenfier"
    @IBOutlet weak var m_fullComboSegmentedControl: UISegmentedControl!
    
/**@section Method */
    public override func createMusicFilter() -> MusicFilter {
        return FullComboFilter(isFilterOutFullCombo: m_fullComboSegmentedControl.selectedSegmentIndex != 0)
    }
}

public enum MusicFilterType : Int {
    case score
    case version
    case difficulty
    case level
    case fullCombo
    
    public func toString() -> String {
        switch self {
        case .score:
            return "스코어"
        case .version:
            return "시리즈"
        case .difficulty:
            return "난이도"
        case .level:
            return "레벨"
        case .fullCombo:
            return "풀 콤보"
        }
    }
}

public class MusicNotPlayedFilter : MusicFilter {
    public override func filterOut(musicScoreData: MusicScoreData) -> Bool {
        return !(musicScoreData.isNotPlayedYet)
    }
}

class MusicFilterViewController : UIViewController, SBCardPopupContent, UITableViewDelegate, UITableViewDataSource {
/**@section Variable */
    var popupViewController: SBCardPopupViewController?
    var allowsTapToDismissPopupCard = true
    var allowsSwipeToDismissPopupCard = false
    
    @IBOutlet weak var m_filterTableView: UITableView!
    @IBOutlet weak var m_filterTableViewHeightConstraint: NSLayoutConstraint!
    private lazy var m_filterTypeDataSource: [MusicFilterType] = [.score]
    private var m_optOnTouchOkButton: (([MusicFilter]) -> Void)?
    private var m_tickTimer = TickTimer()
    private let m_tableViewCellHeight: CGFloat = 44
    private let m_visibleCellCountPerOnePage = 7
    private static var m_cachedMusicFilterViewController: MusicFilterViewController!
    
/**@section Method */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_filterTableView.delegate = self
        m_filterTableView.dataSource = self
        m_filterTableView.contentInset = .zero
        m_filterTableView.setEditing(true, animated: false)
    }
    
    public static func show(currentViewController: UIViewController, optOnTouchOkButton: (([MusicFilter]) -> Void)? = nil) {
        if m_cachedMusicFilterViewController == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            m_cachedMusicFilterViewController = storyboard.instantiateViewController(withIdentifier: "MusicFilterViewController") as! MusicFilterViewController
        }
        
        let rootViewController = SBCardPopupViewController(contentViewController: m_cachedMusicFilterViewController) {
            self.m_cachedMusicFilterViewController.view.endEditing(true)
        }
        rootViewController.show(onViewController: currentViewController)
        
        m_cachedMusicFilterViewController.initialize(optOnTouchOkButton: optOnTouchOkButton)
    }
    
    private func initialize(optOnTouchOkButton: (([MusicFilter]) -> Void)?) {
        m_optOnTouchOkButton = optOnTouchOkButton
        
        m_filterTableViewHeightConstraint.constant = min(m_tableViewCellHeight * CGFloat(m_filterTypeDataSource.count + 1), m_tableViewCellHeight * CGFloat(m_visibleCellCountPerOnePage))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_filterTypeDataSource.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == m_filterTypeDataSource.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "insertCellIdenfier")!
            return cell
        }
        else {
            switch m_filterTypeDataSource[indexPath.row] {
            case .score:
                return tableView.dequeueReusableCell(withIdentifier: ScoreFilterUITableViewCell.cellIdenfierName)!
                
            case .version:
                return tableView.dequeueReusableCell(withIdentifier: VersionFilterUITableViewCell.cellIdenfierName)!
                
            case .difficulty:
                return tableView.dequeueReusableCell(withIdentifier: DifficultyFilterUITableViewCell.cellIdenfierName)!
                
            case .level:
                return tableView.dequeueReusableCell(withIdentifier: LevelFilterUITableViewCell.cellIdenfierName)!
                
            case .fullCombo:
                return tableView.dequeueReusableCell(withIdentifier: FullComboFilterUITableViewCell.cellIdenfierName)!
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == m_filterTypeDataSource.count {
            return .insert
        }
        else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.indices.count <= 0 {
            return
        }
        
        if editingStyle == .delete {
            m_filterTypeDataSource.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            if tableView.numberOfRows(inSection: 0) >= m_visibleCellCountPerOnePage {
                return
            }
            
            let prevFilterTableViewHeight = self.m_filterTableViewHeightConstraint.constant
            m_tickTimer.initialize(0.3, { [weak self] (tickTime: Double) in
                guard let strongSelf = self else {
                    return
                }
                
                //let interpolated = CGFloat(easeOutQuad(t: strongSelf.m_tickTimer.totalElapsedTime / strongSelf.m_tickTimer.duration))
                let interpolated = CGFloat(strongSelf.m_tickTimer.totalElapsedTime / strongSelf.m_tickTimer.duration)
                strongSelf.m_filterTableViewHeightConstraint.constant = prevFilterTableViewHeight - strongSelf.m_tableViewCellHeight * interpolated
            }) { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.m_filterTableViewHeightConstraint.constant = prevFilterTableViewHeight - strongSelf.m_tableViewCellHeight
            }
        }
        else if editingStyle == .insert {
            // Select a filter type which is not already in table view
            var i = 0
            while true {
                let optMusicFilterType = MusicFilterType(rawValue: i)
                guard let musicFilterType = optMusicFilterType else {
                    showOkPopup(self, "오류", "이미 모든 종류의 필터를 추가했습니다.")
                    return
                }
                
                if m_filterTypeDataSource.contains(musicFilterType) == false {
                    break
                }
                
                i += 1
            }
            
            m_filterTypeDataSource.append(MusicFilterType(rawValue: i)!)
            
            tableView.insertRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .top)
            if tableView.numberOfRows(inSection: 0) > m_visibleCellCountPerOnePage {
                return
            }
            
            let prevFilterTableViewHeight = self.m_filterTableViewHeightConstraint.constant
            m_tickTimer.initialize(0.3, { [weak self] (tickTime: Double) in
                guard let strongSelf = self else {
                    return
                }
                
                //let interpolated = CGFloat(easeOutQuad(t: strongSelf.m_tickTimer.totalElapsedTime / strongSelf.m_tickTimer.duration))
                let interpolated = CGFloat(strongSelf.m_tickTimer.totalElapsedTime / strongSelf.m_tickTimer.duration)
                strongSelf.m_filterTableViewHeightConstraint.constant = prevFilterTableViewHeight + strongSelf.m_tableViewCellHeight * interpolated
            }) { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.m_filterTableViewHeightConstraint.constant = prevFilterTableViewHeight + strongSelf.m_tableViewCellHeight
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
/**@section Event handler */
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    public func onTouchEditFilterType(tableViewCell: BaseFilterUITableViewCell) {
        var filterTypeStrDataSource: [String] = []
        var filterTypeDataSource: [MusicFilterType] = []
        
        // Fill the data sources
        var i = 0
        while true {
            let optMusicFilterType = MusicFilterType(rawValue: i)
            guard let musicFilterType = optMusicFilterType else {
                break
            }
            
            if m_filterTypeDataSource.contains(musicFilterType) {
                i += 1
                continue
            }
            
            filterTypeStrDataSource.append(musicFilterType.toString())
            filterTypeDataSource.append(musicFilterType)
            
            i += 1
        }
        
        if filterTypeStrDataSource.count <= 0 {
            return
        }
        
        guard let tableViewCellIndexPath = self.m_filterTableView.indexPath(for: tableViewCell) else {
            return
        }
        
        // Show the picker view
        let pickerView = ActionSheetStringPicker(title: nil, rows: filterTypeStrDataSource, initialSelection: 0, doneBlock: {
            picker, selectedIndex, selectedValue in
            self.m_filterTypeDataSource[tableViewCellIndexPath.row] = filterTypeDataSource[selectedIndex]
            self.m_filterTableView.reloadData()
        }, cancel: nil, origin: self.view)!

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        pickerView.pickerTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 23.0), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        pickerView.show()
    }
    
    @IBAction func onTouchOkButton(_ sender: Any) {
        guard let onTouchOkButton = m_optOnTouchOkButton else {
            return
        }
        
        var filters: [MusicFilter] = []
        var recentFilterCache: [(MusicFilterType, Any?)] = []
        
        let rowCount = m_filterTableView.numberOfRows(inSection: 0)
        for i in 0..<rowCount {
            guard let filterCell = m_filterTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? BaseFilterUITableViewCell else {
                continue
            }
            filters.append(filterCell.createMusicFilter())
            recentFilterCache.append((filterCell.musicFilterType, filterCell.getFilterData()))
        }
        
        onTouchOkButton(filters);
        
        SettingDataStorage.instance.setRecentMusicFilters(recentMusicFilterCaches: recentFilterCache)
        
        popupViewController?.close()
    }
}
