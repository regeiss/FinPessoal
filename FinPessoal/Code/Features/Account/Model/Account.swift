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
  
  static func fromDictionary<T: Decodable>(_ dictionary: [String: Any]) throws -> T {
    let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
    return try JSONDecoder().decode(T.self, from: data)
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
    case .savings: return "brazilianrealsign.bank.building.fill"
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
