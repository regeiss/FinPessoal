//
//  RecentTransactionScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 13/08/25.
//

import SwiftUI

struct RecentTransactionScreen: View {
  let transactions: [Transaction]

  var body: some View {
    AnimatedCard(style: .standard) {
      VStack(alignment: .leading, spacing: 16) {
        // Header with title and "View All" button
        HStack {
          HStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
              .foregroundColor(.oldMoney.accent)
              .font(.system(size: 18, weight: .medium))

            Text(String(localized: "dashboard.recent.transactions", defaultValue: "Transações Recentes"))
              .font(.headline)
              .fontWeight(.semibold)
          }

          Spacer()

          NavigationLink(destination: TransactionsScreen()) {
            HStack(spacing: 4) {
              Text(String(localized: "dashboard.view.all", defaultValue: "Ver Todas"))
                .font(.subheadline)
                .fontWeight(.medium)
              Image(systemName: "chevron.right")
                .font(.caption)
            }
            .foregroundColor(.oldMoney.accent)
          }
        }

        if transactions.isEmpty {
          // Enhanced empty state
          VStack(spacing: 12) {
            Image(systemName: "list.bullet.clipboard")
              .font(.system(size: 40))
              .foregroundColor(.oldMoney.textSecondary)

            Text(String(localized: "transactions.empty.title", defaultValue: "Nenhuma Transação"))
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundColor(.oldMoney.text)

            Text(String(localized: "transactions.empty.subtitle", defaultValue: "Suas transações aparecerão aqui"))
              .font(.caption)
              .foregroundColor(.oldMoney.textSecondary)
              .multilineTextAlignment(.center)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 24)
        } else {
          // Transaction list
          LazyVStack(spacing: 12) {
            ForEach(transactions.prefix(5)) { transaction in
              NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                TransactionRow(transaction: transaction)
              }
              .buttonStyle(.plain)
            }
          }

          // Show count if there are more transactions
          if transactions.count > 5 {
            HStack {
              Spacer()
              Text(String(localized: "dashboard.more.transactions",
                         defaultValue: "E mais \(transactions.count - 5) transações..."))
                .font(.caption)
                .foregroundColor(.oldMoney.textSecondary)
              Spacer()
            }
            .padding(.top, 8)
          }
        }
      }
      .padding()
    }
  }
}
