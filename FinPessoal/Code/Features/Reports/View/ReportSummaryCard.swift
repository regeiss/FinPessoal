//
//  ReportSummaryCard.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/09/25.
//

import SwiftUI

struct ReportSummaryCard: View {
  let summary: ReportSummary
  
  var body: some View {
    VStack(spacing: 16) {
      // Header
      HStack {
        Text(String(localized: "reports.overview"))
          .font(.headline)
          .foregroundColor(.primary)
        Spacer()
      }
      
      // Main metrics
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
        MetricView(
          title: String(localized: "reports.total.income"),
          value: summary.totalIncome,
          color: .green,
          icon: "arrow.up.circle.fill"
        )
        
        MetricView(
          title: String(localized: "reports.total.expenses"),
          value: summary.totalExpenses,
          color: .red,
          icon: "arrow.down.circle.fill"
        )
        
        MetricView(
          title: String(localized: "reports.net.income"),
          value: summary.netIncome,
          color: summary.netIncome >= 0 ? .green : .red,
          icon: summary.netIncome >= 0 ? "plus.circle.fill" : "minus.circle.fill"
        )
        
        SavingsRateView(rate: summary.savingsRate)
      }
      
      Divider()
      
      // Additional metrics
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(String(localized: "reports.transaction.count"))
            .font(.caption)
            .foregroundColor(.secondary)
          Text("\(summary.transactionCount)")
            .font(.subheadline)
            .fontWeight(.medium)
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 4) {
          Text(String(localized: "reports.average.daily.spending"))
            .font(.caption)
            .foregroundColor(.secondary)
          Text(NumberFormatter.currency.string(from: NSNumber(value: summary.averageDailySpending)) ?? "R$ 0")
            .font(.subheadline)
            .fontWeight(.medium)
        }
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
  }
}

struct MetricView: View {
  let title: String
  let value: Double
  let color: Color
  let icon: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: icon)
          .foregroundColor(color)
          .font(.system(size: 16, weight: .medium))
        
        Text(title)
          .font(.caption)
          .foregroundColor(.secondary)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
      }
      
      Text(NumberFormatter.currency.string(from: NSNumber(value: value)) ?? "R$ 0")
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .foregroundColor(.primary)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(12)
    .background(color.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}

struct SavingsRateView: View {
  let rate: Double
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: rate >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
          .foregroundColor(rate >= 20 ? .green : rate >= 0 ? .orange : .red)
          .font(.system(size: 16, weight: .medium))
        
        Text(String(localized: "reports.savings.rate"))
          .font(.caption)
          .foregroundColor(.secondary)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
      }
      
      HStack(spacing: 4) {
        Text("\(Int(rate.rounded()))")
          .font(.system(size: 18, weight: .semibold, design: .rounded))
          .foregroundColor(.primary)
        Text("%")
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(12)
    .background((rate >= 20 ? Color.green : rate >= 0 ? Color.orange : Color.red).opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}

#Preview {
  ReportSummaryCard(summary: ReportSummary(
    totalIncome: 5000,
    totalExpenses: 3500,
    netIncome: 1500,
    savingsRate: 30,
    transactionCount: 45,
    averageDailySpending: 116.67
  ))
  .padding()
}