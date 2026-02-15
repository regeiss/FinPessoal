//
//  BudgetPerformanceView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/09/25.
//

import SwiftUI

struct BudgetPerformanceView: View {
  let budgetPerformance: [BudgetPerformance]
  let showingChart: Bool
  let isLoading: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(String(localized: "reports.budget.performance"))
        .font(.headline)
        .foregroundColor(.primary)
        .accessibilityAddTraits(.isHeader)

      if isLoading {
        HStack(alignment: .bottom, spacing: 12) {
          ForEach(0..<4, id: \.self) { _ in
            SkeletonView()
              .frame(width: 40, height: CGFloat.random(in: 60...200))
              .cornerRadius(8)
          }
        }
        .frame(height: 200)
        .accessibilityLabel("Loading budget performance chart")
      } else if budgetPerformance.isEmpty {
        EmptyStateView(
          icon: "chart.bar",
          title: "reports.empty.title",
          subtitle: "reports.empty.subtitle"
        )
        .frame(height: 200)
        .accessibilityLabel("No budget performance data")
        .accessibilityHint("Create budgets to see budget performance tracking")
      } else if showingChart {
        BudgetPerformanceChartView(budgetPerformance: budgetPerformance)
      } else {
        BudgetPerformanceTableView(budgetPerformance: budgetPerformance)
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
  }
}

struct BudgetPerformanceChartView: View {
  let budgetPerformance: [BudgetPerformance]

  private var budgetBars: [ChartBar] {
    guard !budgetPerformance.isEmpty else { return [] }

    let maxAmount = budgetPerformance.map { $0.spentAmount }.max() ?? 0
    return budgetPerformance.map { budget in
      ChartBar(
        id: budget.category.rawValue,
        value: budget.spentAmount,
        maxValue: maxAmount,
        label: budget.category.displayName,
        color: budget.category.swiftUIColor,
        date: nil
      )
    }
  }

  private var chartDescription: String {
    budgetPerformance.map { budget in
      let spentStr = NumberFormatter.currency.string(from: NSNumber(value: budget.spentAmount)) ?? "R$ 0"
      let budgetStr = NumberFormatter.currency.string(from: NSNumber(value: budget.budgetAmount)) ?? "R$ 0"
      return "\(budget.category.displayName): \(spentStr) of \(budgetStr)"
    }.joined(separator: ". ")
  }

  var body: some View {
    VStack(spacing: 16) {
      if !budgetBars.isEmpty {
        BarChart(
          bars: budgetBars,
          maxHeight: 200
        )
        .frame(height: 250)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .animation(AnimationEngine.easeInOut, value: budgetPerformance.count)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Budget performance bar chart")
        .accessibilityValue(chartDescription)
        .accessibilityHint("Shows spending for each budget category")
      } else {
        VStack(spacing: 16) {
          Image(systemName: "chart.bar.fill")
            .font(.system(size: 48))
            .foregroundStyle(.secondary)
          Text("No budget data")
            .font(.headline)
          Text("Create budgets to track spending performance")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(height: 250)
      }
    }
  }
}

struct BudgetPerformanceBar: View {
  let performance: BudgetPerformance

  private var fillPercentage: Double {
    min(performance.percentage / 100.0, 1.0)
  }

  private var barColor: Color {
    if performance.percentage >= 100 {
      return .red
    } else if performance.percentage >= 80 {
      return .orange
    } else {
      return .green
    }
  }

  private var statusDescription: String {
    if performance.percentage >= 100 {
      return "over budget"
    } else if performance.percentage >= 80 {
      return "approaching budget limit"
    } else {
      return "within budget"
    }
  }

  private var spentString: String {
    NumberFormatter.currency.string(from: NSNumber(value: performance.spentAmount)) ?? "R$ 0"
  }

  private var budgetString: String {
    NumberFormatter.currency.string(from: NSNumber(value: performance.budgetAmount)) ?? "R$ 0"
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // Header with category and percentage
      HStack {
        HStack(spacing: 8) {
          Image(systemName: performance.category.icon)
            .font(.system(size: 14))
            .foregroundColor(barColor)
            .accessibilityHidden(true)

          Text(performance.category.displayName)
            .font(.subheadline)
            .fontWeight(.medium)
        }

        Spacer()

        Text("\(Int(performance.percentage.rounded()))%")
          .font(.subheadline)
          .fontWeight(.semibold)
          .foregroundColor(barColor)
      }

      // Progress bar
      ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color(.systemGray5))
          .frame(height: 24)
          .accessibilityHidden(true)

