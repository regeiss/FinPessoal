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
      .navigationTitle("Perfil")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Editar") {
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
      AsyncImage(url: URL(string: authViewModel.currentUser?.profileImageURL ?? "")) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
      } placeholder: {
        Image(systemName: "person.circle.fill")
          .font(.system(size: 80))
          .foregroundColor(.gray)
      }
      .frame(width: 100, height: 100)
      .clipShape(Circle())
      
      // Informações básicas
      VStack(spacing: 4) {
        Text(authViewModel.currentUser?.name ?? "Usuário")
          .font(.title2)
          .fontWeight(.bold)
        
        Text(authViewModel.currentUser?.email ?? "")
          .font(.subheadline)
          .foregroundColor(.secondary)
        
        if let createdAt = authViewModel.currentUser?.createdAt {
          Text("Membro desde \(createdAt.formatted(date: .abbreviated, time: .omitted))")
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
      Text("Estatísticas")
        .font(.headline)
        .fontWeight(.semibold)
      
      LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
      ], spacing: 16) {
        StatCard(
          title: "Dias de Uso",
          value: "\(daysSinceCreation)",
          icon: "calendar",
          color: .blue
        )
        
        StatCard(
          title: "Meta do Mês",
          value: "Em breve",
          icon: "target",
          color: .orange
        )
      }
    }
  }
  
  private var profileSettingsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Configurações")
        .font(.headline)
        .fontWeight(.semibold)
      
      VStack(spacing: 12) {
        ProfileSettingRow(
          title: "Moeda",
          value: authViewModel.currentUser?.settings.currency ?? "BRL",
          icon: "dollarsign.circle"
        )
        
        ProfileSettingRow(
          title: "Idioma",
          value: authViewModel.currentUser?.settings.language ?? "pt-BR",
          icon: "globe"
        )
        
        ProfileSettingRow(
          title: "Notificações",
          value: authViewModel.currentUser?.settings.notifications == true ? "Ativadas" : "Desativadas",
          icon: "bell"
        )
        
        ProfileSettingRow(
          title: "Autenticação Biométrica",
          value: authViewModel.currentUser?.settings.biometricAuth == true ? "Ativada" : "Desativada",
          icon: "faceid"
        )
      }
    }
  }
  
  private var accountActionsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Conta")
        .font(.headline)
        .fontWeight(.semibold)
      
      VStack(spacing: 12) {
        Button("Exportar Dados") {
          // TODO: Implementar exportação de dados
        }
        .foregroundColor(.blue)
        .frame(maxWidth: .infinity, alignment: .leading)
        
        Button("Política de Privacidade") {
          // TODO: Mostrar política de privacidade
        }
        .foregroundColor(.blue)
        .frame(maxWidth: .infinity, alignment: .leading)
        
        Button("Termos de Uso") {
          // TODO: Mostrar termos de uso
        }
        .foregroundColor(.blue)
        .frame(maxWidth: .infinity, alignment: .leading)
        
        Divider()
        
        Button("Sair da Conta") {
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
