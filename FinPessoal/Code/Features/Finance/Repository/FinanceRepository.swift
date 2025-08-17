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
  
  func getAccounts() async throws -> [Account] {
    return try await firebaseService.getAccounts(for: currentUserID)
  }
  
  func saveAccount(_ account: Account) async throws {
    try await firebaseService.saveAccount(account, for: currentUserID)
  }
  
  func getTransactions(limit: Int? = nil) async throws -> [Transaction] {
    return try await firebaseService.getTransactions(
      for: currentUserID,
      limit: limit
    )
  }
  
  func getTransactions() async throws -> [Transaction] {
    return try await getTransactions(limit: nil)
  }
  
  func saveTransaction(_ transaction: Transaction) async throws {
    try await firebaseService.saveTransaction(transaction, for: currentUserID)
  }
  
  func addTransaction(_ transaction: Transaction) async throws {
    try await saveTransaction(transaction)
  }
  
  func getBudgets() async throws -> [Budget] {
    // TODO: Implement Firebase getBudgets
    return []
  }
  
  func addBudget(_ budget: Budget) async throws {
    // TODO: Implement Firebase addBudget
  }
  
  func updateBudget(_ budget: Budget) async throws {
    // TODO: Implement Firebase updateBudget
  }
  
  func deleteBudget(_ budgetId: String) async throws {
    // TODO: Implement Firebase deleteBudget
  }
  
  func getBudgetProgress(_ budgetId: String) async throws -> Double {
    // TODO: Implement Firebase getBudgetProgress
    return 0.0
  }
  
  func deleteAccount(_ accountID: String) async throws {
    // Implementar remoção de conta
    // Verificar se há transações associadas
  }
  
  func deleteTransaction(_ transactionID: String) async throws {
    // Implementar remoção de transação
    // Ajustar saldo da conta
  }
}
