import Foundation

struct Transaction: Identifiable, Codable {
  let id: String
  let accountId: String
  let amount: Double
  let description: String
  let category: TransactionCategory
  let type: TransactionType
  let date: Date
  let isRecurring: Bool
  
  var formattedAmount: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    let prefix = type == .expense ? "-" : "+"
    return prefix + (formatter.string(from: NSNumber(value: abs(amount))) ?? "R$ 0,00")
  }
}

enum RecurringInterval: String, CaseIterable, Codable {
  case daily = "daily"
  case weekly = "weekly"
  case monthly = "monthly"
  case yearly = "yearly"
  
  var displayName: String {
    switch self {
    case .daily: return "Diário"
    case .weekly: return "Semanal"
    case .monthly: return "Mensal"
    case .yearly: return "Anual"
    }
  }
}
