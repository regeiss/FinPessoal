//
//  EditAccountView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 31/08/25.
//

import SwiftUI

struct EditAccountView: View {
  let account: Account
  @ObservedObject var accountViewModel: AccountViewModel
  @Environment(\.dismiss) private var dismiss
  
  @State private var accountName: String
  @State private var selectedAccountType: AccountType
  @State private var balance: String
  @State private var balanceAmount: Double
  @State private var currency: String
  @State private var isActive: Bool
  @State private var isLoading = false
  @State private var showingDeleteConfirmation = false

  init(account: Account, accountViewModel: AccountViewModel) {
    self.account = account
    self.accountViewModel = accountViewModel

    self._accountName = State(initialValue: account.name)
    self._selectedAccountType = State(initialValue: account.type)
    self._balanceAmount = State(initialValue: account.balance)

    // Format initial balance
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatter.decimalSeparator = ","
    formatter.groupingSeparator = "."
    self._balance = State(initialValue: formatter.string(from: NSNumber(value: account.balance)) ?? "0,00")

    self._currency = State(initialValue: account.currency)
    self._isActive = State(initialValue: account.isActive)
  }
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text(String(localized: "accounts.basic.info"))
          .accessibilityAddTraits(.isHeader)) {
          TextField(String(localized: "accounts.name.placeholder"), text: $accountName)
            .accessibilityLabel("Account Name")
            .accessibilityHint("Edit the name for your account")
            .accessibilityValue(accountName.isEmpty ? "Empty" : accountName)

          Picker(String(localized: "accounts.type"), selection: $selectedAccountType) {
            ForEach(AccountType.allCases, id: \.self) { type in
              HStack {
                Image(systemName: type.icon)
                  .foregroundColor(type.color)
                Text(LocalizedStringKey(type.rawValue))
              }
              .tag(type)
            }
          }
          .pickerStyle(MenuPickerStyle())
          .accessibilityLabel("Account Type")
          .accessibilityHint("Select the type of account")
          .accessibilityValue(selectedAccountType.rawValue)
        }

        Section(header: Text(String(localized: "accounts.balance.info"))
          .accessibilityAddTraits(.isHeader)) {
          TextField(String(localized: "accounts.current.balance"), text: $balance)
            .keyboardType(.decimalPad)
            .onChange(of: balance) { _, newValue in
              formatBalanceInput(newValue)
            }
            .accessibilityLabel("Current Balance")
            .accessibilityHint("Edit the current balance for this account")
            .accessibilityValue(balance.isEmpty ? "Empty" : balance)

          Picker(String(localized: "accounts.currency"), selection: $currency) {
            Text("Real (BRL)").tag("BRL")
            Text("Dólar (USD)").tag("USD")
            Text("Euro (EUR)").tag("EUR")
          }
          .pickerStyle(MenuPickerStyle())
          .accessibilityLabel("Currency")
          .accessibilityHint("Select the currency for this account")
          .accessibilityValue(currency)
        }

        Section(header: Text(String(localized: "accounts.settings"))
          .accessibilityAddTraits(.isHeader)) {
          Toggle(String(localized: "accounts.is.active"), isOn: $isActive)
            .accessibilityLabel("Account Active")
            .accessibilityHint("Toggle to activate or deactivate this account")
            .accessibilityValue(isActive ? "Active" : "Inactive")
        }

        Section(header: Text("Account Information")
          .accessibilityAddTraits(.isHeader)) {
          VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "accounts.created.at"))
              .font(.caption)
              .foregroundColor(.secondary)

            Text(account.createdAt.formatted(date: .abbreviated, time: .shortened))
              .font(.subheadline)

            Text(String(localized: "accounts.updated.at"))
              .font(.caption)
              .foregroundColor(.secondary)

            Text(account.updatedAt.formatted(date: .abbreviated, time: .shortened))
              .font(.subheadline)
          }
          .accessibilityElement(children: .combine)
          .accessibilityLabel("Account Information")
          .accessibilityValue("Created at \(account.createdAt.formatted(date: .abbreviated, time: .shortened)), Last updated at \(account.updatedAt.formatted(date: .abbreviated, time: .shortened))")
        }
      }
      .navigationTitle(String(localized: "accounts.edit.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            showingDeleteConfirmation = true
          } label: {
            Image(systemName: "trash")
              .foregroundColor(.red)
          }
          .accessibilityLabel("Delete Account")
          .accessibilityHint("Delete this account permanently")
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          HStack(spacing: 16) {
            Button(String(localized: "common.save")) {
              Task {
                await saveAccount()
              }
            }
            .disabled(isLoading || accountName.isEmpty)
            .accessibilityLabel("Save Changes")
            .accessibilityHint("Save changes to this account")

            Button(String(localized: "common.close")) {
              dismiss()
            }
            .accessibilityLabel("Close")
            .accessibilityHint("Close this form without saving")
          }
        }
      }
      .disabled(isLoading)
      .alert(
        String(localized: "accounts.delete.confirmation"),
        isPresented: $showingDeleteConfirmation
      ) {
        Button(String(localized: "common.cancel"), role: .cancel) {}
        Button(String(localized: "accounts.delete.button"), role: .destructive) {
          deleteAccount()
        }
      } message: {
        Text(String(localized: "accounts.delete.message"))
      }
    }
  }
  
  private func formatBalanceInput(_ input: String) {
    // Remove all non-numeric characters
    let digitsOnly = input.filter { "0123456789".contains($0) }

    // If empty, reset
    guard !digitsOnly.isEmpty else {
      balanceAmount = 0
      balance = ""
      return
    }

    // Convert to cents (integer)
    guard let cents = Int(digitsOnly) else {
      balanceAmount = 0
      return
    }

    // Convert cents to actual value
    let value = Double(cents) / 100.0
    balanceAmount = value

    // Format the display value
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatter.decimalSeparator = ","
    formatter.groupingSeparator = "."

    if let formattedValue = formatter.string(from: NSNumber(value: value)) {
      balance = formattedValue
    }
  }

  private func saveAccount() async {
    isLoading = true

    let updatedAccount = Account(
      id: account.id,
      name: accountName,
      type: selectedAccountType,
      balance: balanceAmount,
      currency: currency,
      isActive: isActive,
      userId: account.userId,
      createdAt: account.createdAt,
      updatedAt: Date()
    )

    let success = await accountViewModel.updateAccount(updatedAccount)

    isLoading = false

    if success {
      dismiss()
    }
  }

  private func deleteAccount() {
    Task {
      _ = await accountViewModel.deleteAccount(account.id)
      dismiss()
    }
  }
}
