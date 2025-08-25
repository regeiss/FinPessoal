//
//  SettingsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/08/25.
//

import SwiftUI

struct SettingsScreen: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @EnvironmentObject var onboardingManager: OnboardingManager
  @State private var showingProfile = false
  
  var body: some View {
    NavigationView {
      List {
        Section(String(localized: "profile.title", defaultValue: "Perfil")) {
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
        
        Section(String(localized: "settings.preferences.section")) {
          SettingsRow(title: String(localized: "settings.notifications"), icon: "bell", action: {})
          SettingsRow(title: String(localized: "settings.currency"), icon: "dollarsign.circle", action: {})
          SettingsRow(title: String(localized: "settings.language"), icon: "globe", action: {})
          SettingsRow(title: String(localized: "settings.theme", defaultValue: "Tema"), icon: "paintbrush", action: {})
        }
        
        Section(String(localized: "settings.data.section", defaultValue: "Dados")) {
          SettingsRow(title: String(localized: "profile.export.data", defaultValue: "Exportar Dados"), icon: "square.and.arrow.up", action: {})
          SettingsRow(title: String(localized: "settings.import.data", defaultValue: "Importar Dados"), icon: "square.and.arrow.down", action: {})
          SettingsRow(title: String(localized: "settings.backup", defaultValue: "Backup"), icon: "icloud", action: {})
        }
        
        Section(String(localized: "settings.support.section")) {
          SettingsRow(title: String(localized: "settings.help"), icon: "questionmark.circle", action: {})
          SettingsRow(title: String(localized: "settings.contact"), icon: "envelope", action: {})
          SettingsRow(title: String(localized: "settings.rate.app"), icon: "star", action: {})
        }
        
        Section(String(localized: "settings.development.section", defaultValue: "Desenvolvimento")) {
          Button(String(localized: "settings.reset.onboarding", defaultValue: "Resetar Onboarding")) {
            onboardingManager.resetOnboarding()
          }
          .foregroundColor(.orange)
        }
        
        Section(String(localized: "settings.account.section")) {
          Button(String(localized: "settings.signout.button")) {
            Task {
              await authViewModel.signOut()
            }
          }
          .foregroundColor(.red)
        }
      }
      .navigationTitle(String(localized: "settings.title"))
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
