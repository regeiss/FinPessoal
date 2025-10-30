//
//  FinancialAnalyticsService.swift
//  FinPessoal
//
//  Created by Claude Code on 29/10/25.
//

import Foundation

/// Financial Analytics Service - Provides intelligent analysis of financial data
class FinancialAnalyticsService {

  // MARK: - Singleton
  static let shared = FinancialAnalyticsService()
  private init() {}

  // MARK: - Transaction Categorization

  /// Automatically categorize transactions based on description and amount patterns
  func categorizeTransactions(_ transactions: [Transaction]) -> [Transaction] {
    return transactions.map { transaction in
      // If already has a category, skip
      guard transaction.category == .other else {
        return transaction
      }

      // Smart categorization based on keywords
      let category = detectCategory(from: transaction.description)

      // Create new transaction with updated category
      return Transaction(
        id: transaction.id,
        accountId: transaction.accountId,
        amount: transaction.amount,
        description: transaction.description,
        category: category,
        type: transaction.type,
        date: transaction.date,
        isRecurring: transaction.isRecurring,
        userId: transaction.userId,
        createdAt: transaction.createdAt,
        updatedAt: transaction.updatedAt,
        subcategory: transaction.subcategory
      )
    }
  }

  private func detectCategory(from description: String) -> TransactionCategory {
    let lowercased = description.lowercased()

    // Food & Dining
    if lowercased.contains("restaurante") || lowercased.contains("ifood") ||
       lowercased.contains("uber eats") || lowercased.contains("rappi") ||
       lowercased.contains("mercado") || lowercased.contains("supermercado") {
      return .food
    }

    // Transportation
    if lowercased.contains("uber") || lowercased.contains("99") ||
       lowercased.contains("posto") || lowercased.contains("gasolina") ||
       lowercased.contains("combustível") {
      return .transport
    }

    // Shopping
    if lowercased.contains("amazon") || lowercased.contains("mercado livre") ||
       lowercased.contains("americanas") || lowercased.contains("magazine") {
      return .shopping
    }

    // Entertainment
    if lowercased.contains("netflix") || lowercased.contains("spotify") ||
       lowercased.contains("cinema") || lowercased.contains("streaming") {
      return .entertainment
    }

    // Healthcare
    if lowercased.contains("farmácia") || lowercased.contains("hospital") ||
       lowercased.contains("médico") || lowercased.contains("clínica") {
      return .healthcare
    }

    // Bills
    if lowercased.contains("energia") || lowercased.contains("água") ||
       lowercased.contains("internet") || lowercased.contains("celular") ||
       lowercased.contains("aluguel") {
      return .bills
    }

    return .other
  }

  // MARK: - Spending Pattern Detection

  /// Detect spending patterns and trends
  func detectSpendingPatterns(transactions: [Transaction], budgets: [Budget]) -> [SpendingPattern] {
    var patterns: [SpendingPattern] = []

    // Group by category
    let categoryGroups = Dictionary(grouping: transactions) { $0.category }

    for (category, categoryTransactions) in categoryGroups {
      let expenseTransactions = categoryTransactions.filter { $0.type == .expense }

      guard !expenseTransactions.isEmpty else { continue }

      // Calculate statistics
      let totalSpent = expenseTransactions.reduce(0) { $0 + $1.amount }
      let avgTransaction = totalSpent / Double(expenseTransactions.count)
      let frequency = expenseTransactions.count

      // Detect if spending is increasing
      let trend = detectTrend(transactions: expenseTransactions)

      // Compare with budget
      let budgetComparison = compareToBudget(category: category, spent: totalSpent, budgets: budgets)

      let pattern = SpendingPattern(
        category: category,
        totalSpent: totalSpent,
        averageTransaction: avgTransaction,
        frequency: frequency,
        trend: trend,
        budgetStatus: budgetComparison
      )

      patterns.append(pattern)
    }

    return patterns.sorted { $0.totalSpent > $1.totalSpent }
  }

  private func detectTrend(transactions: [Transaction]) -> SpendingTrend {
    guard transactions.count >= 4 else { return .stable }

    let sorted = transactions.sorted { $0.date < $1.date }
    let midpoint = sorted.count / 2

    let firstHalf = sorted[0..<midpoint]
    let secondHalf = sorted[midpoint...]

    let firstTotal = firstHalf.reduce(0.0) { $0 + $1.amount }
    let secondTotal = secondHalf.reduce(0.0) { $0 + $1.amount }

    let changePercent = ((secondTotal - firstTotal) / firstTotal) * 100

    if changePercent > 20 {
      return .increasing
    } else if changePercent < -20 {
      return .decreasing
    } else {
      return .stable
    }
  }

