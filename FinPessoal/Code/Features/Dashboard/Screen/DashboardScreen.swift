//
//  DashboardScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import SwiftUI
import Firebase

struct DashboardScreen: View {
  @StateObject private var viewModel = DashboardViewModel()
  
  var body: some View {
    NavigationView {
      ScrollView {
        LazyVStack(spacing: 20) {
          // Balance Card
          BalanceCardView(
            totalBalance: viewModel.totalBalance,
            monthlyExpenses: viewModel.monthlyExpenses
          )
          
          // Budget Alerts
          if !viewModel.budgetAlerts.isEmpty {
            BudgetAlertsView(budgets: viewModel.budgetAlerts)
          }
          
          // Recent Transactions
          RecentTransactionScreen(transactions: viewModel.recentTransactions)
          
          // Quick Actions
          QuickActionsView()
        }
        .padding()
      }
      .navigationTitle("dashboard.title")
      .refreshable {
        viewModel.loadDashboardData()
      }
    }
    .onAppear {
      viewModel.loadDashboardData()
      Analytics.logEvent("dashboard_viewed", parameters: nil)
    }
  }
}
