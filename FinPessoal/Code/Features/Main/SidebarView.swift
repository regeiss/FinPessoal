//
//  SidebarView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import SwiftUI

struct SidebarView: View {
  @EnvironmentObject var appState: AppState
  
  var body: some View {
    List {
      NavigationLink(destination: DashboardView()) {
        Label("tab.dashboard", systemImage: "house.fill")
      }
      
      NavigationLink(destination: TransactionsScreen()) {
        Label("tab.transactions", systemImage: "list.bullet")
      }
      
      NavigationLink(destination: BudgetScreen()) {
        Label("tab.budgets", systemImage: "chart.pie.fill")
      }
      
      NavigationLink(destination: GoalScreen()) {
        Label("tab.goals", systemImage: "target")
      }
      
      NavigationLink(destination: ReportsScreen()) {
        Label("tab.reports", systemImage: "chart.bar.fill")
      }
      
      NavigationLink(destination: SettingsView()) {
        Label("tab.settings", systemImage: "gearshape.fill")
      }
    }
    .navigationTitle("app.name")
  }
}
