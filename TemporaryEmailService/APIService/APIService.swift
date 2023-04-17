//
//  APIService.swift
//  TemporaryEmailService
//
//  Created by Gerson Arbigaus on 17/04/23.
//

import Foundation

protocol APIServiceProtocol {
    associatedtype T: Codable

    func get(endpoint: String) async throws -> T
}

final class APIService<T: Codable>: APIServiceProtocol {
    let baseUrl: String

    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }

    func get(endpoint: String) async throws -> T {

        do {
            guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
                throw NSError(domain: "Some error", code: 0)
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw NSError(domain: "Some error", code: 0)
            }

            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            throw NSError(domain: "Some error", code: 0)
        }
    }
}
