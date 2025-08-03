//
//  AccountsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct AccountsView: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  
  var body: some View {
    NavigationView {
      List {
        ForEach(financeViewModel.accounts) { account in
          AccountCard(account: account)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        }
      }
      .listStyle(.plain)
      .navigationTitle("Contas")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Adicionar") {
            // Action to add new account
          }
        }
      }
    }
  }
}
