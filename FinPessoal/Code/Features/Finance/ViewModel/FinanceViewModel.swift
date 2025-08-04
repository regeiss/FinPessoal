//
//  FinanceViewModel.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class FinanceViewModel: ObservableObject {
  @Published var accounts: [Account] = []
  @Published var transactions: [Transaction] = []
  @Published var budgets: [Budget] = []
  @Published var isLoading = false
  @Published var errorMessage: String?
  
  private let financeRepository: FinanceRepositoryProtocol
  
  var totalBalance: Double {
    accounts.filter { $0.isActive }.reduce(0) { $0 + $1.balance }
  }
  
  var formattedTotalBalance: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: totalBalance)) ?? "R$ 0,00"
  }
  
  var budgetsNeedingAttention: [Budget] {
    return budgets.filter { $0.shouldAlert || $0.isOverBudget }
  }
  
  var totalBudgetAmount: Double {
    return budgets.reduce(0) { $0 + $1.budgetAmount }
  }
  
  var totalBudgetSpent: Double {
    return budgets.reduce(0) { $0 + $1.spent }
  }
  
  init(financeRepository: FinanceRepositoryProtocol = MockFinanceRepository()) {
    self.financeRepository = financeRepository
  }
  
  func loadData() async {
    isLoading = true
    errorMessage = nil
    
    do {
      async let accountsData = financeRepository.getAccounts()
      async let transactionsData = financeRepository.getTransactions()
      async let budgetsData = financeRepository.getBudgets()
      
      accounts = try await accountsData
      transactions = try await transactionsData
      budgets = try await budgetsData
    } catch {
      errorMessage = "Erro ao carregar dados: \(error.localizedDescription)"
    }
    
    isLoading = false
  }
  
  func addTransaction(_ transaction: Transaction) async {
    do {
      try await financeRepository.addTransaction(transaction)
      await loadData()
    } catch {
      errorMessage = "Erro ao adicionar transação: \(error.localizedDescription)"
    }
  }
  
  func addBudget(_ budget: Budget) async {
    do {
      try await financeRepository.addBudget(budget)
      await loadData()
    } catch {
      errorMessage = "Erro ao adicionar orçamento: \(error.localizedDescription)"
    }
  }
  
  func updateBudget(_ budget: Budget) async {
    do {
      try await financeRepository.updateBudget(budget)
      await loadData()
    } catch {
      errorMessage = "Erro ao atualizar orçamento: \(error.localizedDescription)"
    }
  }
  
  func deleteBudget(_ budgetId: String) async {
    do {
      try await financeRepository.deleteBudget(budgetId)
      await loadData()
    } catch {
      errorMessage = "Erro ao deletar orçamento: \(error.localizedDescription)"
    }
  }
  
  func getBudgetProgress(_ budgetId: String) async -> Double {
    do {
      return try await financeRepository.getBudgetProgress(budgetId)
    } catch {
      return 0.0
    }
  }
}
