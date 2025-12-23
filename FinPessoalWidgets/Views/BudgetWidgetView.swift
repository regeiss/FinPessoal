//
//  BudgetWidgetView.swift
//  FinPessoalWidgets
//
//  Created by Claude Code on 16/12/25.
//

import SwiftUI
import WidgetKit

struct BudgetWidgetView: View {
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
      Label("Orçamentos", systemImage: "chart.pie")
        .font(.caption)
        .foregroundStyle(Color.widget.textSecondary)

      if data.budgets.isEmpty {
        emptyState
      } else {
        ForEach(data.budgets.prefix(3)) { budget in
          budgetRow(budget)
        }
      }
    }
    .padding()
  }

  // MARK: - Large View

  private var largeView: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Label("Orçamentos", systemImage: "chart.pie")
          .font(.headline)

        Spacer()

        if !data.budgets.isEmpty {
          Text("\(data.budgets.count) ativos")
            .font(.caption)
            .foregroundStyle(Color.widget.textSecondary)
        }
      }

      if data.budgets.isEmpty {
        emptyState
      } else {
        ForEach(data.budgets) { budget in
          budgetRowLarge(budget)
        }
      }

      Spacer()
    }
    .padding()
  }

  // MARK: - Components

  private var emptyState: some View {
    VStack {
      Spacer()
      Image(systemName: "chart.pie")
        .font(.largeTitle)
        .foregroundStyle(Color.widget.textSecondary)
      Text("Nenhum orçamento")
        .font(.caption)
        .foregroundStyle(Color.widget.textSecondary)
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .accessibilityLabel("Nenhum orçamento cadastrado")
  }

  private func budgetRow(_ budget: BudgetSummary) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack {
        Image(systemName: budget.categoryIcon)
          .font(.caption)
          .foregroundStyle(colorForPercentage(budget.percentage))
        Text(budget.name)
          .font(.caption)
          .lineLimit(1)
        Spacer()
        Text("\(Int(budget.percentage))%")
          .font(.caption)
          .fontWeight(.medium)
          .foregroundStyle(colorForPercentage(budget.percentage))
      }

      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 2)
            .fill(Color.widget.divider)

          RoundedRectangle(cornerRadius: 2)
            .fill(colorForPercentage(budget.percentage))
            .frame(width: geometry.size.width * min(1, budget.percentage / 100))
        }
      }
      .frame(height: 4)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(budget.accessibilityLabel)
  }

  private func budgetRowLarge(_ budget: BudgetSummary) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Image(systemName: budget.categoryIcon)
          .foregroundStyle(colorForPercentage(budget.percentage))
          .frame(width: 20)
        Text(budget.name)
          .font(.subheadline)
          .fontWeight(.medium)
          .lineLimit(1)
        Spacer()
        Text(budget.formattedSpent)
          .font(.caption)
        Text("/")
          .font(.caption)
          .foregroundStyle(Color.widget.textSecondary)
        Text(budget.formattedLimit)
          .font(.caption)
          .foregroundStyle(Color.widget.textSecondary)
      }

      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 3)
            .fill(Color.widget.divider)

          RoundedRectangle(cornerRadius: 3)
            .fill(colorForPercentage(budget.percentage))
            .frame(width: geometry.size.width * min(1, budget.percentage / 100))
        }
      }
      .frame(height: 6)

      if budget.isOverBudget {
        HStack {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.caption2)
          Text("Excedido em \(budget.formattedRemaining)")
            .font(.caption2)
        }
        .foregroundStyle(Color.widget.expense)
      }
    }
    .padding(.vertical, 2)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(budget.accessibilityLabel)
  }

  // MARK: - Helpers

  private func colorForPercentage(_ percentage: Double) -> Color {
    switch percentage {
    case ..<75:
      return Color.widget.income
    case 75..<90:
      return Color.widget.warning
    case 90..<100:
      return Color.widget.warning.opacity(0.8)
    default:
      return Color.widget.expense
    }
  }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
  BudgetWidget()
} timeline: {
  BudgetWidgetEntry(date: Date(), data: .preview)
}

#Preview(as: .systemLarge) {
  BudgetWidget()
} timeline: {
  BudgetWidgetEntry(date: Date(), data: .preview)
}
