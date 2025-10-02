//
//  MainTabView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import SwiftUI

struct MainTabView: View {
  @EnvironmentObject var appState: AppState
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var themeManager: ThemeManager
  
  var body: some View {
    if UIDevice.current.userInterfaceIdiom == .pad {
      NavigationSplitView(columnVisibility: .constant(.all)) {
        SidebarView()
          .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: 400)
      } detail: {
        selectedDetailView
          .navigationSplitViewColumnWidth(min: 600, ideal: 800)
      }
      .navigationSplitViewStyle(.balanced)
    } else {
      TabView(selection: $appState.selectedTab) {
        DashboardScreen()
          .tabItem {
            Image(systemName: "house.fill")
            Text("tab.dashboard")
          }
          .tag(0)
        
        TransactionsScreen()
          .tabItem {
            Image(systemName: "list.bullet")
            Text("tab.transactions")
          }
          .tag(1)
        
        BudgetsScreen()
          .tabItem {
            Image(systemName: "chart.pie.fill")
            Text("tab.budgets")
          }
          .tag(2)
        
        GoalScreen()
          .tabItem {
            Image(systemName: "target")
            Text("tab.goals")
          }
          .tag(3)
        
        ReportsScreen()
          .tabItem {
            Image(systemName: "chart.bar.fill")
            Text("tab.reports")
          }
          .tag(4)
        
        CategoriesManagementScreen(transactionRepository: AppConfiguration.shared.createTransactionRepository())
          .tabItem {
            Image(systemName: "tag.circle.fill")
            Text("tab.categories")
          }
          .tag(5)
        
        SettingsScreen()
          .tabItem {
            Image(systemName: "gearshape.fill")
            Text("tab.settings")
          }
          .tag(6)
      }
      .accentColor(themeManager.isDarkMode ? Color(red: 0.40, green: 0.86, blue: 0.18) : .blue)
      .background(themeManager.isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : .clear)
    }
  }
  
  @ViewBuilder
  private var selectedDetailView: some View {
    switch navigationState.selectedSidebarItem {
    case .dashboard:
      DashboardScreen()
    case .accounts:
      AccountsView()
    case .transactions:
      TransactionsScreen()
    case .budgets:
      BudgetsScreen()
    case .goals:
      GoalScreen()
    case .reports:
      ReportsScreen()
    case .categories:
      CategoriesManagementScreen(transactionRepository: AppConfiguration.shared.createTransactionRepository())
    case .settings:
      SettingsScreen()
    case .none:
      DashboardScreen()
    }
  }
}
