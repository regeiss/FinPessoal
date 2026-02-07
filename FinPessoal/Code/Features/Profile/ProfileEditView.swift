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
        Section(String(localized: "profile.edit.personal.info", defaultValue: "Informações Pessoais")) {
          HStack {
            Text(String(localized: "profile.edit.name", defaultValue: "Nome"))
            Spacer()
            StyledTextField(
              text: $name,
              placeholder: String(localized: "profile.edit.name", defaultValue: "Nome")
            )
            .multilineTextAlignment(.trailing)
          }

          HStack {
            Text(String(localized: "profile.edit.email", defaultValue: "Email"))
            Spacer()
            Text(authViewModel.currentUser?.email ?? "")
              .foregroundColor(.secondary)
          }
        }
        
        Section(String(localized: "settings.preferences.section")) {
          Picker(String(localized: "settings.currency"), selection: $currency) {
            ForEach(currencies, id: \.self) { currency in
              Text(currency).tag(currency)
            }
          }
          
          Picker(String(localized: "settings.language"), selection: $language) {
            Text(String(localized: "language.portuguese.brazil", defaultValue: "Português (Brasil)")).tag("pt-BR")
            Text(String(localized: "language.english.us", defaultValue: "English (US)")).tag("en-US")
            Text(String(localized: "language.spanish", defaultValue: "Español")).tag("es-ES")
          }
        }
        
        Section(String(localized: "profile.edit.notifications.security", defaultValue: "Notificações e Segurança")) {
          Toggle(String(localized: "settings.notifications"), isOn: $notifications)
          
          Toggle(String(localized: "settings.biometric.auth", defaultValue: "Autenticação Biométrica"), isOn: $biometricAuth)
          
          if biometricAuth {
            Text(String(localized: "settings.biometric.description", defaultValue: "Use Face ID ou Touch ID para acessar o app"))
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        
        Section {
          Button(String(localized: "profile.save.changes", defaultValue: "Salvar Alterações")) {
            saveChanges()
          }
          .frame(maxWidth: .infinity)
        }
      }
      .navigationTitle(String(localized: "profile.edit.title", defaultValue: "Editar Perfil"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.cancel")) {
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
