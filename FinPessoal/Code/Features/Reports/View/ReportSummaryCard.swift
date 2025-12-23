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
          .foregroundStyle(Color.oldMoney.text)
        Spacer()
      }
      
      // Main metrics
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
        MetricView(
          title: String(localized: "reports.total.income"),
          value: summary.totalIncome,
          color: Color.oldMoney.income,
          icon: "arrow.up.circle.fill"
        )

        MetricView(
          title: String(localized: "reports.total.expenses"),
          value: summary.totalExpenses,
          color: Color.oldMoney.expense,
          icon: "arrow.down.circle.fill"
        )

        MetricView(
          title: String(localized: "reports.net.income"),
          value: summary.netIncome,
          color: summary.netIncome >= 0 ? Color.oldMoney.income : Color.oldMoney.expense,
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
            .foregroundStyle(Color.oldMoney.textSecondary)
          Text("\(summary.transactionCount)")
            .font(.subheadline)
            .fontWeight(.medium)
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 4) {
          Text(String(localized: "reports.average.daily.spending"))
            .font(.caption)
            .foregroundStyle(Color.oldMoney.textSecondary)
          Text(NumberFormatter.currency.string(from: NSNumber(value: summary.averageDailySpending)) ?? "R$ 0")
            .font(.subheadline)
            .fontWeight(.medium)
        }
      }
    }
    .padding()
    .background(Color.oldMoney.background)
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
          .foregroundStyle(color)
          .font(.system(size: 16, weight: .medium))
        
        Text(title)
          .font(.caption)
          .foregroundStyle(Color.oldMoney.textSecondary)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
      }
      
      Text(NumberFormatter.currency.string(from: NSNumber(value: value)) ?? "R$ 0")
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .foregroundStyle(Color.oldMoney.text)
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
          .foregroundStyle(rate >= 20 ? Color.oldMoney.income : rate >= 0 ? Color.oldMoney.warning : Color.oldMoney.expense)
          .font(.system(size: 16, weight: .medium))
        
        Text(String(localized: "reports.savings.rate"))
          .font(.caption)
          .foregroundStyle(Color.oldMoney.textSecondary)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
      }
      
      HStack(spacing: 4) {
        Text("\(Int(rate.rounded()))")
          .font(.system(size: 18, weight: .semibold, design: .rounded))
          .foregroundStyle(Color.oldMoney.text)
        Text("%")
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(Color.oldMoney.textSecondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(12)
    .background((rate >= 20 ? Color.oldMoney.income : rate >= 0 ? Color.oldMoney.warning : Color.oldMoney.expense).opacity(0.1))
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