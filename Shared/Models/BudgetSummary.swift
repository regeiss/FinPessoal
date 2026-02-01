//
//  BudgetSummary.swift
//  FinPessoal
//
//  Created by Claude Code on 16/12/25.
//

import Foundation

/// Lightweight budget data for widget display
struct BudgetSummary: Codable, Identifiable {
  let id: String
  let name: String
  let category: String
  let categoryIcon: String
  let spent: Double
  let limit: Double

  // MARK: - Computed Properties

  var percentage: Double {
    guard limit > 0 else { return 0 }
    return (spent / limit) * 100
  }

  var isOverBudget: Bool {
    spent > limit
  }

  var remaining: Double {
    max(0, limit - spent)
  }

  // MARK: - Accessibility

  var accessibilityLabel: String {
    let status = isOverBudget ? "excedido" : "\(Int(percentage))% utilizado"
    return "\(name): \(status), \(formattedSpent) de \(formattedLimit)"
  }

  var formattedSpent: String {
    formatCurrency(spent)
  }

  var formattedLimit: String {
    formatCurrency(limit)
  }

  var formattedRemaining: String {
    formatCurrency(remaining)
  }

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
  }
}
