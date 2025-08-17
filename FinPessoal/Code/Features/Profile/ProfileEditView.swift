//
//  ProfileEditView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import SwiftUI
struct ProfileEditView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) private var dismiss
  
  @State private var name: String = ""
  @State private var currency: String = "BRL"
  @State private var language: String = "pt-BR"
  @State private var notifications: Bool = true
  @State private var biometricAuth: Bool = false
  
  private let currencies = ["BRL", "USD", "EUR", "GBP"]
  private let languages = ["pt-BR", "en-US", "es-ES"]
  
  var body: some View {
    NavigationView {
      Form {
        Section("Informações Pessoais") {
          HStack {
            Text("Nome")
            Spacer()
            TextField("Nome", text: $name)
              .multilineTextAlignment(.trailing)
          }
          
          HStack {
            Text("Email")
            Spacer()
            Text(authViewModel.currentUser?.email ?? "")
              .foregroundColor(.secondary)
          }
        }
        
        Section("Preferências") {
          Picker("Moeda", selection: $currency) {
            ForEach(currencies, id: \.self) { currency in
              Text(currency).tag(currency)
            }
          }
          
          Picker("Idioma", selection: $language) {
            Text("Português (Brasil)").tag("pt-BR")
            Text("English (US)").tag("en-US")
            Text("Español").tag("es-ES")
          }
        }
        
        Section("Notificações e Segurança") {
          Toggle("Notificações", isOn: $notifications)
          
          Toggle("Autenticação Biométrica", isOn: $biometricAuth)
          
          if biometricAuth {
            Text("Use Face ID ou Touch ID para acessar o app")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        
        Section {
          Button("Salvar Alterações") {
            saveChanges()
          }
          .frame(maxWidth: .infinity)
        }
      }
      .navigationTitle("Editar Perfil")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancelar") {
            dismiss()
          }
        }
      }
      .onAppear {
        loadCurrentSettings()
      }
    }
  }
  
  private func loadCurrentSettings() {
    guard let user = authViewModel.currentUser else { return }
    name = user.name
  }
  
  private func saveChanges() {
    // TODO: Implementar salvamento das configurações
    dismiss()
  }
}
