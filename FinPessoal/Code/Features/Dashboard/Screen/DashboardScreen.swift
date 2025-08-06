//
//  DashboardScreen.swift (iPad Otimizado)
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import SwiftUI

struct DashboardScreen: View {
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @EnvironmentObject var themeManager: ThemeManager
  @EnvironmentObject var navigationState: NavigationState
  @Environment(\.colorScheme) var colorScheme
  @StateObject private var coordinator = NavigationCoordinator()
  
  var body: some View {
    SafeContentContainer {
      LazyVStack(spacing: DeviceInfo.isIPad ? 32 : 20) {
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
    .modernNavigationStyle()
    .refreshable {
      await financeViewModel.loadData()
    }
    .toolbar {
      ResponsiveToolbar(actions: [
        ToolbarAction(title: "Adicionar", icon: "plus", action: {
          coordinator.presentSheet()
        }),
        ToolbarAction(title: "Filtrar", icon: "line.3.horizontal.decrease.circle", action: {
          // Ação de filtro
        })
      ])
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
      VStack(spacing: DeviceInfo.isIPad ? 16 : 12) {
        HStack {
          Text("Saldo Total")
            .font(DeviceInfo.isIPad ? .title2 : .headline)
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
            size: DeviceInfo.isIPad ? 48 : 36,
            weight: .bold,
            design: .rounded
          ))
          .foregroundColor(.adaptiveLabel)
          .multilineTextAlignment(.center)
        
        if DeviceInfo.isIPad {
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
      VStack(alignment: .leading, spacing: DeviceInfo.isIPad ? 20 : 16) {
        HStack {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.orange)
            .font(DeviceInfo.isIPad ? .title2 : .headline)
          
          Text("Alertas de Orçamento")
            .font(DeviceInfo.isIPad ? .title2 : .headline)
            .fontWeight(.semibold)
            .foregroundColor(.adaptiveLabel)
          
          Spacer()
          
          NavigationLink("Ver Todos") {
            BudgetsScreen()
          }
          .font(.callout)
          .foregroundColor(.blue)
        }
        
        if DeviceInfo.isIPad {
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
      
      if DeviceInfo.isIPad {
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
      VStack(alignment: .leading, spacing: DeviceInfo.isIPad ? 20 : 16) {
        HStack {
          Text("Orçamentos")
            .font(DeviceInfo.isIPad ? .title2 : .headline)
            .fontWeight(.semibold)
            .foregroundColor(.adaptiveLabel)
          
          Spacer()
          
          NavigationLink("Ver Todos") {
            BudgetsScreen()
          }
          .font(.callout)
          .foregroundColor(.blue)
        }
        
        if DeviceInfo.isIPad {
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
      VStack(alignment: .leading, spacing: DeviceInfo.isIPad ? 20 : 16) {
        HStack {
          Text("Transações Recentes")
            .font(DeviceInfo.isIPad ? .title2 : .headline)
            .fontWeight(.semibold)
            .foregroundColor(.adaptiveLabel)
          
          Spacer()
          
          NavigationLink("Ver Todas") {
            TransactionsView()
          }
          .font(.callout)
          .foregroundColor(.blue)
        }
        
        LazyVStack(spacing: DeviceInfo.isIPad ? 12 : 8) {
          ForEach(financeViewModel.transactions.prefix(DeviceInfo.isIPad ? 8 : 5)) { transaction in
            ModernTransactionRow(transaction: transaction)
          }
        }
      }
    }
  }
  
  private var accountsOverviewSection: some View {
    ResponsiveCard {
      VStack(alignment: .leading, spacing: DeviceInfo.isIPad ? 20 : 16) {
        HStack {
          Text("Suas Contas")
            .font(DeviceInfo.isIPad ? .title2 : .headline)
            .fontWeight(.semibold)
            .foregroundColor(.adaptiveLabel)
          
          Spacer()
          
          NavigationLink("Ver Todas") {
            AccountsView()
          }
          .font(.callout)
          .foregroundColor(.blue)
        }
        
        if DeviceInfo.isIPad {
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

struct CompactBudgetAlertCard: View {
  let budget: Budget
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: budget.isOverBudget ? "exclamationmark.circle.fill" : "exclamationmark.triangle.fill")
          .foregroundColor(budget.isOverBudget ? .red : .orange)
          .font(.caption)
        
        Text(budget.name)
          .font(.caption)
          .fontWeight(.medium)
          .lineLimit(1)
        
        Spacer()
      }
      
      Text(budget.formattedSpent)
        .font(.callout)
        .fontWeight(.semibold)
        .foregroundColor(budget.isOverBudget ? .red : .orange)
    }
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(budget.isOverBudget ? Color.red.opacity(0.1) : Color.orange.opacity(0.1))
    )
  }
}

struct ModernTransactionRow: View {
  let transaction: Transaction
  
  var body: some View {
    HStack(spacing: DeviceInfo.isIPad ? 16 : 12) {
      Image(systemName: transaction.category.icon)
        .font(DeviceInfo.isIPad ? .title2 : .title3)
        .foregroundColor(.blue)
        .frame(width: DeviceInfo.isIPad ? 40 : 32, height: DeviceInfo.isIPad ? 40 : 32)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(DeviceInfo.isIPad ? 10 : 8)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(transaction.description)
          .font(DeviceInfo.isIPad ? .body : .headline)
          .fontWeight(.medium)
        
        Text(transaction.category.displayName)
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 4) {
        Text(transaction.formattedAmount)
          .font(DeviceInfo.isIPad ? .body : .headline)
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
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancelar") {
            dismiss()
          }
        }
      }
    }
  }
}
