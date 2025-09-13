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
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(String(localized: "reports.monthly.trends"))
        .font(.headline)
        .foregroundColor(.primary)
      
      if monthlyTrends.isEmpty {
        EmptyStateView(
          icon: "chart.line.uptrend.xyaxis",
          title: "reports.empty.title",
          subtitle: "reports.empty.subtitle"
        )
        .frame(height: 200)
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
  
  private let maxValue: Double
  
  init(monthlyTrends: [MonthlyTrend]) {
    self.monthlyTrends = monthlyTrends
    
    let allValues = monthlyTrends.flatMap { [abs($0.income), abs($0.expenses), abs($0.netIncome)] }
    self.maxValue = allValues.max() ?? 1000
  }
  
  var body: some View {
    VStack(spacing: 16) {
      // Legend
      HStack(spacing: 20) {
        LegendItem(color: .green, title: String(localized: "reports.income"))
        LegendItem(color: .red, title: String(localized: "reports.expenses"))
        LegendItem(color: .blue, title: String(localized: "reports.net.income"))
      }
      .font(.caption)
      
      // Chart
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .bottom, spacing: 12) {
          ForEach(monthlyTrends, id: \.month) { trend in
            MonthlyTrendBar(
              trend: trend,
              maxValue: maxValue
            )
          }
        }
        .padding(.horizontal)
      }
      .frame(height: 200)
    }
  }
}

struct LegendItem: View {
  let color: Color
  let title: String
  
  var body: some View {
    HStack(spacing: 4) {
      Circle()
        .fill(color)
        .frame(width: 8, height: 8)
      
      Text(title)
        .foregroundColor(.secondary)
    }
  }
}

struct MonthlyTrendBar: View {
  let trend: MonthlyTrend
  let maxValue: Double
  
  private var incomeHeight: CGFloat {
    CGFloat(trend.income / maxValue) * 160
  }
  
  private var expensesHeight: CGFloat {
    CGFloat(trend.expenses / maxValue) * 160
  }
  
  private var netIncomeHeight: CGFloat {
    CGFloat(abs(trend.netIncome) / maxValue) * 160
  }
  
  var body: some View {
    VStack(spacing: 8) {
      // Bars
      HStack(alignment: .bottom, spacing: 4) {
        // Income bar
        Rectangle()
          .fill(Color.green)
          .frame(width: 16, height: max(incomeHeight, 4))
          .clipShape(RoundedRectangle(cornerRadius: 2))
          .animation(.easeInOut(duration: 0.8), value: incomeHeight)
        
        // Expenses bar
        Rectangle()
          .fill(Color.red)
          .frame(width: 16, height: max(expensesHeight, 4))
          .clipShape(RoundedRectangle(cornerRadius: 2))
          .animation(.easeInOut(duration: 0.8), value: expensesHeight)
        
        // Net income bar
        Rectangle()
          .fill(trend.netIncome >= 0 ? Color.blue : Color.orange)
          .frame(width: 16, height: max(netIncomeHeight, 4))
          .clipShape(RoundedRectangle(cornerRadius: 2))
          .animation(.easeInOut(duration: 0.8), value: netIncomeHeight)
      }
      .frame(height: 160)
      
      // Month label
      Text(trend.month)
        .font(.caption2)
        .fontWeight(.medium)
        .foregroundColor(.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(width: 60)
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
  
  var body: some View {
    HStack {
      Text(trend.month)
        .font(.subheadline)
        .fontWeight(.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      Text(NumberFormatter.currency.string(from: NSNumber(value: trend.income)) ?? "R$ 0")
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.green)
        .frame(width: 80, alignment: .trailing)
      
      Text(NumberFormatter.currency.string(from: NSNumber(value: trend.expenses)) ?? "R$ 0")
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.red)
        .frame(width: 80, alignment: .trailing)
      
      Text(NumberFormatter.currency.string(from: NSNumber(value: trend.netIncome)) ?? "R$ 0")
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(trend.netIncome >= 0 ? .blue : .orange)
        .frame(width: 80, alignment: .trailing)
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 4)
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
    showingChart: true
  )
  .padding()
}