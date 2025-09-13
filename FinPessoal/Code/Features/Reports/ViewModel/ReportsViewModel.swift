//
//  ReportsViewModel.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 12/09/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Report Data Models

struct ReportSummary {
  let totalIncome: Double
  let totalExpenses: Double
  let netIncome: Double
  let savingsRate: Double
  let transactionCount: Int
  let averageDailySpending: Double
}

struct CategorySpending {
  let category: TransactionCategory
  let amount: Double
  let percentage: Double
  let transactionCount: Int
}

struct MonthlyTrend {
  let month: String
  let income: Double
  let expenses: Double
  let netIncome: Double
}

struct BudgetPerformance {
  let category: TransactionCategory
  let budgetAmount: Double
  let spentAmount: Double
  let remainingAmount: Double
  let percentage: Double
}

enum ReportPeriod: String, CaseIterable {
  case thisMonth = "thisMonth"
  case lastMonth = "lastMonth"
  case last3Months = "last3Months"
  case last6Months = "last6Months"
  case thisYear = "thisYear"
  case custom = "custom"
  
  var displayName: String {
    switch self {
    case .thisMonth: return String(localized: "reports.period.this.month")
    case .lastMonth: return String(localized: "reports.period.last.month")
    case .last3Months: return String(localized: "reports.period.last.3.months")
    case .last6Months: return String(localized: "reports.period.last.6.months")
    case .thisYear: return String(localized: "reports.period.this.year")
    case .custom: return String(localized: "reports.period.custom")
    }
  }
}

@MainActor
class ReportsViewModel: ObservableObject {
  @Published var isLoading = false
  @Published var errorMessage: String?
  
  // Data
  @Published var reportSummary: ReportSummary?
  @Published var categorySpending: [CategorySpending] = []
  @Published var monthlyTrends: [MonthlyTrend] = []
  @Published var budgetPerformance: [BudgetPerformance] = []
  
  // Filters
  @Published var selectedPeriod: ReportPeriod = .thisMonth
  @Published var selectedAccount: String? = nil
  @Published var selectedCategories: Set<String> = []
  @Published var customStartDate = Date()
  @Published var customEndDate = Date()
  
