//
//  MockFinanceRepository.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

//
//  MockRepositoryProtocol.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import Foundation

class MockFinanceRepository: FinanceRepositoryProtocol {
  private let mockUserId = "mock-user-123"
  private let baseDate = Date()
  
  private var accounts: [Account] = []
  private var transactions: [Transaction] = []
  private var budgets: [Budget] = []
  
  init() {
    setupMockData()
  }
  
  private func setupMockData() {
    // Setup mock accounts
    accounts = [
      Account(
        id: "1",
        name: "Conta Principal",
        type: .checking,
        balance: 5420.30,
        currency: "BRL",
        isActive: true,
        userId: mockUserId,
        createdAt: baseDate.addingTimeInterval(-86400 * 30),
        updatedAt: baseDate
      ),
      Account(
        id: "2",
        name: "Poupança",
        type: .savings,
        balance: 12500.00,
        currency: "BRL",
        isActive: true,
        userId: mockUserId,
        createdAt: baseDate.addingTimeInterval(-86400 * 25),
        updatedAt: baseDate.addingTimeInterval(-86400 * 5)
      ),
      Account(
        id: "3",
        name: "Cartão Nubank",
        type: .credit,
        balance: -1250.45,
        currency: "BRL",
        isActive: true,
        userId: mockUserId,
        createdAt: baseDate.addingTimeInterval(-86400 * 20),
        updatedAt: baseDate.addingTimeInterval(-86400 * 2)
      ),
      Account(
        id: "4",
        name: "Investimentos XP",
        type: .investment,
        balance: 25780.90,
        currency: "BRL",
        isActive: true,
        userId: mockUserId,
        createdAt: baseDate.addingTimeInterval(-86400 * 15),
        updatedAt: baseDate.addingTimeInterval(-86400 * 1)
      )
    ]
    
    // Setup mock transactions
    transactions = [
      Transaction(
        id: "1",
        accountId: "1",
        amount: 3500.00,
        description: "Salário",
        category: .salary,
        type: .income,
        date: baseDate.addingTimeInterval(-86400 * 2),
        isRecurring: true,
        userId: mockUserId,
        createdAt: baseDate.addingTimeInterval(-86400 * 2),
        updatedAt: baseDate.addingTimeInterval(-86400 * 2)
      ),
      Transaction(
        id: "2",
        accountId: "1",
        amount: 250.50,
        description: "Supermercado",
        category: .food,
        type: .expense,
        date: baseDate.addingTimeInterval(-86400),
        isRecurring: false,
        userId: mockUserId,
        createdAt: baseDate.addingTimeInterval(-86400),
        updatedAt: baseDate.addingTimeInterval(-86400)
      ),
      Transaction(
        id: "3",
        accountId: "3",
        amount: 80.00,
        description: "Combustível",
        category: .transport,
        type: .expense,
        date: baseDate,
        isRecurring: false,
        userId: mockUserId,
        createdAt: baseDate,
        updatedAt: baseDate
      ),
      Transaction(
        id: "4",
        accountId: "1",
        amount: 1200.00,
        description: "Aluguel",
        category: .bills,
        type: .expense,
        date: baseDate.addingTimeInterval(-86400 * 3),
        isRecurring: true,
        userId: mockUserId,
        createdAt: baseDate.addingTimeInterval(-86400 * 3),
        updatedAt: baseDate.addingTimeInterval(-86400 * 3)
      ),
      Transaction(
        id: "5",
        accountId: "2",
        amount: 500.00,
        description: "Aplicação Poupança",
        category: .investment,
        type: .income,
        date: baseDate.addingTimeInterval(-86400 * 5),
        isRecurring: false,
        userId: mockUserId,
        createdAt: baseDate.addingTimeInterval(-86400 * 5),
        updatedAt: baseDate.addingTimeInterval(-86400 * 5)
      ),
      Transaction(
        id: "6",
        accountId: "1",
        amount: 150.00,
        description: "Restaurante",
        category: .food,
        type: .expense,
        date: baseDate.addingTimeInterval(-86400 * 1),
        isRecurring: false,
        userId: mockUserId,
        createdAt: baseDate.addingTimeInterval(-86400 * 1),
        updatedAt: baseDate.addingTimeInterval(-86400 * 1)
      ),
      Transaction(
        id: "7",
        accountId: "1",
        amount: 45.00,
        description: "Uber",
        category: .transport,
        type: .expense,
        date: baseDate.addingTimeInterval(-86400 * 2),
        isRecurring: false,
        userId: mockUserId,
        createdAt: baseDate.addingTimeInterval(-86400 * 2),
        updatedAt: baseDate.addingTimeInterval(-86400 * 2)
      ),
      Transaction(
        id: "8",
        accountId: "1",
        amount: 200.00,
        description: "Cinema",
        category: .entertainment,
        type: .expense,
        date: baseDate.addingTimeInterval(-86400 * 4),
        isRecurring: false,
        userId: mockUserId,
        createdAt: baseDate.addingTimeInterval(-86400 * 4),
        updatedAt: baseDate.addingTimeInterval(-86400 * 4)
      )
    ]
    
    // Setup mock budgets
    budgets = [
      Budget(
        id: "budget1",
        name: "Alimentação Mensal",
        category: .food,
        budgetAmount: 800.00,
        spent: 400.50,
        period: .monthly,
        startDate: Calendar.current.startOfMonth(for: baseDate) ?? baseDate,
        endDate: Calendar.current.endOfMonth(for: baseDate) ?? baseDate,
        isActive: true,
        alertThreshold: 0.8,
        userId: mockUserId,
        createdAt: Calendar.current.startOfMonth(for: baseDate) ?? baseDate,
        updatedAt: baseDate
      ),
      Budget(
        id: "budget2",
        name: "Transporte Mensal",
        category: .transport,
        budgetAmount: 300.00,
        spent: 125.00,
        period: .monthly,
        startDate: Calendar.current.startOfMonth(for: baseDate) ?? baseDate,
        endDate: Calendar.current.endOfMonth(for: baseDate) ?? baseDate,
        isActive: true,
        alertThreshold: 0.75,
        userId: mockUserId,
        createdAt: Calendar.current.startOfMonth(for: baseDate) ?? baseDate,
        updatedAt: baseDate.addingTimeInterval(-86400 * 5)
      ),
      Budget(
        id: "budget3",
        name: "Entretenimento Mensal",
        category: .entertainment,
        budgetAmount: 400.00,
        spent: 200.00,
        period: .monthly,
        startDate: Calendar.current.startOfMonth(for: baseDate) ?? baseDate,
        endDate: Calendar.current.endOfMonth(for: baseDate) ?? baseDate,
        isActive: true,
        alertThreshold: 0.9,
        userId: mockUserId,
        createdAt: Calendar.current.startOfMonth(for: baseDate) ?? baseDate,
        updatedAt: baseDate.addingTimeInterval(-86400 * 3)
      ),
      Budget(
        id: "budget4",
        name: "Moradia Mensal",
        category: .housing,
        budgetAmount: 1500.00,
        spent: 1200.00,
        period: .monthly,
        startDate: Calendar.current.startOfMonth(for: baseDate) ?? baseDate,
        endDate: Calendar.current.endOfMonth(for: baseDate) ?? baseDate,
        isActive: true,
        alertThreshold: 0.85,
        userId: mockUserId,
        createdAt: Calendar.current.startOfMonth(for: baseDate) ?? baseDate,
        updatedAt: baseDate.addingTimeInterval(-86400 * 1)
      )
    ]
  }
  
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
    
