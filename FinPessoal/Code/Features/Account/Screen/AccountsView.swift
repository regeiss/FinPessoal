//
//  AccountsView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import SwiftUI

struct AccountsView: View {
  @EnvironmentObject var accountViewModel: AccountViewModel
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @EnvironmentObject var authViewModel: AuthViewModel
  @State private var accountToEdit: Account?

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 20) {
        if accountViewModel.isLoading {
          ProgressView(String(localized: "accounts.loading"))
            .padding(.vertical, 60)
            .accessibilityLabel("Loading accounts")
        } else if accountViewModel.accounts.isEmpty {
          emptyStateView
        } else {
          summarySection
          accountsListSection
        }
      }
      .padding(.horizontal, 20)
      .padding(.top, 8)
    }
    .background(Color.oldMoney.background)
    .navigationTitle(String(localized: "tab.accounts"))
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          accountViewModel.showAddAccount()
        } label: {
          Image(systemName: "plus")
        }
        .accessibilityLabel("Add Account")
        .accessibilityHint("Opens form to add a new account")
      }
    }
    .frostedSheet(isPresented: $accountViewModel.showingAddAccount) {
      if UIDevice.current.userInterfaceIdiom != .pad {
        AddAccountView(accountViewModel: accountViewModel)
      }
    }
    .frostedSheet(isPresented: $accountViewModel.showingAccountDetail) {
      if UIDevice.current.userInterfaceIdiom != .pad {
        if let selectedAccount = accountViewModel.selectedAccount {
          AccountDetailView(account: selectedAccount, accountViewModel: accountViewModel)
            .environmentObject(financeViewModel)
        }
      }
    }
    .frostedSheet(item: $accountToEdit) { account in
      EditAccountView(account: account, accountViewModel: accountViewModel)
    }
    .refreshable {
      await accountViewModel.fetchAccounts()
    }
    .onAppear {
      // Only load accounts if user is authenticated
      if authViewModel.isAuthenticated {
        accountViewModel.loadAccounts()
      }
    }
    .onChange(of: authViewModel.isAuthenticated) { _, isAuthenticated in
      if isAuthenticated {
        accountViewModel.loadAccounts()
      } else {
        // Clear accounts when user logs out
        accountViewModel.accounts = []
      }
    }
    .alert("Error", isPresented: .constant(accountViewModel.errorMessage != nil)) {
      Button("OK") {
        accountViewModel.clearError()
      }
    } message: {
      if let errorMessage = accountViewModel.errorMessage {
        Text(errorMessage)
      }
    }
  }
  
  private var emptyStateView: some View {
    VStack(spacing: 24) {
      Image(systemName: "creditcard")
        .font(.system(size: 60))
        .foregroundStyle(Color.oldMoney.accent)
        .accessibilityHidden(true)

      Text(String(localized: "accounts.empty.title"))
        .font(.title2)
        .fontWeight(.semibold)

      Text(String(localized: "accounts.empty.description"))
        .multilineTextAlignment(.center)
        .foregroundStyle(Color.oldMoney.textSecondary)
        .padding(.horizontal, 24)

      Button(String(localized: "accounts.add.first.button")) {
        accountViewModel.showAddAccount()
      }
      .buttonStyle(.borderedProminent)
      .accessibilityLabel("Add Your First Account")
      .accessibilityHint("Opens form to create your first account")
    }
    .padding(.vertical, 80)
    .accessibilityElement(children: .contain)
  }
  
  private var summarySection: some View {
    VStack(spacing: 20) {
      HStack {
        Text(String(localized: "accounts.summary.title"))
          .font(.headline)
          .fontWeight(.semibold)
          .accessibilityAddTraits(.isHeader)
        Spacer()
      }

      LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
      ], spacing: 16) {
        SummaryCard(
          title: String(localized: "accounts.total.count"),
          value: "\(accountViewModel.accounts.count)",
          icon: "creditcard.fill",
          color: .blue
        )

        SummaryCard(
          title: String(localized: "accounts.total.balance"),
          value: accountViewModel.formattedTotalBalance,
          icon: "dollarsign.circle.fill",
          color: accountViewModel.totalBalance >= 0 ? .green : .red
        )
      }
    }
    .padding(20)
    .background(Color.oldMoney.surface)
    .cornerRadius(16)
  }
  
  private var accountsListSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text(String(localized: "accounts.your.accounts"))
          .font(.headline)
          .fontWeight(.semibold)
          .accessibilityAddTraits(.isHeader)
        Spacer()
        Text(String(localized: "accounts.count.label", defaultValue: "\(accountViewModel.accounts.count) conta(s)"))
          .font(.caption)
          .foregroundStyle(Color.oldMoney.textSecondary)
          .accessibilityLabel("\(accountViewModel.accounts.count) accounts")
      }

      ForEach(accountViewModel.accounts) { account in
        EnhancedAccountCard(account: account) {
          accountToEdit = account
        }
        .padding(.bottom, 4)
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
          .font(.title)
          .foregroundColor(account.type.color)
          .frame(width: 52, height: 52)
          .background(account.type.color.opacity(0.15))
          .cornerRadius(14)
          .accessibilityHidden(true)

        // Informações da conta
        VStack(alignment: .leading, spacing: 4) {
          Text(account.name)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(Color.oldMoney.text)

          HStack {
            Text(LocalizedStringKey(account.type.rawValue))
              .font(.caption)
              .foregroundStyle(Color.oldMoney.textSecondary)

            if account.isActive {
              Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(Color.oldMoney.income)
                .accessibilityHidden(true)
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
            .foregroundStyle(Color.oldMoney.textSecondary)
        }

        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundStyle(Color.oldMoney.textSecondary)
          .accessibilityHidden(true)
      }
      .padding(16)
      .background(Color.oldMoney.background)
      .cornerRadius(16)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(Color.oldMoney.divider, lineWidth: 1)
      )
      .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(account.name), \(account.type.rawValue)")
    .accessibilityValue("Balance: \(account.formattedBalance), Status: \(account.isActive ? "Active" : "Inactive")")
    .accessibilityHint("Double tap to edit account")
    .accessibilityAddTraits(.isButton)
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
          .accessibilityHidden(true)
        Spacer()
      }

      Text(title)
        .font(.caption)
        .foregroundStyle(Color.oldMoney.textSecondary)

      Text(value)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundStyle(Color.oldMoney.text)
    }
    .padding(16)
    .background(Color.oldMoney.background)
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(title)
    .accessibilityValue(value)
  }
}

// MARK: - Placeholder Views

