//
//  AddAccountView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import SwiftUI

struct AddAccountView: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @Environment(\.dismiss) private var dismiss
  
  @State private var name = ""
  @State private var selectedType: AccountType = .checking
  @State private var initialBalance = ""
  @State private var currency = "BRL"
  @State private var isActive = true
  @State private var showingError = false
  @State private var errorMessage = ""
  
  private let currencies = ["BRL", "USD", "EUR", "GBP"]
  
  var body: some View {
    NavigationView {
      Form {
        Section("Informações Básicas") {
          TextField("Nome da Conta", text: $name)
            .textInputAutocapitalization(.words)
          
          Picker("Tipo de Conta", selection: $selectedType) {
            ForEach(AccountType.allCases, id: \.self) { type in
              Label(type.rawValue, systemImage: type.icon)
                .tag(type)
            }
          }
        }
        
        Section("Configurações Financeiras") {
          HStack {
            Text("Saldo Inicial")
            Spacer()
            Text("R$")
            TextField("0,00", text: $initialBalance)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }
          
          Picker("Moeda", selection: $currency) {
            ForEach(currencies, id: \.self) { currency in
              Text(currency).tag(currency)
            }
          }
        }
        
        Section("Opções") {
          Toggle("Conta Ativa", isOn: $isActive)
          
          if !isActive {
            Text("Contas inativas não aparecem nos relatórios e estatísticas")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        
        Section {
          accountPreview
        } header: {
          Text("Prévia")
        }
        
        Section {
          Button("Criar Conta") {
            createAccount()
          }
          .disabled(!isValidAccount)
          .frame(maxWidth: .infinity)
        }
      }
      .navigationTitle("Nova Conta")
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
  
  private var accountPreview: some View {
    HStack {
      Image(systemName: selectedType.icon)
        .font(.title2)
        .foregroundColor(selectedType.color)
        .frame(width: 40, height: 40)
        .background(selectedType.color.opacity(0.1))
        .cornerRadius(8)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(name.isEmpty ? "Nome da Conta" : name)
          .font(.headline)
          .foregroundColor(name.isEmpty ? .secondary : .primary)
        
        Text(selectedType.rawValue)
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 4) {
        Text(formattedBalance)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(.green)
        
        if !isActive {
          Text("Inativa")
            .font(.caption)
            .foregroundColor(.red)
        }
      }
    }
    .padding(.vertical, 4)
  }
  
  private var formattedBalance: String {
    guard let balance = Double(initialBalance) else {
      return "R$ 0,00"
    }
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency
    formatter.locale = Locale(identifier: currency == "BRL" ? "pt_BR" : "en_US")
    return formatter.string(from: NSNumber(value: balance)) ?? "R$ 0,00"
  }
  
  private var isValidAccount: Bool {
    return !name.isEmpty &&
    !initialBalance.isEmpty &&
    Double(initialBalance) != nil
  }
  
  private func createAccount() {
    guard let balance = Double(initialBalance) else {
      errorMessage = "Saldo inicial inválido"
      showingError = true
      return
    }
    
    let account = Account(
      id: UUID().uuidString,
      name: name,
      type: selectedType,
      balance: balance,
      currency: currency,
      isActive: isActive
    )
    
    // TODO: Implementar adição de conta no FinanceViewModel
    // await financeViewModel.addAccount(account)
    
    dismiss()
  }
}

#Preview {
  AddAccountView()
    .environmentObject(FinanceViewModel())
}
