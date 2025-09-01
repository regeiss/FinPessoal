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
  @State private var selectedType: TransactionType = .expense
  @State private var selectedAccountId: String = ""
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
          }
          
          TextField(String(localized: "transactions.amount.placeholder"), text: $amount)
            .keyboardType(.decimalPad)
          
          TextField(String(localized: "transactions.description.placeholder"), text: $description)
        }
        
        Section(header: Text(String(localized: "transactions.details"))) {
          Picker(String(localized: "transactions.category"), selection: $selectedCategory) {
            ForEach(TransactionCategory.allCases.sorted(), id: \.self) { category in
              HStack {
                Image(systemName: category.icon)
                Text(category.displayName)
              }
              .tag(category)
            }
          }
          .pickerStyle(MenuPickerStyle())
          
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
          }
          
          DatePicker(String(localized: "transactions.date"), selection: $selectedDate, displayedComponents: .date)
          
          Toggle(String(localized: "transactions.is.recurring"), isOn: $isRecurring)
        }
      }
      .navigationTitle(String(localized: "transactions.new.title"))
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
              await saveTransaction()
            }
          }
          .disabled(isLoading || amount.isEmpty || description.isEmpty || selectedAccountId.isEmpty)
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
    
    let newTransaction = Transaction(
      id: UUID().uuidString,
      accountId: selectedAccountId,
      amount: amountValue,
      description: description,
      category: selectedCategory,
      type: selectedType,
      date: selectedDate,
      isRecurring: isRecurring,
      userId: "", // Will be set in repository
      createdAt: Date(),
      updatedAt: Date()
    )
    
    let success = await transactionViewModel.addTransaction(newTransaction)
    
    isLoading = false
    
    if success {
      dismiss()
    }
  }
}
