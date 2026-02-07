//
//  AddAccountView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import SwiftUI

struct AddAccountView: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var accountViewModel: AccountViewModel
  
  @State private var accountName = ""
  @State private var selectedAccountType: AccountType = .checking
  @State private var initialBalance: String = ""
  @State private var currency = "BRL"
  @State private var isActive = true
  @State private var isLoading = false
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text(String(localized: "accounts.basic.info"))
          .accessibilityAddTraits(.isHeader)) {
          StyledTextField(
            title: String(localized: "accounts.name"),
            text: $accountName,
            placeholder: String(localized: "accounts.name.placeholder")
          )
          .accessibilityLabel("Account Name")
          .accessibilityHint("Enter the name for your account")
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
          StyledTextField(
            title: String(localized: "accounts.initial.balance"),
            text: $initialBalance,
            placeholder: "0.00",
            keyboardType: .decimalPad
          )
          .accessibilityLabel("Initial Balance")
          .accessibilityHint("Enter the starting balance for this account")
          .accessibilityValue(initialBalance.isEmpty ? "Empty" : initialBalance)

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
      }
      .navigationTitle(String(localized: "accounts.new.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack(spacing: 16) {
            Button(String(localized: "common.save")) {
              Task {
                await saveAccount()
              }
            }
            .disabled(isLoading || accountName.isEmpty)
            .accessibilityLabel("Save Account")
            .accessibilityHint("Save this new account")
            .accessibilityAddTraits(accountName.isEmpty ? .isButton : .isButton)

            Button(String(localized: "common.close")) {
              dismiss()
            }
            .accessibilityLabel("Close")
            .accessibilityHint("Close this form without saving")
          }
        }
      }
      .disabled(isLoading)
    }
  }
  
  private func saveAccount() async {
    isLoading = true
    
    let balance = Double(initialBalance.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    
    let newAccount = Account(
      id: UUID().uuidString,
      name: accountName,
      type: selectedAccountType,
      balance: balance,
      currency: currency,
      isActive: isActive,
      userId: "", // Will be set in the repository
      createdAt: Date(),
      updatedAt: Date()
    )
    
    let success = await accountViewModel.addAccount(newAccount)
    
    isLoading = false
    
    if success {
      dismiss()
    }
  }
}
