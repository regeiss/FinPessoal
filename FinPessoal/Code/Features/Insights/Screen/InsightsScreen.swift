//
//  InsightsScreen.swift
//  FinPessoal
//
//  Created by Claude Code on 29/10/25.
//

import SwiftUI

struct InsightsScreen: View {
  @StateObject private var viewModel = InsightsViewModel()
  @EnvironmentObject var financeViewModel: FinanceViewModel

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 20) {
        if viewModel.isLoading {
          ProgressView()
            .scaleEffect(1.5)
            .padding(.top, 60)
        } else if viewModel.insights.isEmpty {
          emptyStateView
        } else {
          // Filter chips
          filterSection

          // Critical insights
          criticalInsightsSection

          // Budget predictions
          budgetPredictionsSection

          // Spending patterns
          spendingPatternsSection

          // All insights
          insightsSection
        }
      }
      .padding()
    }
    .coordinateSpace(name: "scroll")
    .navigationTitle(String(localized: "insights.title"))
    .blurredNavigationBar()
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          viewModel.loadInsights(
            transactions: financeViewModel.transactions,
            budgets: financeViewModel.budgets,
            goals: financeViewModel.goals
          )
        } label: {
          Image(systemName: "arrow.clockwise")
        }
      }
    }
    .onAppear {
      if viewModel.insights.isEmpty {
        viewModel.loadInsights(
          transactions: financeViewModel.transactions,
          budgets: financeViewModel.budgets,
          goals: financeViewModel.goals
        )
      }
    }
    .refreshable {
      viewModel.loadInsights(
        transactions: financeViewModel.transactions,
        budgets: financeViewModel.budgets,
        goals: financeViewModel.goals
      )
    }
  }

  // MARK: - Empty State

  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "chart.line.uptrend.xyaxis")
        .font(.system(size: 60))
        .foregroundColor(.blue)

      Text(String(localized: "insights.empty.title"))
        .font(.title2)
        .fontWeight(.semibold)

      Text(String(localized: "insights.empty.message"))
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding(.horizontal)
    }
    .padding(.top, 60)
  }

  // MARK: - Filter Section

  private var filterSection: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        FilterChip(
          title: String(localized: "common.all"),
          isSelected: viewModel.selectedCategory == nil
        ) {
          viewModel.filterByCategory(nil)
        }

        FilterChip(
          title: InsightCategory.spending.displayName,
          isSelected: viewModel.selectedCategory == .spending
        ) {
          viewModel.filterByCategory(.spending)
        }

        FilterChip(
          title: InsightCategory.budget.displayName,
          isSelected: viewModel.selectedCategory == .budget
        ) {
          viewModel.filterByCategory(.budget)
        }

        FilterChip(
          title: InsightCategory.goals.displayName,
          isSelected: viewModel.selectedCategory == .goals
        ) {
          viewModel.filterByCategory(.goals)
        }

        FilterChip(
          title: InsightCategory.savings.displayName,
          isSelected: viewModel.selectedCategory == .savings
        ) {
          viewModel.filterByCategory(.savings)
        }
      }
    }
  }

  // MARK: - Critical Insights

  private var criticalInsightsSection: some View {
    let criticalInsights = viewModel.filteredInsights.filter { $0.priority == .critical || $0.priority == .high }

    return Group {
      if !criticalInsights.isEmpty {
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Image(systemName: "exclamationmark.triangle.fill")
              .foregroundColor(.red)
            Text(String(localized: "insights.critical.title"))
              .font(.headline)
              .fontWeight(.semibold)
          }

          ForEach(criticalInsights) { insight in
            InsightCard(insight: insight)
          }
        }
      }
    }
  }

  // MARK: - Budget Predictions

  private var budgetPredictionsSection: some View {
    let highRiskPredictions = viewModel.budgetPredictions.filter {
      $0.riskLevel == .high || $0.riskLevel == .critical
    }

    return Group {
      if !highRiskPredictions.isEmpty && (viewModel.selectedCategory == nil || viewModel.selectedCategory == .budget) {
        VStack(alignment: .leading, spacing: 12) {
          Text(String(localized: "insights.predictions.title"))
            .font(.headline)
            .fontWeight(.semibold)

          ForEach(highRiskPredictions, id: \.budget.id) { prediction in
            BudgetPredictionCard(prediction: prediction)
          }
        }
      }
    }
  }

  // MARK: - Spending Patterns

  private var spendingPatternsSection: some View {
    Group {
      if !viewModel.spendingPatterns.isEmpty && (viewModel.selectedCategory == nil || viewModel.selectedCategory == .spending) {
        VStack(alignment: .leading, spacing: 12) {
          Text(String(localized: "insights.patterns.title"))
            .font(.headline)
            .fontWeight(.semibold)

          ForEach(viewModel.spendingPatterns.prefix(5), id: \.category) { pattern in
            SpendingPatternCard(pattern: pattern)
          }
        }
      }
    }
  }

  // MARK: - All Insights

  private var insightsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(String(localized: "insights.all.title"))
        .font(.headline)
        .fontWeight(.semibold)

      ForEach(viewModel.filteredInsights) { insight in
        InsightCard(insight: insight)
      }
    }
  }
}

