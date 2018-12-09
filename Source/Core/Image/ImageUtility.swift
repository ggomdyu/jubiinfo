//
//  ImageUtility.swift
//  jubiinfo
//
//  Created by ggomdyu on 28/11/2018.
//  Copyright © 2018 ggomdyu. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

public func getImagePixel(image: UIImage, point: Point<Int>) -> Color3b {
    let data = image.cgImage!.dataProvider!.data
    let imageData: UnsafePointer<UInt8> = CFDataGetBytePtr(data)
    
    let pixelPos = (point.y * Int(image.size.width) + point.x) * 4;
    
    return Color3b(imageData[pixelPos], imageData[pixelPos + 1], imageData[pixelPos + 2])
}
