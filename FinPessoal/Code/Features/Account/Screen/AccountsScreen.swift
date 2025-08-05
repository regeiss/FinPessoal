//
//  AccountsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct AccountsView: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @State private var showAddAccountView = false
  
  var body: some View {
    NavigationView {
      List {
        ForEach(financeViewModel.accounts) { account in
          AccountCard(account: account)
            .listRowInsets(EdgeInsets())
            //.listRowSeparator(.hidden)
            .padding(.vertical, 2)
        }
      }
      //.listStyle(.plain)
      .navigationTitle("Contas")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Adicionar") {
            showAddAccountView = true
          }
          .foregroundColor(.blue)
        }
      }
      .refreshable {
        await financeViewModel.loadData()
      }
      .sheet(isPresented: $showAddAccountView) {
        AddAccountView()
          .environmentObject(financeViewModel)
      }
    }
  }
}
