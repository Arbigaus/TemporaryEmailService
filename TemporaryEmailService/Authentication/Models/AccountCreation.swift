//
//  AccountCreation.swift
//  TemporaryEmailService
//
//  Created by Gerson Arbigaus on 26/06/23.
//

import Foundation

public struct AccountCreation: Encodable {
    let address: String
    let password: String
}
