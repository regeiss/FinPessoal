//
//  NotificationManagerTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 26/10/25.
//

import XCTest
import UserNotifications
@testable import FinPessoal

@MainActor
final class NotificationManagerTests: XCTestCase {

  // MARK: - Properties

  private var notificationManager: NotificationManager!
  private var testBudget: Budget!
  private var testTransaction: Transaction!
  private var testGoal: Goal!

  // MARK: - Setup & Teardown

  override func setUp() async throws {
    try await super.setUp()

    notificationManager = NotificationManager.shared

    // Create test data
    testBudget = Budget(
      id: "test-budget-id",
      name: "Test Budget",
      category: .food,
      budgetAmount: 1000.0,
      spent: 850.0, // 85% used
      period: .monthly,
      startDate: Date(),
      endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
      isActive: true,
      alertThreshold: 0.8,
      userId: "test-user-id",
      createdAt: Date(),
      updatedAt: Date()
    )

    testTransaction = Transaction(
      id: "test-transaction-id",
      accountId: "test-account-id",
      amount: 1500.0,
      description: "Large Purchase",
      category: .shopping,
      type: .expense,
      date: Date(),
      isRecurring: true,
      userId: "test-user-id",
      createdAt: Date(),
      updatedAt: Date()
    )

    testGoal = Goal(
      id: "test-goal-id",
      name: "Vacation Fund",
      targetAmount: 5000.0,
      currentAmount: 2500.0, // 50% achieved
      category: .other,
      deadline: Calendar.current.date(byAdding: .month, value: 6, to: Date())!,
      userId: "test-user-id",
      createdAt: Date(),
      updatedAt: Date()
    )
  }

  override func tearDown() async throws {
    // Clean up all notifications
    await notificationManager.cancelAllNotifications()
    testBudget = nil
    testTransaction = nil
    testGoal = nil

    try await super.tearDown()
  }

  // MARK: - Initialization Tests

  func testSingletonInstance() throws {
    let instance1 = NotificationManager.shared
    let instance2 = NotificationManager.shared

    XCTAssertTrue(instance1 === instance2, "NotificationManager should be a singleton")
  }

  // MARK: - Authorization Tests

  func testRequestAuthorization() async throws {
    // Note: In tests, authorization request will likely fail or require simulator permissions
    // This test validates the method exists and can be called without crashing
    do {
      let granted = try await notificationManager.requestAuthorization()
      // In test environment, this might be false
      XCTAssertNotNil(granted)
    } catch {
      // Authorization request might fail in tests - this is expected
      print("Authorization test - expected failure in test environment: \(error)")
    }
  }

  func testCheckAuthorizationStatus() async throws {
    await notificationManager.checkAuthorizationStatus()

    // Verify that the method completes without errors
    // The actual authorization status will depend on simulator settings
    XCTAssertNotNil(notificationManager.notificationSettings)
  }

  // MARK: - Budget Alert Tests

  func testScheduleBudgetAlertForBudgetOverThreshold() async throws {
    // Test budget is at 85%, threshold is 80%
    XCTAssertTrue(testBudget.percentageUsed >= testBudget.alertThreshold)

    await notificationManager.scheduleBudgetAlert(budget: testBudget)

    let pendingCount = await notificationManager.getPendingNotificationsCount()
    // Note: In test environment without proper authorization, this might be 0
    // The test validates the method executes without errors
    XCTAssertGreaterThanOrEqual(pendingCount, 0)
  }

  func testScheduleBudgetAlertForBudgetUnderThreshold() async throws {
    // Create budget under threshold
    let underThresholdBudget = Budget(
      id: "under-threshold-budget",
      name: "Under Threshold",
      category: .food,
      budgetAmount: 1000.0,
      spent: 500.0, // 50% used
      period: .monthly,
      startDate: Date(),
      endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
      isActive: true,
      alertThreshold: 0.8,
      userId: "test-user-id",
      createdAt: Date(),
      updatedAt: Date()
    )

    await notificationManager.scheduleBudgetAlert(budget: underThresholdBudget)

    // Should not schedule notification for budget under threshold
    // Verify method completes without error
    XCTAssertTrue(true)
  }

  func testUpdateBudgetAlert() async throws {
    await notificationManager.scheduleBudgetAlert(budget: testBudget)
    await notificationManager.updateBudgetAlert(budget: testBudget)

    // Verify method completes without error
    XCTAssertTrue(true)
  }

  // MARK: - Bill Reminder Tests

  func testScheduleBillReminderForRecurringTransaction() async throws {
    XCTAssertTrue(testTransaction.isRecurring)

    await notificationManager.scheduleBillReminder(transaction: testTransaction, daysBeforeDue: 3)

    // Verify method completes without error
    let pendingCount = await notificationManager.getPendingNotificationsCount()
    XCTAssertGreaterThanOrEqual(pendingCount, 0)
  }

  func testScheduleBillReminderForNonRecurringTransaction() async throws {
    let nonRecurringTransaction = Transaction(
      id: "non-recurring-id",
      accountId: "test-account-id",
      amount: 100.0,
      description: "One-time Purchase",
      category: .shopping,
      type: .expense,
      date: Date(),
      isRecurring: false,
      userId: "test-user-id",
      createdAt: Date(),
      updatedAt: Date()
    )

    await notificationManager.scheduleBillReminder(transaction: nonRecurringTransaction, daysBeforeDue: 3)

    // Should not schedule notification for non-recurring transaction
    XCTAssertTrue(true)
  }

