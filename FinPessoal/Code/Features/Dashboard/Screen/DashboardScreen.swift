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
  @StateObject private var refreshCoordinator = RefreshCoordinator()
  @StateObject private var transitionCoordinator = LoadingTransitionCoordinator()
  @State private var showingSettings = false
  @State private var previousCompletedCount = 0

  var body: some View {
    PullToRefreshView(
      isRefreshing: $refreshCoordinator.isRefreshing,
      onRefresh: handleRefresh
    ) {
      LazyVStack(spacing: 20) {
        // Balance Card with skeleton
        StaggeredRevealCard(
          coordinator: transitionCoordinator,
          staggerIndex: 0
        ) {
          BalanceCardView(
            totalBalance: viewModel.totalBalance,
            monthlyExpenses: viewModel.monthlyExpenses
          )
          .withParallax(speed: 0.7, axis: .vertical)
        } skeleton: {
          BalanceCardSkeleton()
        }

        // Spending Trends Chart
        if let chartData = viewModel.spendingTrendsData {
          StaggeredRevealCard(
            coordinator: transitionCoordinator,
            staggerIndex: 1
          ) {
            AnimatedCard {
              VStack(alignment: .leading, spacing: 16) {
                HStack {
                  Text(String(localized: "Spending Trends"))
                    .font(.headline)
                  Spacer()
                  chartRangePicker
                }

                SpendingTrendsChart(data: chartData)
              }
              .padding()
            }
            .withGradientAnimation(
              colors: [Color.oldMoney.accent.opacity(0.1), .clear],
              duration: 3.0,
              style: .linear(.topLeading, .bottomTrailing)
            )
          } skeleton: {
            SpendingTrendsChartSkeleton()
          }
        }

        // Budget Alerts (only show if there are alerts)
        if !viewModel.budgetAlerts.isEmpty {
          StaggeredRevealCard(
            coordinator: transitionCoordinator,
            staggerIndex: 2
          ) {
            BudgetAlertsView(budgets: viewModel.budgetAlerts)
          } skeleton: {
            BalanceCardSkeleton()
          }
        }

        // Recent Transactions with skeleton
        StaggeredRevealCard(
          coordinator: transitionCoordinator,
          staggerIndex: 3
        ) {
          RecentTransactionScreen(transactions: viewModel.recentTransactions)
        } skeleton: {
          RecentTransactionsSkeleton(rowCount: 5)
        }

        // Quick Actions
        QuickActionsView()
          .padding(.bottom, 20)
      }
      .padding()
    }
    .coordinateSpace(name: "scroll")
    .background(Color.oldMoney.background)
    .navigationTitle(String(localized: "tab.dashboard"))
    .blurredNavigationBar()
    .toolbar {
      if UIDevice.current.userInterfaceIdiom != .pad {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingSettings = true
          } label: {
            Image(systemName: "gearshape")
          }
          .accessibilityLabel(String(localized: "Settings"))
          .accessibilityHint(String(localized: "Open application settings"))
        }
      }
    }
    .accessibilityAction(named: String(localized: "Refresh Dashboard")) {
      viewModel.loadDashboardData()
    }
    .alert(String(localized: "Erro"), isPresented: .constant(viewModel.error != nil)) {
      Button(String(localized: "OK")) {
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
    .overlay {
      if viewModel.showMilestoneCelebration,
         let config = viewModel.milestoneCelebrationConfig {
        CelebrationView(
          config: config
        ) {
          viewModel.showMilestoneCelebration = false
          viewModel.milestoneCelebrationConfig = nil
        }
        .allowsHitTesting(false)
      }
    }
    .sheet(isPresented: $showingSettings) {
      SettingsScreen()
    }
    .onAppear {
      print("DashboardScreen: onAppear called")

      if viewModel.recentTransactions.isEmpty {
        // First load - show skeleton
        transitionCoordinator.reset()
        viewModel.loadDashboardData()

        // Trigger transition after data loads
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          transitionCoordinator.transitionToContent(staggerIndex: 0)
        }
      } else {
        // Subsequent loads - skip skeleton
        transitionCoordinator.transitionToContent(staggerIndex: 0)
      }

      // Only log analytics if not using mock data
      if !AppConfiguration.shared.useMockData {
        Analytics.logEvent("dashboard_viewed", parameters: nil)
      }
    }
  }

  // MARK: - Helper Views

  private var chartRangePicker: some View {
    Picker(String(localized: "Range"), selection: $viewModel.chartDateRange) {
      Text(String(localized: "7 Days")).tag(ChartDateRange.sevenDays)
      Text(String(localized: "30 Days")).tag(ChartDateRange.thirtyDays)
    }
    .pickerStyle(.segmented)
    .frame(width: 150)
    .onChange(of: viewModel.chartDateRange) { _, newValue in
      viewModel.updateChartRange(newValue)
    }
  }

  // MARK: - Actions

  private func handleRefresh() async {
    await refreshCoordinator.executeRefresh {
      try await viewModel.loadDashboardData()
    }
  }
}
