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
  @State private var showingAddGoal = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("dashboard.quick.actions")
        .font(.headline)
      
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
          showingAddGoal = true
        }
        
        NavigationLink(destination: ReportsScreen()) {
          VStack(spacing: 8) {
            Image(systemName: "chart.bar.fill")
              .font(.title2)
              .foregroundColor(.orange)
            
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
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
    .sheet(isPresented: $showingAddTransaction) {
      AddTransactionView(transactionViewModel: TransactionViewModel(repository: AppConfiguration.shared.createTransactionRepository()))
    }
    .sheet(isPresented: $showingAddBudget) {
      AddBudgetScreen()
        .environmentObject(BudgetViewModel())
        .environmentObject(FinanceViewModel(financeRepository: AppConfiguration.shared.createFinanceRepository()))
    }
    .sheet(isPresented: $showingAddGoal) {
      // Placeholder for Add Goal Screen - to be implemented
      Text(String(localized: "goals.add.coming.soon"))
        .font(.title2)
        .padding()
    }
  }
}
