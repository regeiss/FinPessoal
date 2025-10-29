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
      NavigationStack {
        DashboardScreen()
      }
      .tabItem {
        Image(systemName: MainTab.dashboard.icon)
        Text(MainTab.dashboard.displayName)
      }
      .tag(MainTab.dashboard)

      NavigationStack {
        AccountsView()
      }
      .tabItem {
        Image(systemName: MainTab.accounts.icon)
        Text(MainTab.accounts.displayName)
      }
      .tag(MainTab.accounts)

      NavigationStack {
        TransactionsScreen()
      }
      .tabItem {
        Image(systemName: MainTab.transactions.icon)
        Text(MainTab.transactions.displayName)
      }
      .tag(MainTab.transactions)

      NavigationStack {
        BillsScreen(repository: AppConfiguration.shared.createBillRepository())
      }
      .tabItem {
        Image(systemName: MainTab.bills.icon)
        Text(MainTab.bills.displayName)
      }
      .tag(MainTab.bills)

      NavigationStack {
        MoreScreen()
      }
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
