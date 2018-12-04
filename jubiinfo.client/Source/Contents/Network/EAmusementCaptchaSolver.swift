//
//  EAmusementCaptchaSolver.swift
//  jubiinfo
//
//  Created by ggomdyu on 28/12/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit

public class EAmusementCaptchaSolver {
/**@section Enum */
    private enum CharacterType {
        case Unknown
        case Bomberman
        case Girl
        case Goemon
        case Rabbit
        case Robot
    }
    
/**@section Variable */
    private var mainCharacterImageUrl: String
    private var subCharacterImageUrls: [String]
    private let rabbitIdentifierColor = Color3b(0, 220, 170)
    private let robotIdentifierColor = Color3b(40, 90, 180)
    private let girlIdentifierColor = Color3b(240, 90, 145)
    private let bombermanIdentifierColor = Color3b(255, 225, 170)
    private let goemonIdentifierColor = Color3b(230, 55, 35)
    
/**@section Constructor */
    public init(_ mainCharacterImageUrl: String, _ subCharacterImageUrls: [String]) {
        self.mainCharacterImageUrl = mainCharacterImageUrl;
        self.subCharacterImageUrls = subCharacterImageUrls
    }
    
/**@section Method */
    public func SolveProblem() -> [Int]? {
        // 1. Download main character image and identify the type of character.
        var mainCharacterType = CharacterType.Unknown
        var mainCharacterTypeQueryComplete = false
        
        downloadImageAsync(imageUrl: self.mainCharacterImageUrl, isWriteCache: false, isReadCache: false, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
            mainCharacterType = self.getMainCharacterType(optImage: image)
            mainCharacterTypeQueryComplete = true
        })
        
        // 2. Download sub character images together while requesting.
        let subCharacterImageCount = 5;
        var downloadedSubCharacterImageCount: Int32 = 0;
        var subCharacterImages = [UIImage?](repeating: nil, count: subCharacterImageCount)
        for i in 0 ... 4 {
            downloadImageAsync(imageUrl: subCharacterImageUrls[i], isWriteCache: false, isReadCache: false, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
                if isDownloadSucceed {
                    subCharacterImages[i] = image
                }
                
                OSAtomicIncrement32(&downloadedSubCharacterImageCount)
            })
        }
        
        Debug.log("[DEBUG]: Wait until all images have downloaded.")
        
        // 3. Wait until the above task have finished
        SpinLock {
            return mainCharacterTypeQueryComplete && downloadedSubCharacterImageCount >= subCharacterImageCount
        }
        
        if mainCharacterType == .Unknown || (subCharacterImages.firstIndex(of: nil) != nil) {
            return nil
        }
        
        // 4. Finally, we have to select two sub character images that matched with the main character type.
        return self.getMatchedSubCharacterIndices(mainCharacterType: mainCharacterType, subCharacterImages: subCharacterImages);
    }
    
    private func getMainCharacterType(optImage: UIImage?) -> CharacterType {
        repeat {
            guard let image = optImage else {
                break
            }
            
            let characterTypeMatchConditionTable = [
                (Point<Int>(42, 19), bombermanIdentifierColor, CharacterType.Bomberman),
                (Point<Int>(55, 8), girlIdentifierColor, CharacterType.Girl),
                (Point<Int>(42, 58), goemonIdentifierColor, CharacterType.Goemon),
                (Point<Int>(48, 11), rabbitIdentifierColor, CharacterType.Rabbit),
                (Point<Int>(53, 22), robotIdentifierColor, CharacterType.Robot)
            ]
            
            for characterTypeMatchCondition in characterTypeMatchConditionTable {
                if (getImagePixel(image: image, point: characterTypeMatchCondition.0) == characterTypeMatchCondition.1)
                {
                    return characterTypeMatchCondition.2
                }
            }
        }
            while (false)
        
        return CharacterType.Unknown
    }
    
    private func getMatchedSubCharacterIndices(mainCharacterType: CharacterType, subCharacterImages: [UIImage?]) -> [Int]? {
        
        Debug.log("[DEBUG]: ImageMatchProblemSolver begun to solve image match problem.")
        
        var characterTypeMatchConditionTable = [
            CharacterType.Bomberman: ([Point<Int>(49, 9), Point<Int>(48, 34), Point<Int>(57, 32), Point<Int>(51, 20), Point<Int>(31, 29)], bombermanIdentifierColor),
            CharacterType.Girl: ([Point<Int>(41, 15), Point<Int>(39, 10), Point<Int>(45, 13), Point<Int>(50, 14), Point<Int>(42, 11)], girlIdentifierColor),
            CharacterType.Goemon: ([Point<Int>(56, 51), Point<Int>(49, 49), Point<Int>(55, 60), Point<Int>(59, 68), Point<Int>(38, 72)], goemonIdentifierColor),
            CharacterType.Rabbit: ([Point<Int>(81, 9), Point<Int>(55, 11), Point<Int>(38, 5), Point<Int>(31, 18), Point<Int>(69, 4)], rabbitIdentifierColor),
            CharacterType.Robot: ([Point<Int>(37, 54), Point<Int>(68, 32), Point<Int>(27, 45), Point<Int>(27, 49), Point<Int>(48, 45)], robotIdentifierColor)
        ];
        
        var matchedSubCharacterIncides = [Int]()
        
        // Get the condition datas to check character type of UIImage
        var characterTypeMatchCondition = characterTypeMatchConditionTable[mainCharacterType]!;
        
        for i in 0 ..< subCharacterImages.count {
            let subCharacterImage = subCharacterImages[i]
            for j in 0 ..< characterTypeMatchCondition.0.count {
                if (getImagePixel(image: subCharacterImage!, point: characterTypeMatchCondition.0[j]) == characterTypeMatchCondition.1) {
                    matchedSubCharacterIncides.append(i)
                    break
                }
            }
        }
        
        Debug.log("[DEBUG]: ImageMatchProblemSolver finished to solve image match problem.")
        
        return matchedSubCharacterIncides
    }
}
