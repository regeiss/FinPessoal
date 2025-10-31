//
//  BudgetRowView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 23/08/25.
//

import SwiftUI

struct BudgetRowView: View {
  let budget: Budget

    var body: some View {
        HStack(spacing: 12) {
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

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(budget.formattedSpent)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(budget.isOverBudget ? .red : .primary)

                Text(String(localized: "budget.card.of.amount", defaultValue: "de \(budget.formattedBudgetAmount)"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(budget.name), \(budget.category.displayName)")
        .accessibilityValue("\(budget.formattedSpent) spent of \(budget.formattedBudgetAmount)\(budget.isOverBudget ? ", over budget" : "")")
        .accessibilityHint("Double tap to view budget details")
        .accessibilityAddTraits(.isButton)
    }
}
