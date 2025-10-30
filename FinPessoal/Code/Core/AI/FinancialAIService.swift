//
//  FinancialAIService.swift
//  FinPessoal
//
//  Created by Claude Code on 29/10/25.
//

import Foundation

/// Financial AI Service - Machine Learning for intelligent financial predictions and recommendations
class FinancialAIService {

  // MARK: - Singleton
  static let shared = FinancialAIService()
  private init() {}

  // MARK: - Expense Prediction

  /// Predict future expenses using ML-based analysis
  func predictExpenses(
    transactions: [Transaction],
    months: Int = 3
  ) -> [ExpensePrediction] {
    guard !transactions.isEmpty else { return [] }

    let expenseTransactions = transactions.filter { $0.type == .expense }
    let calendar = Calendar.current

    // Group by category
    let categoryGroups = Dictionary(grouping: expenseTransactions) { $0.category }

    var predictions: [ExpensePrediction] = []

    for (category, categoryTransactions) in categoryGroups {
      // Get historical data (last 6 months)
      let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: Date())!
      let recentTransactions = categoryTransactions.filter { $0.date >= sixMonthsAgo }

      guard recentTransactions.count >= 3 else { continue }

      // Calculate monthly averages
      let monthlyData = calculateMonthlyAverages(transactions: recentTransactions)

      // Apply linear regression for trend
      let trend = calculateTrend(monthlyData: monthlyData)

      // Calculate seasonal factors
      let seasonalFactors = calculateSeasonality(transactions: recentTransactions)

      // Predict next months
      var monthlyPredictions: [MonthlyPrediction] = []
      let currentMonth = calendar.component(.month, from: Date())

      for i in 1...months {
        let futureMonth = (currentMonth + i - 1) % 12 + 1
        let baseAmount = monthlyData.average + (trend * Double(i))
        let seasonalFactor = seasonalFactors[futureMonth - 1]
        let predictedAmount = baseAmount * seasonalFactor

        // Calculate confidence based on data consistency
        let confidence = calculateConfidence(
          data: monthlyData.values,
          prediction: predictedAmount
        )

        monthlyPredictions.append(MonthlyPrediction(
          month: futureMonth,
          predictedAmount: max(0, predictedAmount),
          confidence: confidence,
          trend: trend > 0 ? .increasing : trend < 0 ? .decreasing : .stable
        ))
      }

      predictions.append(ExpensePrediction(
        category: category,
        predictions: monthlyPredictions,
        historicalAverage: monthlyData.average,
        trendSlope: trend,
        dataPoints: recentTransactions.count
      ))
    }

