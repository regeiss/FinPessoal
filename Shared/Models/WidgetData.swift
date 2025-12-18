//
//  WidgetData.swift
//  FinPessoal
//
//  Created by Claude Code on 16/12/25.
//

import Foundation

/// Main data structure for widget information sharing between app and widgets
struct WidgetData: Codable {
  let lastUpdated: Date
  let totalBalance: Double
  let monthlyIncome: Double
  let monthlyExpenses: Double
  let accounts: [AccountSummary]
  let budgets: [BudgetSummary]
  let upcomingBills: [BillSummary]
  let goals: [GoalSummary]
  let creditCards: [CardSummary]
  let recentTransactions: [TransactionSummary]

  /// Empty placeholder data for widget previews
  static let empty = WidgetData(
    lastUpdated: Date(),
    totalBalance: 0,
    monthlyIncome: 0,
    monthlyExpenses: 0,
    accounts: [],
    budgets: [],
    upcomingBills: [],
    goals: [],
    creditCards: [],
    recentTransactions: []
  )
}