  private func compareToBudget(category: TransactionCategory, spent: Double, budgets: [Budget]) -> BudgetStatus {
    guard let budget = budgets.first(where: { $0.category == category }) else {
      return .noBudget
    }

    let percentage = (spent / budget.budgetAmount) * 100

    if percentage >= 100 {
      return .exceeded
    } else if percentage >= 90 {
      return .critical
    } else if percentage >= 80 {
      return .warning
    } else {
      return .healthy
    }
  }

  // MARK: - Budget Overrun Prediction

  /// Predict which budgets are likely to be exceeded
  func predictBudgetOverruns(transactions: [Transaction], budgets: [Budget]) -> [BudgetPrediction] {
    let calendar = Calendar.current
    let now = Date()

    guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
          let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
      return []
    }

    let daysInMonth = calendar.dateComponents([.day], from: startOfMonth, to: endOfMonth).day ?? 30
    let daysPassed = calendar.dateComponents([.day], from: startOfMonth, to: now).day ?? 1
    let daysRemaining = daysInMonth - daysPassed

    var predictions: [BudgetPrediction] = []

    for budget in budgets {
      // Get transactions for this month and category
      let monthTransactions = transactions.filter { transaction in
        transaction.type == .expense &&
        transaction.category == budget.category &&
        calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
      }

      let currentSpent = monthTransactions.reduce(0) { $0 + $1.amount }

      // Calculate daily average
      let dailyAverage = daysPassed > 0 ? currentSpent / Double(daysPassed) : 0

      // Project end of month
      let projectedTotal = currentSpent + (dailyAverage * Double(daysRemaining))

      // Calculate risk level
      let riskLevel = calculateRiskLevel(projected: projectedTotal, limit: budget.budgetAmount)

      let prediction = BudgetPrediction(
        budget: budget,
        currentSpent: currentSpent,
        projectedTotal: projectedTotal,
        daysRemaining: daysRemaining,
        riskLevel: riskLevel,
        recommendation: generateRecommendation(
          budget: budget,
          projected: projectedTotal,
          risk: riskLevel
        )
      )

      predictions.append(prediction)
    }

