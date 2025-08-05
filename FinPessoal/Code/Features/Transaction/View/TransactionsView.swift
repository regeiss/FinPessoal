//
//  TransactionsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct TransactionsView: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @State private var showingAddTransactionSheet = false
  
  var body: some View {
    NavigationView {
      List {
        ForEach(financeViewModel.transactions) { transaction in
          TransactionRow(transaction: transaction)
        }
      }
      .navigationTitle("Transações")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Adicionar") {
            showingAddTransactionSheet = true
          }
        }
      }
      .refreshable {
        await financeViewModel.loadData()
      }
      .sheet(isPresented: $showingAddTransactionSheet) {
        AddTransactionScreen()
          .environmentObject(financeViewModel)
      }
    }
  }
}
