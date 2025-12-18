//
//  WidgetDataProviderTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 16/12/25.
//

import XCTest
@testable import FinPessoal

final class WidgetDataProviderTests: XCTestCase {

  // MARK: - Account Conversion Tests

  func testAccountToSummary() {
    let account = Account(
      id: "acc-1",
      name: "Nubank",
      type: .checking,
      balance: 5000.50,
      currency: "BRL",
      isActive: true,
      userId: "user-1",
      createdAt: Date(),
      updatedAt: Date()
    )

    let summary = WidgetDataProvider.toSummary(account)

    XCTAssertEqual(summary.id, "acc-1")
    XCTAssertEqual(summary.name, "Nubank")
    XCTAssertEqual(summary.balance, 5000.50)
    XCTAssertEqual(summary.currency, "BRL")
  }

  // MARK: - Budget Conversion Tests

  func testBudgetToSummary() {
    let budget = Budget(
      id: "bud-1",
      name: "Alimentação",
      category: .food,
      budgetAmount: 1000,
      spent: 750,
      period: .monthly,
      startDate: Date(),
      endDate: Date(),
      isActive: true,
      alertThreshold: 0.8
    )

    let summary = WidgetDataProvider.toSummary(budget)

    XCTAssertEqual(summary.id, "bud-1")
    XCTAssertEqual(summary.name, "Alimentação")
    XCTAssertEqual(summary.spent, 750)
    XCTAssertEqual(summary.limit, 1000)
    XCTAssertEqual(summary.categoryIcon, "fork.knife")
  }

  // MARK: - Goal Conversion Tests

  func testGoalToSummary() {
    let goal = Goal(
      id: "goal-1",
      userId: "user-1",
      name: "Viagem",
      description: "Férias na praia",
      targetAmount: 5000,
      currentAmount: 3000,
      targetDate: Date(),
      category: .vacation,
      isActive: true,
      createdAt: Date(),
      updatedAt: Date()
    )

    let summary = WidgetDataProvider.toSummary(goal)

    XCTAssertEqual(summary.id, "goal-1")
    XCTAssertEqual(summary.name, "Viagem")
    XCTAssertEqual(summary.currentAmount, 3000)
    XCTAssertEqual(summary.targetAmount, 5000)
    XCTAssertEqual(summary.categoryIcon, "airplane")
  }

  // MARK: - Transaction Conversion Tests

  func testTransactionToSummary() {
    let transaction = Transaction(
      id: "tx-1",
      accountId: "acc-1",
      amount: 250,
      description: "Supermercado",
      category: .food,
      type: .expense,
      date: Date(),
      isRecurring: false,
      userId: "user-1",
      createdAt: Date(),
      updatedAt: Date()
    )

    let summary = WidgetDataProvider.toSummary(transaction)

    XCTAssertEqual(summary.id, "tx-1")
    XCTAssertEqual(summary.description, "Supermercado")
    XCTAssertEqual(summary.amount, 250)
    XCTAssertEqual(summary.type, "expense")
    XCTAssertEqual(summary.categoryIcon, "fork.knife")
  }

  // MARK: - Build Widget Data Tests

  func testBuildWidgetDataEmpty() {
    let widgetData = WidgetDataProvider.buildWidgetData(
      accounts: [],
      budgets: [],
      bills: [],
      goals: [],
      creditCards: [],
      transactions: []
    )

    XCTAssertEqual(widgetData.totalBalance, 0)
    XCTAssertEqual(widgetData.monthlyIncome, 0)
    XCTAssertEqual(widgetData.monthlyExpenses, 0)
    XCTAssertTrue(widgetData.accounts.isEmpty)
  }

  func testBuildWidgetDataWithAccounts() {
    let accounts = [
      Account(
        id: "1",
        name: "Conta 1",
        type: .checking,
        balance: 1000,
        currency: "BRL",
        isActive: true,
        userId: "user-1",
        createdAt: Date(),
        updatedAt: Date()
      ),
      Account(
        id: "2",
        name: "Conta 2",
        type: .savings,
        balance: 2000,
        currency: "BRL",
        isActive: true,
        userId: "user-1",
        createdAt: Date(),
        updatedAt: Date()
      ),
      Account(
        id: "3",
        name: "Conta Inativa",
        type: .checking,
        balance: 500,
        currency: "BRL",
        isActive: false,
        userId: "user-1",
        createdAt: Date(),
        updatedAt: Date()
      )
    ]

    let widgetData = WidgetDataProvider.buildWidgetData(
      accounts: accounts,
      budgets: [],
      bills: [],
      goals: [],
      creditCards: [],
      transactions: []
    )

    // Should only include active accounts
    XCTAssertEqual(widgetData.accounts.count, 2)
    // Total balance should only include active accounts
    XCTAssertEqual(widgetData.totalBalance, 3000)
  }

