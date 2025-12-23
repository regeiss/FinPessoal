//
//  BalanceWidgetView.swift
//  FinPessoalWidgets
//
//  Created by Claude Code on 16/12/25.
//

import SwiftUI
import WidgetKit

struct BalanceWidgetView: View {
  let data: WidgetData
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .systemSmall:
      smallView
    case .systemMedium:
      mediumView
    case .systemLarge:
      largeView
    default:
      smallView
    }
  }

  // MARK: - Small View

  private var smallView: some View {
    VStack(alignment: .leading, spacing: 4) {
      Label("Saldo Total", systemImage: "banknote")
        .font(.caption)
        .foregroundStyle(Color.widget.textSecondary)

      Text(formattedBalance)
        .font(.title2)
        .fontWeight(.bold)
        .minimumScaleFactor(0.5)
        .lineLimit(1)

      Spacer()

      HStack {
        trendIndicator
        Text(trendText)
          .font(.caption2)
          .foregroundStyle(Color.widget.textSecondary)
          .lineLimit(1)
      }
    }
    .padding()
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Saldo total: \(formattedBalance). \(trendText)")
  }

  // MARK: - Medium View

  private var mediumView: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Label("Saldo Total", systemImage: "banknote")
          .font(.caption)
          .foregroundStyle(Color.widget.textSecondary)

        Text(formattedBalance)
          .font(.title)
          .fontWeight(.bold)
          .minimumScaleFactor(0.7)
          .lineLimit(1)

        HStack {
          trendIndicator
          Text(trendText)
            .font(.caption)
            .foregroundStyle(Color.widget.textSecondary)
        }
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 8) {
        accountTypeRow(icon: "building.columns", label: "Corrente", value: checkingBalance)
        accountTypeRow(icon: "dollarsign.circle", label: "Poupança", value: savingsBalance)
        accountTypeRow(icon: "chart.line.uptrend.xyaxis", label: "Investimentos", value: investmentBalance)
      }
    }
    .padding()
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Saldo total: \(formattedBalance). Corrente: \(formatCurrency(checkingBalance)). Poupança: \(formatCurrency(savingsBalance)). Investimentos: \(formatCurrency(investmentBalance))")
  }

  // MARK: - Large View

  private var largeView: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Header
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Label("Saldo Total", systemImage: "banknote")
            .font(.caption)
            .foregroundStyle(Color.widget.textSecondary)

          Text(formattedBalance)
            .font(.largeTitle)
            .fontWeight(.bold)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
        }

        Spacer()

        trendIndicator
          .font(.title2)
      }

      Divider()

      // Monthly Summary
      HStack {
        VStack(alignment: .leading) {
          Text("Receitas")
            .font(.caption)
            .foregroundStyle(Color.widget.textSecondary)
          Text(formatCurrency(data.monthlyIncome))
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(Color.widget.income)
        }

        Spacer()

        VStack(alignment: .trailing) {
          Text("Despesas")
            .font(.caption)
            .foregroundStyle(Color.widget.textSecondary)
          Text(formatCurrency(data.monthlyExpenses))
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(Color.widget.expense)
        }
      }

      Divider()

      // Account List
      Text("Contas")
        .font(.headline)

      if data.accounts.isEmpty {
        Text("Nenhuma conta cadastrada")
          .font(.caption)
          .foregroundStyle(Color.widget.textSecondary)
          .frame(maxWidth: .infinity, alignment: .center)
      } else {
        ForEach(data.accounts.prefix(3)) { account in
          HStack {
            Image(systemName: iconForAccountType(account.type))
              .foregroundStyle(Color.widget.accent)
              .frame(width: 20)
            Text(account.name)
              .font(.subheadline)
              .lineLimit(1)
            Spacer()
            Text(formatCurrency(account.balance))
              .font(.subheadline)
              .fontWeight(.medium)
          }
        }
      }

      Spacer()

      // Last updated
      Text("Atualizado: \(formattedLastUpdate)")
        .font(.caption2)
        .foregroundStyle(Color.widget.textSecondary.opacity(0.7))
    }
    .padding()
  }

  // MARK: - Helpers

  private var formattedBalance: String {
    formatCurrency(data.totalBalance)
  }

  private var trendIndicator: some View {
    let isPositive = data.monthlyIncome >= data.monthlyExpenses
    return Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
      .foregroundStyle(isPositive ? Color.widget.income : Color.widget.expense)
  }

  private var trendText: String {
    let net = data.monthlyIncome - data.monthlyExpenses
    let sign = net >= 0 ? "+" : ""
    return "\(sign)\(formatCurrency(net)) este mês"
  }

  private var checkingBalance: Double {
    data.accounts
      .filter { $0.type.lowercased().contains("corrente") || $0.type == "checking" }
      .reduce(0) { $0 + $1.balance }
  }

  private var savingsBalance: Double {
    data.accounts
      .filter { $0.type.lowercased().contains("poupança") || $0.type == "savings" }
      .reduce(0) { $0 + $1.balance }
  }

  private var investmentBalance: Double {
    data.accounts
      .filter { $0.type.lowercased().contains("investimento") || $0.type == "investment" }
      .reduce(0) { $0 + $1.balance }
  }

  private func accountTypeRow(icon: String, label: String, value: Double) -> some View {
    HStack(spacing: 4) {
      Image(systemName: icon)
        .font(.caption)
        .foregroundStyle(Color.widget.textSecondary)
      Text(formatCurrency(value))
        .font(.caption)
        .fontWeight(.medium)
    }
    .accessibilityLabel("\(label): \(formatCurrency(value))")
  }

  private func iconForAccountType(_ type: String) -> String {
    let lowercased = type.lowercased()
    if lowercased.contains("corrente") || lowercased == "checking" {
      return "building.columns"
    } else if lowercased.contains("poupança") || lowercased == "savings" {
      return "dollarsign.circle"
    } else if lowercased.contains("investimento") || lowercased == "investment" {
      return "chart.line.uptrend.xyaxis"
    } else if lowercased.contains("crédito") || lowercased == "credit" {
      return "creditcard"
    }
    return "banknote"
  }

  private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
  }

  private var formattedLastUpdate: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.locale = Locale(identifier: "pt_BR")
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: data.lastUpdated, relativeTo: Date())
  }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
  BalanceWidget()
} timeline: {
  BalanceWidgetEntry(date: Date(), data: .empty)
  BalanceWidgetEntry(date: Date(), data: .preview)
}

#Preview(as: .systemMedium) {
  BalanceWidget()
} timeline: {
  BalanceWidgetEntry(date: Date(), data: .preview)
}

#Preview(as: .systemLarge) {
  BalanceWidget()
} timeline: {
  BalanceWidgetEntry(date: Date(), data: .preview)
}
