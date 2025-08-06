//
//  iPadMainView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct iPadMainView: View {
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @EnvironmentObject var authViewModel: AuthViewModel
  @EnvironmentObject var themeManager: ThemeManager
  
  var body: some View {
    NavigationSplitView(
      columnVisibility: $navigationState.columnVisibility,
      sidebar: {
        ModernSidebarView()
          .navigationSplitViewColumnWidth(
            min: 280,
            ideal: 320,
            max: 400
          )
      },
      detail: {
        ModernDetailView()
          .navigationSplitViewColumnWidth(
            min: 600,
            ideal: 800
          )
      }
    )
    .navigationSplitViewStyle(.balanced)
    .task {
      await financeViewModel.loadData()
    }
  }
}

struct ModernSidebarView: View {
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var authViewModel: AuthViewModel
  @EnvironmentObject var themeManager: ThemeManager
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    NavigationStack {
      List(selection: $navigationState.selectedSidebarItem) {
        // Seção do usuário
        Section {
          if let user = authViewModel.currentUser {
            ModernUserProfileCard(user: user)
              .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
              .listRowBackground(Color.clear)
          }
        }
        
        // Menu principal
        Section("Principal") {
          ForEach([SidebarItem.dashboard, .accounts, .transactions, .reports], id: \.self) { item in
            ModernSidebarRow(item: item)
          }
        }
        .listSectionSpacing(12)
        
        // Ferramentas
        Section("Ferramentas") {
          ForEach([SidebarItem.budgets, .goals], id: \.self) { item in
            ModernSidebarRow(item: item)
          }
        }
        .listSectionSpacing(12)
        
        // Configurações
        Section {
          ModernSidebarRow(item: .settings)
        }
      }
      .listStyle(.sidebar)
      .navigationTitle("Money Manager")
      .navigationBarTitleDisplayMode(.large)
      .background(Color(.systemGroupedBackground))
      .scrollContentBackground(.hidden)
    }
  }
}

struct ModernSidebarRow: View {
  let item: SidebarItem
  @EnvironmentObject var navigationState: NavigationState
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    NavigationLink(
      value: item,
      label: {
        HStack(spacing: 16) {
          Image(systemName: item.icon)
            .font(.title3)
            .foregroundStyle(isSelected ? .white : .primary)
            .frame(width: 24, height: 24)
          
          Text(item.title)
            .font(.body)
            .fontWeight(.medium)
            .foregroundStyle(isSelected ? .white : .primary)
          
          Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
          RoundedRectangle(cornerRadius: 10)
            .fill(isSelected ? .blue : Color.clear)
        )
      }
    )
    .listRowBackground(Color.clear)
    .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
  }
  
  private var isSelected: Bool {
    navigationState.selectedSidebarItem == item
  }
}

struct ModernUserProfileCard: View {
  let user: User
  @EnvironmentObject var authViewModel: AuthViewModel
  @EnvironmentObject var themeManager: ThemeManager
  @Environment(\.colorScheme) var colorScheme
  @State private var showingProfileMenu = false
  
  var body: some View {
    HStack(spacing: 16) {
      // Avatar
      ZStack {
        Circle()
          .fill(
            LinearGradient(
              colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 56, height: 56)
        
        if let imageURL = user.profileImageURL, !imageURL.isEmpty {
          AsyncImage(url: URL(string: imageURL)) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
          } placeholder: {
            Image(systemName: "person.fill")
              .font(.title2)
              .foregroundColor(.white)
          }
          .frame(width: 56, height: 56)
          .clipShape(Circle())
        } else {
          Text(user.name.prefix(2).uppercased())
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.white)
        }
      }
      
      // Info
      VStack(alignment: .leading, spacing: 4) {
        Text(user.name)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(.primary)
        
        Text(user.email)
          .font(.caption)
          .foregroundColor(.secondary)
          .lineLimit(1)
      }
      
      Spacer()
      
      // Menu button
      Button(action: {
        showingProfileMenu = true
      }) {
        Image(systemName: "ellipsis")
          .font(.title3)
          .foregroundColor(.secondary)
          .frame(width: 32, height: 32)
          .background(Color(.systemGray6))
          .clipShape(Circle())
      }
      .buttonStyle(.plain)
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 16)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color(.secondarySystemGroupedBackground))
        .shadow(
          color: colorScheme == .dark ? .clear : .black.opacity(0.05),
          radius: 8,
          x: 0,
          y: 2
        )
    )
    .confirmationDialog("Opções da Conta", isPresented: $showingProfileMenu) {
      Button("Configurações") {
        // Navegar para configurações
      }
      
      Button("Sair", role: .destructive) {
        Task {
          await authViewModel.signOut()
        }
      }
      
      Button("Cancelar", role: .cancel) { }
    }
  }
}

struct ModernDetailView: View {
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @EnvironmentObject var authViewModel: AuthViewModel
  @EnvironmentObject var themeManager: ThemeManager
  
  var body: some View {
    NavigationStack(path: $navigationState.navigationPath) {
      Group {
        switch navigationState.selectedSidebarItem {
        case .dashboard:
          ModernDashboardContent()
        case .accounts:
          ModernAccountsContent()
        case .transactions:
          ModernTransactionsContent()
        case .reports:
          ModernReportsContent()
        case .budgets:
          ModernBudgetsContent()
        case .goals:
          ModernGoalsContent()
        case .settings:
          ModernSettingsContent()
        case .none:
          ModernDashboardContent()
        }
      }
      .navigationDestination(for: NavigationDestination.self) { destination in
        destinationView(for: destination)
      }
      .navigationDestination(for: SidebarItem.self) { item in
        // Fallback para navegação simples
        EmptyView()
      }
    }
  }
  
  @ViewBuilder
  private func destinationView(for destination: NavigationDestination) -> some View {
    switch destination.screen {
    case .dashboard:
      ModernDashboardContent()
    case .accounts:
      ModernAccountsContent()
    case .transactions:
      ModernTransactionsContent()
    case .reports:
      ModernReportsContent()
    case .budgets:
      ModernBudgetsContent()
    case .goals:
      ModernGoalsContent()
    case .settings:
      ModernSettingsContent()
    }
  }
}

// MARK: - Content Views

struct ModernDashboardContent: View {
  var body: some View {
    DashboardScreen()
      .navigationTitle("Dashboard")
      .navigationBarTitleDisplayMode(.large)
  }
}

struct ModernAccountsContent: View {
  var body: some View {
    AccountsView()
      .navigationTitle("Contas")
      .navigationBarTitleDisplayMode(.large)
  }
}

struct ModernTransactionsContent: View {
  var body: some View {
    TransactionsView()
      .navigationTitle("Transações")
      .navigationBarTitleDisplayMode(.large)
  }
}

struct ModernReportsContent: View {
  var body: some View {
    ReportsView()
      .navigationTitle("Relatórios")
      .navigationBarTitleDisplayMode(.large)
  }
}

struct ModernBudgetsContent: View {
  var body: some View {
    BudgetsScreen()
      .navigationTitle("Orçamentos")
      .navigationBarTitleDisplayMode(.large)
  }
}

struct ModernGoalsContent: View {
  var body: some View {
    GoalsScreen()
      .navigationTitle("Metas")
      .navigationBarTitleDisplayMode(.large)
  }
}

struct ModernSettingsContent: View {
  var body: some View {
    SettingsScreen()
      .navigationTitle("Configurações")
      .navigationBarTitleDisplayMode(.large)
  }
}
