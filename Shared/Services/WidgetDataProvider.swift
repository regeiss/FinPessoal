//
//  WidgetDataProvider.swift
//  FinPessoal
//
//  Created by Claude Code on 16/12/25.
//

import Foundation

/// Converts main app models to lightweight widget summary models
enum WidgetDataProvider {

  // MARK: - Account Conversion

  /// Converts an Account to AccountSummary for widget display
  static func toSummary(_ account: Account) -> AccountSummary {
    AccountSummary(
      id: account.id,
      name: account.name,
      type: account.type.rawValue,
      balance: account.balance,
      currency: account.currency
    )
  }

  // MARK: - Budget Conversion

  /// Converts a Budget to BudgetSummary for widget display
  static func toSummary(_ budget: Budget) -> BudgetSummary {
    BudgetSummary(
      id: budget.id,
      name: budget.name,
      category: budget.category.rawValue,
      categoryIcon: budget.category.icon,
      spent: budget.spent,
      limit: budget.budgetAmount
    )
  }

  // MARK: - Bill Conversion

  /// Converts a Bill to BillSummary for widget display
  static func toSummary(_ bill: Bill) -> BillSummary {
    BillSummary(
      id: bill.id,
      name: bill.name,
      amount: bill.amount,
      dueDate: bill.nextDueDate,
      status: bill.status.rawValue,
      categoryIcon: bill.category.icon
    )
  }

  // MARK: - Goal Conversion

  /// Converts a Goal to GoalSummary for widget display
  static func toSummary(_ goal: Goal) -> GoalSummary {
    GoalSummary(
      id: goal.id,
      name: goal.name,
      currentAmount: goal.currentAmount,
      targetAmount: goal.targetAmount,
      targetDate: goal.targetDate,
      categoryIcon: goal.category.icon
    )
  }

  // MARK: - Credit Card Conversion

  /// Converts a CreditCard to CardSummary for widget display
  static func toSummary(_ card: CreditCard) -> CardSummary {
    CardSummary(
      id: card.id,
      name: card.name,
      currentBalance: card.currentBalance,
      creditLimit: card.creditLimit,
      dueDate: card.nextDueDate,
      brand: card.brand.rawValue
    )
  }

  // MARK: - Transaction Conversion

  /// Converts a Transaction to TransactionSummary for widget display
  static func toSummary(_ transaction: Transaction) -> TransactionSummary {
    TransactionSummary(
      id: transaction.id,
      description: transaction.description,
      amount: transaction.amount,
      date: transaction.date,
      type: transaction.type.rawValue,
      category: transaction.category.rawValue,
      categoryIcon: transaction.category.icon
    )
  }

  // MARK: - Build Complete Widget Data

