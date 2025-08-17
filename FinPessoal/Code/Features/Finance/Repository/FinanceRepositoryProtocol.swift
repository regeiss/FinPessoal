//
//  FinanceRepositoryProtocol.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
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
