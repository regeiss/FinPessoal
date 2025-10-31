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

  var body: some View {
    if UIDevice.current.userInterfaceIdiom == .pad {
      NavigationSplitView(columnVisibility: .constant(.all)) {
        SidebarView()
          .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
      } detail: {
        selectedDetailView
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .navigationSplitViewStyle(.balanced)
    } else {
      TabView(selection: $appState.selectedTab) {
        DashboardScreen()
          .tabItem {
            Label("tab.dashboard", systemImage: "house.fill")
          }
          .tag(0)
          .accessibilityLabel(String(localized: "tab.dashboard"))
          .accessibilityHint(String(localized: "tab.dashboard.hint", defaultValue: "View your financial dashboard and overview"))

        TransactionsScreen()
          .tabItem {
            Label("tab.transactions", systemImage: "list.bullet")
          }
          .tag(1)
          .accessibilityLabel(String(localized: "tab.transactions"))
          .accessibilityHint(String(localized: "tab.transactions.hint", defaultValue: "View and manage your transactions"))

        BudgetsScreen()
          .tabItem {
            Label("tab.budgets", systemImage: "chart.pie.fill")
          }
          .tag(2)
          .accessibilityLabel(String(localized: "tab.budgets"))
          .accessibilityHint(String(localized: "tab.budgets.hint", defaultValue: "View and manage your budgets"))

        GoalScreen()
          .tabItem {
            Label("tab.goals", systemImage: "target")
          }
          .tag(3)
          .accessibilityLabel(String(localized: "tab.goals"))
          .accessibilityHint(String(localized: "tab.goals.hint", defaultValue: "View and track your financial goals"))

        ReportsScreen()
          .tabItem {
            Label("tab.reports", systemImage: "chart.bar.fill")
          }
          .tag(4)
          .accessibilityLabel(String(localized: "tab.reports"))
          .accessibilityHint(String(localized: "tab.reports.hint", defaultValue: "View financial reports and analytics"))

        CategoriesManagementScreen(
          transactionRepository: AppConfiguration.shared.createTransactionRepository(),
          categoryRepository: AppConfiguration.shared.createCategoryRepository()
        )
          .tabItem {
            Label("tab.categories", systemImage: "tag.circle.fill")
          }
          .tag(5)
          .accessibilityLabel(String(localized: "tab.categories"))
          .accessibilityHint(String(localized: "tab.categories.hint", defaultValue: "Manage transaction categories"))

        SettingsScreen()
          .tabItem {
            Label("tab.settings", systemImage: "gearshape.fill")
          }
          .tag(6)
          .accessibilityLabel(String(localized: "tab.settings"))
          .accessibilityHint(String(localized: "tab.settings.hint", defaultValue: "Access application settings"))
      }
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
    case .bills:
      BillsScreen(repository: AppConfiguration.shared.createBillRepository())
    case .budgets:
      BudgetsScreen()
    case .goals:
      GoalScreen()
    case .reports:
      ReportsScreen()
    case .categories:
      CategoriesManagementScreen(
        transactionRepository: AppConfiguration.shared.createTransactionRepository(),
        categoryRepository: AppConfiguration.shared.createCategoryRepository()
      )
    case .settings:
      SettingsScreen()
    case .none:
      DashboardScreen()
    }
  }
}
