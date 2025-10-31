//
//  BudgetScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 13/08/25.
//

import SwiftUI

struct BudgetsScreen: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @StateObject private var budgetViewModel = BudgetViewModel()
  @State private var showingAddBudget = false
  @State private var selectedBudget: Budget?
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 16) {
        if financeViewModel.budgets.isEmpty {
          emptyStateView
        } else {
          budgetSummarySection
          budgetAlertSection
          budgetListSection
        }
      }
      .padding(.horizontal)
    }
    .navigationTitle(String(localized: "sidebar.budgets"))
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          showingAddBudget = true
        } label: {
          Image(systemName: "plus")
        }
        .accessibilityLabel("Add Budget")
        .accessibilityHint("Opens form to create a new budget")
      }
    }
    .sheet(isPresented: $showingAddBudget) {
      AddBudgetScreen()
        .environmentObject(budgetViewModel)
        .environmentObject(financeViewModel)
    }
    .sheet(item: $selectedBudget) { budget in
      BudgetDetailSheet(budget: budget)
        .environmentObject(financeViewModel)
    }
    .refreshable {
      await financeViewModel.loadData()
    }
  }
  
  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "chart.pie")
        .font(.system(size: 60))
        .foregroundColor(.blue)
        .accessibilityHidden(true)

      Text(String(localized: "budgets.empty.title"))
        .font(.title2)
        .fontWeight(.semibold)

      Text(String(localized: "budgets.empty.description"))
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding(.horizontal)

      Button(String(localized: "budgets.create.first")) {
        showingAddBudget = true
      }
      .buttonStyle(.borderedProminent)
      .accessibilityLabel("Create Your First Budget")
      .accessibilityHint("Opens form to create your first budget")
    }
    .padding(.vertical, 60)
    .accessibilityElement(children: .contain)
    .accessibilityLabel("No Budgets")
    .accessibilityHint("You haven't created any budgets yet. Tap the button to create your first budget")
  }
  
  private var budgetSummarySection: some View {
    VStack(spacing: 16) {
      HStack {
        VStack(alignment: .leading) {
          Text(String(localized: "budgets.total.budgeted"))
            .font(.caption)
            .foregroundColor(.secondary)
          Text(formatCurrency(financeViewModel.totalBudgetAmount))
            .font(.title2)
            .fontWeight(.bold)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Total Budgeted")
        .accessibilityValue(formatCurrency(financeViewModel.totalBudgetAmount))

        Spacer()

        VStack(alignment: .trailing) {
          Text(String(localized: "budgets.total.spent"))
            .font(.caption)
            .foregroundColor(.secondary)
          Text(formatCurrency(financeViewModel.totalBudgetSpent))
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.red)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Total Spent")
        .accessibilityValue(formatCurrency(financeViewModel.totalBudgetSpent))
      }

      ProgressView(value: financeViewModel.totalBudgetSpent, total: financeViewModel.totalBudgetAmount)
        .tint(.blue)
        .accessibilityLabel("Overall Budget Progress")
        .accessibilityValue("\(Int((financeViewModel.totalBudgetSpent / max(financeViewModel.totalBudgetAmount, 1)) * 100))% used, \(formatCurrency(financeViewModel.totalBudgetSpent)) of \(formatCurrency(financeViewModel.totalBudgetAmount))")

      HStack {
        Text(String(localized: "budgets.remaining", defaultValue: "Restante: \(formatCurrency(financeViewModel.totalBudgetAmount - financeViewModel.totalBudgetSpent))"))
          .font(.caption)
          .foregroundColor(.secondary)
        Spacer()
        Text(String(localized: "budgets.used.percentage", defaultValue: "\(Int((financeViewModel.totalBudgetSpent / financeViewModel.totalBudgetAmount) * 100))% usado"))
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .accessibilityElement(children: .combine)
      .accessibilityLabel("Budget Summary")
      .accessibilityValue("Remaining: \(formatCurrency(financeViewModel.totalBudgetAmount - financeViewModel.totalBudgetSpent)), \(Int((financeViewModel.totalBudgetSpent / max(financeViewModel.totalBudgetAmount, 1)) * 100))% used")
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
    .accessibilityElement(children: .contain)
  }
  
  private var budgetAlertSection: some View {
    Group {
      if !financeViewModel.budgetsNeedingAttention.isEmpty {
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Image(systemName: "exclamationmark.triangle.fill")
              .foregroundColor(.orange)
              .accessibilityHidden(true)
            Text(String(localized: "budgets.alerts.title"))
              .font(.headline)
              .fontWeight(.semibold)
          }
          .accessibilityElement(children: .combine)
          .accessibilityLabel("Budget Alerts")
          .accessibilityAddTraits(.isHeader)

          ForEach(financeViewModel.budgetsNeedingAttention) { budget in
            BudgetAlertCard(budget: budget)
          }
        }
      }
    }
  }
  
  private var budgetListSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(String(localized: "budgets.all.title"))
        .font(.headline)
        .fontWeight(.semibold)
        .accessibilityAddTraits(.isHeader)

      ForEach(financeViewModel.budgets) { budget in
        BudgetCard(budget: budget)
          .onTapGesture { selectedBudget = budget }
          .accessibilityAddTraits(.isButton)
          .accessibilityHint("Double tap to view budget details")
      }
    }
  }
  
  private func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }
}

