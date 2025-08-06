//
//  AddAccountView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 04/08/25.
//

import SwiftUI

struct AddAccountView: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @Environment(\.dismiss) private var dismiss

  @State private var name: String = ""
  @State private var type: AccountType = .checking
  @State private var balance: String = ""
  @State private var currency: String = "BRL"
  @State private var isActive: Bool = true
  @State private var errorMessage: String?
  @FocusState private var focusedField: Field?

  enum Field: Hashable {
    case name, balance, currency
  }

  var body: some View {
    NavigationView {
      Form {
        Section("Informações da Conta") {
          TextField("Nome da Conta", text: $name)
            .focused($focusedField, equals: .name)
            .submitLabel(.next)
          Picker("Tipo", selection: $type) {
            ForEach(AccountType.allCases, id: \.self) { tipo in
              Label(tipo.rawValue, systemImage: tipo.icon).tag(tipo)
            }
          }
          HStack {
            Text("Saldo Inicial")
            Spacer()
            TextField("0,00", text: $balance)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
              .focused($focusedField, equals: .balance)
          }
          HStack {
            Text("Moeda")
            Spacer()
            TextField("BRL", text: $currency)
              .autocapitalization(.allCharacters)
              .multilineTextAlignment(.trailing)
              .focused($focusedField, equals: .currency)
          }
          Toggle("Conta Ativa", isOn: $isActive)
        }
        Section {
          Button("Adicionar Conta") { Task { await addAccount() } }
            .disabled(!isValid)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .listRowBackground(isValid ? Color.blue : Color.gray)
        }
      }
      .navigationTitle("Nova Conta")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancelar") { dismiss() }
        }
      }
      .alert(
        "Erro",
        isPresented: .constant(errorMessage != nil),
        actions: {
          Button("OK") { errorMessage = nil }
        },
        message: {
          Text(errorMessage ?? "")
        }
      )
    }
  }

  private var isValid: Bool {
    !name.trimmingCharacters(in: .whitespaces).isEmpty
      && !balance.replacingOccurrences(of: ",", with: ".").isEmpty
      && Double(balance.replacingOccurrences(of: ",", with: ".")) != nil
      && !currency.trimmingCharacters(in: .whitespaces).isEmpty
  }

  private func addAccount() async {
    guard let value = Double(balance.replacingOccurrences(of: ",", with: "."))
    else {
      errorMessage = "Saldo inválido"
      return
    }
    let newAccount = Account(
      id: UUID().uuidString,
      name: name.trimmingCharacters(in: .whitespaces),
      type: type,
      balance: value,
      currency: currency.trimmingCharacters(in: .whitespacesAndNewlines)
        .uppercased(),
      isActive: isActive
    )
    do {
      try await financeViewModel.addAccount(newAccount)
      dismiss()
    } catch {
      errorMessage = "Erro ao adicionar conta. Tente novamente."
    }
  }
}
