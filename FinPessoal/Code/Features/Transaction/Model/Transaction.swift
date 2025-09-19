//
//  Transaction.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation

struct Transaction: Identifiable, Codable, Hashable {
  let id: String
  let accountId: String
  let amount: Double
  let description: String
  let category: TransactionCategory
  let subcategory: TransactionSubcategory?
  let type: TransactionType
  let date: Date
  let isRecurring: Bool
  let userId: String
  let createdAt: Date
  let updatedAt: Date
  
  // Convenience initializer for backward compatibility
  init(id: String, accountId: String, amount: Double, description: String, category: TransactionCategory, type: TransactionType, date: Date, isRecurring: Bool, userId: String, createdAt: Date, updatedAt: Date, subcategory: TransactionSubcategory? = nil) {
    self.id = id
    self.accountId = accountId
    self.amount = amount
    self.description = description
    self.category = category
    self.subcategory = subcategory
    self.type = type
    self.date = date
    self.isRecurring = isRecurring
    self.userId = userId
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
  
  var formattedAmount: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    let prefix = type == .expense ? "-" : type == .income ? "+" : ""
    return prefix + (formatter.string(from: NSNumber(value: abs(amount))) ?? "R$ 0,00")
  }
}
