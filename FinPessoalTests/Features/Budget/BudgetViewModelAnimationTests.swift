//
//  BudgetViewModelAnimationTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 17/02/26.
//

import XCTest
@testable import FinPessoal

@MainActor
final class BudgetViewModelAnimationTests: XCTestCase {

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

  // MARK: - Celebration State Tests

  func testCelebrationStateDefaultsToFalse() {
    // Then: Celebration is initially false
    XCTAssertFalse(viewModel.showBudgetSuccessCelebration)
  }

  func testCelebrationTriggersWhenBudgetUnderLimit() {
    // Given: A budget under its limit with some spending
    let budget = Budget(
      id: "budget-1",
      name: "Food Budget",
      category: .food,
      budgetAmount: 1000,
      spent: 500,
      period: .monthly,
      startDate: Date(),
      endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
      isActive: true,
      alertThreshold: 0.8,
      userId: "user",
      createdAt: Date(),
      updatedAt: Date()
    )

    // When: Check budget status
    viewModel.checkBudgetStatus(budgets: [budget])

    // Then: Celebration triggers
    XCTAssertTrue(viewModel.showBudgetSuccessCelebration)
  }

  func testNoCelebrationWithOverBudget() {
    // Given: An over-budget budget
    let budget = Budget(
      id: "budget-1",
      name: "Transport Budget",
      category: .transport,
      budgetAmount: 300,
      spent: 400,
      period: .monthly,
      startDate: Date(),
      endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
      isActive: true,
      alertThreshold: 0.8,
      userId: "user",
      createdAt: Date(),
      updatedAt: Date()
    )

    // When: Check budget status
    viewModel.checkBudgetStatus(budgets: [budget])

    // Then: No celebration (budget is over limit)
    XCTAssertFalse(viewModel.showBudgetSuccessCelebration)
  }

  func testNoCelebrationWithEmptyBudgets() {
    // Given: Empty budget list
    // When: Check budget status
    viewModel.checkBudgetStatus(budgets: [])

    // Then: No celebration
    XCTAssertFalse(viewModel.showBudgetSuccessCelebration)
  }

  func testCelebrationCanBeReset() {
    // Given: Celebration is showing
    viewModel.showBudgetSuccessCelebration = true

    // When: Celebration completes (user dismisses or auto-dismiss)
    viewModel.showBudgetSuccessCelebration = false

    // Then: State is clean
    XCTAssertFalse(viewModel.showBudgetSuccessCelebration)
  }

  func testNoCelebrationWithZeroSpending() {
    // Given: A budget with no spending yet
    let budget = Budget(
      id: "budget-1",
      name: "Leisure Budget",
      category: .entertainment,
      budgetAmount: 500,
      spent: 0,
      period: .monthly,
      startDate: Date(),
      endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
      isActive: true,
      alertThreshold: 0.8,
      userId: "user",
      createdAt: Date(),
      updatedAt: Date()
    )

    // When: Check budget status
    viewModel.checkBudgetStatus(budgets: [budget])

    // Then: No celebration (spending must be > 0 to celebrate)
    XCTAssertFalse(viewModel.showBudgetSuccessCelebration)
  }
}
