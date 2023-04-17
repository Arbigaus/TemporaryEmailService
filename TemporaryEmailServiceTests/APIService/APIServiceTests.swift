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
