//
//  MonthlyTrendsView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/09/25.
//

import SwiftUI

struct MonthlyTrendsView: View {
  let monthlyTrends: [MonthlyTrend]
  let showingChart: Bool
  let isLoading: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(String(localized: "reports.monthly.trends"))
        .font(.headline)
        .foregroundColor(.primary)
        .accessibilityAddTraits(.isHeader)

      if isLoading {
        HStack(alignment: .bottom, spacing: 12) {
          ForEach(0..<6, id: \.self) { _ in
            SkeletonView()
              .frame(width: 40, height: CGFloat.random(in: 60...200))
              .cornerRadius(8)
          }
        }
        .frame(height: 200)
        .accessibilityLabel("Loading monthly trends chart")
      } else if monthlyTrends.isEmpty {
        EmptyStateView(
          icon: "chart.line.uptrend.xyaxis",
          title: "reports.empty.title",
          subtitle: "reports.empty.subtitle"
        )
        .frame(height: 200)
        .accessibilityLabel("No monthly trends data")
        .accessibilityHint("Add transactions to see monthly income and expense trends")
      } else if showingChart {
        MonthlyTrendsChartView(monthlyTrends: monthlyTrends)
      } else {
        MonthlyTrendsTableView(monthlyTrends: monthlyTrends)
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
  }
}

struct MonthlyTrendsChartView: View {
  let monthlyTrends: [MonthlyTrend]

  private var monthlyBars: [ChartBar] {
    guard !monthlyTrends.isEmpty else { return [] }

    let maxAmount = monthlyTrends.map { $0.expenses }.max() ?? 0
    return monthlyTrends.map { $0.toChartBar(maxAmount: maxAmount) }
  }

  private var chartDescription: String {
    monthlyTrends.map { trend in
      let expensesStr = NumberFormatter.currency.string(from: NSNumber(value: trend.expenses)) ?? "R$ 0"
      return "\(trend.month): \(expensesStr)"
    }.joined(separator: ". ")
  }

  var body: some View {
    VStack(spacing: 16) {
      if !monthlyBars.isEmpty {
        BarChart(
          bars: monthlyBars,
          maxHeight: 200
        )
        .frame(height: 250)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .animation(AnimationEngine.easeInOut, value: monthlyTrends.count)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Monthly trends bar chart")
        .accessibilityValue(chartDescription)
        .accessibilityHint("Shows expenses for each month")
      } else {
        VStack(spacing: 16) {
          Image(systemName: "chart.bar")
            .font(.system(size: 48))
            .foregroundStyle(.secondary)
          Text("No trend data")
            .font(.headline)
          Text("Track expenses over time to see monthly trends")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(height: 250)
      }
    }
  }
}


struct MonthlyTrendsTableView: View {
  let monthlyTrends: [MonthlyTrend]

  var body: some View {
    VStack(spacing: 0) {
      // Header
      HStack {
        Text(String(localized: "reports.month"))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, alignment: .leading)

        Text(String(localized: "reports.income"))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.secondary)
          .frame(width: 80, alignment: .trailing)

        Text(String(localized: "reports.expenses"))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.secondary)
          .frame(width: 80, alignment: .trailing)

        Text(String(localized: "reports.net"))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.secondary)
          .frame(width: 80, alignment: .trailing)
      }
      .padding(.vertical, 8)
      .padding(.horizontal, 4)
      .accessibilityElement(children: .combine)
      .accessibilityAddTraits(.isHeader)
      .accessibilityLabel("Monthly trends table: month, income, expenses, net income")
      
      Divider()
      
      // Rows
      LazyVStack(spacing: 0) {
        ForEach(Array(monthlyTrends.enumerated()), id: \.offset) { index, trend in
          MonthlyTrendRow(trend: trend)
          
          if index < monthlyTrends.count - 1 {
            Divider()
          }
        }
      }
    }
  }
}

struct MonthlyTrendRow: View {
  let trend: MonthlyTrend

  private var incomeString: String {
    NumberFormatter.currency.string(from: NSNumber(value: trend.income)) ?? "R$ 0"
  }

  private var expensesString: String {
    NumberFormatter.currency.string(from: NSNumber(value: trend.expenses)) ?? "R$ 0"
  }

  private var netIncomeString: String {
    NumberFormatter.currency.string(from: NSNumber(value: trend.netIncome)) ?? "R$ 0"
  }

  var body: some View {
    HStack {
      Text(trend.month)
        .font(.subheadline)
        .fontWeight(.medium)
        .frame(maxWidth: .infinity, alignment: .leading)

      Text(incomeString)
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.green)
        .frame(width: 80, alignment: .trailing)

      Text(expensesString)
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.red)
        .frame(width: 80, alignment: .trailing)

      Text(netIncomeString)
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(trend.netIncome >= 0 ? .blue : .orange)
        .frame(width: 80, alignment: .trailing)
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 4)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(trend.month)
    .accessibilityValue("Income \(incomeString), Expenses \(expensesString), Net income \(netIncomeString)")
  }
}

#Preview {
  MonthlyTrendsView(
    monthlyTrends: [
      MonthlyTrend(month: "Jan 2024", income: 5000, expenses: 3500, netIncome: 1500),
      MonthlyTrend(month: "Feb 2024", income: 5200, expenses: 3800, netIncome: 1400),
      MonthlyTrend(month: "Mar 2024", income: 4800, expenses: 4200, netIncome: 600),
      MonthlyTrend(month: "Apr 2024", income: 5500, expenses: 3200, netIncome: 2300),
      MonthlyTrend(month: "May 2024", income: 5000, expenses: 3600, netIncome: 1400)
    ],
    showingChart: true,
    isLoading: false
  )
  .padding()
}