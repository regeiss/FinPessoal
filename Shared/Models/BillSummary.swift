//
//  BillSummary.swift
//  FinPessoal
//
//  Created by Claude Code on 16/12/25.
//

import Foundation

/// Lightweight bill data for widget display
struct BillSummary: Codable, Identifiable {
  let id: String
  let name: String
  let amount: Double
  let dueDate: Date
  let status: String
  let categoryIcon: String

  // MARK: - Computed Properties

  var daysUntilDue: Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let due = calendar.startOfDay(for: dueDate)
    return calendar.dateComponents([.day], from: today, to: due).day ?? 0
  }

  var isOverdue: Bool {
    status == "overdue" || (status != "paid" && daysUntilDue < 0)
  }

  var isDueSoon: Bool {
    !isOverdue && daysUntilDue <= 3 && daysUntilDue >= 0
  }

  // MARK: - Accessibility

  var accessibilityLabel: String {
    let statusText: String
    if isOverdue {
      statusText = "vencida"
    } else if daysUntilDue == 0 {
      statusText = "vence hoje"
    } else if daysUntilDue == 1 {
      statusText = "vence amanhã"
    } else {
      statusText = "vence em \(daysUntilDue) dias"
    }
    return "\(name), \(formattedAmount), \(statusText)"
  }

  var formattedAmount: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }

  var formattedDueDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: dueDate)
  }

  var daysText: String {
    switch daysUntilDue {
    case ..<0: return "Vencido"
    case 0: return "Hoje"
    case 1: return "Amanhã"
    default: return "em \(daysUntilDue) dias"
    }
  }
}
