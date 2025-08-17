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
    
    return Budget(
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
