//
//  InsightsViewModel.swift
//  FinPessoal
//
//  Created by Claude Code on 29/10/25.
//

import Foundation
import Combine

@MainActor
class InsightsViewModel: ObservableObject {
  @Published var insights: [FinancialInsight] = []
  @Published var spendingPatterns: [SpendingPattern] = []
  @Published var budgetPredictions: [BudgetPrediction] = []

  // AI Features
  @Published var expensePredictions: [ExpensePrediction] = []
  @Published var anomalies: [TransactionAnomaly] = []
  @Published var budgetSuggestions: [BudgetSuggestion] = []
  @Published var personalizedAdvice: [PersonalizedAdvice] = []

  @Published var isLoading = false
  @Published var selectedCategory: InsightCategory?
  @Published var showAIInsights = true

  private let analyticsService = FinancialAnalyticsService.shared
  private let aiService = FinancialAIService.shared

  var filteredInsights: [FinancialInsight] {
    guard let category = selectedCategory else {
      return insights
    }
    return insights.filter { $0.category == category }
  }

  var criticalAnomalies: [TransactionAnomaly] {
    anomalies.filter { $0.severity == .high }
  }

  var topAdvice: [PersonalizedAdvice] {
    Array(personalizedAdvice.prefix(5))
  }

  func loadInsights(transactions: [Transaction], budgets: [Budget], goals: [Goal]) {
    isLoading = true

    // Generate analytics insights
    insights = analyticsService.generateInsights(
      transactions: transactions,
      budgets: budgets,
      goals: goals
    )

    // Detect spending patterns
    spendingPatterns = analyticsService.detectSpendingPatterns(
      transactions: transactions,
      budgets: budgets
    )

    // Predict budget overruns
    budgetPredictions = analyticsService.predictBudgetOverruns(
      transactions: transactions,
      budgets: budgets
    )

    // AI-powered features
    if showAIInsights {
      loadAIInsights(transactions: transactions, budgets: budgets, goals: goals)
    }

    isLoading = false
  }

  func loadAIInsights(transactions: [Transaction], budgets: [Budget], goals: [Goal]) {
    // Predict expenses
    expensePredictions = aiService.predictExpenses(transactions: transactions, months: 3)

    // Detect anomalies
    anomalies = aiService.detectAnomalies(transactions: transactions)

    // Generate budget suggestions
    budgetSuggestions = aiService.generateBudgetSuggestions(
      transactions: transactions,
      currentBudgets: budgets
    )

    // Generate personalized advice
    personalizedAdvice = aiService.generatePersonalizedAdvice(
      transactions: transactions,
      budgets: budgets,
      goals: goals,
      predictions: expensePredictions
    )
  }

  func filterByCategory(_ category: InsightCategory?) {
    selectedCategory = category
  }

  func toggleAIInsights() {
    showAIInsights.toggle()
  }
}