    return predictions.sorted { $0.predictions[0].predictedAmount > $1.predictions[0].predictedAmount }
  }

  private func calculateMonthlyAverages(transactions: [Transaction]) -> MonthlyData {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: transactions) { transaction -> String in
      let components = calendar.dateComponents([.year, .month], from: transaction.date)
      return "\(components.year!)-\(components.month!)"
    }

    let monthlyTotals = grouped.mapValues { $0.reduce(0) { $0 + $1.amount } }
    let values = monthlyTotals.values.map { $0 }

    return MonthlyData(
      values: values,
      average: values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
    )
  }

  private func calculateTrend(monthlyData: MonthlyData) -> Double {
    let values = monthlyData.values
    guard values.count >= 2 else { return 0 }

    // Simple linear regression
    let n = Double(values.count)
    let sumX = (0..<values.count).reduce(0) { $0 + $1 }
    let sumY = values.reduce(0, +)
    let sumXY = values.enumerated().reduce(0.0) { $0 + Double($1.offset) * $1.element }
    let sumX2 = (0..<values.count).reduce(0) { $0 + $1 * $1 }

    let slope = (n * sumXY - Double(sumX) * sumY) / (n * Double(sumX2) - Double(sumX * sumX))

    return slope
  }

  private func calculateSeasonality(transactions: [Transaction]) -> [Double] {
    let calendar = Calendar.current
    var monthlyTotals = Array(repeating: [Double](), count: 12)

    for transaction in transactions {
      let month = calendar.component(.month, from: transaction.date)
      monthlyTotals[month - 1].append(transaction.amount)
    }

    let overallAverage = transactions.reduce(0) { $0 + $1.amount } / Double(transactions.count)

    return monthlyTotals.map { amounts in
      guard !amounts.isEmpty else { return 1.0 }
      let monthAverage = amounts.reduce(0, +) / Double(amounts.count)
      return overallAverage > 0 ? monthAverage / overallAverage : 1.0
    }
  }

  private func calculateConfidence(data: [Double], prediction: Double) -> Double {
    guard !data.isEmpty else { return 0 }

    // Calculate coefficient of variation
    let mean = data.reduce(0, +) / Double(data.count)
    let variance = data.map { pow($0 - mean, 2) }.reduce(0, +) / Double(data.count)
    let stdDev = sqrt(variance)
    let coefficientOfVariation = mean > 0 ? stdDev / mean : 1.0

    // Lower CV = higher confidence
    let confidence = max(0, min(1, 1 - coefficientOfVariation))

    return confidence
  }

  // MARK: - Anomaly Detection

  /// Detect anomalies in transactions using ML-based statistical analysis
  func detectAnomalies(transactions: [Transaction]) -> [TransactionAnomaly] {
    guard transactions.count >= 10 else { return [] }

    var anomalies: [TransactionAnomaly] = []

    // Group by category
    let categoryGroups = Dictionary(grouping: transactions) { $0.category }

    for (category, categoryTransactions) in categoryGroups {
      let amounts = categoryTransactions.map { $0.amount }

      // Calculate statistical measures
      let mean = amounts.reduce(0, +) / Double(amounts.count)
      let variance = amounts.map { pow($0 - mean, 2) }.reduce(0, +) / Double(amounts.count)
      let stdDev = sqrt(variance)

      // Detect outliers using Z-score (3 sigma rule)
      for transaction in categoryTransactions {
        let zScore = stdDev > 0 ? abs(transaction.amount - mean) / stdDev : 0

        if zScore > 3 {
          // Significant outlier
          let severity: AnomalySeverity = zScore > 4 ? .high : .medium

          anomalies.append(TransactionAnomaly(
            transaction: transaction,
            type: .unusualAmount,
            severity: severity,
            zScore: zScore,
            expectedRange: (mean - 2 * stdDev, mean + 2 * stdDev),
            explanation: "ai.anomaly.unusual.amount"
          ))
        }
      }

      // Detect frequency anomalies
      let frequencyAnomalies = detectFrequencyAnomalies(transactions: categoryTransactions)
      anomalies.append(contentsOf: frequencyAnomalies)
    }

    // Detect unusual timing
    let timingAnomalies = detectTimingAnomalies(transactions: transactions)
    anomalies.append(contentsOf: timingAnomalies)

    // Detect duplicate transactions
    let duplicates = detectPotentialDuplicates(transactions: transactions)
    anomalies.append(contentsOf: duplicates)

    return anomalies.sorted { $0.severity.rawValue > $1.severity.rawValue }
  }

  private func detectFrequencyAnomalies(transactions: [Transaction]) -> [TransactionAnomaly] {
    var anomalies: [TransactionAnomaly] = []
    let calendar = Calendar.current

    // Check for sudden spike in transaction count
    let monthlyGroups = Dictionary(grouping: transactions) { transaction -> String in
      let components = calendar.dateComponents([.year, .month], from: transaction.date)
      return "\(components.year!)-\(components.month!)"
    }

    let counts = monthlyGroups.values.map { $0.count }
    guard counts.count >= 2 else { return [] }

    let avgCount = Double(counts.reduce(0, +)) / Double(counts.count)
    let variance = counts.map { pow(Double($0) - avgCount, 2) }.reduce(0, +) / Double(counts.count)
    let stdDev = sqrt(variance)

    for (month, monthTransactions) in monthlyGroups {
      let count = Double(monthTransactions.count)
      let zScore = stdDev > 0 ? abs(count - avgCount) / stdDev : 0

      if zScore > 2.5 && count > avgCount {
        // Unusual spike in frequency
        if let mostRecent = monthTransactions.max(by: { $0.date < $1.date }) {
          anomalies.append(TransactionAnomaly(
            transaction: mostRecent,
            type: .frequencySpike,
            severity: .medium,
            zScore: zScore,
            expectedRange: (avgCount - stdDev, avgCount + stdDev),
            explanation: "ai.anomaly.frequency.spike"
          ))
        }
      }
    }

    return anomalies
  }

  private func detectTimingAnomalies(transactions: [Transaction]) -> [TransactionAnomaly] {
    var anomalies: [TransactionAnomaly] = []
    let calendar = Calendar.current

    // Detect transactions at unusual hours
    let nightTransactions = transactions.filter { transaction in
      let hour = calendar.component(.hour, from: transaction.date)
      return hour >= 23 || hour <= 5
    }

    for transaction in nightTransactions where transaction.amount > 500 {
      anomalies.append(TransactionAnomaly(
        transaction: transaction,
        type: .unusualTiming,
        severity: .low,
        zScore: 0,
        expectedRange: (0, 0),
        explanation: "ai.anomaly.unusual.timing"
      ))
    }

    return anomalies
  }

  private func detectPotentialDuplicates(transactions: [Transaction]) -> [TransactionAnomaly] {
    var anomalies: [TransactionAnomaly] = []
    let sortedTransactions = transactions.sorted { $0.date < $1.date }

    for i in 0..<sortedTransactions.count - 1 {
      let current = sortedTransactions[i]
      let next = sortedTransactions[i + 1]

      // Check if same amount, same category, within 1 hour
      if current.amount == next.amount &&
         current.category == next.category &&
         abs(current.date.timeIntervalSince(next.date)) < 3600 {
        anomalies.append(TransactionAnomaly(
          transaction: next,
          type: .potentialDuplicate,
          severity: .medium,
          zScore: 0,
          expectedRange: (0, 0),
          explanation: "ai.anomaly.potential.duplicate"
        ))
      }
    }

    return anomalies
  }

  // MARK: - Smart Budget Suggestions

  /// Generate smart budget suggestions using ML analysis
  func generateBudgetSuggestions(
    transactions: [Transaction],
    currentBudgets: [Budget]
  ) -> [BudgetSuggestion] {
    guard !transactions.isEmpty else { return [] }

    let expenseTransactions = transactions.filter { $0.type == .expense }
    let categoryGroups = Dictionary(grouping: expenseTransactions) { $0.category }

    var suggestions: [BudgetSuggestion] = []

    for (category, categoryTransactions) in categoryGroups {
      // Get last 3 months of data
      let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
      let recentTransactions = categoryTransactions.filter { $0.date >= threeMonthsAgo }

      guard !recentTransactions.isEmpty else { continue }

      // Calculate statistics
      let amounts = recentTransactions.map { $0.amount }
      let monthlyTotals = calculateMonthlyTotals(transactions: recentTransactions)

      let mean = monthlyTotals.reduce(0, +) / Double(monthlyTotals.count)
      let median = calculateMedian(values: monthlyTotals)
      let percentile90 = calculatePercentile(values: monthlyTotals, percentile: 0.9)

      // Check if budget exists
      let existingBudget = currentBudgets.first(where: { $0.category == category })

      let suggestedAmount: Double
      let reasoning: String

      if let budget = existingBudget {
        // Analyze budget performance
        if budget.percentageUsed >= 0.95 {
          // Consistently over/near budget
          suggestedAmount = percentile90 * 1.1 // 10% buffer
          reasoning = "ai.budget.suggestion.increase"
        } else if budget.percentageUsed <= 0.6 {
          // Under-utilizing budget
          suggestedAmount = median * 1.15 // 15% buffer
          reasoning = "ai.budget.suggestion.decrease"
        } else {
          // Budget is appropriate
          continue
        }
      } else {
        // No budget exists - suggest based on 90th percentile
        suggestedAmount = percentile90 * 1.15
        reasoning = "ai.budget.suggestion.new"
      }

      let confidence = calculateBudgetConfidence(
        data: monthlyTotals,
        suggestion: suggestedAmount
      )

      suggestions.append(BudgetSuggestion(
        category: category,
        suggestedAmount: suggestedAmount,
        currentAmount: existingBudget?.budgetAmount,
        averageSpending: mean,
        medianSpending: median,
        percentile90: percentile90,
        confidence: confidence,
        reasoning: reasoning,
        impactLevel: calculateImpactLevel(
          current: existingBudget?.budgetAmount,
          suggested: suggestedAmount
        )
      ))
    }

    return suggestions.sorted { $0.impactLevel.rawValue > $1.impactLevel.rawValue }
  }

  private func calculateMonthlyTotals(transactions: [Transaction]) -> [Double] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: transactions) { transaction -> String in
      let components = calendar.dateComponents([.year, .month], from: transaction.date)
      return "\(components.year!)-\(components.month!)"
    }

    return grouped.values.map { $0.reduce(0) { $0 + $1.amount } }
  }

  private func calculateMedian(values: [Double]) -> Double {
    let sorted = values.sorted()
    let count = sorted.count

    if count % 2 == 0 {
      return (sorted[count / 2 - 1] + sorted[count / 2]) / 2
    } else {
      return sorted[count / 2]
    }
  }

  private func calculatePercentile(values: [Double], percentile: Double) -> Double {
    let sorted = values.sorted()
    let index = Int(Double(sorted.count - 1) * percentile)
    return sorted[index]
  }

  private func calculateBudgetConfidence(data: [Double], suggestion: Double) -> Double {
    guard !data.isEmpty else { return 0 }

    let mean = data.reduce(0, +) / Double(data.count)
    let variance = data.map { pow($0 - mean, 2) }.reduce(0, +) / Double(data.count)
    let stdDev = sqrt(variance)

    // Check if suggestion covers most scenarios (within 2 std dev)
    let coverage = data.filter { abs($0 - suggestion) <= 2 * stdDev }.count
    let confidenceFromCoverage = Double(coverage) / Double(data.count)

    // Check consistency of data
    let coefficientOfVariation = mean > 0 ? stdDev / mean : 1.0
    let confidenceFromConsistency = max(0, min(1, 1 - coefficientOfVariation))

    return (confidenceFromCoverage + confidenceFromConsistency) / 2
  }

  private func calculateImpactLevel(current: Double?, suggested: Double) -> ImpactLevel {
    guard let current = current else { return .high }

    let change = abs(suggested - current) / current

    if change > 0.3 {
      return .high
    } else if change > 0.15 {
      return .medium
    } else {
      return .low
    }
  }

  // MARK: - Personalized Advice

  /// Generate personalized financial advice using ML-based analysis
  func generatePersonalizedAdvice(
    transactions: [Transaction],
    budgets: [Budget],
    goals: [Goal],
    predictions: [ExpensePrediction]
  ) -> [PersonalizedAdvice] {
    var advice: [PersonalizedAdvice] = []

    // Analyze spending behavior
    advice.append(contentsOf: analyzeSpendingBehavior(transactions: transactions))

    // Budget optimization
    advice.append(contentsOf: analyzeBudgetOptimization(budgets: budgets, transactions: transactions))

    // Goal achievement strategies
    advice.append(contentsOf: analyzeGoalStrategies(goals: goals, transactions: transactions))

    // Savings opportunities
    advice.append(contentsOf: analyzeSavingsOpportunities(transactions: transactions))

    // Income optimization
    advice.append(contentsOf: analyzeIncomePatterns(transactions: transactions))

    // Risk management
    advice.append(contentsOf: analyzeFinancialRisks(transactions: transactions, budgets: budgets))

    return advice.sorted { $0.priority.rawValue > $1.priority.rawValue }
  }

  private func analyzeSpendingBehavior(transactions: [Transaction]) -> [PersonalizedAdvice] {
    var advice: [PersonalizedAdvice] = []

    let expenses = transactions.filter { $0.type == .expense }
    let categoryTotals = Dictionary(grouping: expenses) { $0.category }
      .mapValues { $0.reduce(0) { $0 + $1.amount } }

    let totalExpenses = categoryTotals.values.reduce(0, +)

    // Find dominant category
    if let topCategory = categoryTotals.max(by: { $0.value < $1.value }) {
      let percentage = (topCategory.value / totalExpenses) * 100

      if percentage > 50 {
        advice.append(PersonalizedAdvice(
          id: UUID(),
          title: "ai.advice.spending.concentration.title",
          message: "ai.advice.spending.concentration.message",
          category: .spending,
          priority: .high,
          actionable: true,
          potentialSavings: topCategory.value * 0.1,
          metadata: [
            "category": topCategory.key.displayName,
            "percentage": String(format: "%.0f", percentage)
          ]
        ))
      }
    }

    return advice
  }

  private func analyzeBudgetOptimization(budgets: [Budget], transactions: [Transaction]) -> [PersonalizedAdvice] {
    var advice: [PersonalizedAdvice] = []

    let underutilizedBudgets = budgets.filter { $0.percentageUsed < 0.5 && $0.isActive }

    if underutilizedBudgets.count >= 2 {
      let totalUnused = underutilizedBudgets.reduce(0) { $0 + $1.remaining }

      advice.append(PersonalizedAdvice(
        id: UUID(),
        title: "ai.advice.budget.underutilized.title",
        message: "ai.advice.budget.underutilized.message",
        category: .budgeting,
        priority: .medium,
        actionable: true,
        potentialSavings: totalUnused,
        metadata: ["count": "\(underutilizedBudgets.count)"]
      ))
    }

    return advice
  }

  private func analyzeGoalStrategies(goals: [Goal], transactions: [Transaction]) -> [PersonalizedAdvice] {
    var advice: [PersonalizedAdvice] = []

    for goal in goals where goal.isActive && !goal.isCompleted {
      let monthsRemaining = max(1, Double(goal.daysRemaining) / 30)
      let requiredMonthly = goal.remainingAmount / monthsRemaining

      // Check if current savings rate is sufficient
      let recentIncome = transactions.filter {
        $0.type == .income &&
        $0.date >= Calendar.current.date(byAdding: .month, value: -1, to: Date())!
      }.reduce(0) { $0 + $1.amount }

      if requiredMonthly > recentIncome * 0.3 {
        advice.append(PersonalizedAdvice(
          id: UUID(),
          title: "ai.advice.goal.challenging.title",
          message: "ai.advice.goal.challenging.message",
          category: .goals,
          priority: .high,
          actionable: true,
          potentialSavings: 0,
          metadata: [
            "goalName": goal.name,
            "requiredMonthly": String(format: "%.2f", requiredMonthly)
          ]
        ))
      }
    }

    return advice
  }

  private func analyzeSavingsOpportunities(transactions: [Transaction]) -> [PersonalizedAdvice] {
    var advice: [PersonalizedAdvice] = []

    // Analyze subscription spending
    let subscriptionCategories: [TransactionCategory] = [.entertainment, .bills]
    let subscriptions = transactions.filter { subscriptionCategories.contains($0.category) }

    let monthlySubscriptions = Dictionary(grouping: subscriptions) { $0.description }
      .filter { $0.value.count >= 2 } // Recurring
      .mapValues { $0.reduce(0) { $0 + $1.amount } / Double($0.count) }

    let totalSubscriptions = monthlySubscriptions.values.reduce(0, +)

    if totalSubscriptions > 200 {
      advice.append(PersonalizedAdvice(
        id: UUID(),
        title: "ai.advice.subscriptions.review.title",
        message: "ai.advice.subscriptions.review.message",
        category: .savings,
        priority: .medium,
        actionable: true,
        potentialSavings: totalSubscriptions * 0.3,
        metadata: [
          "monthlyTotal": String(format: "%.2f", totalSubscriptions),
          "count": "\(monthlySubscriptions.count)"
        ]
      ))
    }

    return advice
  }

  private func analyzeIncomePatterns(transactions: [Transaction]) -> [PersonalizedAdvice] {
    var advice: [PersonalizedAdvice] = []

    let incomeTransactions = transactions.filter { $0.type == .income }
    guard !incomeTransactions.isEmpty else { return [] }

    // Check income stability
    let monthlyGroups = Dictionary(grouping: incomeTransactions) { transaction -> String in
      let calendar = Calendar.current
      let components = calendar.dateComponents([.year, .month], from: transaction.date)
      return "\(components.year!)-\(components.month!)"
    }

    let monthlyIncomes = monthlyGroups.values.map { $0.reduce(0) { $0 + $1.amount } }

    if monthlyIncomes.count >= 3 {
      let mean = monthlyIncomes.reduce(0, +) / Double(monthlyIncomes.count)
      let variance = monthlyIncomes.map { pow($0 - mean, 2) }.reduce(0, +) / Double(monthlyIncomes.count)
      let stdDev = sqrt(variance)
      let coefficientOfVariation = mean > 0 ? stdDev / mean : 0

      if coefficientOfVariation > 0.3 {
        advice.append(PersonalizedAdvice(
          id: UUID(),
          title: "ai.advice.income.volatile.title",
          message: "ai.advice.income.volatile.message",
          category: .income,
          priority: .high,
          actionable: true,
          potentialSavings: 0,
          metadata: ["variability": String(format: "%.0f%%", coefficientOfVariation * 100)]
        ))
      }
    }

    return advice
  }

  private func analyzeFinancialRisks(transactions: [Transaction], budgets: [Budget]) -> [PersonalizedAdvice] {
    var advice: [PersonalizedAdvice] = []

    let expenses = transactions.filter { $0.type == .expense }
    let income = transactions.filter { $0.type == .income }

    let totalExpenses = expenses.reduce(0) { $0 + $1.amount }
    let totalIncome = income.reduce(0) { $0 + $1.amount }

    // Check expense to income ratio
    if totalIncome > 0 {
      let ratio = totalExpenses / totalIncome

      if ratio > 0.9 {
        advice.append(PersonalizedAdvice(
          id: UUID(),
          title: "ai.advice.risk.high.ratio.title",
          message: "ai.advice.risk.high.ratio.message",
          category: .risk,
          priority: .critical,
          actionable: true,
          potentialSavings: totalExpenses * 0.15,
          metadata: ["ratio": String(format: "%.0f%%", ratio * 100)]
        ))
      }
    }

    return advice
  }
}

