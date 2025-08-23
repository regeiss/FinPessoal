//
//  AccountsView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import SwiftUI

struct AccountsView: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @State private var showingAddAccount = false
  @State private var selectedAccount: Account?
  
  var body: some View {
    NavigationView {
      ScrollView {
        LazyVStack(spacing: 16) {
          if financeViewModel.accounts.isEmpty {
            emptyStateView
          } else {
            summarySection
            accountsListSection
          }
        }
        .padding(.horizontal)
      }
      .navigationTitle(String(localized: "accounts.title"))
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingAddAccount = true
          } label: {
            Image(systemName: "plus.circle.fill")
          }
        }
      }
      .sheet(isPresented: $showingAddAccount) {
        AddAccountView()
          .environmentObject(financeViewModel)
      }
      .sheet(item: $selectedAccount) { account in
        AccountDetailView(account: account)
          .environmentObject(financeViewModel)
      }
      .refreshable {
        await financeViewModel.loadData()
      }
    }
  }
  
  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "creditcard")
        .font(.system(size: 60))
        .foregroundColor(.blue)
      
      Text(String(localized: "accounts.empty.title"))
        .font(.title2)
        .fontWeight(.semibold)
      
      Text(String(localized: "accounts.empty.description"))
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding(.horizontal)
      
      Button(String(localized: "accounts.add.first.button")) {
        showingAddAccount = true
      }
      .buttonStyle(.borderedProminent)
    }
    .padding(.vertical, 60)
  }
  
  private var summarySection: some View {
    VStack(spacing: 16) {
      HStack {
        Text(String(localized: "accounts.summary.title"))
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
      }
      
      LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
      ], spacing: 12) {
        SummaryCard(
          title: String(localized: "accounts.total.count"),
          value: "\(financeViewModel.accounts.count)",
          icon: "creditcard.fill",
          color: .blue
        )
        
        SummaryCard(
          title: String(localized: "accounts.total.balance"),
          value: financeViewModel.formattedTotalBalance,
          icon: "dollarsign.circle.fill",
          color: financeViewModel.totalBalance >= 0 ? .green : .red
        )
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
  
  private var accountsListSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text(String(localized: "accounts.your.accounts"))
          .font(.headline)
          .fontWeight(.semibold)
        Spacer()
        Text(String(localized: "accounts.count.label", defaultValue: "\(financeViewModel.accounts.count) conta(s)"))
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      ForEach(financeViewModel.accounts) { account in
        EnhancedAccountCard(account: account) {
          selectedAccount = account
        }
      }
    }
  }
}

struct EnhancedAccountCard: View {
  let account: Account
  let onTap: () -> Void
  
  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 16) {
        // Ícone da conta
        Image(systemName: account.type.icon)
          .font(.title2)
          .foregroundColor(account.type.color)
          .frame(width: 48, height: 48)
          .background(account.type.color.opacity(0.15))
          .cornerRadius(12)
        
        // Informações da conta
        VStack(alignment: .leading, spacing: 4) {
          Text(account.name)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
          
          HStack {
            Text(LocalizedStringKey(account.type.rawValue))
              .font(.caption)
              .foregroundColor(.secondary)
            
            if account.isActive {
              Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.green)
            }
          }
        }
        
        Spacer()
        
        // Saldo da conta
        VStack(alignment: .trailing, spacing: 2) {
          Text(account.formattedBalance)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(account.balance >= 0 ? .green : .red)
          
          Text(String(localized: "accounts.balance.label"))
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        
        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding()
      .background(Color(.systemBackground))
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color(.systemGray5), lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
  }
}

struct SummaryCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: icon)
          .foregroundColor(color)
          .font(.title3)
        Spacer()
      }
      
      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)
      
      Text(value)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(.primary)
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(8)
  }
}

// MARK: - Placeholder Views
