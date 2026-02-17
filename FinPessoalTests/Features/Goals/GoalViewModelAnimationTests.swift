//
//  GoalViewModelAnimationTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 17/02/26.
//

import XCTest
@testable import FinPessoal

@MainActor
final class GoalViewModelAnimationTests: XCTestCase {

  // MARK: - Properties

  private var viewModel: GoalViewModel!

  // MARK: - Setup & Teardown

  override func setUp() async throws {
    try await super.setUp()
    viewModel = GoalViewModel()
  }

  override func tearDown() async throws {
    viewModel = nil
    try await super.tearDown()
  }

  // MARK: - Goal Progress Tests

  func testUpdateGoalProgressIncreasesAmount() {
    // Given: A goal with partial progress
    let goal = Goal(
      id: "goal-1",
      userId: "user",
      name: "Emergency Fund",
      description: nil,
      targetAmount: 10000,
      currentAmount: 0,
      targetDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date(),
      category: .emergency,
      isActive: true,
      createdAt: Date(),
      updatedAt: Date()
    )
    var goals = [goal]

    // When: Progress is updated
    viewModel.updateGoalProgress("goal-1", newAmount: 5000, in: &goals)

    // Then: Goal amount is updated
    XCTAssertEqual(goals.first?.currentAmount, 5000)
  }

  func testUpdateGoalProgressForNonExistentGoalNoChange() {
    // Given: A goal list
    let goal = Goal(
      id: "goal-1",
      userId: "user",
      name: "Vacation",
      description: nil,
      targetAmount: 5000,
      currentAmount: 1000,
      targetDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date(),
      category: .vacation,
      isActive: true,
      createdAt: Date(),
      updatedAt: Date()
    )
    var goals = [goal]

    // When: Update references a non-existent goal ID
    viewModel.updateGoalProgress("non-existent", newAmount: 3000, in: &goals)

    // Then: List unchanged
    XCTAssertEqual(goals.first?.currentAmount, 1000)
  }

  func testUpdateGoalProgressPreservesOtherFields() {
    // Given: A goal
    let targetDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    let goal = Goal(
      id: "goal-1",
      userId: "user",
      name: "House Down Payment",
      description: "Save for a house",
      targetAmount: 50000,
      currentAmount: 10000,
      targetDate: targetDate,
      category: .house,
      isActive: true,
      createdAt: Date(),
      updatedAt: Date()
    )
    var goals = [goal]

    // When: Update progress
    viewModel.updateGoalProgress("goal-1", newAmount: 20000, in: &goals)

    // Then: Other fields unchanged
    let updated = goals.first
    XCTAssertEqual(updated?.name, "House Down Payment")
    XCTAssertEqual(updated?.targetAmount, 50000)
    XCTAssertEqual(updated?.category, .house)
    XCTAssertEqual(updated?.currentAmount, 20000)
  }

  func testGoalProgressPercentageAtCompletion() {
    // Given: A goal at target amount
    let goal = Goal(
      id: "goal-1",
      userId: "user",
      name: "Vacation Fund",
      description: nil,
      targetAmount: 3000,
      currentAmount: 3000,
      targetDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date(),
      category: .vacation,
      isActive: true,
      createdAt: Date(),
      updatedAt: Date()
    )

    // Then: Progress shows 100%
    XCTAssertGreaterThanOrEqual(goal.progressPercentage, 100)
    XCTAssertTrue(goal.isCompleted)
  }
}
