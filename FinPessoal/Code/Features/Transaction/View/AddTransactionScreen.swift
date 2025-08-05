import Foundation
import SwiftUI

struct AddTransactionScreen: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @Environment(\.dismiss) private var dismiss

  @State private var amount: String = ""
  @State private var description: String = ""
  @State private var selectedCategory: TransactionCategory = .food
  @State private var selectedType: TransactionType = .expense
  @State private var selectedAccountId: String = ""
  @State private var date: Date = Date()
  @State private var isRecurring: Bool = false
  @State private var errorMessage: String?

  var body: some View {
    NavigationView {
      Form {
        Section("Tipo e Valor") {
          Picker("Tipo", selection: $selectedType) {
            ForEach(TransactionType.allCases, id: \.self) { type in
              Text(type.displayName).tag(type)
            }
          }
          .pickerStyle(.segmented)

          HStack {
            Text("R$")
            TextField("0,00", text: $amount)
              .keyboardType(.decimalPad)
          }
        }
        Section("Descrição e Categoria") {
          TextField("Descrição", text: $description)

          Picker("Categoria", selection: $selectedCategory) {
            ForEach(TransactionCategory.allCases, id: \.self) { category in
              Label(category.displayName, systemImage: category.icon).tag(category)
            }
          }
        }
        Section("Conta e Data") {
          if financeViewModel.accounts.isEmpty {
            Text("Nenhuma conta cadastrada").foregroundColor(.secondary)
          } else {
            Picker("Conta", selection: $selectedAccountId) {
              ForEach(financeViewModel.accounts) { account in
                Text(account.name).tag(account.id)
              }
            }
          }
          DatePicker("Data", selection: $date, displayedComponents: .date)
            .environment(\.locale, Locale(identifier: "pt_BR"))
          Text("Selecionada: " + DateFormatter.transaction.string(from: date))
            .font(.caption)
            .foregroundColor(.secondary)
        }
        Section {
          Toggle("Transação Recorrente", isOn: $isRecurring)
        }
        Section {
          Button("Adicionar Transação") {
            Task { await addTransaction() }
          }
          .disabled(!isValid)
          .frame(maxWidth: .infinity)
        }
      }
      .navigationTitle("Nova Transação")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancelar") { dismiss() }
        }
      }
      .alert("Erro", isPresented: .constant(errorMessage != nil), actions: {
        Button("OK") { errorMessage = nil }
      }, message: {
        Text(errorMessage ?? "")
      })
    }
    .onAppear {
      if selectedAccountId.isEmpty, let first = financeViewModel.accounts.first?.id { selectedAccountId = first }
    }
  }

  private var isValid: Bool {
    guard !amount.replacingOccurrences(of: ",", with: ".").isEmpty, Double(amount.replacingOccurrences(of: ",", with: ".")) != nil,
          !description.isEmpty, !selectedAccountId.isEmpty else { return false }
    return true
  }

  private func addTransaction() async {
    guard let value = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
      errorMessage = "Valor inválido"
      return
    }
    let transaction = Transaction(
      id: UUID().uuidString,
      accountId: selectedAccountId,
      amount: value,
      description: description,
      category: selectedCategory,
      type: selectedType,
      date: date,
      isRecurring: isRecurring
    )
    await financeViewModel.addTransaction(transaction)
    dismiss()
  }
}

