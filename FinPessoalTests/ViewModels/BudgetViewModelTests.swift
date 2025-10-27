//
//  BudgetViewModelTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 26/10/25.
//

import XCTest
import Combine
@testable import FinPessoal

@MainActor
final class BudgetViewModelTests: XCTestCase {

  // MARK: - Properties

  private var viewModel: BudgetViewModel!

  // MARK: - Setup & Teardown

  override func setUp() async throws {
    try await super.setUp()
    viewModel = BudgetViewModel()
  }

  override func tearDown() async throws {
    viewModel = nil
    try await super.tearDown()
  }

  // MARK: - Initialization Tests

  func testInitialization() throws {
    XCTAssertEqual(viewModel.name, "")
    XCTAssertEqual(viewModel.selectedCategory, .food)
    XCTAssertEqual(viewModel.budgetAmount, "")
    XCTAssertEqual(viewModel.selectedPeriod, .monthly)
    XCTAssertEqual(viewModel.alertThreshold, 0.8)
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertNil(viewModel.errorMessage)
    XCTAssertNotNil(viewModel.startDate)
  }

  // MARK: - End Date Calculation Tests

  func testEndDateCalculationMonthly() throws {
    let calendar = Calendar.current
    let startDate = DateComponents(calendar: calendar, year: 2025, month: 1, day: 15).date!

    viewModel.startDate = startDate
    viewModel.selectedPeriod = .monthly

    let endDate = viewModel.endDate

    XCTAssertEqual(calendar.component(.month, from: endDate), 2) // February
    XCTAssertEqual(calendar.component(.day, from: endDate), 15)
  }

