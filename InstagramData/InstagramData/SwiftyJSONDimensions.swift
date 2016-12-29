//
//  SwiftyJsonDimensions.swift
//  InstagramData
//
//  Created by Ben Davis on 28/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import SwiftyJSON

// MARK: - Size
extension JSON {
    
    // Optional date
    public var size: CGSize? {
        get {
            if let width = self["width"].number, let height = self["height"].number {
                return CGSize(width: width as Int, height: height as Int)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                let width = Int(newValue.width)
                let height = Int(newValue.height)
                self.dictionaryObject = ["width": width as NSNumber, "height": height as NSNumber]
            }
            self.object = NSNull()
        }
    }
    
    // Non-optional size
    public var sizeValue: CGSize {
        get {
            return self.size ?? CGSize.zero
        }
        set {
            self.size = newValue
        }
    }
}
