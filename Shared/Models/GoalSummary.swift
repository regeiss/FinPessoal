//
//  GoalSummary.swift
//  FinPessoal
//
//  Created by Claude Code on 16/12/25.
//

import Foundation

/// Lightweight goal data for widget display
struct GoalSummary: Codable, Identifiable {
  let id: String
  let name: String
  let currentAmount: Double
  let targetAmount: Double
  let targetDate: Date?
  let categoryIcon: String

  // MARK: - Computed Properties

  var percentage: Double {
    guard targetAmount > 0 else { return 0 }
    return min(100, (currentAmount / targetAmount) * 100)
  }

  var remaining: Double {
    max(0, targetAmount - currentAmount)
  }

  var isCompleted: Bool {
    currentAmount >= targetAmount
  }

  var daysRemaining: Int? {
    guard let targetDate = targetDate else { return nil }
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let target = calendar.startOfDay(for: targetDate)
    return max(0, calendar.dateComponents([.day], from: today, to: target).day ?? 0)
  }

  var monthlyContributionNeeded: Double? {
    guard !isCompleted, let days = daysRemaining, days > 0 else { return nil }
    let monthsLeft = max(1, Double(days) / 30.0)
    return remaining / monthsLeft
  }

  // MARK: - Accessibility

  var accessibilityLabel: String {
    let progressText = "\(Int(percentage))% completo"
    let remainingText = "faltam \(formattedRemaining)"
    return "\(name), \(progressText), \(remainingText)"
  }

  var formattedCurrentAmount: String {
    formatCurrency(currentAmount)
  }

  var formattedTargetAmount: String {
    formatCurrency(targetAmount)
  }

  var formattedRemaining: String {
    formatCurrency(remaining)
  }

  var formattedMonthlyContribution: String? {
    guard let contribution = monthlyContributionNeeded else { return nil }
    return formatCurrency(contribution)
  }

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
  }
}
