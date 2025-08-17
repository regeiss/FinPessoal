//
//  Budget.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation

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
  let userId: String?
  let createdAt: Date?
  let updatedAt: Date?
  
  // Convenience initializer for backward compatibility
  init(id: String, name: String, category: TransactionCategory, budgetAmount: Double, spent: Double, period: BudgetPeriod, startDate: Date, endDate: Date, isActive: Bool, alertThreshold: Double, userId: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
    self.id = id
    self.name = name
    self.category = category
    self.budgetAmount = budgetAmount
    self.spent = spent
    self.period = period
    self.startDate = startDate
    self.endDate = endDate
    self.isActive = isActive
    self.alertThreshold = alertThreshold
    self.userId = userId
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
  
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
