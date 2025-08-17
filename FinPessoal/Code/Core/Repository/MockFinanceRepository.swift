//
//  MockFinanceRepository.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import Foundation

class MockFinanceRepository: FinanceRepositoryProtocol {
  private var accounts: [Account] = [
    Account(id: "1", name: "Conta Principal", type: .checking, balance: 5420.30, currency: "BRL", isActive: true),
    Account(id: "2", name: "Poupança", type: .savings, balance: 12500.00, currency: "BRL", isActive: true),
    Account(id: "3", name: "Cartão Nubank", type: .credit, balance: -1250.45, currency: "BRL", isActive: true),
    Account(id: "4", name: "Investimentos XP", type: .investment, balance: 25780.90, currency: "BRL", isActive: true)
  ]
  
  private var transactions: [Transaction] = [
    Transaction(id: "1", accountId: "1", amount: 3500.00, description: "Salário", category: .salary, type: .income, date: Date().addingTimeInterval(-86400 * 2), isRecurring: true),
    Transaction(id: "2", accountId: "1", amount: 250.50, description: "Supermercado", category: .food, type: .expense, date: Date().addingTimeInterval(-86400), isRecurring: false),
    Transaction(id: "3", accountId: "3", amount: 80.00, description: "Combustível", category: .transport, type: .expense, date: Date(), isRecurring: false),
    Transaction(id: "4", accountId: "1", amount: 1200.00, description: "Aluguel", category: .bills, type: .expense, date: Date().addingTimeInterval(-86400 * 3), isRecurring: true),
    Transaction(id: "5", accountId: "2", amount: 500.00, description: "Aplicação Poupança", category: .investment, type: .income, date: Date().addingTimeInterval(-86400 * 5), isRecurring: false),
    Transaction(id: "6", accountId: "1", amount: 150.00, description: "Restaurante", category: .food, type: .expense, date: Date().addingTimeInterval(-86400 * 1), isRecurring: false),
    Transaction(id: "7", accountId: "1", amount: 45.00, description: "Uber", category: .transport, type: .expense, date: Date().addingTimeInterval(-86400 * 2), isRecurring: false),
    Transaction(id: "8", accountId: "1", amount: 200.00, description: "Cinema", category: .entertainment, type: .expense, date: Date().addingTimeInterval(-86400 * 4), isRecurring: false)
  ]
  
  private var budgets: [Budget] = [
    Budget(
      id: "budget1",
      name: "Alimentação Mensal",
      category: "food",
      budgetAmount: 800.00,
      spent: 400.50,
      period: .monthly,
      startDate: Calendar.current.startOfMonth(for: Date()) ?? Date(),
      endDate: Calendar.current.endOfMonth(for: Date()) ?? Date(),
      isActive: true,
      alertThreshold: 0.8
    ),
    Budget(
      id: "budget2",
      name: "Transporte Mensal",
      category: "transport",
      budgetAmount: 300.00,
      spent: 125.00,
      period: .monthly,
      startDate: Calendar.current.startOfMonth(for: Date()) ?? Date(),
      endDate: Calendar.current.endOfMonth(for: Date()) ?? Date(),
      isActive: true,
      alertThreshold: 0.75
    ),
    Budget(
      id: "budget3",
      name: "Entretenimento Mensal",
      category: "entertainment",
      budgetAmount: 400.00,
      spent: 200.00,
      period: .monthly,
      startDate: Calendar.current.startOfMonth(for: Date()) ?? Date(),
      endDate: Calendar.current.endOfMonth(for: Date()) ?? Date(),
      isActive: true,
      alertThreshold: 0.9
    )
  ]
  
  func getAccounts() async throws -> [Account] {
    try await Task.sleep(nanoseconds: 500_000_000)
    return accounts
  }
  
  func getTransactions() async throws -> [Transaction] {
    try await Task.sleep(nanoseconds: 500_000_000)
    return transactions.sorted { $0.date > $1.date }
  }
  
  func addTransaction(_ transaction: Transaction) async throws {
    try await Task.sleep(nanoseconds: 300_000_000)
    transactions.append(transaction)
    
    // Atualizar budgets automaticamente
    await updateBudgetsWithNewTransaction(transaction)
  }
  
  func getBudgets() async throws -> [Budget] {
    try await Task.sleep(nanoseconds: 500_000_000)
    return budgets.filter { $0.isActive }
  }
  
  func addBudget(_ budget: Budget) async throws {
    try await Task.sleep(nanoseconds: 300_000_000)
    budgets.append(budget)
  }
  
  func updateBudget(_ budget: Budget) async throws {
    try await Task.sleep(nanoseconds: 300_000_000)
    if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
      budgets[index] = budget
    }
  }
  
  func deleteBudget(_ budgetId: String) async throws {
    try await Task.sleep(nanoseconds: 300_000_000)
    budgets.removeAll { $0.id == budgetId }
  }
  
  func getBudgetProgress(_ budgetId: String) async throws -> Double {
    try await Task.sleep(nanoseconds: 200_000_000)
    guard let budget = budgets.first(where: { $0.id == budgetId }) else {
      return 0.0
    }
    return budget.percentageUsed
  }
  
  // Método privado para atualizar budgets quando uma nova transação é adicionada
  private func updateBudgetsWithNewTransaction(_ transaction: Transaction) async {
    guard transaction.type == .expense else { return }
    
    for i in 0..<budgets.count {
      if budgets[i].category == transaction.category &&
          transaction.date >= budgets[i].startDate &&
          transaction.date <= budgets[i].endDate {
        budgets[i] = Budget(
          id: budgets[i].id,
          name: budgets[i].name,
          category: budgets[i].category,
          budgetAmount: budgets[i].budgetAmount,
          spent: budgets[i].spent + transaction.amount,
          period: budgets[i].period,
          startDate: budgets[i].startDate,
          endDate: budgets[i].endDate,
          isActive: budgets[i].isActive,
          alertThreshold: budgets[i].alertThreshold
        )
      }
    }
  }
}

