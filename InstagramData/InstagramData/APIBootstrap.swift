//
//  APIBootstrap.swift
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
        let queryHash: String
    }

    func fetchQueryHash() -> Result<Success, Failure> {
        let result = connection.makeRequest(path: "/", payload: nil, requiresAuthentication: false)
        guard result.succeeded else { return .failure(Failure.requestFailed(failureResponse: result)) }

        let queryHash: String
        do {
            queryHash = try fetchQueryHash(fromPageContent: result.responseBodyData)
        } catch {
            return .failure(error as! Failure)
        }
        return .success(.init(queryHash: queryHash))
    }

    private func fetchQueryHash(fromPageContent pageContent: Data?) throws -> String {
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

    private func fetchQueryHash(fromConsumerJSBody consumerJSBody: Data?) throws -> String {
        guard let consumerJSBody = consumerJSBody else {
            throw Failure.parseFailure(reason: "\(consumerJSName) loaded no content")
        }

        guard let jsContentString = String(data: consumerJSBody, encoding: .utf8) else {
            throw Failure.parseFailure(reason: "\(consumerJSName) content was not a UTF8 string")
        }

        let pattern = "E=\"([0-9a-f]{32})\""
        guard let queryHash = jsContentString.matches(of: pattern, groupIndex: 1).first else {
            throw Failure.parseFailure(reason: "Could not find query hash in \(consumerJSName)")
        }

        return queryHash
    }
}