// MARK: - Insight Card

struct InsightCard: View {
  let insight: FinancialInsight

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: insight.type.icon)
        .font(.title2)
        .foregroundColor(colorForType(insight.type))
        .frame(width: 44, height: 44)
        .background(colorForType(insight.type).opacity(0.15))
        .cornerRadius(12)

      VStack(alignment: .leading, spacing: 6) {
        Text(String(localized: LocalizedStringResource(stringLiteral: insight.title)))
          .font(.headline)
          .fontWeight(.semibold)

        Text(formatMessage(insight))
          .font(.subheadline)
          .foregroundColor(.secondary)

        if insight.actionable {
          Text(String(localized: "insights.actionable"))
            .font(.caption)
            .foregroundColor(.blue)
            .padding(.top, 4)
        }
      }

      Spacer()

      if insight.value > 0 {
        VStack(alignment: .trailing) {
          Text(formatValue(insight))
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(colorForType(insight.type))
        }
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }

  private func colorForType(_ type: InsightType) -> Color {
    switch type.color {
    case "green": return .green
    case "orange": return .orange
    case "blue": return .blue
    default: return .gray
    }
  }

  private func formatMessage(_ insight: FinancialInsight) -> String {
    var message = String(localized: LocalizedStringResource(stringLiteral: insight.message))

    // Replace placeholders with metadata
    for (key, value) in insight.metadata {
      message = message.replacingOccurrences(of: "{\(key)}", with: value)
    }

    message = message.replacingOccurrences(of: "{value}", with: formatValue(insight))

    return message
  }

  private func formatValue(_ insight: FinancialInsight) -> String {
    switch insight.category {
    case .spending, .budget, .savings:
      return formatCurrency(insight.value)
    case .goals:
      return "\(Int(insight.value))%"
    }
  }

  private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }
}

// MARK: - Budget Prediction Card

struct BudgetPredictionCard: View {
  let prediction: BudgetPrediction

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(prediction.budget.name)
            .font(.headline)
            .fontWeight(.semibold)

          Text(String(localized: "insights.days.remaining", defaultValue: "\(prediction.daysRemaining) dias restantes"))
            .font(.caption)
            .foregroundColor(.secondary)
        }

        Spacer()

        Text(prediction.riskLevel.displayName)
          .font(.caption)
          .fontWeight(.semibold)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(colorForRisk(prediction.riskLevel).opacity(0.2))
          .foregroundColor(colorForRisk(prediction.riskLevel))
          .cornerRadius(8)
      }

      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(String(localized: "insights.current"))
            .font(.caption)
            .foregroundColor(.secondary)
          Text(formatCurrency(prediction.currentSpent))
            .font(.subheadline)
            .fontWeight(.semibold)
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 4) {
          Text(String(localized: "insights.projected"))
            .font(.caption)
            .foregroundColor(.secondary)
          Text(formatCurrency(prediction.projectedTotal))
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(colorForRisk(prediction.riskLevel))
        }
      }

      ProgressView(value: prediction.projectedTotal, total: prediction.budget.budgetAmount)
        .tint(colorForRisk(prediction.riskLevel))

      Text(String(localized: LocalizedStringResource(stringLiteral: prediction.recommendation)))
        .font(.caption)
        .foregroundColor(.secondary)
        .italic()
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }

  private func colorForRisk(_ risk: RiskLevel) -> Color {
    switch risk.color {
    case "green": return .green
    case "yellow": return .yellow
    case "orange": return .orange
    case "red": return .red
    default: return .gray
    }
  }

  private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }
}

// MARK: - Spending Pattern Card

struct SpendingPatternCard: View {
  let pattern: SpendingPattern

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: pattern.category.icon)
        .font(.title3)
        .foregroundColor(pattern.category.swiftUIColor)
        .frame(width: 40, height: 40)
        .background(pattern.category.swiftUIColor.opacity(0.15))
        .cornerRadius(10)

      VStack(alignment: .leading, spacing: 4) {
        Text(pattern.category.displayName)
          .font(.headline)
          .fontWeight(.semibold)

        HStack(spacing: 12) {
          Label("\(pattern.frequency)", systemImage: "number")
            .font(.caption)
            .foregroundColor(.secondary)

          Label(pattern.trend.displayName, systemImage: pattern.trend.icon)
            .font(.caption)
            .foregroundColor(colorForTrend(pattern.trend))
        }
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 4) {
        Text(formatCurrency(pattern.totalSpent))
          .font(.headline)
          .fontWeight(.bold)

        Text(pattern.budgetStatus.displayName)
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }

  private func colorForTrend(_ trend: SpendingTrend) -> Color {
    switch trend.color {
    case "red": return .red
    case "green": return .green
    case "blue": return .blue
    default: return .gray
    }
  }

  private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }
}

#Preview {
  NavigationStack {
    InsightsScreen()
      .environmentObject(FinanceViewModel(financeRepository: MockFinanceRepository()))
  }
}
