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
        Text("dashboard.total.balance")
          .font(.headline)
          .foregroundStyle(Color.oldMoney.textSecondary)
        Spacer()
        Image(systemName: "eye")
          .foregroundStyle(Color.oldMoney.textSecondary)
          .accessibilityHidden(true)
      }

      Text(totalBalance.formatted(.currency(code: "BRL")))
        .font(OldMoneyTheme.Typography.moneyLarge)
        .foregroundStyle(Color.oldMoney.text)

      HStack {
        VStack(alignment: .leading) {
          Text("dashboard.monthly.expenses")
            .font(.caption)
            .foregroundStyle(Color.oldMoney.textSecondary)
          Text(monthlyExpenses.formatted(.currency(code: "BRL")))
            .font(OldMoneyTheme.Typography.moneyMedium)
            .foregroundStyle(Color.oldMoney.expense)
        }
        Spacer()
      }
    }
    .padding()
    .background(Color.oldMoney.surface)
    .clipShape(RoundedRectangle(cornerRadius: OldMoneyTheme.Radius.medium))
    .oldMoneyCardShadow()
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Balance Overview")
    .accessibilityValue("Total balance: \(totalBalance.formatted(.currency(code: "BRL"))), Monthly expenses: \(monthlyExpenses.formatted(.currency(code: "BRL")))")
  }
}
