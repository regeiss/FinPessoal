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
  @State private var showingSettings = false
  
  var body: some View {
    NavigationView {
      ScrollView {
        LazyVStack(spacing: 20) {
          // Balance Card
          BalanceCardView(
            totalBalance: viewModel.totalBalance,
            monthlyExpenses: viewModel.monthlyExpenses
          )
          .redacted(reason: viewModel.isLoading ? .placeholder : [])
          
          // Budget Alerts (only show if there are alerts)
          if !viewModel.budgetAlerts.isEmpty {
            BudgetAlertsView(budgets: viewModel.budgetAlerts)
          }
          
          // Recent Transactions
          RecentTransactionScreen(transactions: viewModel.recentTransactions)
            .redacted(reason: viewModel.isLoading ? .placeholder : [])
          
          // Quick Actions
          QuickActionsView()
        }
        .padding()
      }
      .navigationTitle(String(localized: "dashboard.title", defaultValue: "Painel"))
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingSettings = true
          } label: {
            Image(systemName: "gear")
          }
        }
      }
      .refreshable {
        await MainActor.run {
          viewModel.loadDashboardData()
        }
      }
      .overlay {
        if viewModel.isLoading && viewModel.recentTransactions.isEmpty {
          ProgressView(String(localized: "dashboard.loading", defaultValue: "Carregando..."))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
      }
      .alert("Erro", isPresented: .constant(viewModel.error != nil)) {
        Button("OK") {
          viewModel.error = nil
        }
        Button(String(localized: "common.try.again", defaultValue: "Tentar Novamente")) {
          viewModel.error = nil
          viewModel.loadDashboardData()
        }
      } message: {
        if let error = viewModel.error {
          Text(error.localizedDescription)
        }
      }
    }
    .sheet(isPresented: $showingSettings) {
      SettingsScreen()
    }
    .onAppear {
      print("DashboardScreen: onAppear called")
      viewModel.loadDashboardData()
      
      // Only log analytics if not using mock data
      if !AppConfiguration.shared.useMockData {
        Analytics.logEvent("dashboard_viewed", parameters: nil)
      }
    }
  }
}
