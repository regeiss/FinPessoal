//
//  AIInsightsScreen.swift
//  FinPessoal
//
//  Created by Claude Code on 29/10/25.
//

import SwiftUI

struct AIInsightsScreen: View {
  @StateObject private var viewModel = InsightsViewModel()
  @EnvironmentObject var financeViewModel: FinanceViewModel

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 20) {
        if viewModel.isLoading {
          ProgressView()
            .scaleEffect(1.5)
            .padding(.top, 60)
        } else if viewModel.expensePredictions.isEmpty {
          emptyStateView
        } else {
          // Personalized Advice Section
          personalizedAdviceSection

          // Anomalies Section
          anomaliesSection

          // Expense Predictions Section
          expensePredictionsSection

          // Budget Suggestions Section
          budgetSuggestionsSection
        }
      }
      .padding()
    }
    .navigationTitle(String(localized: "ai.insights.title"))
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          viewModel.loadAIInsights(
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
      if viewModel.expensePredictions.isEmpty {
        viewModel.loadAIInsights(
          transactions: financeViewModel.transactions,
          budgets: financeViewModel.budgets,
          goals: financeViewModel.goals
        )
      }
    }
    .refreshable {
      viewModel.loadAIInsights(
        transactions: financeViewModel.transactions,
        budgets: financeViewModel.budgets,
        goals: financeViewModel.goals
      )
    }
  }

  // MARK: - Empty State

  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "brain")
        .font(.system(size: 60))
        .foregroundColor(.purple)

      Text(String(localized: "ai.insights.empty.title"))
        .font(.title2)
        .fontWeight(.semibold)

      Text(String(localized: "ai.insights.empty.message"))
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding(.horizontal)
    }
    .padding(.top, 60)
  }

  // MARK: - Personalized Advice

  private var personalizedAdviceSection: some View {
    Group {
      if !viewModel.topAdvice.isEmpty {
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Image(systemName: "brain")
              .foregroundColor(.purple)
            Text(String(localized: "ai.advice.title"))
              .font(.headline)
              .fontWeight(.semibold)
          }

          ForEach(viewModel.topAdvice) { advice in
            PersonalizedAdviceCard(advice: advice)
          }
        }
      }
    }
  }

  // MARK: - Anomalies

  private var anomaliesSection: some View {
    Group {
      if !viewModel.criticalAnomalies.isEmpty {
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Image(systemName: "exclamationmark.triangle.fill")
              .foregroundColor(.red)
            Text(String(localized: "ai.anomalies.title"))
              .font(.headline)
              .fontWeight(.semibold)
          }

          ForEach(viewModel.criticalAnomalies) { anomaly in
            AnomalyCard(anomaly: anomaly)
          }
        }
      }
    }
  }

  // MARK: - Expense Predictions

  private var expensePredictionsSection: some View {
    Group {
      if !viewModel.expensePredictions.isEmpty {
        VStack(alignment: .leading, spacing: 12) {
          Text(String(localized: "ai.predictions.title"))
            .font(.headline)
            .fontWeight(.semibold)

          ForEach(viewModel.expensePredictions.prefix(5), id: \.category) { prediction in
            ExpensePredictionCard(prediction: prediction)
          }
        }
      }
    }
  }

  // MARK: - Budget Suggestions

  private var budgetSuggestionsSection: some View {
    Group {
      if !viewModel.budgetSuggestions.isEmpty {
        VStack(alignment: .leading, spacing: 12) {
          Text(String(localized: "ai.suggestions.title"))
            .font(.headline)
            .fontWeight(.semibold)

          ForEach(viewModel.budgetSuggestions.prefix(5)) { suggestion in
            BudgetSuggestionCard(suggestion: suggestion)
          }
        }
      }
    }
  }
}

// MARK: - Personalized Advice Card

struct PersonalizedAdviceCard: View {
  let advice: PersonalizedAdvice

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: advice.category.icon)
        .font(.title2)
        .foregroundColor(colorForPriority(advice.priority))
        .frame(width: 44, height: 44)
        .background(colorForPriority(advice.priority).opacity(0.15))
        .cornerRadius(12)

      VStack(alignment: .leading, spacing: 6) {
        Text(String(localized: LocalizedStringResource(stringLiteral: advice.title)))
          .font(.headline)
          .fontWeight(.semibold)

        Text(formatMessage(advice))
          .font(.subheadline)
          .foregroundColor(.secondary)

        if advice.potentialSavings > 0 {
          HStack {
            Image(systemName: "arrow.down.circle.fill")
              .foregroundColor(.green)
            Text(String(localized: "ai.advice.potential.savings", defaultValue: "Economia potencial: \(formatCurrency(advice.potentialSavings))"))
              .font(.caption)
              .fontWeight(.semibold)
              .foregroundColor(.green)
          }
          .padding(.top, 4)
        }
      }

      Spacer()

      if advice.actionable {
        Image(systemName: "chevron.right")
          .foregroundColor(.secondary)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }

  private func colorForPriority(_ priority: AdvicePriority) -> Color {
    switch priority {
    case .low: return .blue
    case .medium: return .orange
    case .high: return .red
    case .critical: return .purple
    }
  }

  private func formatMessage(_ advice: PersonalizedAdvice) -> String {
    var message = String(localized: LocalizedStringResource(stringLiteral: advice.message))

    for (key, value) in advice.metadata {
      message = message.replacingOccurrences(of: "{\(key)}", with: value)
    }

    return message
  }

  private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }
}

