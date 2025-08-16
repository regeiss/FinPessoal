//
//  AddTransactionView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import SwiftUI

struct AddTransactionView: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @Environment(\.dismiss) private var dismiss
  
  @State private var description = ""
  @State private var amount = ""
  @State private var selectedType: TransactionType = .expense
  @State private var selectedCategory: TransactionCategory = .food
  @State private var selectedAccount: Account?
  @State private var date = Date()
  @State private var isRecurring = false
  @State private var showingError = false
  @State private var errorMessage = ""
  
  var body: some View {
    NavigationView {
      Form {
        Section("Informações Básicas") {
          TextField("Descrição", text: $description)
          
          HStack {
            Text("R$")
            TextField("0,00", text: $amount)
              .keyboardType(.decimalPad)
          }
          
          Picker("Tipo", selection: $selectedType) {
            ForEach(TransactionType.allCases, id: \.self) { type in
              Text(type.displayName).tag(type)
            }
          }
          .pickerStyle(.segmented)
        }
        
        Section("Categoria") {
          Picker("Categoria", selection: $selectedCategory) {
            ForEach(TransactionCategory.allCases.sorted(), id: \.self) { category in
              Label(category.displayName, systemImage: category.icon)
                .tag(category)
            }
          }
        }
        
        Section("Conta") {
          Picker("Conta", selection: $selectedAccount) {
            Text("Selecione uma conta").tag(nil as Account?)
            ForEach(financeViewModel.accounts) { account in
              Text(account.name).tag(account as Account?)
            }
          }
        }
        
        Section("Data e Opções") {
          DatePicker("Data", selection: $date, displayedComponents: .date)
          
          Toggle("Transação recorrente", isOn: $isRecurring)
        }
        
        Section {
          Button("Salvar Transação") {
            saveTransaction()
          }
          .disabled(!isValidTransaction)
          .frame(maxWidth: .infinity)
        }
      }
      .navigationTitle("Nova Transação")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancelar") {
            dismiss()
          }
        }
      }
      .alert("Erro", isPresented: $showingError) {
        Button("OK") { }
      } message: {
        Text(errorMessage)
      }
    }
  }
  
  private var isValidTransaction: Bool {
    return !description.isEmpty &&
    !amount.isEmpty &&
    Double(amount) != nil &&
    Double(amount) ?? 0 > 0 &&
    selectedAccount != nil
  }
  
  private func saveTransaction() {
    guard let amountValue = Double(amount),
          let account = selectedAccount else {
      errorMessage = "Por favor, preencha todos os campos obrigatórios"
      showingError = true
      return
    }
    
    let transaction = Transaction(
      id: UUID().uuidString,
      accountId: account.id,
      amount: amountValue,
      description: description,
      category: selectedCategory,
      type: selectedType,
      date: date,
      isRecurring: isRecurring
    )
    
    Task {
      await financeViewModel.addTransaction(transaction)
      dismiss()
    }
  }
}
