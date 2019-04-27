//
//  RivalRankCellView.swift
//  jubiinfo
//
//  Created by ggomdyu on 05/02/2019.
//  Copyright © 2019 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

public class RivalRankCellView : UIView {
/**@section Variable */
    @IBOutlet weak var m_nicknameLabel: UILabel!
    @IBOutlet weak var m_scoreLabel: UILabel!
    @IBOutlet weak var m_lockImageView: UIImageView!
    @IBOutlet weak var m_crownImageView: UIImageView!
    @IBOutlet weak var m_crownImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var m_colorBoxView: UIView!
    private let m_grayBoxColor = UIColor(red: 0.83, green: 0.83, blue: 0.83, alpha: 1.0)
    
/**@section Method */
    public func initialize(nickname: String, isProfilePrivated: Bool, ranking: Int = 0, score: Int = 0) {
        m_nicknameLabel.text = nickname
        
        if isProfilePrivated == false {
            // User played the music at least once
            if score != -1 {
                m_scoreLabel.text = "\(score)"
                
                if ranking <= 3 {
                    let crownNameTable = ["goldCrown.png", "silverCrown.png", "bronzeCrown.png"]
                    m_crownImageView.image = UIImage(named: crownNameTable[ranking - 1])
                    m_crownImageView.isHidden = false
                }
                else {
                    m_crownImageLeadingConstraint.constant -= m_crownImageView.frame.width + 5
                    m_crownImageView.isHidden = true
                }
                
                m_colorBoxView.backgroundColor = getCurrentThemeColorTable().musicCellViewRivalScoreBarColor
            }
            // User not played the music yet
            else {
                m_scoreLabel.text = " -"
                m_crownImageLeadingConstraint.constant -= m_crownImageView.frame.width + 5
                
                m_crownImageView.isHidden = true
                
                m_colorBoxView.backgroundColor = m_grayBoxColor
            }
            
            m_lockImageView.isHidden = true
        }
        else {
            m_lockImageView.isHidden = false
            
            m_scoreLabel.isHidden = true
            
            m_crownImageLeadingConstraint.constant -= m_crownImageView.frame.width + 5
            m_crownImageView.isHidden = true
            
            m_colorBoxView.backgroundColor = m_grayBoxColor
        }
    }
}
