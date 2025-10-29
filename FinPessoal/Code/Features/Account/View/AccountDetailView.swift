//
//  AccountDetailView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import SwiftUI

struct AccountDetailView: View {
  let account: Account
  @ObservedObject var accountViewModel: AccountViewModel
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var financeViewModel: FinanceViewModel
  
  @State private var showingEditAccount = false
  @State private var showingConfirmation = false
  
  private var accountTransactions: [Transaction] {
    financeViewModel.transactions.filter { $0.accountId == account.id }
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          accountHeaderSection
          accountStatsSection
          recentTransactionsSection
        }
        .padding()
      }
      .navigationTitle(account.name)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.close")) {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            Button(String(localized: "accounts.edit.button")) {
              showingEditAccount = true
            }
            Button(String(localized: "accounts.view.statement")) {
              // Navigate to transactions screen for this account
            }
            Divider()
            if account.isActive {
              Button(String(localized: "accounts.deactivate"), role: .destructive) {
                showingConfirmation = true
              }
            } else {
              Button(String(localized: "accounts.activate")) {
                Task {
                  _ = await accountViewModel.activateAccount(account.id)
                  dismiss()
                }
              }
            }
          } label: {
            Image(systemName: "ellipsis.circle")
          }
        }
      }
      .sheet(isPresented: $showingEditAccount) {
        EditAccountView(account: account, accountViewModel: accountViewModel)
      }
      .confirmationDialog(
        String(localized: "accounts.deactivate.confirm.title"),
        isPresented: $showingConfirmation
      ) {
        Button(String(localized: "accounts.deactivate"), role: .destructive) {
          Task {
            _ = await accountViewModel.deactivateAccount(account.id)
            dismiss()
          }
        }
        Button(String(localized: "common.cancel"), role: .cancel) { }
      } message: {
        Text(String(localized: "accounts.deactivate.confirm.message"))
      }
    }
  }
  
  private var accountHeaderSection: some View {
    VStack(spacing: 16) {
      Image(systemName: account.type.icon)
        .font(.system(size: 60))
        .foregroundColor(account.type.color)
        .frame(width: 80, height: 80)
        .background(account.type.color.opacity(0.15))
        .cornerRadius(20)
      
      VStack(spacing: 4) {
        Text(LocalizedStringKey(account.type.rawValue))
          .font(.headline)
          .foregroundColor(.secondary)
        
        Text(account.formattedBalance)
          .font(.system(size: 32, weight: .bold, design: .rounded))
          .foregroundColor(account.balance >= 0 ? .green : .red)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 20)
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }
  
  private var accountStatsSection: some View {
    LazyVGrid(columns: [
      GridItem(.flexible()),
      GridItem(.flexible())
    ], spacing: 12) {
      StatCard(
        title: String(localized: "transactions.title"),
        value: "\(accountTransactions.count)",
        icon: "list.bullet",
        color: .blue
      )
      
      StatCard(
        title: String(localized: "common.status"),
        value: String(localized: account.isActive ? "common.active" : "common.inactive"),
        icon: account.isActive ? "checkmark.circle" : "pause.circle",
        color: account.isActive ? .green : .orange
      )
    }
  }
  
  private var recentTransactionsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text(String(localized: "transactions.recent"))
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
        if !accountTransactions.isEmpty {
          Text(String(localized: "transactions.total.count", defaultValue: "\(accountTransactions.count) total"))
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      
      if accountTransactions.isEmpty {
        VStack(spacing: 12) {
          Image(systemName: "tray")
            .font(.system(size: 40))
            .foregroundColor(.secondary)
          
          Text(String(localized: "transactions.empty.title"))
            .font(.subheadline)
            .foregroundColor(.secondary)
          
          Text(String(localized: "transactions.empty.account.description"))
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
      } else {
        ForEach(accountTransactions.prefix(5)) { transaction in
          TransactionRow(transaction: transaction)
        }
        
        if accountTransactions.count > 5 {
          Button(String(localized: "transactions.view.all.count", defaultValue: "Ver todas as \(accountTransactions.count) transações")) {
            // Navegar para lista completa de transações
          }
          .font(.caption)
          .foregroundColor(.blue)
          .padding(.top, 8)
        }
      }
    }
  }
}

