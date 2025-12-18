//
//  WidgetDataTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 16/12/25.
//

import XCTest
@testable import FinPessoal

final class WidgetDataTests: XCTestCase {

  // MARK: - WidgetData Tests

  func testWidgetDataEmpty() {
    let empty = WidgetData.empty

    XCTAssertEqual(empty.totalBalance, 0)
    XCTAssertEqual(empty.monthlyIncome, 0)
    XCTAssertEqual(empty.monthlyExpenses, 0)
    XCTAssertTrue(empty.accounts.isEmpty)
    XCTAssertTrue(empty.budgets.isEmpty)
    XCTAssertTrue(empty.upcomingBills.isEmpty)
    XCTAssertTrue(empty.goals.isEmpty)
    XCTAssertTrue(empty.creditCards.isEmpty)
    XCTAssertTrue(empty.recentTransactions.isEmpty)
  }

  func testWidgetDataEncoding() throws {
    let data = WidgetData(
      lastUpdated: Date(),
      totalBalance: 1000.50,
      monthlyIncome: 5000,
      monthlyExpenses: 3000,
      accounts: [],
      budgets: [],
      upcomingBills: [],
      goals: [],
      creditCards: [],
      recentTransactions: []
    )

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let encoded = try encoder.encode(data)

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let decoded = try decoder.decode(WidgetData.self, from: encoded)

    XCTAssertEqual(decoded.totalBalance, 1000.50)
    XCTAssertEqual(decoded.monthlyIncome, 5000)
    XCTAssertEqual(decoded.monthlyExpenses, 3000)
  }

  // MARK: - AccountSummary Tests

  func testAccountSummaryFormattedBalance() {
    let account = AccountSummary(
      id: "1",
      name: "Nubank",
      type: "Conta Corrente",
      balance: 1234.56,
      currency: "BRL"
    )

    XCTAssertEqual(account.id, "1")
    XCTAssertEqual(account.name, "Nubank")
    XCTAssertTrue(account.formattedBalance.contains("1.234"))
  }

  func testAccountSummaryAccessibility() {
    let account = AccountSummary(
      id: "1",
      name: "Poupança",
      type: "Poupança",
      balance: 5000,
      currency: "BRL"
    )

    XCTAssertTrue(account.accessibilityLabel.contains("Poupança"))
    XCTAssertTrue(account.accessibilityLabel.contains("saldo"))
  }

  // MARK: - BudgetSummary Tests

  func testBudgetSummaryPercentage() {
    let budget = BudgetSummary(
      id: "1",
      name: "Alimentação",
      category: "food",
      categoryIcon: "fork.knife",
      spent: 750,
      limit: 1000
    )

    XCTAssertEqual(budget.percentage, 75)
    XCTAssertFalse(budget.isOverBudget)
    XCTAssertEqual(budget.remaining, 250)
  }

  func testBudgetSummaryOverBudget() {
    let budget = BudgetSummary(
      id: "1",
      name: "Lazer",
      category: "entertainment",
      categoryIcon: "gamecontroller",
      spent: 1200,
      limit: 1000
    )

    XCTAssertEqual(budget.percentage, 120)
    XCTAssertTrue(budget.isOverBudget)
    XCTAssertEqual(budget.remaining, 0)
  }

  func testBudgetSummaryZeroLimit() {
    let budget = BudgetSummary(
      id: "1",
      name: "Test",
      category: "other",
      categoryIcon: "circle",
      spent: 100,
      limit: 0
    )

    XCTAssertEqual(budget.percentage, 0)
  }

  // MARK: - BillSummary Tests

  func testBillSummaryDaysUntilDue() {
    let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
    let bill = BillSummary(
      id: "1",
      name: "Internet",
      amount: 120,
      dueDate: futureDate,
      status: "upcoming",
      categoryIcon: "wifi"
    )

    XCTAssertEqual(bill.daysUntilDue, 5)
    XCTAssertFalse(bill.isOverdue)
    XCTAssertFalse(bill.isDueSoon)
  }

