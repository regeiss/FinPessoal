//
//  AddTransactionView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import Foundation
import SwiftUI

struct AddTransactionView: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var transactionViewModel: TransactionViewModel
  @EnvironmentObject var accountViewModel: AccountViewModel
  
  @State private var amount: String = ""
  @State private var description: String = ""
  @State private var selectedCategory: TransactionCategory = .other
  @State private var selectedSubcategory: TransactionSubcategory?
  @State private var selectedType: TransactionType = .expense
  @State private var selectedAccountId: String = ""
  @State private var selectedToAccountId: String = ""
  @State private var selectedDate = Date()
  @State private var isRecurring = false
  @State private var isLoading = false
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text(String(localized: "transactions.basic.info"))) {
          HStack {
            Text(String(localized: "transactions.type"))
            Spacer()
            Picker("", selection: $selectedType) {
              ForEach(TransactionType.allCases, id: \.self) { type in
                Text(type.displayName).tag(type)
              }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedType) { _, newType in
              // Initialize destination account when switching to transfer
              if newType == .transfer && selectedToAccountId.isEmpty {
                selectedToAccountId = accountViewModel.accounts.first(where: { $0.id != selectedAccountId })?.id ?? ""
              }
            }
          }
          
          TextField(String(localized: "transactions.amount.placeholder"), text: $amount)
            .keyboardType(.decimalPad)
          
          TextField(String(localized: "transactions.description.placeholder"), text: $description)
        }
        
        Section(header: Text(String(localized: "transactions.details"))) {
          CategorySubcategoryPicker(
            selectedCategory: $selectedCategory,
            selectedSubcategory: $selectedSubcategory
          )
          
          if !accountViewModel.accounts.isEmpty {
            Picker(String(localized: "transactions.account"), selection: $selectedAccountId) {
              ForEach(accountViewModel.accounts) { account in
                Text(account.name).tag(account.id)
              }
            }
            .pickerStyle(MenuPickerStyle())
            .onAppear {
              if selectedAccountId.isEmpty && !accountViewModel.accounts.isEmpty {
                selectedAccountId = accountViewModel.accounts.first?.id ?? ""
              }
            }
            .onChange(of: selectedAccountId) { _, newAccountId in
              // Reset destination account if it's the same as source account
              if selectedType == .transfer && selectedToAccountId == newAccountId {
                selectedToAccountId = accountViewModel.accounts.first(where: { $0.id != newAccountId })?.id ?? ""
              }
            }
            
            // Transfer to account picker (only shown for transfers)
            if selectedType == .transfer {
              Picker(String(localized: "transactions.transfer.to.account"), selection: $selectedToAccountId) {
                ForEach(accountViewModel.accounts.filter { $0.id != selectedAccountId }) { account in
                  Text(account.name).tag(account.id)
                }
              }
              .pickerStyle(MenuPickerStyle())
              .onAppear {
                if selectedToAccountId.isEmpty {
                  selectedToAccountId = accountViewModel.accounts.first(where: { $0.id != selectedAccountId })?.id ?? ""
                }
              }
            }
          }
          
          DatePicker(String(localized: "transactions.date"), selection: $selectedDate, displayedComponents: .date)
          
          Toggle(String(localized: "transactions.is.recurring"), isOn: $isRecurring)
        }
      }
      .navigationTitle(String(localized: "transactions.new.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack(spacing: 16) {
            Button(String(localized: "common.save")) {
              Task {
                await saveTransaction()
              }
            }
            .disabled(isLoading || amount.isEmpty || description.isEmpty || selectedAccountId.isEmpty || (selectedType == .transfer && selectedToAccountId.isEmpty))

            Button(String(localized: "common.close")) {
              dismiss()
            }
          }
        }
      }
      .disabled(isLoading)
    }
    .onAppear {
      if accountViewModel.accounts.isEmpty {
        accountViewModel.loadAccounts()
      }
    }
  }
  
  private func saveTransaction() async {
    isLoading = true
    
    guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
      isLoading = false
      return
    }
    
    // For transfers, append destination account info to description
    let finalDescription: String
    if selectedType == .transfer {
      let destinationAccount = accountViewModel.accounts.first { $0.id == selectedToAccountId }
      let destinationName = destinationAccount?.name ?? "Unknown Account"
      finalDescription = "\(description) → \(destinationName)"
    } else {
      finalDescription = description
    }
    
    let newTransaction = Transaction(
      id: UUID().uuidString,
      accountId: selectedAccountId,
      amount: amountValue,
      description: finalDescription,
      category: selectedCategory,
      type: selectedType,
      date: selectedDate,
      isRecurring: isRecurring,
      userId: "", // Will be set in repository
      createdAt: Date(),
      updatedAt: Date(),
      subcategory: selectedSubcategory
    )
    
    let success = await transactionViewModel.addTransaction(newTransaction)
    
    isLoading = false
    
    if success {
      dismiss()
    }
  }
}
