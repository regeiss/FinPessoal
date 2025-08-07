//
//  ContentView.swift (Cross-Platform)
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 02/08/25.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var authViewModel = AuthViewModel()
  @StateObject private var financeViewModel = FinanceViewModel()
  @StateObject private var navigationState = NavigationState()
  @StateObject private var themeManager = ThemeManager()
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Environment(\.verticalSizeClass) var verticalSizeClass
  
  var body: some View {
    Group {
      if authViewModel.isAuthenticated {
        AdaptiveMainView()
      } else {
        AuthenticationView()
      }
    }
    .environmentObject(authViewModel)
    .environmentObject(financeViewModel)
    .environmentObject(navigationState)
    .environmentObject(themeManager)
    .preferredColorScheme(themeManager.currentTheme.colorScheme)
    .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
  }
}

// MARK: - Adaptive Main View

struct AdaptiveMainView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Environment(\.verticalSizeClass) var verticalSizeClass
  
  var body: some View {
    Group {
      if shouldUseSplitView {
        CrossPlatformSplitView()
      } else {
        CrossPlatformTabView()
      }
    }
  }
  
  private var shouldUseSplitView: Bool {
    // Usar split view para:
    // - iPad em qualquer orientação
    // - macOS sempre
    // - iPhone Plus/Pro Max em landscape
    return PlatformInfo.isIPad ||
    PlatformInfo.isMacOS ||
    (horizontalSizeClass == .regular && verticalSizeClass == .compact)
  }
}

// MARK: - Cross-Platform Split View

struct CrossPlatformSplitView: View {
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
            min: sidebarMinWidth,
            ideal: sidebarIdealWidth,
            max: sidebarMaxWidth
          )
      },
      detail: {
        ModernDetailView()
          .navigationSplitViewColumnWidth(
            min: detailMinWidth,
            ideal: detailIdealWidth
          )
      }
    )
    .navigationSplitViewStyle(.balanced)
    .task {
      await financeViewModel.loadData()
    }
  }
  
  // MARK: - Responsive Sidebar Widths
  
  private var sidebarMinWidth: CGFloat {
    PlatformInfo.isMacOS ? 300 : 280
  }
  
  private var sidebarIdealWidth: CGFloat {
    PlatformInfo.isMacOS ? 350 : 320
  }
  
  private var sidebarMaxWidth: CGFloat {
    PlatformInfo.isMacOS ? 450 : 400
  }
  
  private var detailMinWidth: CGFloat {
    PlatformInfo.isMacOS ? 700 : 600
  }
  
  private var detailIdealWidth: CGFloat {
    PlatformInfo.isMacOS ? 900 : 800
  }
}

// MARK: - Cross-Platform Tab View

struct CrossPlatformTabView: View {
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var financeViewModel: FinanceViewModel
  
  var body: some View {
    TabView(selection: $navigationState.selectedTab) {
      NavigationStack {
        DashboardScreen()
      }
      .tabItem {
        Label(MainTab.dashboard.rawValue, systemImage: MainTab.dashboard.icon)
      }
      .tag(MainTab.dashboard)
      
      NavigationStack {
        AccountsView()
      }
      .tabItem {
        Label(MainTab.accounts.rawValue, systemImage: MainTab.accounts.icon)
      }
      .tag(MainTab.accounts)
      
      NavigationStack {
        TransactionsView()
      }
      .tabItem {
        Label(MainTab.transactions.rawValue, systemImage: MainTab.transactions.icon)
      }
      .tag(MainTab.transactions)
      
      NavigationStack {
        ReportsView()
      }
      .tabItem {
        Label(MainTab.reports.rawValue, systemImage: MainTab.reports.icon)
      }
      .tag(MainTab.reports)
      
      NavigationStack {
        SettingsScreen()
      }
      .tabItem {
        Label(MainTab.settings.rawValue, systemImage: MainTab.settings.icon)
      }
      .tag(MainTab.settings)
    }
    .task {
      await financeViewModel.loadData()
    }
  }
}

// MARK: - Modern Sidebar View

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
      .background(Color(.systemGroupedBackground))
      .scrollContentBackground(.hidden)
    }
  }
}

// MARK: - Modern Sidebar Row

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

// MARK: - Modern User Profile Card

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
          .frame(width: avatarSize, height: avatarSize)
        
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
          .frame(width: avatarSize, height: avatarSize)
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
  
  private var avatarSize: CGFloat {
    PlatformInfo.isMacOS ? 64 : 56
  }
}

// MARK: - Modern Detail View

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
          DashboardScreen()
        case .accounts:
          AccountsView()
        case .transactions:
          TransactionsView()
        case .reports:
          ReportsView()
        case .budgets:
          BudgetsView()
        case .goals:
          GoalsScreen()
        case .settings:
          SettingsScreen()
        case .none:
          DashboardScreen()
        }
      }
      .navigationDestination(for: NavigationDestination.self) { destination in
        destinationView(for: destination)
      }
      .navigationDestination(for: SidebarItem.self) { item in
        EmptyView()
      }
    }
  }
  
  @ViewBuilder
  private func destinationView(for destination: NavigationDestination) -> some View {
    switch destination.screen {
    case .dashboard:
      DashboardScreen()
    case .accounts:
      AccountsView()
    case .transactions:
      TransactionsView()
    case .reports:
      ReportsView()
    case .budgets:
      BudgetsView()
    case .goals:
      GoalsScreen()
    case .settings:
      SettingsScreen()
    }
  }
}

// MARK: - Authentication View

struct AuthenticationView: View {
  var body: some View {
    LoginView()
      .transition(.asymmetric(
        insertion: .move(edge: .trailing),
        removal: .move(edge: .leading)
      ))
  }
}
