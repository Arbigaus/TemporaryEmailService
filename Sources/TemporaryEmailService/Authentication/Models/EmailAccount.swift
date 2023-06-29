//
//  EmailAccount.swift
//  TemporaryEmailService
//
//  Created by Gerson Arbigaus on 26/06/23.
//

import Foundation

public struct EmailAccount: Decodable {
    public let context: String?
    public let id: String?
    public let type: String?
    public let emailId: String?
    public let address: String?
    public let quota: Int?
    public let used: Int?
    public let isDisabled: Bool?
    public let isDeleted: Bool?
    public let createdAt: String?
    public let retentionAt: String?
    public let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case id = "@id"
        case type = "@type"
        case emailId = "id"
        case address
        case quota
        case used
        case isDisabled
        case isDeleted
        case createdAt
        case retentionAt
        case updatedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        context = try container.decodeIfPresent(String.self, forKey: .context)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        emailId = try container.decodeIfPresent(String.self, forKey: .emailId)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        quota = try container.decodeIfPresent(Int.self, forKey: .quota)
        used = try container.decodeIfPresent(Int.self, forKey: .used)
        isDisabled = try container.decodeIfPresent(Bool.self, forKey: .isDisabled)
        isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        retentionAt = try container.decodeIfPresent(String.self, forKey: .retentionAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}
