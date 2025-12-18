//
//  LiveActivityManager.swift
//  FinPessoal
//
//  Created by Claude Code on 16/12/25.
//

import Foundation
import ActivityKit
import Combine 
/// Manages Live Activities for the app
@MainActor
final class LiveActivityManager: ObservableObject {

  // MARK: - Singleton

  static let shared = LiveActivityManager()

  // MARK: - Published Properties

  @Published private(set) var activeBillReminders: [Activity<BillReminderAttributes>] = []
  @Published private(set) var activeBudgetAlerts: [Activity<BudgetAlertAttributes>] = []
  @Published private(set) var activeGoalMilestones: [Activity<GoalMilestoneAttributes>] = []
  @Published private(set) var activeCreditCardReminders: [Activity<CreditCardReminderAttributes>] = []

  // MARK: - Init

  private init() {
    // Load existing activities on init
    loadExistingActivities()
  }

  // MARK: - Load Existing Activities

  private func loadExistingActivities() {
    activeBillReminders = Activity<BillReminderAttributes>.activities
    activeBudgetAlerts = Activity<BudgetAlertAttributes>.activities
    activeGoalMilestones = Activity<GoalMilestoneAttributes>.activities
    activeCreditCardReminders = Activity<CreditCardReminderAttributes>.activities
  }

  // MARK: - Bill Reminder Activities

  /// Starts a Live Activity for a bill reminder
  func startBillReminder(bill: Bill) async throws -> Activity<BillReminderAttributes>? {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      print("LiveActivityManager: Live Activities not enabled")
      return nil
    }

    let attributes = BillReminderAttributes(
      billId: bill.id,
      billName: bill.name,
      amount: bill.amount,
      dueDate: bill.nextDueDate,
      categoryIcon: bill.category.icon
    )

    let initialState = BillReminderAttributes.ContentState(
      daysUntilDue: bill.daysUntilDue,
      isPaid: bill.isPaid
    )

