//
//  APIServiceTests.swift
//  TemporaryEmailServiceTests
//
//  Created by Gerson Arbigaus on 17/04/23.
//

import XCTest
@testable import TemporaryEmailService

final class APIServiceTests: XCTestCase {

    struct FakeObject: Codable, Equatable {
        let id: Int
        let title: String
    }

    override class func setUp() {
        super.setUp()
        URLProtocolMock.startInterceptingRequests()
    }

    override class func tearDown() {
        URLProtocolMock.stopInterceptingRequests()
        super.tearDown()
    }

    func test_getFromURL_succeddsWithDataAndResponse200() async {
        // When
        let expectedObject = fakeObject()
        let jsonData = fakeObjectData()
        let response = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        let sut = makeSUT()

        // Given
        URLProtocolMock.requestHandler = { request in
            return (response!, jsonData)
        }

        // Then
        do {
            let fetchedPost = try await sut.get(endpoint: "getTest")
            XCTAssertEqual(fetchedPost, expectedObject)
        } catch {
            XCTFail("Ocorreu um erro inesperado: \(error)")
        }

    }

    func test_getFromURL_failsOnRequestWithIncorrectData() async {
        // When
        let jsonData = try? JSONEncoder().encode(Data())
        let response = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        let sut = makeSUT()

        // Given
        URLProtocolMock.requestHandler = { request in
            return (response!, Data())
        }

        // Then
        do {
            let _ = try await sut.get(endpoint: "failTest")
            XCTFail("Should occour some error")
        } catch (let error as NSError) {
            XCTAssertEqual(error.code, 4864)
        }
    }

    func test_getFromURL_deliversErrorOnNon200HttpResponse() async {
        // When
        let samples = [199, 201, 300, 400, 500]

        for sample in samples {
            let response = HTTPURLResponse(url: anyURL(), statusCode: sample, httpVersion: nil, headerFields: nil)
            let sut = makeSUT()

            // Given
            URLProtocolMock.requestHandler = { request in
                return (response!, nil)
            }

            // Then
            do {
                let _ = try await sut.get(endpoint: "notFoundTest")
                XCTFail("Deveria ocorrer um erro")
            } catch (let error as NSError) {
                XCTAssertEqual(error.code, sample)
            }
        }

    }

    private func makeSUT() -> APIService<FakeObject> {
        APIService<FakeObject>(baseUrl: baseURL())
    }

    private func baseURL() -> String {
        "https://someUrl.com/"
    }

    private func anyURL() -> URL {
        URL(string: baseURL())!
    }

    private func fakeObject() -> FakeObject {
        FakeObject(id: 1, title: "Some title")
    }

    private func fakeObjectData() -> Data? {
        return try? JSONEncoder().encode(fakeObject())
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

