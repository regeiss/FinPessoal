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
  @State private var showingSettings = false
  
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
      
      GoalScreen()
        .tabItem {
          Image(systemName: MainTab.goals.icon)
          Text(MainTab.goals.displayName)
        }
        .tag(MainTab.goals)
      
      MoreScreen()
        .tabItem {
          Image(systemName: MainTab.more.icon)
          Text(MainTab.more.displayName)
        }
        .tag(MainTab.more)
    }
    .task {
      await financeViewModel.loadData()
    }
  }
}
