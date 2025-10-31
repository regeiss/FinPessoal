//
//  QuickActionsView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 13/08/25.
//

import SwiftUI

struct QuickActionsView: View {
  @State private var showingAddTransaction = false
  @State private var showingAddBudget = false
  @State private var showingGoalScreen = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("dashboard.quick.actions")
        .font(.headline)
        .accessibilityAddTraits(.isHeader)

      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
        QuickActionButton(
          icon: "plus.circle.fill",
          title: "dashboard.add.transaction",
          color: .blue
        ) {
          showingAddTransaction = true
        }

        QuickActionButton(
          icon: "chart.pie.fill",
          title: "dashboard.create.budget",
          color: .green
        ) {
          showingAddBudget = true
        }

        QuickActionButton(
          icon: "target",
          title: "dashboard.set.goal",
          color: .purple
        ) {
          showingGoalScreen = true
        }

        NavigationLink(destination: ReportsScreen()) {
          VStack(spacing: 8) {
            Image(systemName: "chart.bar.fill")
              .font(.title2)
              .foregroundColor(.orange)
              .accessibilityHidden(true)

            Text(LocalizedStringKey("dashboard.view.reports"))
              .font(.caption)
              .multilineTextAlignment(.center)
              .foregroundColor(.primary)
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color(.systemBackground))
          .cornerRadius(8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "dashboard.view.reports"))
        .accessibilityHint(String(localized: "dashboard.view.reports.hint", defaultValue: "Navigate to reports screen"))
        .accessibilityAddTraits(.isButton)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
    .accessibilityElement(children: .contain)
    .sheet(isPresented: $showingAddTransaction) {
      AddTransactionView(transactionViewModel: TransactionViewModel(repository: AppConfiguration.shared.createTransactionRepository()))
    }
    .sheet(isPresented: $showingAddBudget) {
      AddBudgetScreen()
        .environmentObject(BudgetViewModel())
        .environmentObject(FinanceViewModel(financeRepository: AppConfiguration.shared.createFinanceRepository()))
    }
    .sheet(isPresented: $showingGoalScreen) {
      GoalScreen()
    }
  }
}
