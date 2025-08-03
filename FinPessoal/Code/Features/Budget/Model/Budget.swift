import Foundation

struct Budget: Identifiable, Codable {
  let id: String
  let name: String
  let category: TransactionCategory
  let budgetAmount: Double
  let spent: Double
  let period: BudgetPeriod
  let startDate: Date
  let endDate: Date
  let isActive: Bool
  let alertThreshold: Double // Porcentagem para alerta (0.8 = 80%)
  
  var remaining: Double {
    return budgetAmount - spent
  }
  
  var percentageUsed: Double {
    guard budgetAmount > 0 else { return 0 }
    return min(spent / budgetAmount, 1.0)
  }
  
  var isOverBudget: Bool {
    return spent > budgetAmount
  }
  
  var shouldAlert: Bool {
    return percentageUsed >= alertThreshold
  }
  
  var formattedBudgetAmount: String {
    return formatCurrency(budgetAmount)
  }
  
  var formattedSpent: String {
    return formatCurrency(spent)
  }
  
  var formattedRemaining: String {
    return formatCurrency(remaining)
  }
  
  private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }
}

enum BudgetPeriod: String, CaseIterable, Codable {
  case weekly = "Semanal"
  case monthly = "Mensal"
  case quarterly = "Trimestral"
  case yearly = "Anual"
  
  var icon: String {
    switch self {
    case .weekly: return "calendar.badge.clock"
    case .monthly: return "calendar"
    case .quarterly: return "calendar.badge.plus"
    case .yearly: return "calendar.circle"
    }
  }
  
  func nextPeriodStart(from date: Date) -> Date {
    let calendar = Calendar.current
    switch self {
    case .weekly:
      return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
    case .monthly:
      return calendar.date(byAdding: .month, value: 1, to: date) ?? date
    case .quarterly:
      return calendar.date(byAdding: .month, value: 3, to: date) ?? date
    case .yearly:
      return calendar.date(byAdding: .year, value: 1, to: date) ?? date
    }
  }
}
