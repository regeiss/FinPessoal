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
  @State private var currency: String
  @State private var isActive: Bool
  @State private var isLoading = false
  
  init(account: Account, accountViewModel: AccountViewModel) {
    self.account = account
    self.accountViewModel = accountViewModel
    
    self._accountName = State(initialValue: account.name)
    self._selectedAccountType = State(initialValue: account.type)
    self._balance = State(initialValue: String(format: "%.2f", account.balance))
    self._currency = State(initialValue: account.currency)
    self._isActive = State(initialValue: account.isActive)
  }
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text(String(localized: "accounts.basic.info"))) {
          TextField(String(localized: "accounts.name.placeholder"), text: $accountName)
          
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
        }
        
        Section(header: Text(String(localized: "accounts.balance.info"))) {
          TextField(String(localized: "accounts.current.balance"), text: $balance)
            .keyboardType(.decimalPad)
          
          Picker(String(localized: "accounts.currency"), selection: $currency) {
            Text("Real (BRL)").tag("BRL")
            Text("Dólar (USD)").tag("USD")
            Text("Euro (EUR)").tag("EUR")
          }
          .pickerStyle(MenuPickerStyle())
        }
        
        Section(header: Text(String(localized: "accounts.settings"))) {
          Toggle(String(localized: "accounts.is.active"), isOn: $isActive)
        }
        
        Section {
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
        }
      }
      .navigationTitle(String(localized: "accounts.edit.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.cancel")) {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.save")) {
            Task {
              await saveAccount()
            }
          }
          .disabled(isLoading || accountName.isEmpty)
        }
      }
      .disabled(isLoading)
    }
  }
  
  private func saveAccount() async {
    isLoading = true
    
    let updatedBalance = Double(balance.replacingOccurrences(of: ",", with: ".")) ?? account.balance
    
    let updatedAccount = Account(
      id: account.id,
      name: accountName,
      type: selectedAccountType,
      balance: updatedBalance,
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
}