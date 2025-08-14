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
  
  var body: some View {
    if UIDevice.current.userInterfaceIdiom == .pad {
      NavigationSplitView {
        SidebarView()
      } detail: {
        DashboardView()
      }
    } else {
      TabView(selection: $appState.selectedTab) {
        DashboardView()
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
        
        BudgetScreen()
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
        
        SettingsView()
          .tabItem {
            Image(systemName: "gearshape.fill")
            Text("tab.settings")
          }
          .tag(5)
      }
    }
  }
}