  // UI State
  @Published var showingChartView = true // true for charts, false for tables
  @Published var showingPeriodPicker = false
  @Published var showingFilterSheet = false
  @Published var showingExportOptions = false
  
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    setupBindings()
    loadReportData()
  }
  
  private func setupBindings() {
    // Reload data when period changes
    $selectedPeriod
      .dropFirst()
      .sink { [weak self] _ in
        self?.loadReportData()
      }
      .store(in: &cancellables)
    
    // Reload data when filters change
    Publishers.CombineLatest3($selectedAccount, $selectedCategories, $customEndDate)
      .dropFirst()
      .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
      .sink { [weak self] _, _, _ in
        self?.loadReportData()
      }
      .store(in: &cancellables)
  }
  
  // MARK: - Data Loading
  
  func loadReportData() {
    isLoading = true
    errorMessage = nil
    
    Task {
      do {
        let (startDate, endDate) = getDateRange()
        let transactions = await getTransactionsForPeriod(startDate: startDate, endDate: endDate)
        let budgets = await getBudgetsForPeriod(startDate: startDate, endDate: endDate)
        
        await MainActor.run {
          self.processReportData(transactions: transactions, budgets: budgets, startDate: startDate, endDate: endDate)
          self.isLoading = false
        }
      } catch {
        await MainActor.run {
          self.errorMessage = error.localizedDescription
          self.isLoading = false
        }
      }
    }
  }
  
  private func getDateRange() -> (start: Date, end: Date) {
    let calendar = Calendar.current
    let now = Date()
    
    switch selectedPeriod {
    case .thisMonth:
      let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
      let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
      return (startOfMonth, endOfMonth)
      
    case .lastMonth:
      let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
      let startOfLastMonth = calendar.dateInterval(of: .month, for: lastMonth)?.start ?? now
      let endOfLastMonth = calendar.dateInterval(of: .month, for: lastMonth)?.end ?? now
      return (startOfLastMonth, endOfLastMonth)
      
    case .last3Months:
      let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) ?? now
      return (threeMonthsAgo, now)
      
    case .last6Months:
      let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now) ?? now
      return (sixMonthsAgo, now)
      
    case .thisYear:
      let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
      let endOfYear = calendar.dateInterval(of: .year, for: now)?.end ?? now
      return (startOfYear, endOfYear)
      
    case .custom:
      return (customStartDate, customEndDate)
    }
  }
  
  private func getTransactionsForPeriod(startDate: Date, endDate: Date) async -> [Transaction] {
    // This would normally fetch from repository
    // For now, return mock data
    return generateMockTransactions(startDate: startDate, endDate: endDate)
  }
  
  private func getBudgetsForPeriod(startDate: Date, endDate: Date) async -> [Budget] {
    // This would normally fetch from repository
    // For now, return mock data
    return generateMockBudgets()
  }
  
  // MARK: - Data Processing
  
  private func processReportData(transactions: [Transaction], budgets: [Budget], startDate: Date, endDate: Date) {
    processReportSummary(transactions: transactions, startDate: startDate, endDate: endDate)
    processCategorySpending(transactions: transactions)
    processMonthlyTrends(transactions: transactions, startDate: startDate, endDate: endDate)
    processBudgetPerformance(transactions: transactions, budgets: budgets)
  }
  
  private func processReportSummary(transactions: [Transaction], startDate: Date, endDate: Date) {
    let income = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    let expenses = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    let netIncome = income - expenses
    let savingsRate = income > 0 ? (netIncome / income) * 100 : 0
    
    let daysDifference = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
    let averageDailySpending = daysDifference > 0 ? expenses / Double(daysDifference) : 0
    
    reportSummary = ReportSummary(
      totalIncome: income,
      totalExpenses: expenses,
      netIncome: netIncome,
      savingsRate: savingsRate,
      transactionCount: transactions.count,
      averageDailySpending: averageDailySpending
    )
  }
  
  private func processCategorySpending(transactions: [Transaction]) {
    let expenseTransactions = transactions.filter { $0.type == .expense }
    let totalExpenses = expenseTransactions.reduce(0) { $0 + $1.amount }
    
    let categoryGroups = Dictionary(grouping: expenseTransactions) { $0.category }
    
    categorySpending = categoryGroups.map { category, transactions in
      let amount = transactions.reduce(0) { $0 + $1.amount }
      let percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0
      
      return CategorySpending(
        category: category,
        amount: amount,
        percentage: percentage,
        transactionCount: transactions.count
      )
    }.sorted { $0.amount > $1.amount }
  }
  
  private func processMonthlyTrends(transactions: [Transaction], startDate: Date, endDate: Date) {
    let calendar = Calendar.current
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy"
    
    // Group transactions by month
    let monthlyGroups = Dictionary(grouping: transactions) { transaction in
      calendar.dateInterval(of: .month, for: transaction.date)?.start ?? transaction.date
    }
    
    monthlyTrends = monthlyGroups.compactMap { monthStart, transactions in
      let income = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
      let expenses = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
      
      return MonthlyTrend(
        month: formatter.string(from: monthStart),
        income: income,
        expenses: expenses,
        netIncome: income - expenses
      )
    }.sorted { 
      formatter.date(from: $0.month) ?? Date() < formatter.date(from: $1.month) ?? Date()
    }
  }
  
  private func processBudgetPerformance(transactions: [Transaction], budgets: [Budget]) {
    let expenseTransactions = transactions.filter { $0.type == .expense }
    
    budgetPerformance = budgets.map { budget in
      let spent = expenseTransactions
        .filter { $0.category == budget.category }
        .reduce(0) { $0 + $1.amount }
      
      let remaining = max(0, budget.budgetAmount - spent)
      let percentage = budget.budgetAmount > 0 ? (spent / budget.budgetAmount) * 100 : 0
      
      return BudgetPerformance(
        category: budget.category,
        budgetAmount: budget.budgetAmount,
        spentAmount: spent,
        remainingAmount: remaining,
        percentage: percentage
      )
    }.sorted { $0.percentage > $1.percentage }
  }
  
  // MARK: - Actions
  
  func refreshData() {
    loadReportData()
  }
  
  func toggleView() {
    showingChartView.toggle()
  }
  
  func exportToPDF() {
    // TODO: Implement PDF export
    showingExportOptions = false
  }
  
  func exportToCSV() {
    // TODO: Implement CSV export
    showingExportOptions = false
  }
  
  func shareReport() {
    // TODO: Implement share functionality
    showingExportOptions = false
  }
  
  // MARK: - Mock Data Generation
  
  private func generateMockTransactions(startDate: Date, endDate: Date) -> [Transaction] {
    var transactions: [Transaction] = []
    let calendar = Calendar.current
    let daysBetween = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 30
    
    // Generate income transactions
    for i in 0..<(daysBetween/7) { // Weekly income
      let date = calendar.date(byAdding: .day, value: i*7, to: startDate) ?? startDate
      transactions.append(Transaction(
        id: UUID().uuidString,
        accountId: "account1",
        amount: Double.random(in: 3000...5000),
        description: "Salary",
        category: .salary,
        type: .income,
        date: date,
        isRecurring: true,
        userId: "user1",
        createdAt: date,
        updatedAt: date
      ))
    }
    
    // Generate expense transactions
    let categories: [TransactionCategory] = [.food, .transport, .shopping, .bills, .entertainment, .healthcare]
    for i in 0..<daysBetween {
      let date = calendar.date(byAdding: .day, value: i, to: startDate) ?? startDate
      let category = categories.randomElement() ?? .food
      
      // Add 1-3 transactions per day
      for _ in 0..<Int.random(in: 1...3) {
        transactions.append(Transaction(
          id: UUID().uuidString,
          accountId: "account1",
          amount: Double.random(in: 10...200),
          description: "Expense \(category.displayName)",
          category: category,
          type: .expense,
          date: date,
          isRecurring: false,
          userId: "user1",
          createdAt: date,
          updatedAt: date
        ))
      }
    }
    
    return transactions
  }
  
  private func generateMockBudgets() -> [Budget] {
    return [
      Budget(id: "1", name: "Food", category: .food, budgetAmount: 1000, spent: 750, period: .monthly, startDate: Date(), endDate: Date(), isActive: true, alertThreshold: 0.8, userId: "user1", createdAt: Date(), updatedAt: Date()),
      Budget(id: "2", name: "Transport", category: .transport, budgetAmount: 500, spent: 400, period: .monthly, startDate: Date(), endDate: Date(), isActive: true, alertThreshold: 0.8, userId: "user1", createdAt: Date(), updatedAt: Date()),
      Budget(id: "3", name: "Shopping", category: .shopping, budgetAmount: 800, spent: 920, period: .monthly, startDate: Date(), endDate: Date(), isActive: true, alertThreshold: 0.8, userId: "user1", createdAt: Date(), updatedAt: Date()),
      Budget(id: "4", name: "Bills", category: .bills, budgetAmount: 1200, spent: 1100, period: .monthly, startDate: Date(), endDate: Date(), isActive: true, alertThreshold: 0.8, userId: "user1", createdAt: Date(), updatedAt: Date())
    ]
  }
}
