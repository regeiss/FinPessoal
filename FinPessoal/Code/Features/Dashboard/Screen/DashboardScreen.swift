//
//  DashboardScreen.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct DashboardScreen: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  
  var body: some View {
    NavigationView {
      ScrollView {
        LazyVStack(spacing: 20) {
          balanceSection
          budgetAlertsSection
          quickStatsSection
          budgetOverviewSection
          recentTransactionsSection
          accountsOverviewSection
        }
        .padding(.horizontal)
      }
      .navigationTitle("Dashboard")
      .refreshable {
        await financeViewModel.loadData()
      }
    }
  }
  
  private var balanceSection: some View {
    VStack(spacing: 12) {
      Text("Saldo Total")
        .font(.headline)
        .foregroundColor(.secondary)
      
      Text(financeViewModel.formattedTotalBalance)
        .font(.system(size: 36, weight: .bold, design: .rounded))
        .foregroundColor(.primary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 24)
    .background(Color(.systemGray6))
    .cornerRadius(16)
  }
  
  private var budgetAlertsSection: some View {
    Group {
      if !financeViewModel.budgetsNeedingAttention.isEmpty {
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Image(systemName: "exclamationmark.triangle.fill")
              .foregroundColor(.orange)
            Text("Alertas de Orçamento")
              .font(.headline)
              .fontWeight(.semibold)
            Spacer()
            NavigationLink("Ver Todos") {
              BudgetsScreen()
                .environmentObject(financeViewModel)
            }
            .font(.caption)
            .foregroundColor(.blue)
          }
          
          ForEach(financeViewModel.budgetsNeedingAttention.prefix(3)) { budget in
            BudgetAlertCard(budget: budget)
          }
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
      }
    }
  }
  
  private var quickStatsSection: some View {
    LazyVGrid(columns: [
      GridItem(.flexible()),
      GridItem(.flexible())
    ], spacing: 16) {
      StatCard(
        title: "Receitas",
        value: "R$ 3.500,00",
        icon: "arrow.up.circle.fill",
        color: .green
      )
      
      StatCard(
        title: "Despesas",
        value: "R$ 1.530,50",
        icon: "arrow.down.circle.fill",
        color: .red
      )
    }
  }
  
  private var budgetOverviewSection: some View {
    Group {
      if !financeViewModel.budgets.isEmpty {
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Text("Orçamentos")
              .font(.headline)
            Spacer()
            NavigationLink("Ver Todos") {
              BudgetsScreen()
                .environmentObject(financeViewModel)
            }
            .font(.caption)
            .foregroundColor(.blue)
          }
          
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
              ForEach(financeViewModel.budgets.prefix(3)) { budget in
                BudgetSummaryCard(budget: budget)
              }
            }
            .padding(.horizontal, 4)
          }
        }
      }
    }
  }
  
  private var recentTransactionsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Transações Recentes")
          .font(.headline)
        Spacer()
        NavigationLink("Ver Todas") {
          TransactionsView()
            .environmentObject(financeViewModel)
        }
        .font(.caption)
        .foregroundColor(.blue)
      }
      
      ForEach(financeViewModel.transactions.prefix(5)) { transaction in
        TransactionRow(transaction: transaction)
      }
    }
  }
  
  private var accountsOverviewSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Suas Contas")
          .font(.headline)
        Spacer()
        NavigationLink("Ver Todas") {
          AccountsView()
            .environmentObject(financeViewModel)
        }
        .font(.caption)
        .foregroundColor(.blue)
      }
      
      ForEach(financeViewModel.accounts) { account in
        AccountCard(account: account)
      }
    }
  }
}
