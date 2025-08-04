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
  
  func getTransactions() async throws -> [Transaction] {
    return try await getTransactions(limit: nil)
  }
  
  func saveTransaction(_ transaction: Transaction) async throws {
    try await firebaseService.saveTransaction(transaction, for: currentUserID)
  }
  
  func addTransaction(_ transaction: Transaction) async throws {
    try await saveTransaction(transaction)
  }
  
  func deleteAccount(_ accountID: String) async throws {
    // Implementar remoção de conta
    // Verificar se há transações associadas
  }
  
  func deleteTransaction(_ transactionID: String) async throws {
    // Implementar remoção de transação
    // Ajustar saldo da conta
  }
  
  // MARK: - Budget Methods
  func getBudgets() async throws -> [Budget] {
    // Temporary mock data until Firebase implementation is complete
    return [
      Budget(
        id: "budget1",
        name: "Alimentação Mensal",
        category: .food,
        budgetAmount: 800.00,
        spent: 400.50,
        period: .monthly,
        startDate: Calendar.current.startOfMonth(for: Date()) ?? Date(),
        endDate: Calendar.current.endOfMonth(for: Date()) ?? Date(),
        isActive: true,
        alertThreshold: 0.8
      )
    ]
  }
  
  func addBudget(_ budget: Budget) async throws {
    // Implementar adição de orçamento no Firebase
    try await Task.sleep(nanoseconds: 300_000_000)
  }
  
  func updateBudget(_ budget: Budget) async throws {
    // Implementar atualização de orçamento no Firebase
    try await Task.sleep(nanoseconds: 300_000_000)
  }
  
  func deleteBudget(_ budgetId: String) async throws {
    // Implementar remoção de orçamento no Firebase
    try await Task.sleep(nanoseconds: 300_000_000)
  }
  
  func getBudgetProgress(_ budgetId: String) async throws -> Double {
    // Implementar cálculo de progresso do orçamento
    return 0.5
  }
}
