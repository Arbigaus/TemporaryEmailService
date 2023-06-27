//
//  AuthenticationService.swift
//  TemporaryEmailService
//
//  Created by Gerson Arbigaus on 17/05/23.
//

import Foundation

public protocol AuthenticationServiceProtocol {
    func createAccount(email: String, password: String) async throws -> EmailAccount
    func makeAuthentication() async throws -> Autentication
}

public final class AuthenticationService: AuthenticationServiceProtocol {
    private var service: APIServiceProtocol = APIService()

    public func makeAuthentication() async throws -> Autentication {
        do {
            let response: Autentication = try await service.get(endpoint: "token")

            return response
        } catch(let error) {
            throw(error)
        }
    }

    public func createAccount(email: String, password: String) async throws -> EmailAccount {
        do {
            let accountToCreate = AccountCreation(address: email, password: password)
            let response: EmailAccount = try await service.post(endpoint: "accounts", payload: accountToCreate)

            return response
        } catch(let error) {
            throw(error)
        }
    }
}
