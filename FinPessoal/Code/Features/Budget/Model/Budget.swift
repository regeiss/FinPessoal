//
//  Budget.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation

struct Budget: Codable, Identifiable {
  let id: String
  let userId: String
  let name: String
  let category: String
  let budgetAmount: Double
  let spent: Double
  let period: BudgetPeriod
  let startDate: Date
  let endDate: Date
  let isActive: Bool
  let alertThreshold: Double
  let createdAt: Date
  let updatedAt: Date
  
  var percentageUsed: Double {
    guard budgetAmount > 0 else { return 0 }
    return (spent / budgetAmount) * 100
  }
  
  var remainingAmount: Double {
    return budgetAmount - spent
  }
  
  var isOverBudget: Bool {
    return spent > budgetAmount
  }
  
  var shouldAlert: Bool {
    return percentageUsed >= (alertThreshold * 100)
  }
}

enum BudgetPeriod: String, Codable, CaseIterable {
  case weekly = "weekly"
  case monthly = "monthly"
  case quarterly = "quarterly"
  case yearly = "yearly"
  
  var localizedName: String {
    switch self {
    case .weekly:
      return NSLocalizedString("budget.period.weekly", comment: "Weekly")
    case .monthly:
      return NSLocalizedString("budget.period.monthly", comment: "Monthly")
    case .quarterly:
      return NSLocalizedString("budget.period.quarterly", comment: "Quarterly")
    case .yearly:
      return NSLocalizedString("budget.period.yearly", comment: "Yearly")
    }
  }
}
