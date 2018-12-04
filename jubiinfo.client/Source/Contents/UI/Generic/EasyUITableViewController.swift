//
//  EasyUITableViewController.swift
//  jubiinfo
//
//  Created by ggomdyu on 01/03/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

public class DetailPageUITableViewCell : UITableViewCell {
}

public class TextFieldUITableViewCell : UITableViewCell {
/**@section Variable */
    @IBOutlet weak var textField: UITextField!
}

public class ConfirmButtonUITableViewCell : UITableViewCell {
/**@section Variable */
    @IBOutlet weak var button: UIButton!
    public var onTouchButton: (() -> Void)?
    
/**@section Event handler */
    @IBAction func onTouchButton(_ sender: Any) {
        self.onTouchButton?()
    }
}

public class EasyUITableViewController : UITableViewController {
/**@section Enum */
    public enum RowType {
        case basic
        case confirmBtn
        case textfield
        case detailPageBtn
    }
    
/**@section Variable */
    public lazy var sectionDataTable = self.createSectionDataTable()
    
/**@section Method */
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.isUserInteractionEnabled = true
        self.tableView.allowsSelection = true
        self.tableView.allowsSelectionDuringEditing = true
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionDataTable[section].0
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionDataTable[section].1.count
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDataTable.count
    }
    
    override public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = sectionDataTable[sourceIndexPath.section].1[sourceIndexPath.row]
        sectionDataTable[sourceIndexPath.section].1.remove(at: sourceIndexPath.row)
        sectionDataTable[destinationIndexPath.section].1.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        let rowType = sectionDataTable[indexPath.section].1[indexPath.row].rowType
        switch rowType {
        case .basic:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "LabelCellIdenfier")
            break
            
        case .textfield:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "TextFieldCellIdenfier")
            break
            
        case .confirmBtn:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "ConfirmButtonCellIdenfier")
            break
            
        case .detailPageBtn:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "DetailPageCellIdenfier")
            break
        }
        
        sectionDataTable[indexPath.section].1[indexPath.row].initializer(cell)
        
        return cell
    }
    
    public func createSectionDataTable() -> [(sectionTitle: String, [(rowType: RowType, initializer: (Any?) -> Void, param: Any?)])] {
        return [("", [(RowType.basic, { (param: Any?) in }, nil )])]
    }
}
