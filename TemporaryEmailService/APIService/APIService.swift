//
//  APIService.swift
//  TemporaryEmailService
//
//  Created by Gerson Arbigaus on 17/04/23.
//

import Foundation

protocol APIServiceProtocol {
    associatedtype ResponseType: Decodable
    associatedtype PayloadType: Encodable

    func get(endpoint: String) async throws -> ResponseType
    func post(endpoint: String, payload: PayloadType) async throws -> ResponseType
}

final class APIService<ResponseType: Decodable, PayloadType: Encodable>: APIServiceProtocol {
    // MARK: - Variables

    let baseUrl: String

    // MARK: - Intializers

    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }

    // MARK: - Methods

    func get(endpoint: String) async throws -> ResponseType {

        do {
            guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
                throw NSError(domain: "Invalid URL", code: 0)
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                throw NSError(domain: "Response error", code: 2)
            }

            guard statusCode == 200 else {
                throw NSError(domain: "Response error", code: statusCode)
            }

            let decodedData = try JSONDecoder().decode(ResponseType.self, from: data)
            return decodedData
        } catch(let error) {
            throw NSError(domain: error.localizedDescription, code: error._code)
        }
    }

    func post(endpoint: String, payload: PayloadType) async throws -> ResponseType {
        do {
            let data = Data()
            let decodedData = try JSONDecoder().decode(ResponseType.self, from: data)
            return decodedData
        } catch (let error) {
            throw NSError(domain: error.localizedDescription, code: error._code)
        }
    }
}
