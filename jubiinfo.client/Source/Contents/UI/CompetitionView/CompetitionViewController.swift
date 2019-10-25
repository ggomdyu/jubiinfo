//
//  CompetitionViewController.swift
//  jubiinfo
//
//  Created by ggomdyu on 27/04/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import Material

class FeaturedCompetitionCellView : UIView {
/**@section Variable */
    @IBOutlet weak var m_titleLabel: UILabel!
    @IBOutlet weak var m_subTitleLabel: UILabel!
    @IBOutlet weak var m_endDateLabel: UILabel!
    @IBOutlet weak var m_mainImageLabel: UIImageView!
    @IBOutlet weak var m_subImageLabel: UIImageView!
    
/**@section Method */
    public func initialize(competitionDesc: CompetitionDesc) {
        m_titleLabel.text = competitionDesc.title
        m_subTitleLabel.text = competitionDesc.subTitle
        
        let calender = Calendar(identifier: .iso8601)
        let endDateTime = Date(timeIntervalSince1970: Double(competitionDesc.endDate) * 0.001)
        let endYear = calender.component(.year, from: endDateTime)
        let endMonth = calender.component(.month, from: endDateTime)
        let endDay = calender.component(.day, from: endDateTime)
        m_endDateLabel.text = "~\(endYear).\(endMonth).\(endDay)까지"
    }
}

class CompetitionViewController : ViewController, UITableViewDelegate, UITableViewDataSource {
/**@section Variable */
    @IBOutlet var m_topView: UIView!
    @IBOutlet weak var m_scrollView: UIScrollView!
    @IBOutlet weak var m_featuredCompetitionStackView: CustomStackView!
    @IBOutlet weak var m_featuredCompetitionSectionView: UITableView!
    @IBOutlet weak var m_normalCompetitionTableView: UITableView!
    private var m_normalCompetitionDataSource: [String] = ["대회 참가", "대회 열기", "참여중인 대회"]
    
/**@section Method */
    public static func show(currentViewController: UIViewController) {
        let controller = self.create()
        currentViewController.present(controller, animated: true)
    }
    
    private static func create() -> TransitionController  {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let competitionViewController = storyboard.instantiateViewController(withIdentifier: "CompetitionViewController") as! CompetitionViewController
        
        let toolBarController = CompetitionViewToolBarController(rootViewController: competitionViewController)
        
        let navigationDrawerController = NavigationDrawerController(rootViewController: toolBarController)
        navigationDrawerController.isHiddenStatusBarEnabled = false
        
        let snackbarController = SnackbarController(rootViewController: navigationDrawerController)
        snackbarController.motionTransitionType = .autoReverse(presenting: .push(direction: .left))
        snackbarController.isMotionEnabled = true
        snackbarController.modalPresentationStyle = .fullScreen
        
        return snackbarController
    }
    
    override func prepare() {
        super.prepare()
        
        m_featuredCompetitionSectionView.delegate = self
        m_featuredCompetitionSectionView.dataSource = self
        
        m_normalCompetitionTableView.isScrollEnabled = false
        m_normalCompetitionTableView.delegate = self
        m_normalCompetitionTableView.dataSource = self
        
        self.prepareFeaturedCompetitionTickets()
        self.prepareScrollView()
        self.prepareTheme()
    }
    
    private func prepareFeaturedCompetitionTickets() {
        JubiinfoWebServer.requestFeaturedCompetition { (isRequestSucceed: Bool, competitions: [CompetitionDesc]?) in
            if isRequestSucceed {
                runTaskInMainThread {
                    for competition in competitions! {
                        self.m_featuredCompetitionStackView.addMargin(margin: 10.0)
                        self.m_featuredCompetitionStackView.addView(view: self.createFeaturedCompetitionCellView(competitionDesc: competition))
                    }
                    
                    self.m_featuredCompetitionStackView.addMargin(margin: 15.0)
                }
            }
        }
    }
    
    private func prepareScrollView() {
        m_scrollView.contentInsetAdjustmentBehavior = .never
        m_scrollView.insetsLayoutMarginsFromSafeArea = false
    }
    
    private func prepareTheme() {
        m_scrollView.backgroundColor = getCurrentThemeColorTable().tableViewBackgroundColor
        
        m_featuredCompetitionSectionView.backgroundColor = UIColor.clear
        m_featuredCompetitionStackView.backgroundColor = UIColor.clear
        m_normalCompetitionTableView.backgroundColor = UIColor.clear
    }
    
    private func createFeaturedCompetitionCellView(competitionDesc: CompetitionDesc) -> FeaturedCompetitionCellView {
        let view = UINib(nibName: "FeaturedCompetitionCellView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! FeaturedCompetitionCellView
        view.initialize(competitionDesc: competitionDesc)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == m_featuredCompetitionSectionView {
            return 0
        }
        else {
            return m_normalCompetitionDataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.m_normalCompetitionTableView.dequeueReusableCell(withIdentifier: "title")!
        cell.textLabel?.text = m_normalCompetitionDataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == m_featuredCompetitionSectionView {
            return "피쳐드 대회"
        }
        else {
            return "일반 대회"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

public class CompetitionViewToolBarController: ToolbarController {
/**@section Variable */
    private var m_leftTabPrevButton: IconButton!
    
/**@section Method */
    open override func prepare() {
        super.prepare()
        
        self.prepareStatusBar()
        self.prepareToolbarTitle()
        self.prepareToolbarLeftIcon()
        
        self.prepareTheme()
    }
    
    private func prepareStatusBar() {
        statusBarStyle = .lightContent
    }
    
    private func prepareToolbarTitle() {
        toolbar.title = "대회"
    }
    
    private func prepareToolbarLeftIcon() {
        m_leftTabPrevButton = IconButton(image: Icon.cm.arrowBack)
        m_leftTabPrevButton.addTarget(self, action: #selector(onTouchPrevButton), for: .touchUpInside)
        toolbar.leftViews = [m_leftTabPrevButton]
    }
    
    private func prepareTheme() {
        statusBar.backgroundColor = getCurrentThemeColorTable().toolBarBackgroundColor
        
        toolbar.titleLabel.textColor = getCurrentThemeColorTable().toolBarTitleLabelColor
        toolbar.backgroundColor = getCurrentThemeColorTable().toolBarBackgroundColor
        
        m_leftTabPrevButton.tintColor = getCurrentThemeColorTable().toolBarIconColor
    }
    
/**@section Event handler */
    @objc private func onTouchPrevButton() {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }
}