    return predictions.sorted { $0.riskLevel.rawValue > $1.riskLevel.rawValue }
  }

  private func calculateRiskLevel(projected: Double, limit: Double) -> RiskLevel {
    let percentage = (projected / limit) * 100

    if percentage >= 110 {
      return .critical
    } else if percentage >= 100 {
      return .high
    } else if percentage >= 90 {
      return .medium
    } else {
      return .low
    }
  }

  private func generateRecommendation(budget: Budget, projected: Double, risk: RiskLevel) -> String {
    switch risk {
    case .critical:
      return "insights.recommendation.critical"
    case .high:
      return "insights.recommendation.high"
    case .medium:
      return "insights.recommendation.medium"
    case .low:
      return "insights.recommendation.low"
    }
  }

  // MARK: - Insight Generation

  /// Generate intelligent financial insights
  func generateInsights(transactions: [Transaction], budgets: [Budget], goals: [Goal]) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []

    // Spending insights
    insights.append(contentsOf: generateSpendingInsights(transactions: transactions))

    // Budget insights
    insights.append(contentsOf: generateBudgetInsights(transactions: transactions, budgets: budgets))

    // Goal insights
    insights.append(contentsOf: generateGoalInsights(goals: goals))

    // Savings opportunities
    insights.append(contentsOf: generateSavingsInsights(transactions: transactions))

    return insights.sorted { $0.priority.rawValue > $1.priority.rawValue }
  }

  private func generateSpendingInsights(transactions: [Transaction]) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []
    let calendar = Calendar.current
    let now = Date()

    // This month vs last month
    let thisMonthTransactions = transactions.filter {
      $0.type == .expense && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
    }

    let lastMonth = calendar.date(byAdding: .month, value: -1, to: now)!
    let lastMonthTransactions = transactions.filter {
      $0.type == .expense && calendar.isDate($0.date, equalTo: lastMonth, toGranularity: .month)
    }

    let thisMonthTotal = thisMonthTransactions.reduce(0) { $0 + $1.amount }
    let lastMonthTotal = lastMonthTransactions.reduce(0) { $0 + $1.amount }

    if lastMonthTotal > 0 {
      let change = ((thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100

      if change > 20 {
        insights.append(FinancialInsight(
          id: UUID(),
          type: .warning,
          category: .spending,
          title: "insights.spending.increase.title",
          message: "insights.spending.increase.message",
          value: change,
          priority: .high,
          actionable: true
        ))
      } else if change < -15 {
        insights.append(FinancialInsight(
          id: UUID(),
          type: .positive,
          category: .spending,
          title: "insights.spending.decrease.title",
          message: "insights.spending.decrease.message",
          value: abs(change),
          priority: .medium,
          actionable: false
        ))
      }
    }

    // Identify top spending category
    let categoryTotals = Dictionary(grouping: thisMonthTransactions) { $0.category }
      .mapValues { $0.reduce(0) { $0 + $1.amount } }

    if let topCategory = categoryTotals.max(by: { $0.value < $1.value }) {
      let percentage = (topCategory.value / thisMonthTotal) * 100

      if percentage > 40 {
        insights.append(FinancialInsight(
          id: UUID(),
          type: .info,
          category: .spending,
          title: "insights.top.category.title",
          message: "insights.top.category.message",
          value: percentage,
          priority: .medium,
          actionable: true,
          metadata: ["category": topCategory.key.displayName]
        ))
      }
    }

    return insights
  }

  private func generateBudgetInsights(transactions: [Transaction], budgets: [Budget]) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []
    let predictions = predictBudgetOverruns(transactions: transactions, budgets: budgets)

    for prediction in predictions where prediction.riskLevel == .high || prediction.riskLevel == .critical {
      insights.append(FinancialInsight(
        id: UUID(),
        type: .warning,
        category: .budget,
        title: "insights.budget.risk.title",
        message: "insights.budget.risk.message",
        value: (prediction.projectedTotal / prediction.budget.budgetAmount) * 100,
        priority: prediction.riskLevel == .critical ? .critical : .high,
        actionable: true,
        metadata: ["budgetName": prediction.budget.name]
      ))
    }

    return insights
  }

  private func generateGoalInsights(goals: [Goal]) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []

    for goal in goals where goal.isActive {
      let progress = goal.progressPercentage

      // Goal near completion
      if progress >= 90 && progress < 100 {
        insights.append(FinancialInsight(
          id: UUID(),
          type: .positive,
          category: .goals,
          title: "insights.goal.near.completion.title",
          message: "insights.goal.near.completion.message",
          value: progress,
          priority: .high,
          actionable: false,
          metadata: ["goalName": goal.name]
        ))
      }

      // Goal behind schedule
      let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: goal.targetDate).day ?? 0
      let expectedProgress = min(100, max(0, 100 - (Double(daysRemaining) / 365 * 100)))

      if progress < expectedProgress - 20 && daysRemaining > 0 {
        insights.append(FinancialInsight(
          id: UUID(),
          type: .warning,
          category: .goals,
          title: "insights.goal.behind.schedule.title",
          message: "insights.goal.behind.schedule.message",
          value: expectedProgress - progress,
          priority: .medium,
          actionable: true,
          metadata: ["goalName": goal.name]
        ))
      }
    }

    return insights
  }

  private func generateSavingsInsights(transactions: [Transaction]) -> [FinancialInsight] {
    var insights: [FinancialInsight] = []
    let calendar = Calendar.current
    let now = Date()

    // Recurring subscriptions detection
    let thisMonthTransactions = transactions.filter {
      $0.type == .expense && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
    }

    // Find similar transactions (potential subscriptions)
    let subscriptions = findRecurringTransactions(transactions: transactions)

    if !subscriptions.isEmpty {
      let totalSubscriptions = subscriptions.reduce(0) { $0 + $1.amount }

      insights.append(FinancialInsight(
        id: UUID(),
        type: .info,
        category: .savings,
        title: "insights.subscriptions.title",
        message: "insights.subscriptions.message",
        value: totalSubscriptions,
        priority: .medium,
        actionable: true,
        metadata: ["count": "\(subscriptions.count)"]
      ))
    }

    // Unusual spending detection
    let unusualTransactions = detectUnusualSpending(transactions: thisMonthTransactions)

    if !unusualTransactions.isEmpty {
      insights.append(FinancialInsight(
        id: UUID(),
        type: .info,
        category: .spending,
        title: "insights.unusual.spending.title",
        message: "insights.unusual.spending.message",
        value: Double(unusualTransactions.count),
        priority: .low,
        actionable: false
      ))
    }

    return insights
  }

  private func findRecurringTransactions(transactions: [Transaction]) -> [Transaction] {
    // Simplified: look for similar descriptions in last 3 months
    let calendar = Calendar.current
    let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: Date())!

    let recentTransactions = transactions.filter { $0.date >= threeMonthsAgo && $0.type == .expense }

    let grouped = Dictionary(grouping: recentTransactions) { transaction -> String in
      // Normalize description for grouping
      return transaction.description.lowercased()
        .replacingOccurrences(of: "[0-9]", with: "", options: .regularExpression)
        .trimmingCharacters(in: .whitespaces)
    }

    // Find transactions that appear monthly
    return grouped.values
      .filter { $0.count >= 2 }
      .flatMap { $0 }
  }

  private func detectUnusualSpending(transactions: [Transaction]) -> [Transaction] {
    guard !transactions.isEmpty else { return [] }

    let amounts = transactions.map { $0.amount }
    let average = amounts.reduce(0, +) / Double(amounts.count)

    // Transactions > 3x average are unusual
    return transactions.filter { $0.amount > average * 3 }
  }
}

