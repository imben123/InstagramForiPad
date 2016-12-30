//
//  TestCase.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import XCTest

extension XCTestCase: ResourceLoader {}

protocol ResourceLoader: class {
    static func getObject(with fileName: String) -> [String:Any]
}

extension ResourceLoader {
    static func getObject(with fileName: String) -> [String:Any] {
        let bundle = Bundle(for: self)
        let filePath = bundle.bundlePath + "/" + fileName
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
    }
}
