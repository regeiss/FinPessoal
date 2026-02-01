//
//  TransactionsWidgetView.swift
//  FinPessoalWidgets
//
//  Created by Claude Code on 16/12/25.
//

import SwiftUI
import WidgetKit

struct TransactionsWidgetView: View {
  let data: WidgetData
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .systemMedium:
      mediumView
    case .systemLarge:
      largeView
    default:
      mediumView
    }
  }

  // MARK: - Medium View

  private var mediumView: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Label("Transações Recentes", systemImage: "arrow.left.arrow.right")
          .font(.caption)
          .foregroundStyle(.secondary)

        Spacer()

        monthlySummary
      }

      if data.recentTransactions.isEmpty {
        emptyState
      } else {
        ForEach(data.recentTransactions.prefix(3)) { transaction in
          transactionRow(transaction)
        }
      }
    }
    .padding()
  }

  // MARK: - Large View

  private var largeView: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Label("Transações Recentes", systemImage: "arrow.left.arrow.right")
          .font(.headline)

        Spacer()

        monthlySummaryLarge
      }

      Divider()

      if data.recentTransactions.isEmpty {
        emptyState
      } else {
        ForEach(data.recentTransactions.prefix(7)) { transaction in
          transactionRowLarge(transaction)
        }
      }

      Spacer()

      // Last updated
      Text("Atualizado: \(formattedLastUpdate)")
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
    .padding()
  }

  // MARK: - Components

  private var emptyState: some View {
    VStack {
      Spacer()
      Image(systemName: "tray")
        .font(.largeTitle)
        .foregroundStyle(.secondary)
      Text("Nenhuma transação")
        .font(.caption)
        .foregroundStyle(.secondary)
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .accessibilityLabel("Nenhuma transação recente")
  }

  private var monthlySummary: some View {
    HStack(spacing: 8) {
      HStack(spacing: 2) {
        Image(systemName: "arrow.up")
          .font(.caption2)
        Text(formatCompact(data.monthlyIncome))
          .font(.caption2)
      }
      .foregroundStyle(.green)

      HStack(spacing: 2) {
        Image(systemName: "arrow.down")
          .font(.caption2)
        Text(formatCompact(data.monthlyExpenses))
          .font(.caption2)
      }
      .foregroundStyle(.red)
    }
  }

  private var monthlySummaryLarge: some View {
    HStack(spacing: 12) {
      VStack(alignment: .trailing, spacing: 0) {
        Text("Receitas")
          .font(.caption2)
          .foregroundStyle(.secondary)
        Text(formatCurrency(data.monthlyIncome))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundStyle(.green)
      }

      VStack(alignment: .trailing, spacing: 0) {
        Text("Despesas")
          .font(.caption2)
          .foregroundStyle(.secondary)
        Text(formatCurrency(data.monthlyExpenses))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundStyle(.red)
      }
    }
  }

  private func transactionRow(_ transaction: TransactionSummary) -> some View {
    HStack {
      Image(systemName: transaction.categoryIcon)
        .font(.caption)
        .foregroundStyle(transaction.isExpense ? .red : .green)
        .frame(width: 20)

      Text(transaction.description)
        .font(.caption)
        .lineLimit(1)

      Spacer()

      VStack(alignment: .trailing, spacing: 0) {
        Text(transaction.formattedAmount)
          .font(.caption)
          .fontWeight(.medium)
          .foregroundStyle(transaction.isExpense ? .red : .green)

        Text(transaction.formattedDate)
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(transaction.accessibilityLabel)
  }

  private func transactionRowLarge(_ transaction: TransactionSummary) -> some View {
    HStack {
      ZStack {
        Circle()
          .fill(transaction.isExpense ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
          .frame(width: 32, height: 32)

        Image(systemName: transaction.categoryIcon)
          .font(.caption)
          .foregroundStyle(transaction.isExpense ? .red : .green)
      }

      VStack(alignment: .leading, spacing: 0) {
        Text(transaction.description)
          .font(.subheadline)
          .lineLimit(1)

        Text(transaction.category.capitalized)
          .font(.caption2)
          .foregroundStyle(.secondary)
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 0) {
        Text(transaction.formattedAmount)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundStyle(transaction.isExpense ? .red : .green)

        Text(transaction.formattedDate)
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 2)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(transaction.accessibilityLabel)
  }

  // MARK: - Helpers

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
  }

  private func formatCompact(_ value: Double) -> String {
    if value >= 1000 {
      return String(format: "%.1fk", value / 1000)
    }
    return String(format: "%.0f", value)
  }

  private var formattedLastUpdate: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.locale = Locale(identifier: "pt_BR")
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: data.lastUpdated, relativeTo: Date())
  }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
  TransactionsWidget()
} timeline: {
  TransactionsWidgetEntry(date: Date(), data: .preview)
}

#Preview(as: .systemLarge) {
  TransactionsWidget()
} timeline: {
  TransactionsWidgetEntry(date: Date(), data: .preview)
}
