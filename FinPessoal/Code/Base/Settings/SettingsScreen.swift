//
//  SettingsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct SettingsScreen: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @StateObject private var themeManager = ThemeManager()
  @State private var showingThemeSelector = false
  
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
        
        Section("Aparência") {
          Button(action: {
            showingThemeSelector = true
          }) {
            HStack {
              Label("Tema", systemImage: themeManager.currentTheme.icon)
                .foregroundColor(.primary)
              
              Spacer()
              
              Text(themeManager.currentTheme.displayName)
                .foregroundColor(.secondary)
                .font(.callout)
              
              Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
            }
          }
          .buttonStyle(.plain)
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
      .sheet(isPresented: $showingThemeSelector) {
        ThemeSelectorView(themeManager: themeManager)
      }
    }
    .environmentObject(themeManager)
  }
}

struct ThemeSelectorView: View {
  @ObservedObject var themeManager: ThemeManager
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationView {
      List {
        Section("Escolha o Tema") {
          ForEach(AppTheme.allCases, id: \.self) { theme in
            Button(action: {
              themeManager.setTheme(theme)
              dismiss()
            }) {
              HStack {
                Image(systemName: theme.icon)
                  .foregroundColor(.blue)
                  .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                  Text(theme.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                  
                  Text(themeDescription(for: theme))
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if themeManager.currentTheme == theme {
                  Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                    .font(.headline)
                }
              }
              .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
          }
        }
      }
      .navigationTitle("Tema do App")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Fechar") {
            dismiss()
          }
        }
      }
    }
  }
  
  private func themeDescription(for theme: AppTheme) -> String {
    switch theme {
    case .system:
      return "Segue as configurações do sistema"
    case .light:
      return "Sempre modo claro"
    case .dark:
      return "Sempre modo escuro"
    }
  }
}
