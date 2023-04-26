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

    private enum FakeResult {
        case success([FakeObject])
        case failure(NSError)
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
        let response = makeResponse()
        let sut = makeSUT()

        // Given
        URLProtocolMock.requestHandler = { request in
            return (response!, jsonData)
        }

        // Then
        let result = await makeSUTGet(with: "getTest")

        switch result {
        case .success(let fakeObjects):
            XCTAssertTrue(fakeObjects.contains(expectedObject))
        case .failure(let error):
            XCTFail("Ocorreu um erro inesperado: \(error.localizedDescription)")
        }
    }

    func test_getFromURL_failsOnRequestWithIncorrectData() async {
        // When
        let response = makeResponse()
        let sut = makeSUT()

        // Given
        URLProtocolMock.requestHandler = { request in
            return (response!, Data())
        }

        // Then
        let result = await makeSUTGet(with: "incorrectData")

        switch result {
        case .success:
            XCTFail("Should occour error, got success instead")
        case .failure(let error):
            XCTAssertEqual(error.code, 4864)
        }
    }

    func test_getFromURL_deliversErrorOnNon200HttpResponse() async {
        // When
        let samples = [199, 201, 300, 400, 500]
        let sut = makeSUT()

        for sample in samples {
            let response = makeResponse(sample)

            // Given
            URLProtocolMock.requestHandler = { request in
                return (response!, nil)
            }

            // Then
            let result = await makeSUTGet(with: "non200Errors")

            switch result {
            case .success:
                XCTFail("Should occour error, occour success instead")
            case .failure(let error):
                XCTAssertEqual(error.code, sample)
            }
        }

    }

    private func makeSUTGet(with endpoint: String) async -> FakeResult {
        let sut = makeSUT()

        do {
            let result = try await sut.get(endpoint: endpoint)
            return .success([result])
        } catch (let error as NSError) {
            return .failure(error)
        }
    }

    private func makeResponse(_ code: Int = 200) -> HTTPURLResponse? {
        HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)
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

