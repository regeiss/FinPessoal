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
          TextField(String(localized: "accounts.initial.balance"), text: $initialBalance)
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

            Button(String(localized: "common.close")) {
              dismiss()
            }
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
