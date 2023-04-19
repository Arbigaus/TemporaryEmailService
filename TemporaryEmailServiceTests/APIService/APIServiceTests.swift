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

    func test() async {
        let service: any APIServiceProtocol = APIService<FakeObject>(baseUrl: "https://someUrl.com/")

        do {
            let result = try await service.get(endpoint: "get")
            guard let result = result as? FakeObject else {
                XCTFail("Incorrect type of object")
                return
            }
            XCTAssertEqual(result.id, 1)
        }
        catch(let error) {
            XCTFail("Failed with error \(error.localizedDescription)")
        }

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