// MARK: - Models

struct MonthlyData {
  let values: [Double]
  let average: Double
}

struct ExpensePrediction {
  let category: TransactionCategory
  let predictions: [MonthlyPrediction]
  let historicalAverage: Double
  let trendSlope: Double
  let dataPoints: Int
}

struct MonthlyPrediction {
  let month: Int
  let predictedAmount: Double
  let confidence: Double
  let trend: SpendingTrend

  var monthName: String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "pt_BR")
    dateFormatter.dateFormat = "MMMM"
    let calendar = Calendar.current
    let date = calendar.date(from: DateComponents(month: month))!
    return dateFormatter.string(from: date).capitalized
  }
}

struct TransactionAnomaly: Identifiable {
  let id = UUID()
  let transaction: Transaction
  let type: AnomalyType
  let severity: AnomalySeverity
  let zScore: Double
  let expectedRange: (Double, Double)
  let explanation: String
}

enum AnomalyType {
  case unusualAmount
  case frequencySpike
  case unusualTiming
  case potentialDuplicate

  var displayName: String {
    switch self {
    case .unusualAmount: return String(localized: "ai.anomaly.type.amount")
    case .frequencySpike: return String(localized: "ai.anomaly.type.frequency")
    case .unusualTiming: return String(localized: "ai.anomaly.type.timing")
    case .potentialDuplicate: return String(localized: "ai.anomaly.type.duplicate")
    }
  }

