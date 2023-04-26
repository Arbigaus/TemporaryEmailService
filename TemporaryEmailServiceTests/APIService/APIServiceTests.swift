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

        // Given
        URLProtocolMock.requestHandler = { request in
            return (response!, jsonData)
        }

        // Then
        let result = await makeGetFromSUT(with: "getTest")

        switch result {
        case .success(let fakeObjects):
            XCTAssertTrue(fakeObjects.contains(expectedObject))
        case .failure(let error):
            XCTFail("Ocorreu um erro inesperado: \(error.localizedDescription)")
        }
    }

    func test_getFromURL_failsOnRequestWithIncorrectData() async {
        let response = makeResponse()
        do {
            let _ = try JSONDecoder().decode(FakeObject.self, from: Data())
            XCTFail("Should do error")
        }
        catch(let expectedError as NSError) {
            await expect(wit: response, endpoint: "incorrectData", expectedResult: .failure(expectedError))
        }
    }

    func test_getFromURL_deliversErrorOnNon200HttpResponse() async {
        let samples = [199, 201, 300, 400, 500]

        for sample in samples {
            let response = makeResponse(sample)
            let expectedError: FakeResult = .failure(NSError(domain: "Response error", code: sample))

            await expect(wit: response, endpoint: "non200Errors", expectedResult: expectedError)
        }
    }

    private func expect(wit response: HTTPURLResponse?, data: Data? = nil, endpoint: String, expectedResult: FakeResult, file: StaticString = #filePath, line: UInt = #line) async {
        URLProtocolMock.requestHandler = { request in
            return (response!, data)
        }

        let receivedResult = await makeGetFromSUT(with: endpoint)

        switch (receivedResult, expectedResult) {

        case let (.success(receivedItems), .success(expectedItems)):
            XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

        case let (.failure(receivedError), .failure(expectedError)):
            XCTAssertEqual(receivedError.code, expectedError.code, file: file, line: line)

        default:
            XCTFail("Exptected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)

        }
    }

    private func makeGetFromSUT(with endpoint: String) async -> FakeResult {
        do {
            let result = try await makeSUT().get(endpoint: endpoint)
            return .success([result])
        } catch (let error as NSError) {
            return .failure(error)
        }
    }

    private func makeResponse(_ code: Int = 200) -> HTTPURLResponse? {
        HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> APIService<FakeObject> {
        let sut = APIService<FakeObject>(baseUrl: baseURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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
            fatalError("Undefined handler")
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

