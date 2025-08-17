//
//  AccountsView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import SwiftUI

struct AccountsView: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @State private var showingAddTransaction = false
  @State private var selectedTransaction: Transaction?

  var body: some View {
    NavigationView {
      VStack {
        if financeViewModel.transactions.isEmpty {
          emptyStateView
        } else {
          transactionsList
        }
      }
      .navigationTitle("Transações")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Adicionar") {
            showingAddTransaction = true
          }
        }
      }
      .sheet(isPresented: $showingAddTransaction) {
        AddTransactionView()
          .environmentObject(financeViewModel)
      }
      .sheet(item: $selectedTransaction) { transaction in
        TransactionDetailView(transaction: transaction)
          .environmentObject(financeViewModel)
      }
      .refreshable {
        await financeViewModel.loadData()
      }
    }
  }

  private var transactionsList: some View {
    List {
      ForEach(financeViewModel.transactions) { transaction in
        Button {
          selectedTransaction = transaction
        } label: {
          TransactionRow(transaction: transaction)
        }
        .buttonStyle(.plain)
      }
    }
  }

  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "list.bullet")
        .font(.system(size: 60))
        .foregroundColor(.secondary)

      Text("Nenhuma transação")
        .font(.title2)
        .fontWeight(.semibold)

      Text(
        "Adicione sua primeira transação para começar a controlar suas finanças"
      )
      .multilineTextAlignment(.center)
      .foregroundColor(.secondary)
      .padding(.horizontal)

      Button("Adicionar Transação") {
        showingAddTransaction = true
      }
      .buttonStyle(.borderedProminent)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
