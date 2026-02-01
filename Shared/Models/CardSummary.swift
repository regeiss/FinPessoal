//
//  CardSummary.swift
//  FinPessoal
//
//  Created by Claude Code on 16/12/25.
//

import Foundation

/// Lightweight credit card data for widget display
struct CardSummary: Codable, Identifiable {
  let id: String
  let name: String
  let currentBalance: Double
  let creditLimit: Double
  let dueDate: Date?
  let brand: String

  // MARK: - Computed Properties

  var availableCredit: Double {
    max(0, creditLimit - currentBalance)
  }

  var utilizationPercentage: Double {
    guard creditLimit > 0 else { return 0 }
    return (currentBalance / creditLimit) * 100
  }

  var daysUntilDue: Int? {
    guard let dueDate = dueDate else { return nil }
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let due = calendar.startOfDay(for: dueDate)
    return calendar.dateComponents([.day], from: today, to: due).day
  }

  // MARK: - Accessibility

  var accessibilityLabel: String {
    let utilizationText = "\(Int(utilizationPercentage))% utilizado"
    var label = "\(name), \(utilizationText), saldo: \(formattedBalance)"
    if let days = daysUntilDue {
      if days == 0 {
        label += ", vence hoje"
      } else if days == 1 {
        label += ", vence amanhã"
      } else if days > 0 {
        label += ", vence em \(days) dias"
      }
    }
    return label
  }

  var formattedBalance: String {
    formatCurrency(currentBalance)
  }

  var formattedLimit: String {
    formatCurrency(creditLimit)
  }

  var formattedAvailableCredit: String {
    formatCurrency(availableCredit)
  }

  var formattedDueDate: String? {
    guard let dueDate = dueDate else { return nil }
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: dueDate)
  }

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
  }
}