  func testBillSummaryOverdue() {
    let pastDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
    let bill = BillSummary(
      id: "1",
      name: "Energia",
      amount: 180,
      dueDate: pastDate,
      status: "overdue",
      categoryIcon: "bolt"
    )

    XCTAssertTrue(bill.isOverdue)
  }

  func testBillSummaryDueSoon() {
    let soonDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
    let bill = BillSummary(
      id: "1",
      name: "Aluguel",
      amount: 1500,
      dueDate: soonDate,
      status: "upcoming",
      categoryIcon: "house"
    )

    XCTAssertTrue(bill.isDueSoon)
    XCTAssertFalse(bill.isOverdue)
  }

  // MARK: - GoalSummary Tests

  func testGoalSummaryPercentage() {
    let goal = GoalSummary(
      id: "1",
      name: "Viagem",
      currentAmount: 3000,
      targetAmount: 5000,
      targetDate: nil,
      categoryIcon: "airplane"
    )

    XCTAssertEqual(goal.percentage, 60)
    XCTAssertEqual(goal.remaining, 2000)
    XCTAssertFalse(goal.isCompleted)
  }

  func testGoalSummaryCompleted() {
    let goal = GoalSummary(
      id: "1",
      name: "Emergência",
      currentAmount: 10000,
      targetAmount: 10000,
      targetDate: nil,
      categoryIcon: "shield"
    )

    XCTAssertEqual(goal.percentage, 100)
    XCTAssertTrue(goal.isCompleted)
    XCTAssertEqual(goal.remaining, 0)
  }

  func testGoalSummaryDaysRemaining() {
    let futureDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
    let goal = GoalSummary(
      id: "1",
      name: "Carro",
      currentAmount: 5000,
      targetAmount: 50000,
      targetDate: futureDate,
      categoryIcon: "car"
    )

    XCTAssertEqual(goal.daysRemaining, 30)
  }

  // MARK: - CardSummary Tests

  func testCardSummaryUtilization() {
    let card = CardSummary(
      id: "1",
      name: "Nubank",
      currentBalance: 1500,
      creditLimit: 5000,
      dueDate: nil,
      brand: "mastercard"
    )

    XCTAssertEqual(card.utilizationPercentage, 30)
    XCTAssertEqual(card.availableCredit, 3500)
  }

  func testCardSummaryHighUtilization() {
    let card = CardSummary(
      id: "1",
      name: "Itaú",
      currentBalance: 4500,
      creditLimit: 5000,
      dueDate: nil,
      brand: "visa"
    )

    XCTAssertEqual(card.utilizationPercentage, 90)
    XCTAssertEqual(card.availableCredit, 500)
  }

  // MARK: - TransactionSummary Tests

  func testTransactionSummaryExpense() {
    let transaction = TransactionSummary(
      id: "1",
      description: "Supermercado",
      amount: 250,
      date: Date(),
      type: "expense",
      category: "food",
      categoryIcon: "cart"
    )

    XCTAssertTrue(transaction.isExpense)
    XCTAssertFalse(transaction.isIncome)
    XCTAssertTrue(transaction.formattedAmount.contains("-"))
  }

  func testTransactionSummaryIncome() {
    let transaction = TransactionSummary(
      id: "1",
      description: "Salário",
      amount: 5000,
      date: Date(),
      type: "income",
      category: "salary",
      categoryIcon: "banknote"
    )

    XCTAssertFalse(transaction.isExpense)
    XCTAssertTrue(transaction.isIncome)
    XCTAssertTrue(transaction.formattedAmount.contains("+"))
  }

  func testTransactionSummaryFormattedDateToday() {
    let transaction = TransactionSummary(
      id: "1",
      description: "Teste",
      amount: 100,
      date: Date(),
      type: "expense",
      category: "other",
      categoryIcon: "circle"
    )

    XCTAssertEqual(transaction.formattedDate, "Hoje")
  }
}
