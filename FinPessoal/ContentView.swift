//
//  ContentView.swift
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
  
  var body: some View {
    Group {
      if authViewModel.isAuthenticated {
        AdaptiveMainView()
      } else {
        LoginView()
          .transition(.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
          ))
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

struct AdaptiveMainView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Environment(\.verticalSizeClass) var verticalSizeClass
  
  var body: some View {
    Group {
      if shouldUseSplitView {
        iPadMainView()
      } else {
        ModernPhoneMainView()
      }
    }
  }
  
  private var shouldUseSplitView: Bool {
    // Usar split view para iPad e iPhone Plus em landscape
    return horizontalSizeClass == .regular && verticalSizeClass == .regular ||
    (horizontalSizeClass == .regular && verticalSizeClass == .compact)
  }
}

struct ModernPhoneMainView: View {
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
