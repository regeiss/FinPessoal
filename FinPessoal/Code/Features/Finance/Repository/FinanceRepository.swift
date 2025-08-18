//
//  FinanceRepository.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import Foundation

class FinanceRepository: FinanceRepositoryProtocol {
  private let firebaseService = FirebaseService.shared
  private let authRepository: AuthRepositoryProtocol
  
  init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
    self.authRepository = authRepository
  }
  
  private var currentUserID: String {
    guard let user = authRepository.getCurrentUser() else {
      fatalError("User not authenticated")
    }
    return user.id
  }
  
  // MARK: - Account Operations
  
  func getAccounts() async throws -> [Account] {
    return try await firebaseService.getAccounts(for: currentUserID)
  }
  
  func saveAccount(_ account: Account) async throws {
    try await firebaseService.saveAccount(account, for: currentUserID)
  }
  
  func updateAccount(_ account: Account) async throws {
    try await firebaseService.updateAccount(account, for: currentUserID)
  }
  
  func deleteAccount(_ accountID: String) async throws {
    // Check if there are transactions associated with this account
    let transactions = try await firebaseService.getTransactionsByAccount(accountID, for: currentUserID)
    
    if !transactions.isEmpty {
      throw FinanceError.accountHasTransactions
    }
    
    try await firebaseService.deleteAccount(accountID, for: currentUserID)
  }
  
  // MARK: - Transaction Operations
  
  func getTransactions(limit: Int? = nil) async throws -> [Transaction] {
    return try await firebaseService.getTransactions(for: currentUserID, limit: limit)
  }
  
  func getTransactions() async throws -> [Transaction] {
    return try await getTransactions(limit: AppConstants.maxTransactionsPerLoad)
  }
  
  func addTransaction(_ transaction: Transaction) async throws {
    // Ensure the transaction has the correct user ID
    let updatedTransaction = Transaction(
      id: transaction.id,
      accountId: transaction.accountId,
      amount: transaction.amount,
      description: transaction.description,
      category: transaction.category,
      type: transaction.type,
      date: transaction.date,
      isRecurring: transaction.isRecurring,
      userId: currentUserID,
      createdAt: Date(),
      updatedAt: Date()
    )
    
    try await firebaseService.saveTransaction(updatedTransaction, for: currentUserID)
    
    // Update budgets with the new transaction
    try await firebaseService.batchUpdateBudgetsWithTransaction(updatedTransaction, for: currentUserID)
  }
  
  func updateTransaction(_ transaction: Transaction) async throws {
    try await firebaseService.updateTransaction(transaction, for: currentUserID)
  }
  
  func deleteTransaction(_ transactionID: String) async throws {
    try await firebaseService.deleteTransaction(transactionID, for: currentUserID)
  }
  
  func getTransactionsByAccount(_ accountID: String) async throws -> [Transaction] {
    return try await firebaseService.getTransactionsByAccount(accountID, for: currentUserID)
  }
  
  func getTransactionsByCategory(_ category: TransactionCategory) async throws -> [Transaction] {
    return try await firebaseService.getTransactionsByCategory(category, for: currentUserID)
  }
  
  // MARK: - Budget Operations
  
  func getBudgets() async throws -> [Budget] {
    return try await firebaseService.getBudgets(for: currentUserID)
  }
  
  func addBudget(_ budget: Budget) async throws {
    // Ensure the budget has the correct user ID
    let updatedBudget = Budget(
      id: budget.id,
      name: budget.name,
      category: budget.category,
      budgetAmount: budget.budgetAmount,
      spent: 0.0, // Start with 0 spent
      period: budget.period,
      startDate: budget.startDate,
      endDate: budget.endDate,
      isActive: true,
      alertThreshold: budget.alertThreshold,
      userId: currentUserID,
      createdAt: Date(),
      updatedAt: Date()
    )
    
    // Calculate current spending for this budget based on existing transactions
    let spent = try await calculateBudgetSpent(for: updatedBudget)
    
    let budgetWithSpent = Budget(
      id: updatedBudget.id,
      name: updatedBudget.name,
      category: updatedBudget.category,
      budgetAmount: updatedBudget.budgetAmount,
      spent: spent,
      period: updatedBudget.period,
      startDate: updatedBudget.startDate,
      endDate: updatedBudget.endDate,
      isActive: updatedBudget.isActive,
      alertThreshold: updatedBudget.alertThreshold,
      userId: updatedBudget.userId,
      createdAt: updatedBudget.createdAt,
      updatedAt: updatedBudget.updatedAt
    )
    
    try await firebaseService.saveBudget(budgetWithSpent, for: currentUserID)
  }
  
  func updateBudget(_ budget: Budget) async throws {
    let updatedBudget = Budget(
      id: budget.id,
      name: budget.name,
      category: budget.category,
      budgetAmount: budget.budgetAmount,
      spent: budget.spent,
      period: budget.period,
      startDate: budget.startDate,
      endDate: budget.endDate,
      isActive: budget.isActive,
      alertThreshold: budget.alertThreshold,
      userId: budget.userId ?? currentUserID,
      createdAt: budget.createdAt,
      updatedAt: Date()
    )
    
    try await firebaseService.updateBudget(updatedBudget, for: currentUserID)
  }
  
  func deleteBudget(_ budgetId: String) async throws {
    try await firebaseService.deleteBudget(budgetId, for: currentUserID)
  }
  
  func getBudgetProgress(_ budgetId: String) async throws -> Double {
    return try await firebaseService.getBudgetProgress(budgetId, for: currentUserID)
  }
  
  // MARK: - Analytics and Reporting
  
  func getMonthlyExpensesByCategory(month: Date) async throws -> [TransactionCategory: Double] {
    return try await firebaseService.getMonthlyExpensesByCategory(for: currentUserID, month: month)
  }
  
  func getTotalBalanceHistory(days: Int = 30) async throws -> [(Date, Double)] {
    return try await firebaseService.getTotalBalanceHistory(for: currentUserID, days: days)
  }
  
  // MARK: - Private Helper Methods
  
  private func calculateBudgetSpent(for budget: Budget) async throws -> Double {
    let transactions = try await firebaseService.getTransactionsByCategory(budget.category, for: currentUserID)
    
    let relevantTransactions = transactions.filter { transaction in
      transaction.type == .expense &&
      transaction.date >= budget.startDate &&
      transaction.date <= budget.endDate
    }
    
    return relevantTransactions.reduce(0) { $0 + $1.amount }
  }
}

// MARK: - Finance Errors

enum FinanceError: LocalizedError {
  case accountHasTransactions
  case insufficientBalance
  case invalidAmount
  case budgetNotFound
  case accountNotFound
  case transactionNotFound
  
  var errorDescription: String? {
    switch self {
    case .accountHasTransactions:
      return "Não é possível deletar uma conta que possui transações"
    case .insufficientBalance:
      return "Saldo insuficiente"
    case .invalidAmount:
      return "Valor inválido"
    case .budgetNotFound:
      return "Orçamento não encontrado"
    case .accountNotFound:
      return "Conta não encontrada"
    case .transactionNotFound:
      return "Transação não encontrada"
    }
  }
}
