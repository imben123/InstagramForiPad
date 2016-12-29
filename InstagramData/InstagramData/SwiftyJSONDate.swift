//
//  SwiftyJSONDate.swift
//  InstagramData
//
//  Created by Ben Davis on 28/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import SwiftyJSON

fileprivate extension Int {
    
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }
    
}

fileprivate extension Date {
    
    var number: NSNumber {
        return Int(self.timeIntervalSince1970) as NSNumber
    }
    
}

// MARK: - Date
extension JSON {
    
    // Optional date
    public var date: Date? {
        get {
            if let number = self.int {
                return number.date
            }
            return nil
        }
        set {
            self.object = (newValue != nil) ? newValue!.number as AnyObject : NSNull() as AnyObject
        }
    }
    
    // Non-optional date
    public var dateValue: Date {
        get {
            return self.intValue.date
        }
        set {
            self.object = newValue.number
        }
    }
}