  var icon: String {
    switch self {
    case .unusualAmount: return "exclamationmark.triangle"
    case .frequencySpike: return "chart.line.uptrend.xyaxis"
    case .unusualTiming: return "clock.badge.exclamationmark"
    case .potentialDuplicate: return "doc.on.doc"
    }
  }
}

enum AnomalySeverity: Int {
  case low = 0
  case medium = 1
  case high = 2

  var displayName: String {
    switch self {
    case .low: return String(localized: "severity.low")
    case .medium: return String(localized: "severity.medium")
    case .high: return String(localized: "severity.high")
    }
  }

  var color: String {
    switch self {
    case .low: return "yellow"
    case .medium: return "orange"
    case .high: return "red"
    }
  }
}

struct BudgetSuggestion: Identifiable {
  let id = UUID()
  let category: TransactionCategory
  let suggestedAmount: Double
  let currentAmount: Double?
  let averageSpending: Double
  let medianSpending: Double
  let percentile90: Double
  let confidence: Double
  let reasoning: String
  let impactLevel: ImpactLevel
}

enum ImpactLevel: Int {
  case low = 0
  case medium = 1
  case high = 2

  var displayName: String {
    switch self {
    case .low: return String(localized: "impact.low")
    case .medium: return String(localized: "impact.medium")
    case .high: return String(localized: "impact.high")
    }
  }
}

struct PersonalizedAdvice: Identifiable {
  let id: UUID
  let title: String
  let message: String
  let category: AdviceCategory
  let priority: AdvicePriority
  let actionable: Bool
  let potentialSavings: Double
  var metadata: [String: String] = [:]
}

enum AdviceCategory {
  case spending
  case budgeting
  case goals
  case savings
  case income
  case risk

  var displayName: String {
    switch self {
    case .spending: return String(localized: "ai.advice.category.spending")
    case .budgeting: return String(localized: "ai.advice.category.budgeting")
    case .goals: return String(localized: "ai.advice.category.goals")
    case .savings: return String(localized: "ai.advice.category.savings")
    case .income: return String(localized: "ai.advice.category.income")
    case .risk: return String(localized: "ai.advice.category.risk")
    }
  }

  var icon: String {
    switch self {
    case .spending: return "creditcard"
    case .budgeting: return "chart.pie"
    case .goals: return "target"
    case .savings: return "dollarsign.circle"
    case .income: return "banknote"
    case .risk: return "shield"
    }
  }
}

enum AdvicePriority: Int {
  case low = 0
  case medium = 1
  case high = 2
  case critical = 3
}
