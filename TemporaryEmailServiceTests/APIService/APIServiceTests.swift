//
//  APIServiceTests.swift
//  TemporaryEmailServiceTests
//
//  Created by Gerson Arbigaus on 17/04/23.
//

import XCTest
@testable import TemporaryEmailService

final class APIServiceTests: XCTestCase {

    struct FakeObject: Codable {
        let id: Int
        let title: String
    }

    func test_getFromURL_succeddsWithDataAndResponse200() async {
        // When
        let expectedObject = FakeObject(id: 1, title: "Some title")
        let jsonData = try? JSONEncoder().encode(expectedObject)
        let response = HTTPURLResponse(url: URL(string: "https://someUrl.com/")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        // Given
        URLProtocolMock.startInterceptingRequests()
        URLProtocolMock.requestHandler = { request in
            return (response!, jsonData)
        }

        let apiService = APIService<FakeObject>(baseUrl: "https://someUrl.com/")

        // Then
        do {
            let fetchedPost = try await apiService.get(endpoint: "getTest")
            XCTAssertEqual(fetchedPost.id, expectedObject.id)
            XCTAssertEqual(fetchedPost.title, expectedObject.title)
        } catch {
            XCTFail("Ocorreu um erro inesperado: \(error)")
        }
        URLProtocolMock.stopInterceptingRequests()
    }
}

class URLProtocolMock: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolMock.self)
    }

    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolMock.self)
    }

    override func startLoading() {
        guard let handler = URLProtocolMock.requestHandler else {
            fatalError("Handler não definido.")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