// MARK: - Anomaly Card

struct AnomalyCard: View {
  let anomaly: TransactionAnomaly

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: anomaly.type.icon)
          .foregroundColor(colorForSeverity(anomaly.severity))

        VStack(alignment: .leading, spacing: 4) {
          Text(anomaly.type.displayName)
            .font(.headline)
            .fontWeight(.semibold)

          Text(anomaly.transaction.description)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }

        Spacer()

        Text(anomaly.severity.displayName)
          .font(.caption)
          .fontWeight(.semibold)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(colorForSeverity(anomaly.severity).opacity(0.2))
          .foregroundColor(colorForSeverity(anomaly.severity))
          .cornerRadius(8)
      }

      Divider()

      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text(String(localized: "ai.anomaly.amount"))
            .font(.caption)
            .foregroundColor(.secondary)
          Text(formatCurrency(anomaly.transaction.amount))
            .font(.subheadline)
            .fontWeight(.semibold)
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 2) {
          Text(String(localized: "ai.anomaly.date"))
            .font(.caption)
            .foregroundColor(.secondary)
          Text(anomaly.transaction.date.formatted(date: .abbreviated, time: .omitted))
            .font(.subheadline)
            .fontWeight(.semibold)
        }
      }

      Text(String(localized: LocalizedStringResource(stringLiteral: anomaly.explanation)))
        .font(.caption)
        .foregroundColor(.secondary)
        .italic()
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }

  private func colorForSeverity(_ severity: AnomalySeverity) -> Color {
    switch severity.color {
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

// MARK: - Expense Prediction Card

struct ExpensePredictionCard: View {
  let prediction: ExpensePrediction

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: prediction.category.icon)
          .foregroundColor(prediction.category.swiftUIColor)
        Text(prediction.category.displayName)
          .font(.headline)
          .fontWeight(.semibold)

        Spacer()

        Text(String(localized: "ai.prediction.confidence", defaultValue: "\(Int(prediction.predictions[0].confidence * 100))% confiança"))
          .font(.caption)
          .foregroundColor(.secondary)
      }

      // Next 3 months predictions
      HStack(spacing: 12) {
        ForEach(prediction.predictions.prefix(3), id: \.month) { monthly in
          VStack(spacing: 4) {
            Text(monthly.monthName)
              .font(.caption)
              .foregroundColor(.secondary)

            Text(formatCurrency(monthly.predictedAmount))
              .font(.subheadline)
              .fontWeight(.semibold)

            Image(systemName: monthly.trend.icon)
              .font(.caption)
              .foregroundColor(colorForTrend(monthly.trend))
          }
          .frame(maxWidth: .infinity)
        }
      }

      HStack {
        Text(String(localized: "ai.prediction.historical"))
          .font(.caption)
          .foregroundColor(.secondary)

        Text(formatCurrency(prediction.historicalAverage))
          .font(.caption)
          .fontWeight(.semibold)

        Spacer()

        Text(String(localized: "ai.prediction.datapoints", defaultValue: "\(prediction.dataPoints) transações"))
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

// MARK: - Budget Suggestion Card

struct BudgetSuggestionCard: View {
  let suggestion: BudgetSuggestion

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: suggestion.category.icon)
          .foregroundColor(suggestion.category.swiftUIColor)

        VStack(alignment: .leading, spacing: 4) {
          Text(suggestion.category.displayName)
            .font(.headline)
            .fontWeight(.semibold)

          Text(String(localized: LocalizedStringResource(stringLiteral: suggestion.reasoning)))
            .font(.caption)
            .foregroundColor(.secondary)
        }

        Spacer()

        Text(suggestion.impactLevel.displayName)
          .font(.caption)
          .fontWeight(.semibold)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(colorForImpact(suggestion.impactLevel).opacity(0.2))
          .foregroundColor(colorForImpact(suggestion.impactLevel))
          .cornerRadius(8)
      }

      Divider()

      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(String(localized: "ai.suggestion.current"))
            .font(.caption)
            .foregroundColor(.secondary)
          Text(suggestion.currentAmount != nil ? formatCurrency(suggestion.currentAmount!) : "-")
            .font(.subheadline)
            .fontWeight(.semibold)
        }

        Spacer()

        Image(systemName: "arrow.right")
          .foregroundColor(.secondary)

        Spacer()

        VStack(alignment: .trailing, spacing: 4) {
          Text(String(localized: "ai.suggestion.suggested"))
            .font(.caption)
            .foregroundColor(.secondary)
          Text(formatCurrency(suggestion.suggestedAmount))
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.green)
        }
      }

      ProgressView(value: suggestion.confidence)
        .tint(.blue)

      Text(String(localized: "ai.suggestion.confidence", defaultValue: "Confiança: \(Int(suggestion.confidence * 100))%"))
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }

  private func colorForImpact(_ impact: ImpactLevel) -> Color {
    switch impact {
    case .low: return .blue
    case .medium: return .orange
    case .high: return .red
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
    AIInsightsScreen()
      .environmentObject(FinanceViewModel(financeRepository: MockFinanceRepository()))
  }
}
