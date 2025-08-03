//
//  FinanceRepository.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import Foundation

protocol FinanceRepositoryProtocol {
  func getAccounts() async throws -> [Account]
  func getTransactions() async throws -> [Transaction]
  func addTransaction(_ transaction: Transaction) async throws
  func getBudgets() async throws -> [Budget]
  func addBudget(_ budget: Budget) async throws
  func updateBudget(_ budget: Budget) async throws
  func deleteBudget(_ budgetId: String) async throws
  func getBudgetProgress(_ budgetId: String) async throws -> Double
}

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

  func saveTransaction(_ transaction: Transaction) async throws {
    try await firebaseService.saveTransaction(transaction, for: currentUserID)
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
