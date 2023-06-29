//
//  APIService.swift
//  TemporaryEmailService
//
//  Created by Gerson Arbigaus on 17/04/23.
//

import Foundation

protocol APIServiceProtocol {
    func get<ResponseType: Decodable>(endpoint: String) async throws -> ResponseType
    func post<ResponseType: Decodable, PayloadType: Encodable>(endpoint: String, payload: PayloadType) async throws -> ResponseType
    func put<ResponseType: Decodable, PayloadType: Encodable>(endpoint: String, payload: PayloadType) async throws -> ResponseType
}

final class APIService: APIServiceProtocol {
    // MARK: - Variables

    let baseURL: String

    // MARK: - Intializers

    init(baseUrl: String = "https://api.mail.gw/") {
        self.baseURL = baseUrl
    }

    private enum Method: String {
        case get    = "GET"
        case put    = "PUT"
        case post   = "POST"
        case delete = "DELETE"
    }

    // MARK: - Methods

    private func createURLRequest(_ endpoint: String, method: Method, body: Data? = nil) -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            fatalError("URL inválida.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        return request
    }

    private func handleRequest<ResponseType: Decodable>(with data: Data, and response: URLResponse) throws -> ResponseType {
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw NSError(domain: "Response error", code: 2)
        }

        guard statusCode >= 200 && statusCode <= 204 else {
            throw NSError(domain: "Response error", code: statusCode)
        }

        let decodedData = try JSONDecoder().decode(ResponseType.self, from: data)
        return decodedData
    }

    func get<ResponseType: Decodable>(endpoint: String) async throws -> ResponseType {

        do {
            let request = createURLRequest(endpoint, method: .get)
            let (data, response) = try await URLSession.shared.data(for: request)

            return try handleRequest(with: data, and: response)

        } catch(let error) {
            throw NSError(domain: error.localizedDescription, code: error._code)
        }
    }

    func post<ResponseType: Decodable, PayloadType: Encodable>(endpoint: String, payload: PayloadType) async throws -> ResponseType {
        do {
            let body = try JSONEncoder().encode(payload)
            let request = createURLRequest(endpoint, method: .post, body: body)
            let (data, response) = try await URLSession.shared.data(for: request)

            return try handleRequest(with: data, and: response)

        } catch (let error) {
            throw NSError(domain: error.localizedDescription, code: error._code)
        }
    }

    func put<ResponseType: Decodable, PayloadType: Encodable>(endpoint: String, payload: PayloadType) async throws -> ResponseType {
        do {
            let body = try JSONEncoder().encode(payload)
            let request = createURLRequest(endpoint, method: .put, body: body)
            let (data, response) = try await URLSession.shared.data(for: request)

            return try handleRequest(with: data, and: response)
        } catch (let error) {
            throw NSError(domain: error.localizedDescription, code: error._code)
        }
    }
}
