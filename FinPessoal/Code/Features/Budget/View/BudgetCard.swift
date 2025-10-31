//
//  BudgetCard.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import SwiftUI

struct BudgetCard: View {
  let budget: Budget

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: budget.category.icon)
          .font(.title2)
          .foregroundColor(.blue)
          .frame(width: 32, height: 32)
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 2) {
          Text(budget.name)
            .font(.headline)
            .foregroundColor(.primary)

          Text(budget.category.displayName)
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(budget.name), \(budget.category.displayName)")

        Spacer()

        VStack(alignment: .trailing, spacing: 2) {
          Text(budget.formattedSpent)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(budget.isOverBudget ? .red : .primary)

          Text(String(localized: "budget.card.of.amount", defaultValue: "de \(budget.formattedBudgetAmount)"))
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(budget.isOverBudget ? "Over budget" : "Spent")
        .accessibilityValue("\(budget.formattedSpent) of \(budget.formattedBudgetAmount)")
      }
      
      VStack(spacing: 8) {
        ProgressView(value: budget.percentageUsed, total: 1.0)
          .tint(budget.isOverBudget ? .red :
                  budget.shouldAlert ? .orange : .green)
          .accessibilityLabel("Budget Progress")
          .accessibilityValue("\(Int(budget.percentageUsed * 100))% used, \(budget.formattedSpent) spent of \(budget.formattedBudgetAmount) total")

        HStack {
          Text(String(localized: "budget.card.remaining", defaultValue: "Restante: \(budget.formattedRemaining)"))
            .font(.caption)
            .foregroundColor(.secondary)

          Spacer()

          Text("\(Int(budget.percentageUsed * 100))%")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(budget.isOverBudget ? .red :
                              budget.shouldAlert ? .orange : .green)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Budget Summary")
        .accessibilityValue("Remaining: \(budget.formattedRemaining), \(Int(budget.percentageUsed * 100))% used")
      }
      
      if budget.isOverBudget {
        HStack {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.red)
            .font(.caption)
            .accessibilityHidden(true)

          Text(String(localized: "budget.alert.over.budget"))
            .font(.caption)
            .foregroundColor(.red)
            .fontWeight(.medium)

          Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Warning: Over Budget")
        .accessibilityAddTraits(.isStaticText)
      } else if budget.shouldAlert {
        HStack {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.orange)
            .font(.caption)
            .accessibilityHidden(true)

          Text(String(localized: "budget.alert.near.limit.percent", defaultValue: "Próximo ao limite (\(Int(budget.alertThreshold * 100))%)"))
            .font(.caption)
            .foregroundColor(.orange)
            .fontWeight(.medium)

          Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Warning: Near Budget Limit")
        .accessibilityValue("\(Int(budget.alertThreshold * 100))% threshold reached")
        .accessibilityAddTraits(.isStaticText)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
    .accessibilityElement(children: .contain)
  }
}