    // Create transaction with current timestamp
    let updatedTransaction = Transaction(
      id: transaction.id,
      accountId: transaction.accountId,
      amount: transaction.amount,
      description: transaction.description,
      category: transaction.category,
      type: transaction.type,
      date: transaction.date,
      isRecurring: transaction.isRecurring,
      userId: mockUserId,
      createdAt: Date(),
      updatedAt: Date()
    )
    
    transactions.append(updatedTransaction)
    
    // Update budgets automatically
    await updateBudgetsWithNewTransaction(updatedTransaction)
  }
  
  func getBudgets() async throws -> [Budget] {
    try await Task.sleep(nanoseconds: 500_000_000)
    return budgets.filter { $0.isActive }
  }
  
  func addBudget(_ budget: Budget) async throws {
    try await Task.sleep(nanoseconds: 300_000_000)
    
    // Create budget with current timestamp
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
      userId: mockUserId,
      createdAt: Date(),
      updatedAt: Date()
    )
    
    budgets.append(updatedBudget)
  }
  
  func updateBudget(_ budget: Budget) async throws {
    try await Task.sleep(nanoseconds: 300_000_000)
    if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
      // Update with current timestamp
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
        userId: budget.userId ?? mockUserId,
        createdAt: budget.createdAt ?? Date(),
        updatedAt: Date()
      )
      budgets[index] = updatedBudget
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
  
  // Private method to update budgets when a new transaction is added
  private func updateBudgetsWithNewTransaction(_ transaction: Transaction) async {
    guard transaction.type == .expense else { return }
    
    for i in 0..<budgets.count {
      if budgets[i].category == transaction.category &&
          transaction.date >= budgets[i].startDate &&
          transaction.date <= budgets[i].endDate {
        
        let updatedBudget = Budget(
          id: budgets[i].id,
          name: budgets[i].name,
          category: budgets[i].category,
          budgetAmount: budgets[i].budgetAmount,
          spent: budgets[i].spent + transaction.amount,
          period: budgets[i].period,
          startDate: budgets[i].startDate,
          endDate: budgets[i].endDate,
          isActive: budgets[i].isActive,
          alertThreshold: budgets[i].alertThreshold,
          userId: budgets[i].userId ?? mockUserId,
          createdAt: budgets[i].createdAt ?? Date(),
          updatedAt: Date()
        )
        
        budgets[i] = updatedBudget
      }
    }
  }
}
