//
//  FinanceViewModel.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 14/08/25.
//

import Foundation
import Combine

@MainActor
class FinanceViewModel: ObservableObject {
  @Published var accounts: [Account] = []
  @Published var transactions: [Transaction] = []
  @Published var budgets: [Budget] = []
  @Published var isLoading = false
  @Published var errorMessage: String?
  
  private let financeRepository: FinanceRepositoryProtocol
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Computed Properties
  
  var totalBalance: Double {
    accounts.filter { $0.isActive }.reduce(0) { $0 + $1.balance }
  }
  
  var formattedTotalBalance: String {
    return CurrencyFormatter.shared.string(from: totalBalance)
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
  
  var totalIncome: Double {
    let currentMonth = Calendar.current.startOfMonth(for: Date()) ?? Date()
    let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? Date()
    
    return transactions
      .filter { $0.type == .income && $0.date >= currentMonth && $0.date < nextMonth }
      .reduce(0) { $0 + $1.amount }
  }
  
  var totalExpenses: Double {
    let currentMonth = Calendar.current.startOfMonth(for: Date()) ?? Date()
    let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? Date()
    
    return transactions
      .filter { $0.type == .expense && $0.date >= currentMonth && $0.date < nextMonth }
      .reduce(0) { $0 + $1.amount }
  }
  
  var formattedTotalIncome: String {
    return CurrencyFormatter.shared.string(from: totalIncome)
  }
  
  var formattedTotalExpenses: String {
    return CurrencyFormatter.shared.string(from: totalExpenses)
  }
  
  var monthlyBalance: Double {
    return totalIncome - totalExpenses
  }
  
  var formattedMonthlyBalance: String {
    return CurrencyFormatter.shared.string(from: monthlyBalance)
  }
  
  // MARK: - Initialization
  
  init(financeRepository: FinanceRepositoryProtocol = MockFinanceRepository()) {
    self.financeRepository = financeRepository
  }
  
  // MARK: - Data Loading
  
  func loadData() async {
    isLoading = true
    errorMessage = nil
    
    do {
      async let accountsData = financeRepository.getAccounts()
      async let transactionsData = financeRepository.getTransactions()
      async let budgetsData = financeRepository.getBudgets()
      
      let loadedAccounts = try await accountsData
      let loadedTransactions = try await transactionsData
      let loadedBudgets = try await budgetsData
      
      await MainActor.run {
        self.accounts = loadedAccounts
        self.transactions = loadedTransactions.sorted { $0.date > $1.date }
        self.budgets = loadedBudgets
      }
    } catch {
      await MainActor.run {
        self.errorMessage = "Erro ao carregar dados: \(error.localizedDescription)"
      }
    }
    
    await MainActor.run {
      self.isLoading = false
    }
  }
  
  func refreshData() async {
    await loadData()
  }
  
  // MARK: - Transaction Management
  
  func addTransaction(_ transaction: Transaction) async {
    isLoading = true
    errorMessage = nil
    
    do {
      try await financeRepository.addTransaction(transaction)
      await loadData() // Recarrega todos os dados para manter sincronização
    } catch {
      await MainActor.run {
        self.errorMessage = "Erro ao adicionar transação: \(error.localizedDescription)"
        self.isLoading = false
      }
    }
  }
  
  func updateTransaction(_ transaction: Transaction) async {
    isLoading = true
    errorMessage = nil
    
    do {
      // TODO: Implementar no repository quando necessário
      // try await financeRepository.updateTransaction(transaction)
      await loadData()
    } catch {
      await MainActor.run {
        self.errorMessage = "Erro ao atualizar transação: \(error.localizedDescription)"
        self.isLoading = false
      }
    }
  }
  
  func deleteTransaction(_ transactionId: String) async {
    isLoading = true
    errorMessage = nil
    
    do {
      // TODO: Implementar no repository quando necessário
      // try await financeRepository.deleteTransaction(transactionId)
      await loadData()
    } catch {
      await MainActor.run {
        self.errorMessage = "Erro ao deletar transação: \(error.localizedDescription)"
        self.isLoading = false
      }
    }
  }
  
  // MARK: - Account Management
  
  func addAccount(_ account: Account) async {
    isLoading = true
    errorMessage = nil
    
    do {
      // TODO: Implementar no repository quando necessário
      // try await financeRepository.addAccount(account)
      
      // Por enquanto, adiciona localmente para demonstração
      await MainActor.run {
        self.accounts.append(account)
        self.isLoading = false
      }
    } catch {
      await MainActor.run {
        self.errorMessage = "Erro ao adicionar conta: \(error.localizedDescription)"
        self.isLoading = false
      }
    }
  }
  
  func updateAccount(_ account: Account) async {
    isLoading = true
    errorMessage = nil
    
    do {
      // TODO: Implementar no repository quando necessário
      // try await financeRepository.updateAccount(account)
      await loadData()
    } catch {
      await MainActor.run {
        self.errorMessage = "Erro ao atualizar conta: \(error.localizedDescription)"
        self.isLoading = false
      }
    }
  }
  
  func deleteAccount(_ accountId: String) async {
    isLoading = true
    errorMessage = nil
    
    do {
      // TODO: Implementar no repository quando necessário
      // try await financeRepository.deleteAccount(accountId)
      await loadData()
    } catch {
      await MainActor.run {
        self.errorMessage = "Erro ao deletar conta: \(error.localizedDescription)"
        self.isLoading = false
      }
    }
  }
  
  // MARK: - Budget Management
  
  func addBudget(_ budget: Budget) async {
    isLoading = true
    errorMessage = nil
    
    do {
      try await financeRepository.addBudget(budget)
      await loadData()
    } catch {
      await MainActor.run {
        self.errorMessage = "Erro ao adicionar orçamento: \(error.localizedDescription)"
        self.isLoading = false
      }
    }
  }
  
  func updateBudget(_ budget: Budget) async {
    isLoading = true
    errorMessage = nil
    
    do {
      try await financeRepository.updateBudget(budget)
      await loadData()
    } catch {
      await MainActor.run {
        self.errorMessage = "Erro ao atualizar orçamento: \(error.localizedDescription)"
        self.isLoading = false
      }
    }
  }
  
  func deleteBudget(_ budgetId: String) async {
    isLoading = true
    errorMessage = nil
    
    do {
      try await financeRepository.deleteBudget(budgetId)
      await loadData()
    } catch {
      await MainActor.run {
        self.errorMessage = "Erro ao deletar orçamento: \(error.localizedDescription)"
        self.isLoading = false
      }
    }
  }
  
  func getBudgetProgress(_ budgetId: String) async -> Double {
    do {
      return try await financeRepository.getBudgetProgress(budgetId)
    } catch {
      await MainActor.run {
        self.errorMessage = "Erro ao obter progresso do orçamento: \(error.localizedDescription)"
      }
      return 0.0
    }
  }
  
  // MARK: - Utility Methods
  
  func getAccount(by id: String) -> Account? {
    return accounts.first { $0.id == id }
  }
  
  func getTransactions(for accountId: String) -> [Transaction] {
    return transactions.filter { $0.accountId == accountId }
  }
  
  func getTransactions(for category: TransactionCategory) -> [Transaction] {
    return transactions.filter { $0.category == category.rawValue }
  }
  
  func getTransactions(for type: TransactionType) -> [Transaction] {
    return transactions.filter { $0.type.rawValue == type.rawValue }
  }
  
  func getTransactions(for month: Date) -> [Transaction] {
    let calendar = Calendar.current
    return transactions.filter {
      calendar.isDate($0.date, equalTo: month, toGranularity: .month)
    }
  }
  
  func getBudget(for category: TransactionCategory) -> Budget? {
    return budgets.first { $0.category == category.rawValue && $0.isActive }
  }
  
  func clearError() {
    errorMessage = nil
  }
  
  // MARK: - Analytics and Reports
  
  func getExpensesByCategory(for month: Date = Date()) -> [TransactionCategory: Double] {
    let monthTransactions = getTransactions(for: month)
    let expenses = monthTransactions.filter { $0.type == .expense }
    
    var categoryTotals: [TransactionCategory: Double] = [:]
    
    for expense in expenses {
      if let category = TransactionCategory(rawValue: expense.category) {
        categoryTotals[category, default: 0] += expense.amount
      }
    }
    
    return categoryTotals
  }
  
  func getIncomeByCategory(for month: Date = Date()) -> [TransactionCategory: Double] {
    let monthTransactions = getTransactions(for: month)
    let incomes = monthTransactions.filter { $0.type == .income }
    
    var categoryTotals: [TransactionCategory: Double] = [:]
    
    for income in incomes {
      if let category = TransactionCategory(rawValue: income.category) {
        categoryTotals[category, default: 0] += income.amount
      }
    }
    
    return categoryTotals
  }
  
  func getBalanceHistory(months: Int = 6) -> [(Date, Double)] {
    var history: [(Date, Double)] = []
    let calendar = Calendar.current
    
    for i in 0..<months {
      let date = calendar.date(byAdding: .month, value: -i, to: Date()) ?? Date()
      let monthTransactions = getTransactions(for: date)
      
      let income = monthTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
      let expenses = monthTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
      let balance = income - expenses
      
      history.append((date, balance))
    }
    
    return history.reversed()
  }
  
  // MARK: - Validation
  
  func validateTransaction(_ transaction: Transaction) -> String? {
    guard !transaction.description.isEmpty else {
      return "Descrição é obrigatória"
    }
    
    guard transaction.amount > 0 else {
      return "Valor deve ser maior que zero"
    }
    
    guard getAccount(by: transaction.accountId) != nil else {
      return "Conta selecionada não existe"
    }
    
    return nil
  }
  
  func validateAccount(_ account: Account) -> String? {
    guard !account.name.isEmpty else {
      return "Nome da conta é obrigatório"
    }
    
    guard !accounts.contains(where: { $0.name == account.name && $0.id != account.id }) else {
      return "Já existe uma conta com esse nome"
    }
    
    return nil
  }
  
  func validateBudget(_ budget: Budget) -> String? {
    guard !budget.name.isEmpty else {
      return "Nome do orçamento é obrigatório"
    }
    
    guard budget.budgetAmount > 0 else {
      return "Valor do orçamento deve ser maior que zero"
    }
    
    guard budget.alertThreshold > 0 && budget.alertThreshold <= 1 else {
      return "Limite de alerta deve estar entre 1% e 100%"
    }
    
    return nil
  }
}

