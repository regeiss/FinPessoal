import Foundation
import SwiftUI

struct Account: Identifiable, Codable {
  let id: String
  let name: String
  let type: AccountType
  let balance: Double
  let currency: String
  let isActive: Bool
  
  var formattedBalance: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: balance)) ?? "R$ 0,00"
  }
}

enum AccountType: String, CaseIterable, Codable {
  case checking = "Conta Corrente"
  case savings = "Poupança"
  case credit = "Cartão de Crédito"
  case investment = "Investimentos"
  
  var icon: String {
    switch self {
    case .checking: return "creditcard.fill"
    case .savings: return "piggybank.fill"
    case .credit: return "creditcard"
    case .investment: return "chart.line.uptrend.xyaxis"
    }
  }
  
  var color: Color {
    switch self {
    case .checking: return .blue
    case .savings: return .green
    case .credit: return .orange
    case .investment: return .purple
    }
  }
}
