//
//  BudgetAlertRowView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/08/25.
//

import SwiftUI

struct BudgetAlertRowView: View {
  let budget: Budget

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(budget.name)
          .font(.subheadline)
          .fontWeight(.medium)

        Text("\(budget.percentageUsed, specifier: "%.0f")% used")
          .font(.caption)
          .foregroundColor(.orange)
      }

      Spacer()

      Text(budget.spent.formatted(.currency(code: "BRL")))
        .font(.subheadline)
        .fontWeight(.medium)
    }
    .padding(.vertical, 4)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Budget Alert: \(budget.name)")
    .accessibilityValue("\(Int(budget.percentageUsed * 100))% used, \(budget.spent.formatted(.currency(code: "BRL"))) spent")
    .accessibilityHint("This budget needs attention")
    .accessibilityAddTraits(.isButton)
  }
}
