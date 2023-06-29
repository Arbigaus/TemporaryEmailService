//
//  ModelsMockURLProtocol.swift
//  TemporaryEmailServiceTests
//
//  Created by Gerson Arbigaus on 13/06/23.
//

import Foundation

class ModelsMockURLProtocol: URLProtocol {
    // Response data to return for the request
    static var stubResponseData: Data?
    // Error to return for the request
    static var stubError: Error?

    static func startInterceptingRequests() {
        URLProtocol.registerClass(ModelsMockURLProtocol.self)
    }

    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(ModelsMockURLProtocol.self)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        // Handle all types of requests
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Here you return the same request
        return request
    }

    override func startLoading() {
        // If there's an error, return it via the client
        if let error = ModelsMockURLProtocol.stubError {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else {
            // Return the response data via the client
            let response = HTTPURLResponse(url: self.request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: ModelsMockURLProtocol.stubResponseData ?? Data())
        }

        self.client?.urlProtocolDidFinishLoading(self)

    }

    override func stopLoading() {
        // This is called if the request gets canceled or completed
        ModelsMockURLProtocol.stubResponseData = nil
        ModelsMockURLProtocol.stubError = nil
    }
}