    do {
      let activity = try Activity.request(
        attributes: attributes,
        content: .init(state: initialState, staleDate: nil),
        pushType: nil
      )
      activeBillReminders.append(activity)
      print("LiveActivityManager: Started bill reminder for \(bill.name)")
      return activity
    } catch {
      print("LiveActivityManager: Failed to start bill reminder - \(error)")
      throw error
    }
  }

  /// Updates a bill reminder Live Activity
  func updateBillReminder(billId: String, daysUntilDue: Int, isPaid: Bool) async {
    guard let activity = activeBillReminders.first(where: { $0.attributes.billId == billId }) else {
      return
    }

    let updatedState = BillReminderAttributes.ContentState(
      daysUntilDue: daysUntilDue,
      isPaid: isPaid
    )

    await activity.update(.init(state: updatedState, staleDate: nil))
    print("LiveActivityManager: Updated bill reminder for \(activity.attributes.billName)")
  }

  /// Ends a bill reminder Live Activity
  func endBillReminder(billId: String) async {
    guard let activity = activeBillReminders.first(where: { $0.attributes.billId == billId }) else {
      return
    }

    let finalState = BillReminderAttributes.ContentState(
      daysUntilDue: 0,
      isPaid: true
    )

    await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
    activeBillReminders.removeAll { $0.attributes.billId == billId }
    print("LiveActivityManager: Ended bill reminder for \(activity.attributes.billName)")
  }

  // MARK: - Budget Alert Activities

  /// Starts a Live Activity for a budget alert
  func startBudgetAlert(budget: Budget) async throws -> Activity<BudgetAlertAttributes>? {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      return nil
    }

    let attributes = BudgetAlertAttributes(
      budgetId: budget.id,
      budgetName: budget.name,
      budgetLimit: budget.budgetAmount,
      categoryIcon: budget.category.icon
    )

    let initialState = BudgetAlertAttributes.ContentState(
      currentSpent: budget.spent,
      percentageUsed: budget.percentageUsed * 100
    )

    do {
      let activity = try Activity.request(
        attributes: attributes,
        content: .init(state: initialState, staleDate: nil),
        pushType: nil
      )
      activeBudgetAlerts.append(activity)
      print("LiveActivityManager: Started budget alert for \(budget.name)")
      return activity
    } catch {
      print("LiveActivityManager: Failed to start budget alert - \(error)")
      throw error
    }
  }

  /// Updates a budget alert Live Activity
  func updateBudgetAlert(budgetId: String, spent: Double, percentageUsed: Double) async {
    guard let activity = activeBudgetAlerts.first(where: { $0.attributes.budgetId == budgetId }) else {
      return
    }

    let updatedState = BudgetAlertAttributes.ContentState(
      currentSpent: spent,
      percentageUsed: percentageUsed
    )

    await activity.update(.init(state: updatedState, staleDate: nil))
  }

  /// Ends a budget alert Live Activity
  func endBudgetAlert(budgetId: String) async {
    guard let activity = activeBudgetAlerts.first(where: { $0.attributes.budgetId == budgetId }) else {
      return
    }

    await activity.end(nil, dismissalPolicy: .immediate)
    activeBudgetAlerts.removeAll { $0.attributes.budgetId == budgetId }
  }

  // MARK: - Goal Milestone Activities

  /// Starts a Live Activity for a goal milestone
  func startGoalMilestone(goal: Goal) async throws -> Activity<GoalMilestoneAttributes>? {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      return nil
    }

    let attributes = GoalMilestoneAttributes(
      goalId: goal.id,
      goalName: goal.name,
      targetAmount: goal.targetAmount,
      categoryIcon: goal.category.icon
    )

    let initialState = GoalMilestoneAttributes.ContentState(
      currentAmount: goal.currentAmount,
      progressPercentage: goal.progressPercentage
    )

    do {
      let activity = try Activity.request(
        attributes: attributes,
        content: .init(state: initialState, staleDate: nil),
        pushType: nil
      )
      activeGoalMilestones.append(activity)
      print("LiveActivityManager: Started goal milestone for \(goal.name)")
      return activity
    } catch {
      print("LiveActivityManager: Failed to start goal milestone - \(error)")
      throw error
    }
  }

  /// Updates a goal milestone Live Activity
  func updateGoalMilestone(goalId: String, currentAmount: Double, progressPercentage: Double) async {
    guard let activity = activeGoalMilestones.first(where: { $0.attributes.goalId == goalId }) else {
      return
    }

    let updatedState = GoalMilestoneAttributes.ContentState(
      currentAmount: currentAmount,
      progressPercentage: progressPercentage
    )

    await activity.update(.init(state: updatedState, staleDate: nil))
  }

  /// Ends a goal milestone Live Activity
  func endGoalMilestone(goalId: String) async {
    guard let activity = activeGoalMilestones.first(where: { $0.attributes.goalId == goalId }) else {
      return
    }

    await activity.end(nil, dismissalPolicy: .immediate)
    activeGoalMilestones.removeAll { $0.attributes.goalId == goalId }
  }

  // MARK: - Credit Card Reminder Activities

  /// Starts a Live Activity for a credit card reminder
  func startCreditCardReminder(card: CreditCard) async throws -> Activity<CreditCardReminderAttributes>? {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      return nil
    }

    let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: card.nextDueDate).day ?? 0

    let attributes = CreditCardReminderAttributes(
      cardId: card.id,
      cardName: card.name,
      dueDate: card.nextDueDate,
      minimumPayment: card.minimumPayment,
      brand: card.brand.rawValue
    )

    let initialState = CreditCardReminderAttributes.ContentState(
      daysUntilDue: daysUntilDue,
      currentBalance: card.currentBalance
    )

    do {
      let activity = try Activity.request(
        attributes: attributes,
        content: .init(state: initialState, staleDate: nil),
        pushType: nil
      )
      activeCreditCardReminders.append(activity)
      print("LiveActivityManager: Started credit card reminder for \(card.name)")
      return activity
    } catch {
      print("LiveActivityManager: Failed to start credit card reminder - \(error)")
      throw error
    }
  }

  /// Updates a credit card reminder Live Activity
  func updateCreditCardReminder(cardId: String, daysUntilDue: Int, currentBalance: Double) async {
    guard let activity = activeCreditCardReminders.first(where: { $0.attributes.cardId == cardId }) else {
      return
    }

    let updatedState = CreditCardReminderAttributes.ContentState(
      daysUntilDue: daysUntilDue,
      currentBalance: currentBalance
    )

    await activity.update(.init(state: updatedState, staleDate: nil))
  }

  /// Ends a credit card reminder Live Activity
  func endCreditCardReminder(cardId: String) async {
    guard let activity = activeCreditCardReminders.first(where: { $0.attributes.cardId == cardId }) else {
      return
    }

    await activity.end(nil, dismissalPolicy: .immediate)
    activeCreditCardReminders.removeAll { $0.attributes.cardId == cardId }
  }

  // MARK: - End All Activities

  /// Ends all active Live Activities
  func endAllActivities() async {
    for activity in activeBillReminders {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
    activeBillReminders.removeAll()

    for activity in activeBudgetAlerts {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
    activeBudgetAlerts.removeAll()

    for activity in activeGoalMilestones {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
    activeGoalMilestones.removeAll()

    for activity in activeCreditCardReminders {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
    activeCreditCardReminders.removeAll()

    print("LiveActivityManager: Ended all activities")
  }

  // MARK: - Utility

  /// Checks if Live Activities are available
  var areActivitiesEnabled: Bool {
    ActivityAuthorizationInfo().areActivitiesEnabled
  }

  /// Total count of active activities
  var activeCount: Int {
    activeBillReminders.count +
    activeBudgetAlerts.count +
    activeGoalMilestones.count +
    activeCreditCardReminders.count
  }
}
