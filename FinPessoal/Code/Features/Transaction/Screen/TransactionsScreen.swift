//
//  TransactionsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 13/08/25.
//

import SwiftUI

struct TransactionsScreen: View {
  var body: some View {
    NavigationView {
      EmptyStateView(
        icon: "list.bullet",
        title: "transactions.empty.title",
        subtitle: "transactions.empty.subtitle"
      )
      .navigationTitle("transactions.title")
    }
  }
}