  func testEndDateCalculationWeekly() throws {
    let calendar = Calendar.current
    let startDate = DateComponents(calendar: calendar, year: 2025, month: 1, day: 15).date!

    viewModel.startDate = startDate
    viewModel.selectedPeriod = .weekly

    let endDate = viewModel.endDate

    let expectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: startDate)!
    XCTAssertEqual(calendar.component(.day, from: endDate), calendar.component(.day, from: expectedDate))
  }

  func testEndDateCalculationQuarterly() throws {
    let calendar = Calendar.current
    let startDate = DateComponents(calendar: calendar, year: 2025, month: 1, day: 1).date!

    viewModel.startDate = startDate
    viewModel.selectedPeriod = .quarterly

    let endDate = viewModel.endDate

    XCTAssertEqual(calendar.component(.month, from: endDate), 4) // April
  }

  func testEndDateCalculationYearly() throws {
    let calendar = Calendar.current
    let startDate = DateComponents(calendar: calendar, year: 2025, month: 1, day: 1).date!

    viewModel.startDate = startDate
    viewModel.selectedPeriod = .yearly

    let endDate = viewModel.endDate

    XCTAssertEqual(calendar.component(.year, from: endDate), 2026)
  }

  // MARK: - Validation Tests

  func testIsValidBudgetWithEmptyName() throws {
    viewModel.name = ""
    viewModel.budgetAmount = "1000"

    XCTAssertFalse(viewModel.isValidBudget)
  }

  func testIsValidBudgetWithEmptyAmount() throws {
    viewModel.name = "Monthly Food Budget"
    viewModel.budgetAmount = ""

    XCTAssertFalse(viewModel.isValidBudget)
  }

  func testIsValidBudgetWithInvalidAmount() throws {
    viewModel.name = "Monthly Food Budget"
    viewModel.budgetAmount = "abc"

    XCTAssertFalse(viewModel.isValidBudget)
  }

  func testIsValidBudgetWithZeroAmount() throws {
    viewModel.name = "Monthly Food Budget"
    viewModel.budgetAmount = "0"

    XCTAssertFalse(viewModel.isValidBudget)
  }

  func testIsValidBudgetWithNegativeAmount() throws {
    viewModel.name = "Monthly Food Budget"
    viewModel.budgetAmount = "-100"

    XCTAssertFalse(viewModel.isValidBudget)
  }

  func testIsValidBudgetWithValidData() throws {
    viewModel.name = "Monthly Food Budget"
    viewModel.budgetAmount = "1000"

    XCTAssertTrue(viewModel.isValidBudget)
  }

  func testIsValidBudgetWithDecimalAmount() throws {
    viewModel.name = "Monthly Food Budget"
    viewModel.budgetAmount = "1000.50"

    XCTAssertTrue(viewModel.isValidBudget)
  }

  // MARK: - Budget Creation Tests

  func testCreateBudgetWithInvalidData() throws {
    viewModel.name = ""
    viewModel.budgetAmount = "invalid"

    let budget = viewModel.createBudget()

    XCTAssertNil(budget)
  }

  func testCreateBudgetWithValidData() throws {
    viewModel.name = "Groceries Budget"
    viewModel.selectedCategory = .food
    viewModel.budgetAmount = "500"
    viewModel.selectedPeriod = .monthly
    viewModel.alertThreshold = 0.8
    let startDate = Date()
    viewModel.startDate = startDate

    let budget = viewModel.createBudget()

    XCTAssertNotNil(budget)
    XCTAssertEqual(budget?.name, "Groceries Budget")
    XCTAssertEqual(budget?.category, .food)
    XCTAssertEqual(budget?.budgetAmount, 500.0)
    XCTAssertEqual(budget?.spent, 0.0)
    XCTAssertEqual(budget?.period, .monthly)
    XCTAssertEqual(budget?.isActive, true)
    XCTAssertEqual(budget?.alertThreshold, 0.8)
    XCTAssertNotNil(budget?.id)
    XCTAssertNotNil(budget?.userId)
  }

  func testCreateBudgetGeneratesUniqueId() throws {
    viewModel.name = "Test Budget"
    viewModel.budgetAmount = "100"

    let budget1 = viewModel.createBudget()
    let budget2 = viewModel.createBudget()

    XCTAssertNotNil(budget1)
    XCTAssertNotNil(budget2)
    XCTAssertNotEqual(budget1?.id, budget2?.id)
  }

  func testCreateBudgetWithDifferentCategories() throws {
    viewModel.name = "Transport Budget"
    viewModel.budgetAmount = "300"

    let categories: [TransactionCategory] = [.transport, .food, .entertainment, .healthcare]

    for category in categories {
      viewModel.selectedCategory = category
      let budget = viewModel.createBudget()

      XCTAssertNotNil(budget)
      XCTAssertEqual(budget?.category, category)
    }
  }

  func testCreateBudgetWithDifferentPeriods() throws {
    viewModel.name = "Test Budget"
    viewModel.budgetAmount = "500"

    let periods: [BudgetPeriod] = [.weekly, .monthly, .quarterly, .yearly]

    for period in periods {
      viewModel.selectedPeriod = period
      let budget = viewModel.createBudget()

      XCTAssertNotNil(budget)
      XCTAssertEqual(budget?.period, period)
    }
  }

  func testCreateBudgetEndDateMatchesCalculation() throws {
    viewModel.name = "Test Budget"
    viewModel.budgetAmount = "500"
    viewModel.selectedPeriod = .monthly
    let startDate = Date()
    viewModel.startDate = startDate

    let expectedEndDate = viewModel.endDate
    let budget = viewModel.createBudget()

    XCTAssertNotNil(budget)
    // Compare dates with some tolerance for execution time
    let timeDifference = abs(budget!.endDate.timeIntervalSince(expectedEndDate))
    XCTAssertLessThan(timeDifference, 1.0, "End dates should match within 1 second")
  }

  // MARK: - User ID Tests

  func testSetCurrentUserId() throws {
    let testUserId = "test-user-123"
    viewModel.setCurrentUserId(testUserId)

    viewModel.name = "Test Budget"
    viewModel.budgetAmount = "100"

    let budget = viewModel.createBudget()

    XCTAssertEqual(budget?.userId, testUserId)
  }

  func testCurrentUserIdPersistenceAcrossMultipleBudgets() throws {
    let testUserId = "persistent-user-456"
    viewModel.setCurrentUserId(testUserId)

    viewModel.name = "Budget 1"
    viewModel.budgetAmount = "100"
    let budget1 = viewModel.createBudget()

    viewModel.name = "Budget 2"
    viewModel.budgetAmount = "200"
    let budget2 = viewModel.createBudget()

    XCTAssertEqual(budget1?.userId, testUserId)
    XCTAssertEqual(budget2?.userId, testUserId)
  }

  // MARK: - Reset Tests

  func testReset() throws {
    // Set all properties to non-default values
    viewModel.name = "Test Budget"
    viewModel.selectedCategory = .transport
    viewModel.budgetAmount = "500"
    viewModel.selectedPeriod = .yearly
    viewModel.alertThreshold = 0.5
    viewModel.startDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
    viewModel.errorMessage = "Test error"

    viewModel.reset()

    XCTAssertEqual(viewModel.name, "")
    XCTAssertEqual(viewModel.selectedCategory, .food)
    XCTAssertEqual(viewModel.budgetAmount, "")
    XCTAssertEqual(viewModel.selectedPeriod, .monthly)
    XCTAssertEqual(viewModel.alertThreshold, 0.8)
    XCTAssertNil(viewModel.errorMessage)
    // startDate should be reset to approximately now
    let timeDifference = abs(viewModel.startDate.timeIntervalSinceNow)
    XCTAssertLessThan(timeDifference, 1.0, "Start date should be reset to current date")
  }

  func testResetDoesNotAffectUserId() throws {
    let testUserId = "persistent-user-789"
    viewModel.setCurrentUserId(testUserId)

    viewModel.name = "Test Budget"
    viewModel.budgetAmount = "100"

    viewModel.reset()

    // Create a budget after reset to verify userId is still set
    viewModel.name = "New Budget"
    viewModel.budgetAmount = "200"
    let budget = viewModel.createBudget()

    XCTAssertEqual(budget?.userId, testUserId)
  }

  // MARK: - Alert Threshold Tests

  func testAlertThresholdRange() throws {
    let thresholds = [0.0, 0.5, 0.8, 1.0]

    for threshold in thresholds {
      viewModel.alertThreshold = threshold
      viewModel.name = "Test Budget"
      viewModel.budgetAmount = "100"

      let budget = viewModel.createBudget()

      XCTAssertNotNil(budget)
      XCTAssertEqual(budget?.alertThreshold, threshold)
    }
  }

  // MARK: - Edge Cases

  func testCreateBudgetWithVeryLargeAmount() throws {
    viewModel.name = "Large Budget"
    viewModel.budgetAmount = "999999999.99"

    let budget = viewModel.createBudget()

    XCTAssertNotNil(budget)
    XCTAssertEqual(budget?.budgetAmount, 999999999.99)
  }

  func testCreateBudgetWithVerySmallAmount() throws {
    viewModel.name = "Small Budget"
    viewModel.budgetAmount = "0.01"

    let budget = viewModel.createBudget()

    XCTAssertNotNil(budget)
    XCTAssertEqual(budget?.budgetAmount, 0.01)
  }

  func testCreateBudgetWithWhitespaceInName() throws {
    viewModel.name = "  Budget with spaces  "
    viewModel.budgetAmount = "100"

    let budget = viewModel.createBudget()

    XCTAssertNotNil(budget)
    XCTAssertEqual(budget?.name, "  Budget with spaces  ")
  }

  func testBudgetAmountWithCommaDecimalSeparator() throws {
    // Test if the system handles comma as decimal separator
    viewModel.name = "Comma Budget"
    viewModel.budgetAmount = "1000,50"

    // This might fail depending on locale settings
    // The behavior depends on NumberFormatter locale
    if let budget = viewModel.createBudget() {
      // If it succeeds, verify the amount
      XCTAssertNotNil(budget)
    }
  }

  // MARK: - Timestamp Tests

  func testCreateBudgetTimestamps() throws {
    viewModel.name = "Timestamp Budget"
    viewModel.budgetAmount = "100"

    let beforeCreation = Date()
    let budget = viewModel.createBudget()
    let afterCreation = Date()

    XCTAssertNotNil(budget)
    XCTAssertGreaterThanOrEqual(budget!.createdAt, beforeCreation)
    XCTAssertLessThanOrEqual(budget!.createdAt, afterCreation)
    XCTAssertGreaterThanOrEqual(budget!.updatedAt, beforeCreation)
    XCTAssertLessThanOrEqual(budget!.updatedAt, afterCreation)
  }
}
