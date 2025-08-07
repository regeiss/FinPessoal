//
//  DashboardScreen.swift (Cross-Platform)
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct DashboardScreen: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @EnvironmentObject var themeManager: ThemeManager
  @Environment(\.colorScheme) var colorScheme
  @StateObject private var coordinator = NavigationCoordinator()
  
  var body: some View {
    SafeContentContainer {
      LazyVStack(spacing: PlatformInfo.isIPad ? 32 : 20) {
        balanceSection
        
        if !financeViewModel.budgetsNeedingAttention.isEmpty {
          budgetAlertsSection
        }
        
        quickStatsSection
        
        if !financeViewModel.budgets.isEmpty {
          budgetOverviewSection
        }
        
        recentTransactionsSection
        accountsOverviewSection
      }
    }
    .crossPlatformNavigation()
    .navigationTitle("Dashboard")
    .refreshable {
      await financeViewModel.loadData()
    }
    .toolbar {
      CrossPlatformToolbarContent(
        leadingTitle: "Menu",
        trailingTitle: "Adicionar",
        trailingAction: {
          coordinator.presentSheet()
        }
      )
    }
    .sheet(isPresented: $coordinator.isShowingSheet) {
      AddTransactionSheet()
        .safePresentationStyle()
        .environmentObject(financeViewModel)
    }
    .environmentObject(coordinator)
  }
  
  private var balanceSection: some View {
    ResponsiveCard {
      VStack(spacing: PlatformInfo.isIPad ? 16 : 12) {
        HStack {
          Text("Saldo Total")
            .font(PlatformInfo.isIPad ? .title2 : .headline)
            .foregroundColor(.adaptiveSecondaryLabel)
          
          Spacer()
          
          Button(action: {
            // Ação para ocultar/mostrar saldo
          }) {
            Image(systemName: "eye")
              .font(.title3)
              .foregroundColor(.blue)
          }
        }
        
        Text(financeViewModel.formattedTotalBalance)
          .font(.system(
            size: PlatformInfo.isIPad ? 48 : 36,
            weight: .bold,
            design: .rounded
          ))
          .foregroundColor(.adaptiveLabel)
          .multilineTextAlignment(.center)
        
        if PlatformInfo.isIPad {
          HStack(spacing: 24) {
            BalanceIndicator(
              title: "Este Mês",
              value: "+R$ 1.250,00",
              isPositive: true
            )
            
            Divider()
              .frame(height: 40)
            
            BalanceIndicator(
              title: "Variação",
              value: "+12,5%",
              isPositive: true
            )
          }
        }
      }
    }
  }
  
  private var budgetAlertsSection: some View {
    ResponsiveCard {
      VStack(alignment: .leading, spacing: PlatformInfo.isIPad ? 20 : 16) {
        HStack {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.orange)
            .font(PlatformInfo.isIPad ? .title2 : .headline)
          
          Text("Alertas de Orçamento")
            .font(PlatformInfo.isIPad ? .title2 : .headline)
            .fontWeight(.semibold)
            .foregroundColor(.adaptiveLabel)
          
          Spacer()
          
          NavigationLink("Ver Todos") {
            BudgetsView()
          }
          .font(.callout)
          .foregroundColor(.blue)
        }
        
        if PlatformInfo.isIPad {
          LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ForEach(financeViewModel.budgetsNeedingAttention.prefix(4)) { budget in
              CompactBudgetAlertCard(budget: budget)
            }
          }
        } else {
          ForEach(financeViewModel.budgetsNeedingAttention.prefix(3)) { budget in
            BudgetAlertCard(budget: budget)
          }
        }
      }
    }
  }
  
  private var quickStatsSection: some View {
    ResponsiveGrid {
      ThemedStatCard(
        title: "Receitas",
        value: "R$ 3.500,00",
        icon: "arrow.up.circle.fill",
        color: .income
      )
      
      ThemedStatCard(
        title: "Despesas",
        value: "R$ 1.530,50",
        icon: "arrow.down.circle.fill",
        color: .expense
      )
      
      if PlatformInfo.isIPad {
        ThemedStatCard(
          title: "Investimentos",
          value: "R$ 25.780,90",
          icon: "chart.line.uptrend.xyaxis",
          color: .blue
        )
      }
    }
  }
  
  private var budgetOverviewSection: some View {
    ResponsiveCard {
      VStack(alignment: .leading, spacing: PlatformInfo.isIPad ? 20 : 16) {
        HStack {
          Text("Orçamentos")
            .font(PlatformInfo.isIPad ? .title2 : .headline)
            .fontWeight(.semibold)
            .foregroundColor(.adaptiveLabel)
          
          Spacer()
          
          NavigationLink("Ver Todos") {
            BudgetsView()
          }
          .font(.callout)
          .foregroundColor(.blue)
        }
        
        if PlatformInfo.isIPad {
          LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
            ForEach(financeViewModel.budgets.prefix(6)) { budget in
              BudgetSummaryCard(budget: budget)
            }
          }
        } else {
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
    ResponsiveCard {
      VStack(alignment: .leading, spacing: PlatformInfo.isIPad ? 20 : 16) {
        HStack {
          Text("Transações Recentes")
            .font(PlatformInfo.isIPad ? .title2 : .headline)
            .fontWeight(.semibold)
            .foregroundColor(.adaptiveLabel)
          
          Spacer()
          
          NavigationLink("Ver Todas") {
            TransactionsView()
          }
          .font(.callout)
          .foregroundColor(.blue)
        }
        
        LazyVStack(spacing: PlatformInfo.isIPad ? 12 : 8) {
          ForEach(financeViewModel.transactions.prefix(PlatformInfo.isIPad ? 8 : 5)) { transaction in
            ModernTransactionRow(transaction: transaction)
          }
        }
      }
    }
  }
  
  private var accountsOverviewSection: some View {
    ResponsiveCard {
      VStack(alignment: .leading, spacing: PlatformInfo.isIPad ? 20 : 16) {
        HStack {
          Text("Suas Contas")
            .font(PlatformInfo.isIPad ? .title2 : .headline)
            .fontWeight(.semibold)
            .foregroundColor(.adaptiveLabel)
          
          Spacer()
          
          NavigationLink("Ver Todas") {
            AccountsView()
          }
          .font(.callout)
          .foregroundColor(.blue)
        }
        
        if PlatformInfo.isIPad {
          LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ForEach(financeViewModel.accounts) { account in
              AccountCard(account: account)
            }
          }
        } else {
          LazyVStack(spacing: 12) {
            ForEach(financeViewModel.accounts) { account in
              AccountCard(account: account)
            }
          }
        }
      }
    }
  }
}

