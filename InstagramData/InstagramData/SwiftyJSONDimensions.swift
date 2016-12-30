//
//  SwiftyJsonDimensions.swift
//  InstagramData
//
//  Created by Ben Davis on 28/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import SwiftyJSON

// MARK: - Adds CGRect parsing support for SwiftyJSON
extension JSON {
    
    // Optional date
    public var size: CGSize? {
        get {
            if let width = self["width"].int, let height = self["height"].int {
                return CGSize(width: width, height: height)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                let width = Int(newValue.width)
                let height = Int(newValue.height)
                self.dictionaryObject = ["width": width as NSNumber, "height": height as NSNumber]
            } else {
                self.object = NSNull()
            }
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
