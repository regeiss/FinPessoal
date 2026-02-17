//
//  DashboardViewModelAnimationTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 17/02/26.
//

import XCTest
@testable import FinPessoal

@MainActor
final class DashboardViewModelAnimationTests: XCTestCase {

  // MARK: - Properties

  private var viewModel: DashboardViewModel!

  // MARK: - Setup & Teardown

  override func setUp() async throws {
    try await super.setUp()
    viewModel = DashboardViewModel()
  }

  override func tearDown() async throws {
    viewModel = nil
    try await super.tearDown()
  }

  // MARK: - Milestone Detection Tests

  func testNoMilestoneCelebrationWithZeroBalance() {
    // Given: No accounts (balance = 0)
    viewModel.accounts = []

    // When: Check milestones
    viewModel.checkMilestones()

    // Then: No celebration
    XCTAssertFalse(viewModel.showMilestoneCelebration)
  }

  func testMilestoneCelebrationAtFirstThreshold() {
    // Given: Balance at first milestone ($1000)
    viewModel.accounts = [
      Account(
        id: "1", name: "Test", type: .checking,
        balance: 1000, currency: "BRL",
        isActive: true, userId: "user",
        createdAt: Date(), updatedAt: Date()
      )
    ]

    // When: Check milestones
    viewModel.checkMilestones()

    // Then: Celebration should trigger
    XCTAssertTrue(viewModel.showMilestoneCelebration)
  }

  func testMilestoneCelebrationAtHigherThreshold() {
    // Given: Balance at $5000 milestone
    viewModel.accounts = [
      Account(
        id: "1", name: "Savings", type: .savings,
        balance: 5000, currency: "BRL",
        isActive: true, userId: "user",
        createdAt: Date(), updatedAt: Date()
      )
    ]

    // When: Check milestones
    viewModel.checkMilestones()

    // Then: Celebration should trigger
    XCTAssertTrue(viewModel.showMilestoneCelebration)
  }

  func testMilestoneNotRepeatedForSameThreshold() {
    // Given: Balance at $1000, milestone already seen
    viewModel.accounts = [
      Account(
        id: "1", name: "Test", type: .checking,
        balance: 1000, currency: "BRL",
        isActive: true, userId: "user",
        createdAt: Date(), updatedAt: Date()
      )
    ]

    // When: Check milestones twice
    viewModel.checkMilestones()
    viewModel.showMilestoneCelebration = false // user dismissed
    viewModel.checkMilestones()

    // Then: Celebration should not trigger again for same threshold
    XCTAssertFalse(viewModel.showMilestoneCelebration)
  }

  func testCelebrationStateDefaultsToFalse() {
    // Then: Celebration is initially false
    XCTAssertFalse(viewModel.showMilestoneCelebration)
  }

  func testBelowMilestoneThresholdNoTrigger() {
    // Given: Balance just below first milestone
    viewModel.accounts = [
      Account(
        id: "1", name: "Test", type: .checking,
        balance: 999, currency: "BRL",
        isActive: true, userId: "user",
        createdAt: Date(), updatedAt: Date()
      )
    ]

    // When: Check milestones
    viewModel.checkMilestones()

    // Then: No celebration
    XCTAssertFalse(viewModel.showMilestoneCelebration)
  }
}
