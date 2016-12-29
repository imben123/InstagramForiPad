//
//  UserFetcher.swift
//  InstagramData
//
//  Created by Ben Davis on 28/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

public class UserFetcher {
    
    public init() {}
    
    public func fetchUser(for username: String) -> User {
        let url = self.webURL(for: username)
        let webContent = self.fetchContent(of: url)
        let jsonData = self.findJSONData(in: webContent)
        return self.parse(jsonData)
    }
    
    private func webURL(for username: String) -> URL {
        return URL(string: "https://instagram.com/\(username)")!
    }
    
    private func fetchContent(of url: URL) -> String {
        let data = try! Data(contentsOf: url)
        return String(data: data, encoding: .utf8)!
    }
    
    private func findJSONData(in webContent: String) -> [String: Any] {
        let pattern = "window._sharedData = (.*);</script>"
        let match = webContent.matches(of: pattern, groupIndex: 1)[0]
        return self.jsonDeserialise(jsonString: match)
    }
    
    private func jsonDeserialise(jsonString: String) -> [String: Any] {
        let jsonStringAsData = jsonString.data(using: .utf8)!
        return try! JSONSerialization.jsonObject(with: jsonStringAsData, options: []) as! [String : Any]
    }
    
    private func parse(_ jsonData: [String: Any]) -> User {
        let entryData = jsonData["entry_data"] as! [ String: Any ]
        let profilePage = entryData["ProfilePage"] as! [ [ String: Any ] ]
        let displayedProfile = profilePage[0]
        let userJsonDictionary = displayedProfile["user"] as! [String : Any]
        return User(jsonDictionary: userJsonDictionary)
    }
    
}
