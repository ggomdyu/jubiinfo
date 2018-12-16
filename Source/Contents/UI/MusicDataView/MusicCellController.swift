//
//  MusicCellController.swift
//  jubiinfo
//
//  Created by 차준호 on 15/12/2018.
//  Copyright © 2018 차준호. All rights reserved.
//

import Foundation
import UIKit

public class MusicCellController : UIViewController {
    @IBOutlet weak var difficultyColorView: UIView!
    @IBOutlet weak var musicCoverImageView: UIImageView!
    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var fullComboLabel: UILabel!
    private var optMusicDataCache: SimpleMusicData?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        guard let musicDataCache = optMusicDataCache else {
            return
        }
        
        let imageNumber = musicDataCache.musicId / 10000000
        downloadImageAsync(imageUrl: "https://p.eagate.573.jp/game/jubeat/festo/common/images/jacket/\(imageNumber)/id\(musicDataCache.musicId ).gif") { (isDownloadSucceed: Bool, image: UIImage?) in
            self.musicCoverImageView.image = image
        }
        
        let rankData = self.getRankDataByScore(score: musicDataCache.extremeScore)
        rankLabel.text = rankData.0
        rankLabel.textColor = rankData.1
        
        scoreLabel.text = "\(musicDataCache.extremeScore)"
        musicNameLabel.text = musicDataCache.musicName
        fullComboLabel.isHidden = true
    }
}

extension MusicCellController {
    public func lazyInit(musicDataCache: SimpleMusicData) {
        self.optMusicDataCache = musicDataCache
    }
    
    private func getRankDataByScore(score: Int) -> (String, UIColor) {

        if (score >= 1000000) {
            return ("EXC", UIColor(red: 147 / 255, green: 230 / 255, blue: 33 / 255, alpha: 1))
        }
        else if (score >= 980000) {
            return ("SSS", UIColor(red: 255 / 255, green: 216 / 255, blue: 83 / 255, alpha: 1))
        }
        else if (score >= 950000) {
            return ("SS", UIColor(red: 255 / 255, green: 216 / 255, blue: 83 / 255, alpha: 1))
        }
        else if (score >= 900000) {
            return ("S", UIColor(red: 255 / 255, green: 216 / 255, blue: 83 / 255, alpha: 1))
        }
        else if (score >= 850000) {
            return ("A", UIColor(red: 235 / 255, green: 53 / 255, blue: 93 / 255, alpha: 1))
        }
        else if (score >= 800000) {
            return ("B", UIColor(red: 69 / 255, green: 165 / 255, blue: 248 / 255, alpha: 1))
        }
        else if (score >= 700000) {
            return ("C", UIColor(red: 161 / 255, green: 161 / 255, blue: 161 / 255, alpha: 1))
        }
        else if (score >= 500000) {
            return ("D", UIColor(red: 161 / 255, green: 161 / 255, blue: 161 / 255, alpha: 1))
        }
        else if (score >= 1) {
            return ("E", UIColor(red: 161 / 255, green: 161 / 255, blue: 161 / 255, alpha: 1))
        }
        else {
            return ("NP", UIColor(red: 161 / 255, green: 161 / 255, blue: 161 / 255, alpha: 1))
        }
    }
}
