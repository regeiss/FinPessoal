//
//  ProfileView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import SwiftUI

struct ProfileView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @State private var showingEditProfile = false
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          profileHeaderSection
          profileStatsSection
          profileSettingsSection
          accountActionsSection
        }
        .padding()
      }
      .navigationTitle(String(localized: "profile.title", defaultValue: "Perfil"))
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String(localized: "common.edit")) {
            showingEditProfile = true
          }
        }
      }
      .sheet(isPresented: $showingEditProfile) {
        ProfileEditView()
          .environmentObject(authViewModel)
      }
    }
  }
  
  private var profileHeaderSection: some View {
    VStack(spacing: 16) {
      // Avatar
      Image(systemName: "person.circle.fill")
        .font(.system(size: 80))
        .foregroundColor(.blue)
      
      // Informações básicas
      VStack(spacing: 4) {
        Text(authViewModel.currentUser?.name ?? String(localized: "profile.default.user", defaultValue: "Usuário"))
          .font(.title2)
          .fontWeight(.bold)
        
        Text(authViewModel.currentUser?.email ?? "")
          .font(.subheadline)
          .foregroundColor(.secondary)
        
        if let createdAt = authViewModel.currentUser?.createdAt {
          Text(String(localized: "profile.member.since", defaultValue: "Membro desde \(createdAt.formatted(date: .abbreviated, time: .omitted))"))
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 20)
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }
  
  private var profileStatsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(String(localized: "profile.stats.title", defaultValue: "Estatísticas"))
        .font(.headline)
        .fontWeight(.semibold)
      
      LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
      ], spacing: 16) {
        StatCard(
          title: String(localized: "profile.stats.days.used", defaultValue: "Dias de Uso"),
          value: "\(daysSinceCreation)",
          icon: "calendar",
          color: .blue
        )
        
        StatCard(
          title: String(localized: "profile.stats.monthly.goal", defaultValue: "Meta do Mês"),
          value: String(localized: "common.coming.soon.short", defaultValue: "Em breve"),
          icon: "target",
          color: .orange
        )
      }
    }
  }
  
  private var profileSettingsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(String(localized: "settings.title"))
        .font(.headline)
        .fontWeight(.semibold)
      
      VStack(spacing: 12) {
        ProfileSettingRow(
          title: String(localized: "settings.currency"),
          value: "BRL",
          icon: "dollarsign.circle"
        )
        
        ProfileSettingRow(
          title: String(localized: "settings.language"),
          value: "pt-BR",
          icon: "globe"
        )
        
        ProfileSettingRow(
          title: String(localized: "settings.notifications"),
          value: String(localized: "settings.notifications.enabled", defaultValue: "Ativadas"),
          icon: "bell"
        )
        
        ProfileSettingRow(
          title: String(localized: "settings.biometric.auth", defaultValue: "Autenticação Biométrica"),
          value: String(localized: "settings.biometric.disabled", defaultValue: "Desativada"),
          icon: "faceid"
        )
      }
    }
  }
  
  private var accountActionsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(String(localized: "settings.account.section"))
        .font(.headline)
        .fontWeight(.semibold)
      
      VStack(spacing: 12) {
        Button(String(localized: "profile.export.data", defaultValue: "Exportar Dados")) {
          // TODO: Implementar exportação de dados
        }
        .foregroundColor(.blue)
        .frame(maxWidth: .infinity, alignment: .leading)
        
        Button(String(localized: "profile.privacy.policy", defaultValue: "Política de Privacidade")) {
          // TODO: Mostrar política de privacidade
        }
        .foregroundColor(.blue)
        .frame(maxWidth: .infinity, alignment: .leading)
        
        Button(String(localized: "profile.terms.of.use", defaultValue: "Termos de Uso")) {
          // TODO: Mostrar termos de uso
        }
        .foregroundColor(.blue)
        .frame(maxWidth: .infinity, alignment: .leading)
        
        Divider()
        
        Button(String(localized: "profile.sign.out", defaultValue: "Sair da Conta")) {
          Task {
            await authViewModel.signOut()
          }
        }
        .foregroundColor(.red)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
  
  private var daysSinceCreation: Int {
    guard let createdAt = authViewModel.currentUser?.createdAt else { return 0 }
    return Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
  }
}


struct ProfileSettingRow: View {
  let title: String
  let value: String
  let icon: String
  
  var body: some View {
    HStack {
      Image(systemName: icon)
        .foregroundColor(.blue)
        .frame(width: 24)
      
      Text(title)
        .font(.subheadline)
      
      Spacer()
      
      Text(value)
        .font(.subheadline)
        .foregroundColor(.secondary)
      
      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding(.horizontal)
    .padding(.vertical, 12)
    .background(Color(.systemGray6))
    .cornerRadius(8)
  }
}
