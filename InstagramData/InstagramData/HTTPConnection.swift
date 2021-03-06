//
//  HTTPConnection.swift
//  InstagramData
//
//  Created by Ben Davis on 30/12/2016.
//  Copyright © 2016 bendavisapps. All rights reserved.
//

import Foundation

protocol HTTPConnectionDelegate: class {
    func httpConnection(_ sender: HTTPConnection, receivedCookie cookie: HTTPCookie)
}

class HTTPConnection {
    
    weak var delegate: HTTPConnectionDelegate? = nil
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func makeSynchronousRequest(_ request: URLRequest) -> APIResponse? {
        var result: APIResponse? = nil
        let semaphore = DispatchSemaphore(value: 0)
        let dataTask = session.dataTask(with: request) { (responseBody: Data?, response: URLResponse?, error: Error?) in
            
            guard error == nil else {
                print(error!)
                semaphore.signal()
                return
            }
            
            let responseCode = (response as! HTTPURLResponse).statusCode
            let responseBodyDecoded = self.decodeResponseBody(responseBody)
            result = APIResponse(responseCode: responseCode,
                                 responseBodyData: responseBody,
                                 responseBody: responseBodyDecoded,
                                 urlResponse: response)
            semaphore.signal()
        }
        dataTask.resume()
        _ = semaphore.wait(timeout: .now() + 30)
        
        self.informDelegateOfResponseCookies(response: result?.urlResponse)
        
        return result
    }
    
    private func informDelegateOfResponseCookies(response: URLResponse?) {
        if let response = response as? HTTPURLResponse,
            let responseHeaders = response.allHeaderFields as? [String: String] {
            
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: responseHeaders, for: response.url!)
            for cookie in cookies {
                delegate?.httpConnection(self, receivedCookie: cookie)
            }
        }
    }
    
    private func decodeResponseBody(_ responseBody: Data?) -> [String: Any]? {
        
        guard responseBody != nil else {
            return nil
        }
        
        let result = try? JSONSerialization.jsonObject(with: responseBody!, options: [])
        
        return result as! [String : Any]?
    }
    
}
