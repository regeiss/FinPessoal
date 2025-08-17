//
//  Account.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import SwiftUI

struct Account: Identifiable, Codable {
  let id: String
  let name: String
  let type: AccountType
  let balance: Double
  let currency: String
  let isActive: Bool
  let userId: String
  let createdAt: Date
  let updatedAt: Date
  
  // Convenience initializer for backward compatibility
  init(id: String, name: String, type: AccountType, balance: Double, currency: String, isActive: Bool, userId: String, createdAt: Date, updatedAt: Date) {
    self.id = id
    self.name = name
    self.type = type
    self.balance = balance
    self.currency = currency
    self.isActive = isActive
    self.userId = userId
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
  
  var formattedBalance: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: balance)) ?? "R$ 0,00"
  }
}
