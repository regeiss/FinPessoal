//
//  iPhoneMainView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 18/08/25.
//

import SwiftUI

struct iPhoneMainView: View {
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var financeViewModel: FinanceViewModel
  
  var body: some View {
    TabView(selection: $navigationState.selectedTab) {
      DashboardScreen()
        .tabItem {
          Image(systemName: MainTab.dashboard.icon)
          Text(MainTab.dashboard.displayName)
        }
        .tag(MainTab.dashboard)
      
      AccountsView()
        .tabItem {
          Image(systemName: MainTab.accounts.icon)
          Text(MainTab.accounts.displayName)
        }
        .tag(MainTab.accounts)
      
      TransactionsScreen()
        .tabItem {
          Image(systemName: MainTab.transactions.icon)
          Text(MainTab.transactions.displayName)
        }
        .tag(MainTab.transactions)
      
      ReportsScreen()
        .tabItem {
          Image(systemName: MainTab.reports.icon)
          Text(MainTab.reports.displayName)
        }
        .tag(MainTab.reports)
      
      SettingsScreen()
        .tabItem {
          Image(systemName: MainTab.settings.icon)
          Text(MainTab.settings.displayName)
        }
        .tag(MainTab.settings)
    }
    .task {
      await financeViewModel.loadData()
    }
  }
}
