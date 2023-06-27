//
//  AuthenticationServiceTests.swift
//  TemporaryEmailServiceTests
//
//  Created by Gerson Arbigaus on 17/05/23.
//

import XCTest
@testable import TemporaryEmailService

final class AuthenticationServiceTests: XCTestCase {
    var sut: AuthenticationService!

    private struct FakeAuthentication: Encodable {
        let id: String
        let token: String
    }

    private struct FakeEmailAccount: Encodable {
        let id: String
        let type: String

        enum CodingKeys: String, CodingKey {
            case id = "@id"
            case type = "@type"
        }
    }

    override func setUp() {
        super.setUp()
        ModelsMockURLProtocol.startInterceptingRequests()
        sut = AuthenticationService()
    }

    override func tearDown() {
        sut = nil
        ModelsMockURLProtocol.stopInterceptingRequests()
        super.tearDown()
    }

    func testMakeAuthentication_WhenSuccessful_ReturnsAutentication() async throws {
        // Given
        let expectedResponse = FakeAuthentication(id: "testId", token: "testToken")
        let jsonData = try JSONEncoder().encode(expectedResponse)
        ModelsMockURLProtocol.stubResponseData = jsonData

        // When
        let result = try await sut.makeAuthentication()

        // Then
        XCTAssertEqual(result.id, expectedResponse.id)
        XCTAssertEqual(result.token, expectedResponse.token)
    }

    func testMakeAuthentication_WhenFailed_ThrowsError() async {
        // Given
        let expectedError = NSError(domain: "test", code: 1, userInfo: nil)
        ModelsMockURLProtocol.stubError = expectedError

        do {
            // When
            let _ = try await sut.makeAuthentication()
            XCTFail("Expected error to be thrown")
        } catch(let error) {
            // Then
            XCTAssertNotNil(error)
        }
    }

    func testCreateAccount_WhenSuccessful_ReturnsEmailAccount() async throws {
        // Given
        do {
            let expectedResponse = FakeEmailAccount(id: "SomeID", type: "SomeType")
            let jsonData = try JSONEncoder().encode(expectedResponse)
            ModelsMockURLProtocol.stubResponseData = jsonData

            // When
            let result = try await sut.createAccount(email: "teste@teste.com",
                                                     password: "passwd")

            // Then
            XCTAssertEqual(result.id, expectedResponse.id)
            XCTAssertEqual(result.type, expectedResponse.type)
        } catch(let error) {
            XCTFail("Expected success, but `\(error.localizedDescription)` error occour")
        }
    }

    func testCreateAccount_WhenFailed_ThrowsError() async throws {
        // Given
        let expectedError = NSError(domain: "test", code: 1, userInfo: nil)
        ModelsMockURLProtocol.stubError = expectedError

        do {
            // When
            let _ = try await sut.createAccount(email: "teste@teste.com",
                                                password: "passwd")
            XCTFail("Expected error to be thrown")
        } catch(let error) {
            // Then
            XCTAssertNotNil(error)
        }
    }
}
