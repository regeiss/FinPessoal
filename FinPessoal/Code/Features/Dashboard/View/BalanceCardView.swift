//
//  BalanceCardView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/08/25.
//

import SwiftUI

struct BalanceCardView: View {
  let totalBalance: Double
  let monthlyExpenses: Double
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("dashboard.total_balance")
          .font(.headline)
          .foregroundColor(.secondary)
        Spacer()
        Image(systemName: "eye")
          .foregroundColor(.secondary)
      }
      
      Text(totalBalance.formatted(.currency(code: "BRL")))
        .font(.largeTitle)
        .fontWeight(.bold)
      
      HStack {
        VStack(alignment: .leading) {
          Text("dashboard.monthly_expenses")
            .font(.caption)
            .foregroundColor(.secondary)
          Text(monthlyExpenses.formatted(.currency(code: "BRL")))
            .font(.headline)
            .foregroundColor(.red)
        }
        Spacer()
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("dashboard.balance_card.accessibility")
  }
}
