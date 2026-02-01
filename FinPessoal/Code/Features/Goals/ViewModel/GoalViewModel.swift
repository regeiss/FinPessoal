//
//  GoalViewModel.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import Foundation
import Combine

@MainActor
class GoalViewModel: ObservableObject {
  @Published var name = ""
  @Published var description = ""
  @Published var selectedCategory: GoalCategory = .emergency
  @Published var targetAmount = ""
  @Published var currentAmount = ""
  @Published var targetDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let crashlytics = CrashlyticsManager.shared

  // User ID should be provided by authentication system
  private var currentUserId: String = "current-user-id" // This should come from AuthViewModel
  
  var isValidGoal: Bool {
    return !name.isEmpty &&
    Double(targetAmount) != nil &&
    Double(targetAmount) ?? 0 > 0 &&
    targetDate > Date()
  }
  
  var formattedTargetAmount: String {
    guard let amount = Double(targetAmount) else { return "R$ 0,00" }
    return CurrencyFormatter.shared.string(from: amount)
  }
  
  var formattedCurrentAmount: String {
    guard let amount = Double(currentAmount) else { return "R$ 0,00" }
    return CurrencyFormatter.shared.string(from: amount)
  }
  
  var monthlyContributionNeeded: Double {
    guard let target = Double(targetAmount),
          let current = Double(currentAmount) else { return 0 }
    
    let remaining = max(0, target - current)
    let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
    let monthsLeft = max(1, Double(daysRemaining) / 30.0)
    
    return remaining / monthsLeft
  }
  
  var formattedMonthlyContribution: String {
    return CurrencyFormatter.shared.string(from: monthlyContributionNeeded)
  }
  
  func createGoal() -> Goal? {
    guard isValidGoal,
          let targetAmountDouble = Double(targetAmount) else {
      return nil
    }
    
    let currentAmountDouble = Double(currentAmount) ?? 0.0
    let now = Date()
    
    return Goal(
      id: UUID().uuidString,
      userId: currentUserId,
      name: name,
      description: description.isEmpty ? nil : description,
      targetAmount: targetAmountDouble,
      currentAmount: currentAmountDouble,
      targetDate: targetDate,
      category: selectedCategory,
      isActive: true,
      createdAt: now,
      updatedAt: now
    )
  }
  
  func setCurrentUserId(_ userId: String) {
    self.currentUserId = userId
  }
  
  func reset() {
    name = ""
    description = ""
    selectedCategory = .emergency
    targetAmount = ""
    currentAmount = ""
    targetDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    errorMessage = nil
  }
  
  func updateGoalProgress(_ goalId: String, newAmount: Double, in goals: inout [Goal]) {
    if let index = goals.firstIndex(where: { $0.id == goalId }) {
      let goal = goals[index]
      let updatedGoal = Goal(
        id: goal.id,
        userId: goal.userId,
        name: goal.name,
        description: goal.description,
        targetAmount: goal.targetAmount,
        currentAmount: newAmount,
        targetDate: goal.targetDate,
        category: goal.category,
        isActive: goal.isActive,
        createdAt: goal.createdAt,
        updatedAt: Date()
      )
      goals[index] = updatedGoal
    }
  }
}