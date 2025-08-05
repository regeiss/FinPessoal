//
//  BudgetDetailView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI
import Foundation

struct BudgetDetailView: View {
  let budget: Budget
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @Environment(\.dismiss) private var dismiss
  @State private var showingDeleteAlert = false
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          budgetHeaderSection
          budgetProgressSection
          budgetStatsSection
          recentTransactionsSection
        }
        .padding()
      }
      .navigationTitle(budget.name)
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Fechar") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            Button("Editar") {
              // Action to edit budget
            }
            
            Button("Deletar", role: .destructive) {
              showingDeleteAlert = true
            }
          } label: {
            Image(systemName: "ellipsis.circle")
          }
        }
      }
      .alert("Deletar Orçamento", isPresented: $showingDeleteAlert) {
        Button("Cancelar", role: .cancel) { }
        Button("Deletar", role: .destructive) {
          Task {
            await financeViewModel.deleteBudget(budget.id)
            dismiss()
          }
        }
      } message: {
        Text("Tem certeza que deseja deletar este orçamento? Esta ação não pode ser desfeita.")
      }
    }
  }
  
  private var budgetHeaderSection: some View {
    VStack(spacing: 12) {
      Image(systemName: budget.category.icon)
        .font(.system(size: 50))
        .foregroundColor(.blue)
      
      Text(budget.category.rawValue)
        .font(.headline)
        .foregroundColor(.secondary)
      
      Text(budget.formattedBudgetAmount)
        .font(.system(size: 32, weight: .bold, design: .rounded))
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 20)
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }
  
  private var budgetProgressSection: some View {
    VStack(spacing: 16) {
      HStack {
        Text("Progresso")
          .font(.headline)
        Spacer()
        Text("\(Int(budget.percentageUsed * 100))%")
          .font(.headline)
          .fontWeight(.bold)
          .foregroundColor(budget.isOverBudget ? .red :
                            budget.shouldAlert ? .orange : .green)
      }
      
      ProgressView(value: budget.percentageUsed, total: 1.0)
        .tint(budget.isOverBudget ? .red :
                budget.shouldAlert ? .orange : .green)
        .scaleEffect(x: 1, y: 2, anchor: .center)
      
      HStack {
        VStack(alignment: .leading) {
          Text("Gasto")
            .font(.caption)
            .foregroundColor(.secondary)
          Text(budget.formattedSpent)
            .font(.title3)
            .fontWeight(.semibold)
        }
        
        Spacer()
        
        VStack(alignment: .trailing) {
          Text("Restante")
            .font(.caption)
            .foregroundColor(.secondary)
          Text(budget.formattedRemaining)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(budget.remaining >= 0 ? .green : .red)
        }
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
  
  private var budgetStatsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Detalhes")
        .font(.headline)
      
      VStack(spacing: 8) {
        DetailRow(label: "Período", value: budget.period.rawValue)
        DetailRow(label: "Início", value: DateFormatter.transaction.string(from: budget.startDate))
        DetailRow(label: "Fim", value: DateFormatter.transaction.string(from: budget.endDate))
        DetailRow(label: "Alerta em", value: "\(Int(budget.alertThreshold * 100))%")
      }
    }
  }
  
  private var recentTransactionsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Transações Relacionadas")
        .font(.headline)
      
      let relatedTransactions = financeViewModel.transactions.filter {
        $0.category == budget.category &&
        $0.type == .expense &&
        $0.date >= budget.startDate &&
        $0.date <= budget.endDate
      }
      
      if relatedTransactions.isEmpty {
        Text("Nenhuma transação encontrada")
          .foregroundColor(.secondary)
          .italic()
      } else {
        ForEach(relatedTransactions.prefix(5)) { transaction in
          TransactionRow(transaction: transaction)
        }
        
        if relatedTransactions.count > 5 {
          Text("e mais \(relatedTransactions.count - 5) transações...")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
  }
}
