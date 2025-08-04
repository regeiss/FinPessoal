//
//  iPhoneMainView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//
import SwiftUI

struct IPhoneMainView: View {
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var financeViewModel: FinanceViewModel
  
  var body: some View {
    TabView(selection: $navigationState.selectedTab) {
      DashboardScreen()
        .tabItem {
          Image(systemName: MainTab.dashboard.icon)
          Text(MainTab.dashboard.rawValue)
        }
        .tag(MainTab.dashboard)
      
      AccountsView()
        .tabItem {
          Image(systemName: MainTab.accounts.icon)
          Text(MainTab.accounts.rawValue)
        }
        .tag(MainTab.accounts)
      
      TransactionsView()
        .tabItem {
          Image(systemName: MainTab.transactions.icon)
          Text(MainTab.transactions.rawValue)
        }
        .tag(MainTab.transactions)
      
      ReportsView()
        .tabItem {
          Image(systemName: MainTab.reports.icon)
          Text(MainTab.reports.rawValue)
        }
        .tag(MainTab.reports)
      
      SettingsScreen()
        .tabItem {
          Image(systemName: MainTab.settings.icon)
          Text(MainTab.settings.rawValue)
        }
        .tag(MainTab.settings)
    }
    .task {
      await financeViewModel.loadData()
    }
  }
}