// MARK: - Supporting Views

struct BalanceIndicator: View {
  let title: String
  let value: String
  let isPositive: Bool
  
  var body: some View {
    VStack(spacing: 4) {
      Text(title)
        .font(.caption)
        .foregroundColor(.adaptiveSecondaryLabel)
      
      Text(value)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(isPositive ? .green : .red)
    }
  }
}

struct ModernTransactionRow: View {
  let transaction: Transaction
  
  var body: some View {
    HStack(spacing: PlatformInfo.isIPad ? 16 : 12) {
      Image(systemName: transaction.category.icon)
        .font(PlatformInfo.isIPad ? .title2 : .title3)
        .foregroundColor(.blue)
        .frame(
          width: PlatformInfo.isIPad ? 40 : 32,
          height: PlatformInfo.isIPad ? 40 : 32
        )
        .background(Color.blue.opacity(0.1))
        .cornerRadius(PlatformInfo.isIPad ? 10 : 8)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(transaction.description)
          .font(PlatformInfo.isIPad ? .body : .headline)
          .fontWeight(.medium)
        
        Text(transaction.category.displayName)
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 4) {
        Text(transaction.formattedAmount)
          .font(PlatformInfo.isIPad ? .body : .headline)
          .fontWeight(.semibold)
          .foregroundColor(transaction.type == .expense ? .red : .green)
        
        Text(transaction.date, style: .date)
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
    .padding(.vertical, 4)
  }
}

struct AddTransactionSheet: View {
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationStack {
      VStack {
        Text("Adicionar Transação")
          .font(.title)
          .padding()
        
        Spacer()
        
        Button("Fechar") {
          dismiss()
        }
        .buttonStyle(.borderedProminent)
      }
      .navigationTitle("Nova Transação")
      .toolbar {
        CrossPlatformToolbarContent(
          leadingTitle: "Cancelar",
          trailingTitle: "Salvar",
          leadingAction: {
            dismiss()
          }
        )
      }
    }
  }
}
