//
//  UserQueryHashFinder.swift
//  InstagramData
//
//  Created by Ben Davis on 11/08/2019.
//  Copyright © 2019 bendavisapps. All rights reserved.
//

import Foundation

struct UserQueryHashFinder {
    private let profilePageContainerJSName = "ProfilePageContainer\\.js"
    let connection: APIConnection

    enum Failure: Error {
        case requestFailed(failureResponse: APIResponse)
        case parseFailure(reason: String)
    }

    func fetchUserQueryHash(for username: String) -> Result<String, Failure> {
        let result = connection.makeRequest(path: "/\(username)", payload: nil, requiresAuthentication: true)
        guard result.succeeded else { return .failure(Failure.requestFailed(failureResponse: result)) }

        do {
            let queryHash = try fetchUserQueryHash(fromPageContent: result.responseBodyData)
            return .success(queryHash)
        } catch {
            return .failure(error as! Failure)
        }
    }

    private func fetchUserQueryHash(fromPageContent pageContent: Data?) throws -> String {
        guard let pageContent = pageContent else {
            throw Failure.parseFailure(reason: "User profile page loaded no content")
        }

        guard let pageContentString = String(data: pageContent, encoding: .utf8) else {
            throw Failure.parseFailure(reason: "User profile page content was not a UTF8 string")
        }

        let pattern = #""(/[^"]*\#(profilePageContainerJSName)[^"]*\.js)""#
        guard let profilePageContainerJSPath = pageContentString.matches(of: pattern, groupIndex: 1).first else {
            throw Failure.parseFailure(
                reason: "Could not find '\(profilePageContainerJSName)' path in user profile page HTML body"
            )
        }

        let result = connection.makeRequest(path: profilePageContainerJSPath, 
                                            payload: nil, 
                                            requiresAuthentication: false)
        guard result.succeeded else { throw Failure.requestFailed(failureResponse: result) }
        return try fetchUserQueryHash(fromProfilePageContainerJSBody: result.responseBodyData)
    }

    private func fetchUserQueryHash(fromProfilePageContainerJSBody consumerJSBody: Data?) throws -> String {
        guard let consumerJSBody = consumerJSBody else {
            throw Failure.parseFailure(reason: "\(profilePageContainerJSName) loaded no content")
        }

        guard let jsContentString = String(data: consumerJSBody, encoding: .utf8) else {
            throw Failure.parseFailure(reason: "\(profilePageContainerJSName) content was not a UTF8 string")
        }
        
        guard let queryHash = findQueryHash(in: jsContentString) else {
            throw Failure.parseFailure(reason: "Could not find user feed query hash in \(profilePageContainerJSName)")
        }

        return queryHash
    }
    
    private func findQueryHash(in jsContentString: String) -> String? {
        let patterns = [
            "profilePosts.*queryId:\"([a-f0-9]{32})\"",
        ]
        for pattern in patterns {
            if let result = jsContentString.matches(of: pattern, groupIndex: 1).first {
                return result
            }        
        }
        return nil
    }
}
