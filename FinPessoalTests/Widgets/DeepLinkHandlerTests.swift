//
//  DeepLinkHandlerTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 16/12/25.
//

import XCTest
@testable import FinPessoal

@MainActor
final class DeepLinkHandlerTests: XCTestCase {

  var handler: DeepLinkHandler!

  override func setUp() async throws {
    handler = DeepLinkHandler.shared
    handler.clearPendingDestination()
  }

  override func tearDown() async throws {
    handler.clearPendingDestination()
  }

  // MARK: - URL Scheme Tests

  func testInvalidScheme() {
    let url = URL(string: "https://example.com")!
    let result = handler.handleURL(url)

    XCTAssertFalse(result)
    XCTAssertNil(handler.pendingDestination)
  }

  func testValidScheme() {
    let url = URL(string: "finpessoal://dashboard")!
    let result = handler.handleURL(url)

    XCTAssertTrue(result)
    XCTAssertEqual(handler.pendingDestination, .dashboard)
  }

  // MARK: - Destination Parsing Tests

  func testDashboardURL() {
    let url = URL(string: "finpessoal://dashboard")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .dashboard)
  }

  func testAccountsURL() {
    let url = URL(string: "finpessoal://accounts")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .accounts)
  }

  func testAccountDetailURL() {
    let url = URL(string: "finpessoal://accounts/acc-123")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .accountDetail(id: "acc-123"))
  }

  func testTransactionsURL() {
    let url = URL(string: "finpessoal://transactions")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .transactions)
  }

  func testTransactionDetailURL() {
    let url = URL(string: "finpessoal://transactions/tx-456")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .transactionDetail(id: "tx-456"))
  }

  func testAddTransactionURL() {
    let url = URL(string: "finpessoal://add-transaction?type=expense")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .addTransaction(type: "expense"))
  }

  func testAddTransactionWithoutType() {
    let url = URL(string: "finpessoal://add-transaction")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .addTransaction(type: nil))
  }

  func testBudgetsURL() {
    let url = URL(string: "finpessoal://budgets")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .budgets)
  }

  func testBudgetDetailURL() {
    let url = URL(string: "finpessoal://budgets/bud-789")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .budgetDetail(id: "bud-789"))
  }

  func testBillsURL() {
    let url = URL(string: "finpessoal://bills")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .bills)
  }

  func testBillDetailURL() {
    let url = URL(string: "finpessoal://bills/bill-101")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .billDetail(id: "bill-101"))
  }

  func testGoalsURL() {
    let url = URL(string: "finpessoal://goals")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .goals)
  }

  func testGoalDetailURL() {
    let url = URL(string: "finpessoal://goals/goal-202")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .goalDetail(id: "goal-202"))
  }

  func testCreditCardsURL() {
    let url = URL(string: "finpessoal://creditcards")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .creditCards)
  }

  func testCreditCardDetailURL() {
    let url = URL(string: "finpessoal://creditcards/card-303")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .creditCardDetail(id: "card-303"))
  }

  func testReportsURL() {
    let url = URL(string: "finpessoal://reports")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .reports)
  }

  func testSettingsURL() {
    let url = URL(string: "finpessoal://settings")!
    handler.handleURL(url)

    XCTAssertEqual(handler.pendingDestination, .settings)
  }

  func testUnknownHost() {
    let url = URL(string: "finpessoal://unknown")!
    let result = handler.handleURL(url)

    XCTAssertFalse(result)
    XCTAssertNil(handler.pendingDestination)
  }

  // MARK: - URL Creation Tests

  func testCreateDashboardURL() {
    let url = DeepLinkHandler.url(for: .dashboard)

    XCTAssertNotNil(url)
    XCTAssertEqual(url?.absoluteString, "finpessoal://dashboard")
  }

  func testCreateAccountDetailURL() {
    let url = DeepLinkHandler.url(for: .accountDetail(id: "acc-123"))

    XCTAssertNotNil(url)
    XCTAssertEqual(url?.absoluteString, "finpessoal://accounts/acc-123")
  }

  func testCreateAddTransactionURL() {
    let url = DeepLinkHandler.url(for: .addTransaction(type: "income"))

    XCTAssertNotNil(url)
    XCTAssertTrue(url?.absoluteString.contains("type=income") ?? false)
  }

  // MARK: - URL Extension Tests

  func testWidgetURLExtensions() {
    XCTAssertNotNil(URL.dashboardURL)
    XCTAssertNotNil(URL.accountsURL)
    XCTAssertNotNil(URL.transactionsURL)
    XCTAssertNotNil(URL.budgetsURL)
    XCTAssertNotNil(URL.billsURL)
    XCTAssertNotNil(URL.goalsURL)
    XCTAssertNotNil(URL.creditCardsURL)
    XCTAssertNotNil(URL.addExpenseURL)
  }

  func testAddExpenseURLContainsType() {
    let url = URL.addExpenseURL

    XCTAssertNotNil(url)
    XCTAssertTrue(url?.absoluteString.contains("type=expense") ?? false)
  }

  // MARK: - Clear Pending Tests

  func testClearPendingDestination() {
    let url = URL(string: "finpessoal://dashboard")!
    handler.handleURL(url)

    XCTAssertNotNil(handler.pendingDestination)

    handler.clearPendingDestination()

    XCTAssertNil(handler.pendingDestination)
  }
}