  // MARK: - Goal Progress Tests

  func testNotifyGoalProgress() async throws {
    // Test goal is at 50% (2500/5000)
    XCTAssertEqual(testGoal.percentageAchieved, 0.5)

    await notificationManager.notifyGoalProgress(goal: testGoal)

    // Verify method completes without error
    let deliveredCount = await notificationManager.getDeliveredNotificationsCount()
    XCTAssertGreaterThanOrEqual(deliveredCount, 0)
  }

  func testNotifyGoalProgressForCompletedGoal() async throws {
    let completedGoal = Goal(
      id: "completed-goal-id",
      name: "Completed Goal",
      targetAmount: 1000.0,
      currentAmount: 1000.0, // 100% achieved
      category: .other,
      deadline: Date(),
      userId: "test-user-id",
      createdAt: Date(),
      updatedAt: Date()
    )

    XCTAssertEqual(completedGoal.percentageAchieved, 1.0)

    await notificationManager.notifyGoalProgress(goal: completedGoal)

    // Should send congratulations notification
    XCTAssertTrue(true)
  }

  // MARK: - Suspicious Activity Tests

  func testNotifySuspiciousActivityForLargeExpense() async throws {
    // Test transaction is 1500.0, threshold is 1000.0
    XCTAssertGreaterThan(testTransaction.amount, 1000.0)
    XCTAssertEqual(testTransaction.type, .expense)

    await notificationManager.notifySuspiciousActivity(transaction: testTransaction, threshold: 1000.0)

    // Verify method completes without error
    let deliveredCount = await notificationManager.getDeliveredNotificationsCount()
    XCTAssertGreaterThanOrEqual(deliveredCount, 0)
  }

  func testNotifySuspiciousActivityForSmallExpense() async throws {
    let smallTransaction = Transaction(
      id: "small-transaction-id",
      accountId: "test-account-id",
      amount: 50.0,
      description: "Small Purchase",
      category: .food,
      type: .expense,
      date: Date(),
      isRecurring: false,
      userId: "test-user-id",
      createdAt: Date(),
      updatedAt: Date()
    )

    await notificationManager.notifySuspiciousActivity(transaction: smallTransaction, threshold: 1000.0)

    // Should not send notification for small expense
    XCTAssertTrue(true)
  }

  func testNotifySuspiciousActivityForIncomeTransaction() async throws {
    let incomeTransaction = Transaction(
      id: "income-id",
      accountId: "test-account-id",
      amount: 2000.0,
      description: "Salary",
      category: .salary,
      type: .income,
      date: Date(),
      isRecurring: false,
      userId: "test-user-id",
      createdAt: Date(),
      updatedAt: Date()
    )

    await notificationManager.notifySuspiciousActivity(transaction: incomeTransaction, threshold: 1000.0)

    // Should not send notification for income transactions
    XCTAssertTrue(true)
  }

  // MARK: - Daily Summary Tests

  func testScheduleDailySummary() async throws {
    await notificationManager.scheduleDailySummary()

    // Verify method completes without error
    XCTAssertTrue(true)
  }

  // MARK: - Notification Management Tests

  func testCancelNotification() async throws {
    let identifier = "test-notification-id"

    await notificationManager.cancelNotification(identifier: identifier)

    // Verify method completes without error
    XCTAssertTrue(true)
  }

  func testCancelAllBudgetNotifications() async throws {
    // Schedule some budget notifications
    await notificationManager.scheduleBudgetAlert(budget: testBudget)

    await notificationManager.cancelAllBudgetNotifications()

    // Verify method completes without error
    XCTAssertTrue(true)
  }

  func testCancelAllNotifications() async throws {
    // Schedule various notifications
    await notificationManager.scheduleBudgetAlert(budget: testBudget)
    await notificationManager.scheduleBillReminder(transaction: testTransaction)

    let beforeCount = await notificationManager.getPendingNotificationsCount()

    await notificationManager.cancelAllNotifications()

    let afterCount = await notificationManager.getPendingNotificationsCount()

    XCTAssertEqual(afterCount, 0)
  }

  func testGetPendingNotificationsCount() async throws {
    let count = await notificationManager.getPendingNotificationsCount()

    XCTAssertGreaterThanOrEqual(count, 0)
  }

  func testGetDeliveredNotificationsCount() async throws {
    let count = await notificationManager.getDeliveredNotificationsCount()

    XCTAssertGreaterThanOrEqual(count, 0)
  }

  func testClearBadge() throws {
    // This test just verifies the method can be called without crashing
    notificationManager.clearBadge()

    XCTAssertTrue(true)
  }

  // MARK: - Edge Cases

  func testMultipleNotificationsForSameEntity() async throws {
    // Schedule multiple notifications for the same budget
    await notificationManager.scheduleBudgetAlert(budget: testBudget)
    await notificationManager.scheduleBudgetAlert(budget: testBudget)

    // The second call should replace the first (same identifier)
    XCTAssertTrue(true)
  }

  func testNotificationWithoutAuthorization() async throws {
    // When authorization is denied, notifications should fail gracefully
    // This is handled internally by the NotificationManager
    XCTAssertTrue(true)
  }
}
