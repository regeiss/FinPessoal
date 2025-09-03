//
//  DashboardViewModel.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
  @Published var accounts: [Account] = []
  @Published var recentTransactions: [Transaction] = []
  @Published var budgets: [Budget] = []
  @Published var isLoading = false
  @Published var error: AppError?
  
  private let accountRepository: AccountRepositoryProtocol
  private let transactionRepository: TransactionRepositoryProtocol
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    self.accountRepository = AppConfiguration.shared.createAccountRepository()
    self.transactionRepository = AppConfiguration.shared.createTransactionRepository()
    print("DashboardViewModel: Initialized with repositories")
    print("DashboardViewModel: Using mock data = \(AppConfiguration.shared.useMockData)")
  }
  
  var totalBalance: Double {
    accounts.reduce(0) { $0 + $1.balance }
  }
  
  var monthlyExpenses: Double {
    let calendar = Calendar.current
    let now = Date()
    let startOfMonth = calendar.startOfMonth(for: now) ?? now
    let endOfMonth = calendar.endOfMonth(for: now) ?? now
    
    return recentTransactions
      .filter { transaction in
        transaction.type == .expense && 
        transaction.date >= startOfMonth && 
        transaction.date <= endOfMonth
      }
      .reduce(0) { $0 + $1.amount }
  }
  
  var budgetAlerts: [Budget] {
    budgets.filter { budget in
      let spentPercentage = budget.budgetAmount > 0 ? (budget.spent / budget.budgetAmount) : 0
      return spentPercentage >= budget.alertThreshold
    }
  }
  
  func loadDashboardData() {
    print("DashboardViewModel: loadDashboardData() called")
    isLoading = true
    error = nil
    
    Task {
      await loadAccountsAndTransactions()
      await loadBudgets()
    }
  }
  
  private func loadAccountsAndTransactions() async {
    do {
      print("DashboardViewModel: Loading accounts...")
      let fetchedAccounts = try await accountRepository.getAccounts()
      accounts = fetchedAccounts
      print("DashboardViewModel: Loaded \(fetchedAccounts.count) accounts")
      
      print("DashboardViewModel: Loading recent transactions...")
      let fetchedTransactions = try await transactionRepository.getRecentTransactions(limit: 10)
      recentTransactions = fetchedTransactions
      print("DashboardViewModel: Loaded \(fetchedTransactions.count) recent transactions")
      
    } catch {
      print("DashboardViewModel: Error loading accounts/transactions: \(error)")
      self.error = AppError.databaseError("Erro ao carregar dados do painel")
    }
  }
  
  private func loadBudgets() async {
    // For now, budgets will be empty until Budget repository is implemented
    // This prevents any crashes and the dashboard will still work
    budgets = []
    isLoading = false
    print("DashboardViewModel: Data loading completed")
  }
}
