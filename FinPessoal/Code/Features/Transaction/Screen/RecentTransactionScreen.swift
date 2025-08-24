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
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("dashboard.recent.transactions")
          .font(.headline)
        Spacer()
        NavigationLink(destination: TransactionsScreen()) {
          Text("dashboard.see_all")
            .font(.caption)
            .foregroundColor(.blue)
        }
      }

      if transactions.isEmpty {
        EmptyStateView(
          icon: "list.bullet",
          title: "transactions.empty.title",
          subtitle: "transactions.empty.subtitle"
        )
      } else {
        ForEach(transactions.prefix(5)) { transaction in
          TransactionRow(transaction: transaction)
        }
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
}
