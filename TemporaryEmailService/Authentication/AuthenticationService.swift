//
//  AuthenticationService.swift
//  TemporaryEmailService
//
//  Created by Gerson Arbigaus on 17/05/23.
//

import Foundation

public protocol AuthenticationServiceProtocol {
    func makeAuthentication() async throws -> Autentication
}

public struct Autentication: Decodable {
    let id: String
    let token: String
}

public final class AuthenticationService: AuthenticationServiceProtocol {
    private let service = APIService<Autentication, PayloadType>()

    public func makeAuthentication() async throws -> Autentication {
        do {
            let response = try await service.get(endpoint: "token")

            return response
        } catch(let error) {
            throw(error)
        }
    }

}