  /// Builds complete widget data from all app data sources
  /// - Parameters:
  ///   - accounts: List of user accounts
  ///   - budgets: List of active budgets
  ///   - bills: List of bills
  ///   - goals: List of goals
  ///   - creditCards: List of credit cards
  ///   - transactions: List of recent transactions
  /// - Returns: Complete WidgetData struct for widget display
  static func buildWidgetData(
    accounts: [Account],
    budgets: [Budget],
    bills: [Bill],
    goals: [Goal],
    creditCards: [CreditCard],
    transactions: [Transaction]
  ) -> WidgetData {

    // Filter active accounts and calculate total balance
    let activeAccounts = accounts.filter { $0.isActive }
    let totalBalance = activeAccounts.reduce(0.0) { $0 + $1.balance }

    // Calculate monthly income and expenses
    let calendar = Calendar.current
    let now = Date()
    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now

    let monthlyTransactions = transactions.filter { $0.date >= startOfMonth }
    let monthlyIncome = monthlyTransactions
      .filter { $0.type == .income }
      .reduce(0.0) { $0 + $1.amount }
    let monthlyExpenses = monthlyTransactions
      .filter { $0.type == .expense }
      .reduce(0.0) { $0 + $1.amount }

    // Filter and sort upcoming bills (unpaid, sorted by due date)
    let upcomingBills = bills
      .filter { !$0.isPaid && $0.isActive }
      .sorted { $0.nextDueDate < $1.nextDueDate }
      .prefix(5)

    // Filter active budgets sorted by percentage used (highest first)
    let activeBudgets = budgets
      .filter { $0.isActive }
      .sorted { $0.percentageUsed > $1.percentageUsed }

    // Filter active goals sorted by progress (highest first)
    let activeGoals = goals
      .filter { $0.isActive && !$0.isCompleted }
      .sorted { $0.progressPercentage > $1.progressPercentage }

    // Filter active credit cards
    let activeCards = creditCards
      .filter { $0.isActive }
      .sorted { $0.utilizationPercentage > $1.utilizationPercentage }

    // Get recent transactions (sorted by date, most recent first)
    let recentTransactions = transactions
      .sorted { $0.date > $1.date }
      .prefix(10)

    return WidgetData(
      lastUpdated: Date(),
      totalBalance: totalBalance,
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
      accounts: activeAccounts.map { toSummary($0) },
      budgets: activeBudgets.map { toSummary($0) },
      upcomingBills: Array(upcomingBills).map { toSummary($0) },
      goals: activeGoals.map { toSummary($0) },
      creditCards: activeCards.map { toSummary($0) },
      recentTransactions: Array(recentTransactions).map { toSummary($0) }
    )
  }

  // MARK: - Partial Updates

  /// Builds widget data with only account updates
  static func buildAccountUpdate(accounts: [Account], existingData: WidgetData) -> WidgetData {
    let activeAccounts = accounts.filter { $0.isActive }
    let totalBalance = activeAccounts.reduce(0.0) { $0 + $1.balance }

    return WidgetData(
      lastUpdated: Date(),
      totalBalance: totalBalance,
      monthlyIncome: existingData.monthlyIncome,
      monthlyExpenses: existingData.monthlyExpenses,
      accounts: activeAccounts.map { toSummary($0) },
      budgets: existingData.budgets,
      upcomingBills: existingData.upcomingBills,
      goals: existingData.goals,
      creditCards: existingData.creditCards,
      recentTransactions: existingData.recentTransactions
    )
  }

  /// Builds widget data with only budget updates
  static func buildBudgetUpdate(budgets: [Budget], existingData: WidgetData) -> WidgetData {
    let activeBudgets = budgets
      .filter { $0.isActive }
      .sorted { $0.percentageUsed > $1.percentageUsed }

    return WidgetData(
      lastUpdated: Date(),
      totalBalance: existingData.totalBalance,
      monthlyIncome: existingData.monthlyIncome,
      monthlyExpenses: existingData.monthlyExpenses,
      accounts: existingData.accounts,
      budgets: activeBudgets.map { toSummary($0) },
      upcomingBills: existingData.upcomingBills,
      goals: existingData.goals,
      creditCards: existingData.creditCards,
      recentTransactions: existingData.recentTransactions
    )
  }

  /// Builds widget data with only transaction updates
  static func buildTransactionUpdate(transactions: [Transaction], existingData: WidgetData) -> WidgetData {
    let calendar = Calendar.current
    let now = Date()
    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now

    let monthlyTransactions = transactions.filter { $0.date >= startOfMonth }
    let monthlyIncome = monthlyTransactions
      .filter { $0.type == .income }
      .reduce(0.0) { $0 + $1.amount }
    let monthlyExpenses = monthlyTransactions
      .filter { $0.type == .expense }
      .reduce(0.0) { $0 + $1.amount }

    let recentTransactions = transactions
      .sorted { $0.date > $1.date }
      .prefix(10)

    return WidgetData(
      lastUpdated: Date(),
      totalBalance: existingData.totalBalance,
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
      accounts: existingData.accounts,
      budgets: existingData.budgets,
      upcomingBills: existingData.upcomingBills,
      goals: existingData.goals,
      creditCards: existingData.creditCards,
      recentTransactions: Array(recentTransactions).map { toSummary($0) }
    )
  }
}