  func testBuildWidgetDataWithTransactions() {
    let calendar = Calendar.current
    let now = Date()
    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!

    let transactions = [
      Transaction(
        id: "1",
        accountId: "acc-1",
        amount: 5000,
        description: "Salário",
        category: .salary,
        type: .income,
        date: startOfMonth.addingTimeInterval(86400),
        isRecurring: false,
        userId: "user-1",
        createdAt: Date(),
        updatedAt: Date()
      ),
      Transaction(
        id: "2",
        accountId: "acc-1",
        amount: 250,
        description: "Supermercado",
        category: .food,
        type: .expense,
        date: startOfMonth.addingTimeInterval(86400 * 2),
        isRecurring: false,
        userId: "user-1",
        createdAt: Date(),
        updatedAt: Date()
      )
    ]

    let widgetData = WidgetDataProvider.buildWidgetData(
      accounts: [],
      budgets: [],
      bills: [],
      goals: [],
      creditCards: [],
      transactions: transactions
    )

    XCTAssertEqual(widgetData.monthlyIncome, 5000)
    XCTAssertEqual(widgetData.monthlyExpenses, 250)
    XCTAssertEqual(widgetData.recentTransactions.count, 2)
  }

  // MARK: - Partial Update Tests

  func testBuildAccountUpdate() {
    let existingData = WidgetData(
      lastUpdated: Date(),
      totalBalance: 1000,
      monthlyIncome: 5000,
      monthlyExpenses: 3000,
      accounts: [],
      budgets: [
        BudgetSummary(id: "1", name: "Test", category: "food", categoryIcon: "fork.knife", spent: 500, limit: 1000)
      ],
      upcomingBills: [],
      goals: [],
      creditCards: [],
      recentTransactions: []
    )

    let newAccounts = [
      Account(
        id: "1",
        name: "Nova Conta",
        type: .checking,
        balance: 5000,
        currency: "BRL",
        isActive: true,
        userId: "user-1",
        createdAt: Date(),
        updatedAt: Date()
      )
    ]

    let updatedData = WidgetDataProvider.buildAccountUpdate(
      accounts: newAccounts,
      existingData: existingData
    )

    // Account data should be updated
    XCTAssertEqual(updatedData.totalBalance, 5000)
    XCTAssertEqual(updatedData.accounts.count, 1)

    // Other data should remain unchanged
    XCTAssertEqual(updatedData.monthlyIncome, 5000)
    XCTAssertEqual(updatedData.budgets.count, 1)
  }

  func testBuildBudgetUpdate() {
    let existingData = WidgetData(
      lastUpdated: Date(),
      totalBalance: 10000,
      monthlyIncome: 5000,
      monthlyExpenses: 3000,
      accounts: [
        AccountSummary(id: "1", name: "Conta", type: "checking", balance: 10000, currency: "BRL")
      ],
      budgets: [],
      upcomingBills: [],
      goals: [],
      creditCards: [],
      recentTransactions: []
    )

    let newBudgets = [
      Budget(
        id: "1",
        name: "Alimentação",
        category: .food,
        budgetAmount: 1000,
        spent: 800,
        period: .monthly,
        startDate: Date(),
        endDate: Date(),
        isActive: true,
        alertThreshold: 0.8
      )
    ]

    let updatedData = WidgetDataProvider.buildBudgetUpdate(
      budgets: newBudgets,
      existingData: existingData
    )

    // Budget data should be updated
    XCTAssertEqual(updatedData.budgets.count, 1)
    XCTAssertEqual(updatedData.budgets.first?.spent, 800)

    // Other data should remain unchanged
    XCTAssertEqual(updatedData.totalBalance, 10000)
    XCTAssertEqual(updatedData.accounts.count, 1)
  }
}
