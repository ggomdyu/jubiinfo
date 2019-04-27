//
//  ThemeColorTable.swift
//  jubiinfo
//
//  Created by ggomdyu on 04/03/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

public class ThemeColorTable {
    public var backgroundImageName: String { return "" }
    public var backgroundImageColor: UIColor { return m_backgroundImageColor }
    public var scrollViewBackgroundColor: UIColor { return UIColor.white }
    public var tableViewBackgroundColor: UIColor { return UIColor.white }
    public var toolBarBackgroundColor: UIColor { return UIColor.white }
    public var toolBarTitleLabelColor: UIColor { return UIColor.white }
    public var toolBarIconColor: UIColor { return UIColor.white }
    public var musicCellViewExcBackgroundColor: UIColor { return UIColor.white }
    public var musicCellViewRivalScoreBarColor: UIColor { return UIColor.white }
    public var musicCellViewGraphFillColor: UIColor { return UIColor.white }
    public var profileViewMenuBackgroundColor: UIColor { return UIColor.white }
    public var profileViewMenuLabelColor: UIColor { return UIColor.white }
    
    private lazy var m_backgroundImageColor = UIColor(patternImage: UIImage(named: backgroundImageName)!)
}

public class FestoThemeColorTable : ThemeColorTable {
    public override var backgroundImageName: String { return "background_festo.jpg" }
    public override var scrollViewBackgroundColor: UIColor { return UIColor(red: 250 / 255, green: 245 / 255, blue: 228 / 255, alpha: 0.98) }
    public override var tableViewBackgroundColor: UIColor { return scrollViewBackgroundColor }
    public override var toolBarBackgroundColor: UIColor { return UIColor(red: 36 / 255, green: 75 / 255, blue: 67 / 255, alpha: 1) }
    public override var toolBarTitleLabelColor: UIColor { return UIColor(red: 255 / 255, green: 253 / 255, blue: 228 / 255, alpha: 1) }
    public override var toolBarIconColor: UIColor { return UIColor.white }
    public override var musicCellViewExcBackgroundColor: UIColor { return UIColor(red: 1.0, green: 250 / 255, blue: 194 / 255, alpha: 1.0) }
    public override var musicCellViewRivalScoreBarColor: UIColor { return UIColor(red: 0.80595391, green: 0.9373608, blue: 0.71661174, alpha: 1.0) }
    public override var musicCellViewGraphFillColor: UIColor { return UIColor(red: 250.0 / 255.0, green: 244.0 / 255.0, blue: 228.0 / 255.0, alpha: 1.0) }
    public override var profileViewMenuBackgroundColor: UIColor { return UIColor(red: 0.141176, green: 0.294117, blue: 0.262745, alpha: 1.0) }
    public override var profileViewMenuLabelColor: UIColor { return UIColor.white }
}

public class ClanThemeColorTable : ThemeColorTable {
    public override var backgroundImageName: String { return "background_clan.png" }
    public override var scrollViewBackgroundColor: UIColor { return UIColor.clear }
    public override var tableViewBackgroundColor: UIColor { return scrollViewBackgroundColor }
    public override var toolBarBackgroundColor: UIColor { return UIColor(red: 222 / 255, green: 222 / 255, blue: 222 / 255, alpha: 1) }
    public override var toolBarTitleLabelColor: UIColor { return UIColor(red: 41 / 255, green: 41 / 255, blue: 41 / 255, alpha: 1) }
    public override var toolBarIconColor: UIColor { return UIColor(red: 41 / 255, green: 41 / 255, blue: 41 / 255, alpha: 1) }
    public override var musicCellViewExcBackgroundColor: UIColor { return UIColor.white }
    public override var musicCellViewGraphFillColor: UIColor { return UIColor(red: 235 / 255, green: 235 / 255, blue: 235 / 255, alpha: 1.0) }
    public override var profileViewMenuLabelColor: UIColor { return UIColor.black }
}

public class QubellThemeColorTable : ThemeColorTable {
    public override var backgroundImageName: String { return "background_qubell.jpg" }
    public override var scrollViewBackgroundColor: UIColor { return UIColor.clear }
    public override var tableViewBackgroundColor: UIColor { return backgroundImageColor }
    public override var toolBarBackgroundColor: UIColor { return UIColor(red: 222 / 255, green: 222 / 255, blue: 222 / 255, alpha: 1) }
    public override var toolBarTitleLabelColor: UIColor { return toolBarIconColor }
    public override var toolBarIconColor: UIColor { return UIColor(red: 58 / 255, green: 77 / 255, blue: 116 / 255, alpha: 1) }
    public override var musicCellViewExcBackgroundColor: UIColor { return UIColor(red: 247 / 255, green: 251 / 255, blue: 249 / 255, alpha: 1.0) }
    public override var musicCellViewRivalScoreBarColor: UIColor { return UIColor(red: 211 / 255, green: 229 / 255, blue: 238 / 255, alpha: 1.0 ) }
    public override var musicCellViewGraphFillColor: UIColor { return UIColor(red: 211 / 255, green: 229 / 255, blue: 238 / 255, alpha: 1.0 ) }
    public override var profileViewMenuBackgroundColor: UIColor { return UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1) }
    public override var profileViewMenuLabelColor: UIColor { return toolBarTitleLabelColor }
}

private let g_themeColorTables: [ThemeColorTable?] = {
    var ret = [ThemeColorTable?](repeating: nil, count: ThemeType.allCases.count)
    ret[ThemeType.festo.rawValue] = FestoThemeColorTable()
    ret[ThemeType.clan.rawValue] = ClanThemeColorTable()
    ret[ThemeType.qubell.rawValue] = QubellThemeColorTable()
    
    return ret
} ()

public func getThemeColorTable(themeType: ThemeType) -> ThemeColorTable {
    return g_themeColorTables[themeType.rawValue]!
}

public func getCurrentThemeColorTable() -> ThemeColorTable {
    return getThemeColorTable(themeType: SettingDataStorage.instance.getActiveTheme())
}
