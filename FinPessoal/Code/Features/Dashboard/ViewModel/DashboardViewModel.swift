//
//  DashboardViewModel.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
  @Published var accounts: [Account] = []
  @Published var recentTransactions: [Transaction] = []
  @Published var budgets: [Budget] = []
  @Published var isLoading = false
  @Published var error: AppError?
  @Published var spendingTrendsData: SpendingTrendsData?
  @Published var chartDateRange: ChartDateRange = .sevenDays

  private let accountRepository: AccountRepositoryProtocol
  private let transactionRepository: TransactionRepositoryProtocol
  private var cancellables = Set<AnyCancellable>()
  private var previousChartData: SpendingTrendsData?
  
  init() {
    self.accountRepository = AppConfiguration.shared.createAccountRepository()
    self.transactionRepository = AppConfiguration.shared.createTransactionRepository()
    print("DashboardViewModel: Initialized with repositories")
    print("DashboardViewModel: Using mock data = \(AppConfiguration.shared.useMockData)")
  }
  
  var totalBalance: Double {
    accounts.reduce(0) { $0 + $1.balance }
  }
  
  var monthlyExpenses: Double {
    let calendar = Calendar.current
    let now = Date()
    let startOfMonth = calendar.startOfMonth(for: now) ?? now
    let endOfMonth = calendar.endOfMonth(for: now) ?? now
    
    return recentTransactions
      .filter { transaction in
        transaction.type == .expense && 
        transaction.date >= startOfMonth && 
        transaction.date <= endOfMonth
      }
      .reduce(0) { $0 + $1.amount }
  }
  
  var budgetAlerts: [Budget] {
    budgets.filter { budget in
      let spentPercentage = budget.budgetAmount > 0 ? (budget.spent / budget.budgetAmount) : 0
      return spentPercentage >= budget.alertThreshold
    }
  }
  
  func loadDashboardData() async throws {
    print("DashboardViewModel: loadDashboardData() called")
    isLoading = true
    error = nil

    await loadAccountsAndTransactions()
    await loadBudgets()
    await loadChartData()
  }

  func loadDashboardData() {
    print("DashboardViewModel: loadDashboardData() called (sync wrapper)")
    Task {
      try? await loadDashboardData()
    }
  }
  
  private func loadAccountsAndTransactions() async {
    do {
      print("DashboardViewModel: Loading accounts...")
      let fetchedAccounts = try await accountRepository.getAccounts()
      accounts = fetchedAccounts
      print("DashboardViewModel: Loaded \(fetchedAccounts.count) accounts")
      
      print("DashboardViewModel: Loading recent transactions...")
      let fetchedTransactions = try await transactionRepository.getRecentTransactions(limit: 10)
      recentTransactions = fetchedTransactions
      print("DashboardViewModel: Loaded \(fetchedTransactions.count) recent transactions")
      
    } catch {
      print("DashboardViewModel: Error loading accounts/transactions: \(error)")
      self.error = AppError.databaseError("Erro ao carregar dados do painel")
    }
  }
  
  private func loadBudgets() async {
    // For now, budgets will be empty until Budget repository is implemented
    // This prevents any crashes and the dashboard will still work
    budgets = []
    isLoading = false
    print("DashboardViewModel: Data loading completed")
  }

  // MARK: - Chart Data

  private func loadChartData() async {
    print("DashboardViewModel: Loading chart data for range: \(chartDateRange)")

    // Use background thread for data aggregation
    let chartData = await Task.detached(priority: .userInitiated) { [weak self] () -> SpendingTrendsData? in
      guard let self = self else { return nil }
      return await self.aggregateChartData(range: self.chartDateRange)
    }.value

    if let chartData = chartData {
      // Store previous data for smooth transitions
      previousChartData = spendingTrendsData

      // Update with new data
      var updatedData = chartData
      updatedData.previousPoints = previousChartData?.points
      spendingTrendsData = updatedData

      print("DashboardViewModel: Chart data loaded with \(chartData.points.count) points")
    }
  }

  private func aggregateChartData(range: ChartDateRange) async -> SpendingTrendsData {
    let calendar = Calendar.current
    let endDate = Date()
    let startDate: Date
    let dayCount: Int

    switch range {
    case .sevenDays:
      startDate = calendar.date(byAdding: .day, value: -6, to: endDate) ?? endDate
      dayCount = 7
    case .thirtyDays:
      startDate = calendar.date(byAdding: .day, value: -29, to: endDate) ?? endDate
      dayCount = 30
    }

    // Aggregate transactions by day
    var dailyTotals: [Date: (value: Double, transactions: [Transaction])] = [:]

    for transaction in recentTransactions where transaction.type == .expense {
      guard transaction.date >= startDate && transaction.date <= endDate else { continue }

      let dayStart = calendar.startOfDay(for: transaction.date)

      if var existing = dailyTotals[dayStart] {
        existing.value += transaction.amount
        existing.transactions.append(transaction)
        dailyTotals[dayStart] = existing
      } else {
        dailyTotals[dayStart] = (value: transaction.amount, transactions: [transaction])
      }
    }

    // Create data points for each day
    var points: [ChartDataPoint] = []

    for i in 0..<dayCount {
      let date = calendar.date(byAdding: .day, value: -i, to: endDate) ?? endDate
      let dayStart = calendar.startOfDay(for: date)

      let dayData = dailyTotals[dayStart] ?? (value: 0.0, transactions: [])

      points.append(ChartDataPoint(
        date: dayStart,
        value: dayData.value,
        transactions: dayData.transactions
      ))
    }

    // Reverse to show chronologically (oldest to newest)
    points = points.reversed()

    // Calculate min/max values
    let values = points.map { $0.value }
    let maxValue = values.max() ?? 100.0
    let minValue = values.min() ?? 0.0

    // Add padding for better visualization
    let padding = (maxValue - minValue) * 0.1
    let paddedMax = maxValue + padding
    let paddedMin = max(minValue - padding, 0.0)

    return SpendingTrendsData(
      points: points,
      maxValue: paddedMax,
      minValue: paddedMin,
      dateRange: startDate...endDate
    )
  }

  func updateChartRange(_ range: ChartDateRange) {
    chartDateRange = range

    Task {
      await loadChartData()
    }
  }
}

// MARK: - Chart Date Range

enum ChartDateRange {
  case sevenDays
  case thirtyDays

  var displayName: String {
    switch self {
    case .sevenDays:
      return "7 Days"
    case .thirtyDays:
      return "30 Days"
    }
  }
}
