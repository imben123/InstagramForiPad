//
//  SwiftyJSONURL.swift
//  InstagramData
//
//  Created by Ben Davis on 28/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import SwiftyJSON

//MARK: - URL
extension JSON {
    
    //Optional URL
    public var URLWithoutEscaping: URL? {
        get {
            switch self.type {
            case .string:
                if let rawString: String = self.string {
                    // We have to use `Foundation.URL` otherwise it conflicts with the variable name.
                    return Foundation.URL(string: rawString)
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
        set {
            self.object = newValue?.absoluteString ?? NSNull()
        }
    }
}
