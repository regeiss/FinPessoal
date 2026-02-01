//
//  BudgetViewModel.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import Foundation
import Combine

@MainActor
class BudgetViewModel: ObservableObject {
  @Published var name = ""
  @Published var selectedCategory: TransactionCategory = .food
  @Published var budgetAmount = ""
  @Published var selectedPeriod: BudgetPeriod = .monthly
  @Published var alertThreshold = 0.8
  @Published var startDate = Date()
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let crashlytics = CrashlyticsManager.shared

  // User ID should be provided by authentication system
  private var currentUserId: String = "current-user-id" // This should come from AuthViewModel
  
  var endDate: Date {
    return selectedPeriod.nextPeriodStart(from: startDate)
  }
  
  var isValidBudget: Bool {
    return !name.isEmpty &&
    Double(budgetAmount) != nil &&
    Double(budgetAmount) ?? 0 > 0
  }
  
  func createBudget() -> Budget? {
    guard isValidBudget,
          let amount = Double(budgetAmount) else {
      return nil
    }

    let now = Date()

    let budget = Budget(
      id: UUID().uuidString,
      name: name,
      category: selectedCategory,
      budgetAmount: amount,
      spent: 0.0,
      period: selectedPeriod,
      startDate: startDate,
      endDate: endDate,
      isActive: true,
      alertThreshold: alertThreshold,
      userId: currentUserId,
      createdAt: now,
      updatedAt: now
    )

    // Schedule notification if budget has an alert threshold
    if alertThreshold < 1.0 {
      Task {
        await NotificationManager.shared.scheduleBudgetAlert(budget: budget)
      }
    }

    crashlytics.logEvent("budget_created", parameters: ["category": selectedCategory.rawValue, "period": selectedPeriod.rawValue, "amount": amount])
    return budget
  }

  func updateBudget(_ budget: Budget) {
    // Update budget alert when budget is modified
    Task {
      await NotificationManager.shared.updateBudgetAlert(budget: budget)
    }
    crashlytics.logEvent("budget_updated", parameters: ["budgetId": budget.id])
  }

  func deleteBudget(_ budgetId: String) {
    // Cancel notifications for deleted budget
    Task {
      await NotificationManager.shared.cancelNotification(identifier: "budget-\(budgetId)")
    }
    crashlytics.logEvent("budget_deleted", parameters: ["budgetId": budgetId])
  }
  
  func setCurrentUserId(_ userId: String) {
    self.currentUserId = userId
  }
  
  func reset() {
    name = ""
    selectedCategory = .food
    budgetAmount = ""
    selectedPeriod = .monthly
    alertThreshold = 0.8
    startDate = Date()
    errorMessage = nil
  }
}
