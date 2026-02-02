//
//  BalanceCardView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/08/25.
//

import SwiftUI

struct BalanceCardView: View {
  @Binding var totalBalance: Double
  @Binding var monthlyExpenses: Double
  var onTap: (() -> Void)? = nil

  // Convenience init for backwards compatibility
  init(totalBalance: Double, monthlyExpenses: Double, onTap: (() -> Void)? = nil) {
    self._totalBalance = .constant(totalBalance)
    self._monthlyExpenses = .constant(monthlyExpenses)
    self.onTap = onTap
  }

  // Binding init for animated updates
  init(
    totalBalance: Binding<Double>,
    monthlyExpenses: Binding<Double>,
    onTap: (() -> Void)? = nil
  ) {
    self._totalBalance = totalBalance
    self._monthlyExpenses = monthlyExpenses
    self.onTap = onTap
  }

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

      PhysicsNumberCounter(
        value: $totalBalance,
        format: .currency(code: "BRL"),
        font: OldMoneyTheme.Typography.moneyLarge
      )
      .foregroundStyle(Color.oldMoney.text)

      HStack {
        VStack(alignment: .leading) {
          Text("dashboard.monthly.expenses")
            .font(.caption)
            .foregroundStyle(Color.oldMoney.textSecondary)

          PhysicsNumberCounter(
            value: $monthlyExpenses,
            format: .currency(code: "BRL"),
            font: OldMoneyTheme.Typography.moneyMedium
          )
          .foregroundStyle(Color.oldMoney.expense)
        }
        Spacer()
      }
    }
    .padding()
    .background(Color.oldMoney.surface)
    .clipShape(RoundedRectangle(cornerRadius: OldMoneyTheme.Radius.medium))
    .animatedCard(onTap: onTap)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Balance Overview")
    .accessibilityValue("Total balance: \(totalBalance.formatted(.currency(code: "BRL"))), Monthly expenses: \(monthlyExpenses.formatted(.currency(code: "BRL")))")
  }
}
