//
//  BudgetScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 13/08/25.
//

import SwiftUI

struct BudgetScreen: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  
  var body: some View {
    NavigationView {
      ScrollView {
        LazyVStack(spacing: 16) {
          if financeViewModel.budgets.isEmpty {
            emptyStateView
          } else {
            budgetListSection
          }
        }
        .padding(.horizontal)
      }
      .navigationTitle("Orçamentos")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Adicionar") {
            // TODO: Adicionar orçamento
          }
        }
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
        // TODO: Adicionar orçamento
      }
      .buttonStyle(.borderedProminent)
    }
    .padding(.vertical, 60)
  }
  
  private var budgetListSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Todos os Orçamentos")
        .font(.headline)
        .fontWeight(.semibold)
      
      ForEach(financeViewModel.budgets) { budget in
        BudgetCard(budget: budget)
      }
    }
  }
}
