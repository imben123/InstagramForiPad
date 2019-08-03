//
//  UIImage+Crop.swift
//  Instagram
//
//  Created by Ben Davis on 03/08/2019.
//  Copyright © 2019 bendavisapps. All rights reserved.
//

import UIKit

extension UIImage {
    func cropToSquare() -> UIImage {
        let refWidth = CGFloat((self.cgImage!.width))
        let refHeight = CGFloat((self.cgImage!.height))
        if refWidth == refHeight { return self }

        let cropSize = min(refWidth, refHeight)

        let x = (refWidth - cropSize) * 0.5
        let y = (refHeight - cropSize) * 0.5

        let cropRect = CGRect(x: x, y: y, width: cropSize, height: cropSize)
        let imageRef = self.cgImage?.cropping(to: cropRect)
        let cropped = UIImage(cgImage: imageRef!, scale: 0.0, orientation: self.imageOrientation)

        return cropped
    }
}
