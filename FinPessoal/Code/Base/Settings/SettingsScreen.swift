//
//  SettingsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct SettingsScreen: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  
  var body: some View {
    NavigationView {
      List {
        Section("Conta") {
          if let user = authViewModel.currentUser {
            VStack(alignment: .leading, spacing: 4) {
              Text(user.name)
                .font(.headline)
              Text(user.email)
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
          }
          
          Button("Sair") {
            Task {
              await authViewModel.signOut()
            }
          }
          .foregroundColor(.red)
        }
        
        Section("Preferências") {
          Label("Notificações", systemImage: "bell")
          Label("Moeda", systemImage: "dollarsign.circle")
          Label("Idioma", systemImage: "globe")
        }
        
        Section("Suporte") {
          Label("Ajuda", systemImage: "questionmark.circle")
          Label("Contato", systemImage: "envelope")
          Label("Avalie o App", systemImage: "star")
        }
      }
      .navigationTitle("Configurações")
    }
  }
}

