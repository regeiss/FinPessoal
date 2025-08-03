//
//  DetailView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct DetailView: View {
  @EnvironmentObject var navigationState: NavigationState
  
  var body: some View {
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
        BudgetsScreen()
      case .goals:
        GoalsScreen()
      case .settings:
        SettingsScreen()
      case .none:
        DashboardScreen()
      }
    }
    .navigationBarTitleDisplayMode(.large)
  }
}