        RoundedRectangle(cornerRadius: 8)
          .fill(barColor)
          .frame(width: fillPercentage * 300, height: 24)
          .animation(.easeInOut(duration: 1.0), value: fillPercentage)
          .accessibilityHidden(true)
      }
      .frame(maxWidth: 300)
      
      // Amount details
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text(String(localized: "reports.spent"))
            .font(.caption)
            .foregroundColor(.secondary)

          Text(spentString)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(barColor)
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 2) {
          Text(String(localized: "reports.budget"))
            .font(.caption)
            .foregroundColor(.secondary)

          Text(budgetString)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.primary)
        }
      }
    }
    .padding()
    .background(barColor.opacity(0.05))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(performance.category.displayName) budget")
    .accessibilityValue("\(Int(performance.percentage.rounded())) percent used, \(spentString) spent of \(budgetString) budget, \(statusDescription)")
    .accessibilityHint("Budget performance indicator")
  }
}

struct BudgetPerformanceTableView: View {
  let budgetPerformance: [BudgetPerformance]

  var body: some View {
    VStack(spacing: 0) {
      // Header
      HStack {
        Text(String(localized: "reports.category"))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, alignment: .leading)

        Text(String(localized: "reports.budget"))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.secondary)
          .frame(width: 70, alignment: .trailing)

        Text(String(localized: "reports.spent"))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.secondary)
          .frame(width: 70, alignment: .trailing)

        Text(String(localized: "reports.usage"))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.secondary)
          .frame(width: 60, alignment: .trailing)
      }
      .padding(.vertical, 8)
      .padding(.horizontal, 4)
      .accessibilityElement(children: .combine)
      .accessibilityAddTraits(.isHeader)
      .accessibilityLabel("Budget performance table: category, budget, spent, usage percentage")
      
      Divider()
      
      // Rows
      LazyVStack(spacing: 0) {
        ForEach(budgetPerformance, id: \.category) { performance in
          BudgetPerformanceRow(performance: performance)
          
          if performance.category != budgetPerformance.last?.category {
            Divider()
              .padding(.leading, 40)
          }
        }
      }
    }
  }
}

struct BudgetPerformanceRow: View {
  let performance: BudgetPerformance

  private var statusColor: Color {
    if performance.percentage >= 100 {
      return .red
    } else if performance.percentage >= 80 {
      return .orange
    } else {
      return .green
    }
  }

  private var statusDescription: String {
    if performance.percentage >= 100 {
      return "over budget"
    } else if performance.percentage >= 80 {
      return "approaching limit"
    } else {
      return "within budget"
    }
  }

  private var budgetString: String {
    NumberFormatter.currency.string(from: NSNumber(value: performance.budgetAmount)) ?? "R$ 0"
  }

  private var spentString: String {
    NumberFormatter.currency.string(from: NSNumber(value: performance.spentAmount)) ?? "R$ 0"
  }

  var body: some View {
    HStack {
      HStack(spacing: 8) {
        Circle()
          .fill(statusColor)
          .frame(width: 8, height: 8)
          .accessibilityHidden(true)

        Image(systemName: performance.category.icon)
          .font(.system(size: 14))
          .foregroundColor(statusColor)
          .frame(width: 20)
          .accessibilityHidden(true)

        Text(performance.category.displayName)
          .font(.subheadline)
          .fontWeight(.medium)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Text(budgetString)
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.secondary)
        .frame(width: 70, alignment: .trailing)

      Text(spentString)
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(statusColor)
        .frame(width: 70, alignment: .trailing)

      Text("\(Int(performance.percentage.rounded()))%")
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundColor(statusColor)
        .frame(width: 60, alignment: .trailing)
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 4)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(performance.category.displayName)
    .accessibilityValue("\(Int(performance.percentage.rounded())) percent, budget \(budgetString), spent \(spentString), \(statusDescription)")
  }
}

#Preview {
  BudgetPerformanceView(
    budgetPerformance: [
      BudgetPerformance(category: .food, budgetAmount: 1000, spentAmount: 1200, remainingAmount: -200, percentage: 120),
      BudgetPerformance(category: .transport, budgetAmount: 500, spentAmount: 450, remainingAmount: 50, percentage: 90),
      BudgetPerformance(category: .shopping, budgetAmount: 800, spentAmount: 600, remainingAmount: 200, percentage: 75),
      BudgetPerformance(category: .bills, budgetAmount: 1200, spentAmount: 800, remainingAmount: 400, percentage: 67)
    ],
    showingChart: true,
    isLoading: false
  )
  .padding()
}