// MARK: - Models

struct SpendingPattern {
  let category: TransactionCategory
  let totalSpent: Double
  let averageTransaction: Double
  let frequency: Int
  let trend: SpendingTrend
  let budgetStatus: BudgetStatus
}

enum SpendingTrend: String {
  case increasing
  case decreasing
  case stable

  var displayName: String {
    switch self {
    case .increasing: return String(localized: "trend.increasing")
    case .decreasing: return String(localized: "trend.decreasing")
    case .stable: return String(localized: "trend.stable")
    }
  }

  var icon: String {
    switch self {
    case .increasing: return "arrow.up.right"
    case .decreasing: return "arrow.down.right"
    case .stable: return "arrow.right"
    }
  }

  var color: String {
    switch self {
    case .increasing: return "red"
    case .decreasing: return "green"
    case .stable: return "blue"
    }
  }
}

enum BudgetStatus {
  case healthy
  case warning
  case critical
  case exceeded
  case noBudget

  var displayName: String {
    switch self {
    case .healthy: return String(localized: "budget.status.healthy")
    case .warning: return String(localized: "budget.status.warning")
    case .critical: return String(localized: "budget.status.critical")
    case .exceeded: return String(localized: "budget.status.exceeded")
    case .noBudget: return String(localized: "budget.status.none")
    }
  }
}

struct BudgetPrediction {
  let budget: Budget
  let currentSpent: Double
  let projectedTotal: Double
  let daysRemaining: Int
  let riskLevel: RiskLevel
  let recommendation: String
}

enum RiskLevel: Int {
  case low = 0
  case medium = 1
  case high = 2
  case critical = 3

  var displayName: String {
    switch self {
    case .low: return String(localized: "risk.low")
    case .medium: return String(localized: "risk.medium")
    case .high: return String(localized: "risk.high")
    case .critical: return String(localized: "risk.critical")
    }
  }

  var color: String {
    switch self {
    case .low: return "green"
    case .medium: return "yellow"
    case .high: return "orange"
    case .critical: return "red"
    }
  }
}

struct FinancialInsight: Identifiable {
  let id: UUID
  let type: InsightType
  let category: InsightCategory
  let title: String
  let message: String
  let value: Double
  let priority: InsightPriority
  let actionable: Bool
  var metadata: [String: String] = [:]
}

enum InsightType {
  case positive
  case warning
  case info

  var icon: String {
    switch self {
    case .positive: return "checkmark.circle.fill"
    case .warning: return "exclamationmark.triangle.fill"
    case .info: return "info.circle.fill"
    }
  }

  var color: String {
    switch self {
    case .positive: return "green"
    case .warning: return "orange"
    case .info: return "blue"
    }
  }
}

enum InsightCategory {
  case spending
  case budget
  case goals
  case savings

  var displayName: String {
    switch self {
    case .spending: return String(localized: "insights.category.spending")
    case .budget: return String(localized: "insights.category.budget")
    case .goals: return String(localized: "insights.category.goals")
    case .savings: return String(localized: "insights.category.savings")
    }
  }
}

enum InsightPriority: Int {
  case low = 0
  case medium = 1
  case high = 2
  case critical = 3
}
