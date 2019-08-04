//
//  QueryHashFinder.swift
//  InstagramData
//
//  Created by Ben Davis on 03/08/2019.
//  Copyright © 2019 bendavisapps. All rights reserved.
//

import Foundation

struct QueryHashFinder {
    private let consumerJSName = "Consumer\\.js"
    let connection: APIConnection

    enum Failure: Error {
        case requestFailed(failureResponse: APIResponse)
        case parseFailure(reason: String)
    }

    struct Success {
        let feedQueryHash: String
        let commentsQueryHash: String
    }

    func fetchQueryHash() -> Result<Success, Failure> {
        let result = connection.makeRequest(path: "/", payload: nil, requiresAuthentication: false)
        guard result.succeeded else { return .failure(Failure.requestFailed(failureResponse: result)) }

        let success: Success
        do {
            success = try fetchQueryHash(fromPageContent: result.responseBodyData)
        } catch {
            return .failure(error as! Failure)
        }
        return .success(success)
    }

    private func fetchQueryHash(fromPageContent pageContent: Data?) throws -> Success {
        guard let pageContent = pageContent else {
            throw Failure.parseFailure(reason: "Instagram home page loaded no content")
        }

        guard let pageContentString = String(data: pageContent, encoding: .utf8) else {
            throw Failure.parseFailure(reason: "Instagram home page content was not a UTF8 string")
        }

        let pattern = #""(/[^"]*\#(consumerJSName)[^"]*\.js)""#
        guard let consumerJSPath = pageContentString.matches(of: pattern, groupIndex: 1).first else {
            throw Failure.parseFailure(
                reason: "Could not find '\(consumerJSName)' path in Instagram HTML body"
            )
        }

        let result = connection.makeRequest(path: consumerJSPath, payload: nil, requiresAuthentication: false)
        guard result.succeeded else { throw Failure.requestFailed(failureResponse: result) }
        return try fetchQueryHash(fromConsumerJSBody: result.responseBodyData)
    }

    private func fetchQueryHash(fromConsumerJSBody consumerJSBody: Data?) throws -> Success {
        guard let consumerJSBody = consumerJSBody else {
            throw Failure.parseFailure(reason: "\(consumerJSName) loaded no content")
        }

        guard let jsContentString = String(data: consumerJSBody, encoding: .utf8) else {
            throw Failure.parseFailure(reason: "\(consumerJSName) content was not a UTF8 string")
        }

        let feedPattern = "E=\"([0-9a-f]{32})\""
        guard let feedQueryHash = jsContentString.matches(of: feedPattern, groupIndex: 1).first else {
            throw Failure.parseFailure(reason: "Could not find feed query hash in \(consumerJSName)")
        }

        let commentsPattern = #"parentByPostId[^"]*queryId:"([0-9a-zA-Z]{32})""#
        guard let commentsQueryHash = jsContentString.matches(of: commentsPattern, groupIndex: 1).first else {
            throw Failure.parseFailure(reason: "Could not find comments query hash in \(consumerJSName)")
        }

        return Success(feedQueryHash: feedQueryHash, commentsQueryHash: commentsQueryHash)
    }
}
