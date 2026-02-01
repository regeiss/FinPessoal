//
//  TransactionSummary.swift
//  FinPessoal
//
//  Created by Claude Code on 16/12/25.
//

import Foundation

/// Lightweight transaction data for widget display
struct TransactionSummary: Codable, Identifiable {
  let id: String
  let description: String
  let amount: Double
  let date: Date
  let type: String
  let category: String
  let categoryIcon: String

  // MARK: - Computed Properties

  var isExpense: Bool {
    type == "expense"
  }

  var isIncome: Bool {
    type == "income"
  }

  // MARK: - Accessibility

  var accessibilityLabel: String {
    let typeText = isExpense ? "despesa" : isIncome ? "receita" : "transferência"
    return "\(description), \(typeText), \(formattedAmount), \(formattedDate)"
  }

  var formattedAmount: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    let prefix = isExpense ? "-" : isIncome ? "+" : ""
    return prefix + (formatter.string(from: NSNumber(value: abs(amount))) ?? "R$ 0,00")
  }

  var formattedDate: String {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let transactionDay = calendar.startOfDay(for: date)

    if transactionDay == today {
      return "Hoje"
    }

    if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
       transactionDay == yesterday {
      return "Ontem"
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: date)
  }

  var relativeDate: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.locale = Locale(identifier: "pt_BR")
    formatter.unitsStyle = .short
    return formatter.localizedString(for: date, relativeTo: Date())
  }
}
