//
//  SettingsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/08/25.
//

import SwiftUI

struct SettingsScreen: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @State private var showingProfile = false
  
  var body: some View {
    NavigationView {
      List {
        Section("Perfil") {
          if let user = authViewModel.currentUser {
            Button {
              showingProfile = true
            } label: {
              HStack {
                AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                  image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                } placeholder: {
                  Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                  Text(user.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                  Text(user.email)
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
          }
        }
        
        Section("Preferências") {
          SettingsRow(title: "Notificações", icon: "bell", action: {})
          SettingsRow(title: "Moeda", icon: "dollarsign.circle", action: {})
          SettingsRow(title: "Idioma", icon: "globe", action: {})
          SettingsRow(title: "Tema", icon: "paintbrush", action: {})
        }
        
        Section("Dados") {
          SettingsRow(title: "Exportar Dados", icon: "square.and.arrow.up", action: {})
          SettingsRow(title: "Importar Dados", icon: "square.and.arrow.down", action: {})
          SettingsRow(title: "Backup", icon: "icloud", action: {})
        }
        
        Section("Suporte") {
          SettingsRow(title: "Ajuda", icon: "questionmark.circle", action: {})
          SettingsRow(title: "Contato", icon: "envelope", action: {})
          SettingsRow(title: "Avalie o App", icon: "star", action: {})
        }
        
        Section("Conta") {
          Button("Sair") {
            Task {
              await authViewModel.signOut()
            }
          }
          .foregroundColor(.red)
        }
      }
      .navigationTitle("Configurações")
      .sheet(isPresented: $showingProfile) {
        ProfileView()
          .environmentObject(authViewModel)
      }
    }
  }
}

struct SettingsRow: View {
  let title: String
  let icon: String
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        Image(systemName: icon)
          .foregroundColor(.blue)
          .frame(width: 24)
        
        Text(title)
          .foregroundColor(.primary)
        
        Spacer()
        
        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
    .buttonStyle(.plain)
  }
}
