//
//  Transaction.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import SwiftUI

struct Transaction: Codable, Identifiable {
  let id: String
  let accountId: String
  let amount: Double
  let description: String
  let category: String
  let type: TransactionType
  let date: Date
  let isRecurring: Bool
  
  enum TransactionType: String, Codable, CaseIterable {
    case income = "income"
    case expense = "expense"
    case transfer = "transfer"
    
    var localizedName: String {
      switch self {
      case .income:
        return NSLocalizedString("transaction.type.income", comment: "Income")
      case .expense:
        return NSLocalizedString("transaction.type.expense", comment: "Expense")
      case .transfer:
        return NSLocalizedString("transaction.type.transfer", comment: "Transfer")
      }
    }
    
    var color: Color {
      switch self {
      case .income:
        return .green
      case .expense:
        return .red
      case .transfer:
        return .blue
      }
    }
  }
}
