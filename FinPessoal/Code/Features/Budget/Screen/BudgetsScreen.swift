//
//  BudgetsScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct BudgetsScreen: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @StateObject private var budgetViewModel = BudgetViewModel()
  @State private var showingAddBudget = false
  @State private var selectedBudget: Budget?
  
  var body: some View {
    NavigationView {
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
      .navigationTitle("Orçamentos")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Adicionar") {
            showingAddBudget = true
          }
        }
      }
      .sheet(isPresented: $showingAddBudget) {
        AddBudgetScreen()
          .environmentObject(budgetViewModel)
          .environmentObject(financeViewModel)
      }
      .sheet(item: $selectedBudget) { budget in
        BudgetDetailView(budget: budget)
          .environmentObject(financeViewModel)
      }
      .refreshable {
        await financeViewModel.loadData()
      }
    }
  }
  
  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "chart.pie")
        .font(.system(size: 60))
        .foregroundColor(.blue)
      
      Text("Nenhum Orçamento")
        .font(.title2)
        .fontWeight(.semibold)
      
      Text("Crie seu primeiro orçamento para começar a controlar seus gastos")
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding(.horizontal)
      
      Button("Criar Orçamento") {
        showingAddBudget = true
      }
      .buttonStyle(.borderedProminent)
    }
    .padding(.vertical, 60)
  }
  
  private var budgetSummarySection: some View {
    VStack(spacing: 16) {
      HStack {
        VStack(alignment: .leading) {
          Text("Total Orçado")
            .font(.caption)
            .foregroundColor(.secondary)
          Text(formatCurrency(financeViewModel.totalBudgetAmount))
            .font(.title2)
            .fontWeight(.bold)
        }
        
        Spacer()
        
        VStack(alignment: .trailing) {
          Text("Total Gasto")
            .font(.caption)
            .foregroundColor(.secondary)
          Text(formatCurrency(financeViewModel.totalBudgetSpent))
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.red)
        }
      }
      
      ProgressView(value: financeViewModel.totalBudgetSpent, total: financeViewModel.totalBudgetAmount)
        .tint(.blue)
      
      HStack {
        Text("Restante: \(formatCurrency(financeViewModel.totalBudgetAmount - financeViewModel.totalBudgetSpent))")
          .font(.caption)
          .foregroundColor(.secondary)
        Spacer()
        Text("\(Int((financeViewModel.totalBudgetSpent / financeViewModel.totalBudgetAmount) * 100))% usado")
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
  
  private var budgetAlertSection: some View {
    Group {
      if !financeViewModel.budgetsNeedingAttention.isEmpty {
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Image(systemName: "exclamationmark.triangle.fill")
              .foregroundColor(.orange)
            Text("Alertas de Orçamento")
              .font(.headline)
              .fontWeight(.semibold)
          }
          
          ForEach(financeViewModel.budgetsNeedingAttention) { budget in
            BudgetAlertCard(budget: budget)
          }
        }
      }
    }
  }
  
  private var budgetListSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Todos os Orçamentos")
        .font(.headline)
        .fontWeight(.semibold)
      
      ForEach(financeViewModel.budgets) { budget in
        BudgetCard(budget: budget) {
          selectedBudget = budget
        }
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
