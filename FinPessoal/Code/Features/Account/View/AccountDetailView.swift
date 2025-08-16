//
//  AccountDetailView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 16/08/25.
//

import SwiftUI

struct AccountDetailView: View {
  let account: Account
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @Environment(\.dismiss) private var dismiss
  @State private var showingDeleteAlert = false
  @State private var selectedTransaction: Transaction?
  
  var accountTransactions: [Transaction] {
    financeViewModel.transactions.filter { $0.accountId == account.id }
  }
  
  var totalIncome: Double {
    accountTransactions
      .filter { $0.type == .income }
      .reduce(0) { $0 + $1.amount }
  }
  
  var totalExpenses: Double {
    accountTransactions
      .filter { $0.type == .expense }
      .reduce(0) { $0 + $1.amount }
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          accountHeaderSection
          accountStatsSection
          recentTransactionsSection
        }
        .padding()
      }
      .navigationTitle(account.name)
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Fechar") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            Button("Editar Conta") {
              // TODO: Implementar edição de conta
            }
            
            Button("Desativar Conta", role: .destructive) {
              showingDeleteAlert = true
            }
          } label: {
            Image(systemName: "ellipsis.circle")
          }
        }
      }
      .sheet(item: $selectedTransaction) { transaction in
        TransactionDetailView(transaction: transaction)
          .environmentObject(financeViewModel)
      }
      .alert("Desativar Conta", isPresented: $showingDeleteAlert) {
        Button("Cancelar", role: .cancel) { }
        Button("Desativar", role: .destructive) {
          // TODO: Implementar desativação de conta
          dismiss()
        }
      } message: {
        Text("Tem certeza que deseja desativar esta conta? As transações serão mantidas, mas a conta não aparecerá nos relatórios.")
      }
    }
  }
  
  private var accountHeaderSection: some View {
    VStack(spacing: 16) {
      Image(systemName: account.type.icon)
        .font(.system(size: 60))
        .foregroundColor(account.type.color)
        .frame(width: 80, height: 80)
        .background(account.type.color.opacity(0.1))
        .cornerRadius(20)
      
      Text(account.type.rawValue)
        .font(.headline)
        .foregroundColor(.secondary)
      
      Text(account.formattedBalance)
        .font(.system(size: 36, weight: .bold, design: .rounded))
        .foregroundColor(account.balance >= 0 ? .green : .red)
      
      HStack {
        VStack {
          Text("Status")
            .font(.caption)
            .foregroundColor(.secondary)
          
          HStack {
            Circle()
              .fill(account.isActive ? .green : .red)
              .frame(width: 8, height: 8)
            Text(account.isActive ? "Ativa" : "Inativa")
              .font(.caption)
              .fontWeight(.medium)
          }
        }
        
        Spacer()
        
        VStack {
          Text("Moeda")
            .font(.caption)
            .foregroundColor(.secondary)
          
          Text(account.currency)
            .font(.caption)
            .fontWeight(.medium)
        }
      }
      .padding(.horizontal)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 24)
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }
  
  private var accountStatsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Estatísticas do Mês")
        .font(.headline)
        .fontWeight(.semibold)
      
      LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
      ], spacing: 16) {
        StatCard(
          title: "Receitas",
          value: CurrencyFormatter.shared.string(from: totalIncome),
          icon: "arrow.up.circle.fill",
          color: .green
        )
        
        StatCard(
          title: "Despesas",
          value: CurrencyFormatter.shared.string(from: totalExpenses),
          icon: "arrow.down.circle.fill",
          color: .red
        )
      }
      
      // Gráfico de evolução (placeholder)
      VStack(alignment: .leading, spacing: 8) {
        Text("Evolução do Saldo")
          .font(.subheadline)
          .fontWeight(.medium)
        
        RoundedRectangle(cornerRadius: 8)
          .fill(Color(.systemGray5))
          .frame(height: 120)
          .overlay(
            Text("Gráfico em desenvolvimento")
              .foregroundColor(.secondary)
              .font(.caption)
          )
      }
    }
  }
  
  private var recentTransactionsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Transações Recentes")
          .font(.headline)
          .fontWeight(.semibold)
        
        Spacer()
        
        if accountTransactions.count > 5 {
          Button("Ver Todas") {
            // TODO: Navegar para lista completa de transações da conta
          }
          .font(.caption)
          .foregroundColor(.blue)
        }
      }
      
      if accountTransactions.isEmpty {
        VStack(spacing: 12) {
          Image(systemName: "list.bullet")
            .font(.system(size: 40))
            .foregroundColor(.secondary)
          
          Text("Nenhuma transação")
            .font(.headline)
            .foregroundColor(.secondary)
          
          Text("As transações desta conta aparecerão aqui")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
      } else {
        ForEach(accountTransactions.prefix(5)) { transaction in
          Button {
            selectedTransaction = transaction
          } label: {
            TransactionRow(transaction: transaction)
          }
          .buttonStyle(.plain)
        }
        
        if accountTransactions.count > 5 {
          Text("e mais \(accountTransactions.count - 5) transações...")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 8)
        }
      }
    }
  }
}
