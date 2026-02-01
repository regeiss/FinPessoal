//
//  AccountSummary.swift
//  FinPessoal
//
//  Created by Claude Code on 16/12/25.
//

import Foundation

/// Lightweight account data for widget display
struct AccountSummary: Codable, Identifiable {
  let id: String
  let name: String
  let type: String
  let balance: Double
  let currency: String

  // MARK: - Accessibility

  var accessibilityLabel: String {
    "\(name), saldo: \(formattedBalance)"
  }

  var formattedBalance: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: balance)) ?? "R$ 0,00"
  }
}
