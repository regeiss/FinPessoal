//
//  NotificationManager.swift
//  FinPessoal
//
//  Created by Claude Code on 26/10/25.
//

import Foundation
import UserNotifications
import Combine

/// Manages local notifications for budget alerts, bill reminders, goal progress, and suspicious activity
@MainActor
class NotificationManager: ObservableObject {

  // MARK: - Singleton

  static let shared = NotificationManager()

  // MARK: - Published Properties

  @Published var isAuthorized: Bool = false
  @Published var notificationSettings: UNNotificationSettings?

  // MARK: - Private Properties
  private let center = UNUserNotificationCenter.current()

  // MARK: - Notification Categories

  enum NotificationCategory: String {
    case budgetAlert = "BUDGET_ALERT"
    case billReminder = "BILL_REMINDER"
    case goalProgress = "GOAL_PROGRESS"
    case suspiciousActivity = "SUSPICIOUS_ACTIVITY"
  }

  // MARK: - Initialization

  private init() {
    Task {
      await checkAuthorizationStatus()
      registerNotificationCategories()
    }
  }

  // MARK: - Authorization

  /// Request notification authorization from the user
  func requestAuthorization() async throws -> Bool {
    let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound, .criticalAlert])
    await checkAuthorizationStatus()
    return granted
  }

  /// Check current authorization status
  func checkAuthorizationStatus() async {
    let settings = await center.notificationSettings()
    notificationSettings = settings
    isAuthorized = settings.authorizationStatus == .authorized
  }

  // MARK: - Category Registration

  /// Register notification categories with actions
  private func registerNotificationCategories() {
    let viewBudgetAction = UNNotificationAction(
      identifier: "VIEW_BUDGET",
      title: String(localized: "notification.action.view"),
      options: .foreground
    )

    let viewBillAction = UNNotificationAction(
      identifier: "VIEW_BILL",
      title: String(localized: "notification.action.view"),
      options: .foreground
    )

    let viewGoalAction = UNNotificationAction(
      identifier: "VIEW_GOAL",
      title: String(localized: "notification.action.view"),
      options: .foreground
    )

    let reviewTransactionAction = UNNotificationAction(
      identifier: "REVIEW_TRANSACTION",
      title: String(localized: "notification.action.review"),
      options: .foreground
    )

    let dismissAction = UNNotificationAction(
      identifier: "DISMISS",
      title: String(localized: "notification.action.dismiss"),
      options: .destructive
    )

    let budgetCategory = UNNotificationCategory(
      identifier: NotificationCategory.budgetAlert.rawValue,
      actions: [viewBudgetAction, dismissAction],
      intentIdentifiers: [],
      options: []
    )

    let billCategory = UNNotificationCategory(
      identifier: NotificationCategory.billReminder.rawValue,
      actions: [viewBillAction, dismissAction],
      intentIdentifiers: [],
      options: []
    )

    let goalCategory = UNNotificationCategory(
      identifier: NotificationCategory.goalProgress.rawValue,
      actions: [viewGoalAction, dismissAction],
      intentIdentifiers: [],
      options: []
    )

    let suspiciousCategory = UNNotificationCategory(
      identifier: NotificationCategory.suspiciousActivity.rawValue,
      actions: [reviewTransactionAction, dismissAction],
      intentIdentifiers: [],
      options: []
    )

    center.setNotificationCategories([
      budgetCategory,
      billCategory,
      goalCategory,
      suspiciousCategory
    ])
  }

  // MARK: - Budget Alerts

  /// Schedule a budget alert when spending exceeds the threshold
  func scheduleBudgetAlert(budget: Budget) async {
    guard isAuthorized else { return }
    guard budget.percentageUsed >= budget.alertThreshold else { return }

    let content = UNMutableNotificationContent()
    content.title = String(localized: "notification.budget.alert.title")
    content.body = String(
      localized: "notification.budget.alert.body",
      defaultValue: "You have used \(Int(budget.percentageUsed * 100))% of your '\(budget.name)' budget"
    )
    content.sound = .default
    content.categoryIdentifier = NotificationCategory.budgetAlert.rawValue
    content.userInfo = ["budgetId": budget.id, "type": "budget_alert"]
    content.badge = 1

    // Add threshold-based subtitle
    if budget.isOverBudget {
      content.subtitle = String(localized: "notification.budget.over.subtitle")
      content.sound = .defaultCritical
      content.interruptionLevel = .timeSensitive
    } else if budget.percentageUsed >= 0.9 {
      content.subtitle = String(localized: "notification.budget.warning.subtitle")
      content.interruptionLevel = .timeSensitive
    }

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(
      identifier: "budget-\(budget.id)",
      content: content,
      trigger: trigger
    )

    do {
      try await center.add(request)
      print("✅ Budget alert scheduled for: \(budget.name)")
    } catch {
      print("❌ Error scheduling budget alert: \(error.localizedDescription)")
    }
  }

  /// Update budget alert when budget is updated
  func updateBudgetAlert(budget: Budget) async {
    await cancelNotification(identifier: "budget-\(budget.id)")
    await scheduleBudgetAlert(budget: budget)
  }

  // MARK: - Bill Reminders

  /// Schedule a bill reminder
  func scheduleBillReminder(
    billId: String,
    billName: String,
    amount: Double,
    dueDate: Date,
    daysBeforeDue: Int = 3
  ) async {
    guard isAuthorized else { return }

    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    let formattedAmount = formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"

    let content = UNMutableNotificationContent()
    content.title = String(localized: "notification.bill.reminder.title")
    content.body = String(
      localized: "notification.bill.reminder.body",
      defaultValue: "Bill '\(billName)' (\(formattedAmount)) is due in \(daysBeforeDue) days"
    )
    content.sound = .default
    content.categoryIdentifier = NotificationCategory.billReminder.rawValue
    content.userInfo = ["billId": billId, "type": "bill_reminder"]
    content.badge = 1

    // Calculate reminder date
    let calendar = Calendar.current
    guard let reminderDate = calendar.date(byAdding: .day, value: -daysBeforeDue, to: dueDate) else {
      return
    }

    var dateComponents = calendar.dateComponents([.year, .month, .day], from: reminderDate)
    dateComponents.hour = 9 // 9 AM
    dateComponents.minute = 0

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    let request = UNNotificationRequest(
      identifier: "bill-\(billId)",
      content: content,
      trigger: trigger
    )

    do {
      try await center.add(request)
      print("✅ Bill reminder scheduled for: \(billName)")
    } catch {
      print("❌ Error scheduling bill reminder: \(error.localizedDescription)")
    }
  }

  /// Update bill reminder when bill is modified
  func updateBillReminder(
    billId: String,
    billName: String,
    amount: Double,
    dueDate: Date,
    daysBeforeDue: Int
  ) async {
    await cancelNotification(identifier: "bill-\(billId)")
    await scheduleBillReminder(
      billId: billId,
      billName: billName,
      amount: amount,
      dueDate: dueDate,
      daysBeforeDue: daysBeforeDue
    )
  }

  /// Schedule a recurring bill reminder (legacy - for transactions)
  func scheduleBillReminder(transaction: Transaction, daysBeforeDue: Int = 3) async {
    guard isAuthorized else { return }
    guard transaction.isRecurring else { return }

    let content = UNMutableNotificationContent()
    content.title = String(localized: "notification.bill.reminder.title")
    content.body = String(
      localized: "notification.bill.reminder.body",
      defaultValue: "Bill '\(transaction.description)' is due in \(daysBeforeDue) days"
    )
    content.sound = .default
    content.categoryIdentifier = NotificationCategory.billReminder.rawValue
    content.userInfo = ["transactionId": transaction.id, "type": "bill_reminder"]
    content.badge = 1

    // Calculate reminder date
    var dateComponents = Calendar.current.dateComponents(
      [.year, .month, .day, .hour],
      from: transaction.date
    )

    // Set reminder for 9 AM, X days before due
    if let day = dateComponents.day {
      dateComponents.day = day - daysBeforeDue
    }
    dateComponents.hour = 9
    dateComponents.minute = 0

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(
      identifier: "bill-\(transaction.id)",
      content: content,
      trigger: trigger
    )

    do {
      try await center.add(request)
      print("✅ Bill reminder scheduled for: \(transaction.description)")
    } catch {
      print("❌ Error scheduling bill reminder: \(error.localizedDescription)")
    }
  }

  // MARK: - Goal Progress

  /// Notify user of goal progress milestones
  func notifyGoalProgress(goal: Goal) async {
    guard isAuthorized else { return }

    let milestones: [Double] = [0.25, 0.50, 0.75, 0.90, 1.0]

    // Find the highest milestone reached
    guard let currentMilestone = milestones.last(where: { goal.progressPercentage / 100.0 >= $0 }) else {
      return
    }

    // Check if we've already notified for this milestone
    let identifier = "goal-\(goal.id)-\(Int(currentMilestone * 100))"
    let pendingRequests = await center.pendingNotificationRequests()
    let deliveredNotifications = await center.deliveredNotifications()

    let alreadyNotified = pendingRequests.contains { $0.identifier == identifier } ||
    deliveredNotifications.contains { $0.request.identifier == identifier }

    guard !alreadyNotified else { return }

    let content = UNMutableNotificationContent()
    content.title = String(localized: "notification.goal.progress.title")

    if currentMilestone >= 1.0 {
      content.body = String(
        localized: "notification.goal.complete.body",
        defaultValue: "Congratulations! You've achieved your goal '\(goal.name)'! 🎉"
      )
      content.sound = .default
      content.interruptionLevel = .timeSensitive
    } else {
      content.body = String(
        localized: "notification.goal.progress.body",
        defaultValue: "You're \(Int(currentMilestone * 100))% of the way to '\(goal.name)'! Keep going! 💪"
      )
      content.sound = .default
    }

    content.categoryIdentifier = NotificationCategory.goalProgress.rawValue
    content.userInfo = ["goalId": goal.id, "milestone": currentMilestone, "type": "goal_progress"]
    content.badge = 1

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(
      identifier: identifier,
      content: content,
      trigger: trigger
    )

    do {
      try await center.add(request)
      print("✅ Goal progress notification sent: \(goal.name) - \(Int(currentMilestone * 100))%")
    } catch {
      print("❌ Error sending goal notification: \(error.localizedDescription)")
    }
  }

  // MARK: - Suspicious Activity

  /// Notify user of suspicious activity (large transactions)
  func notifySuspiciousActivity(transaction: Transaction, threshold: Double = 1000.0) async {
    guard isAuthorized else { return }
    guard transaction.type == .expense && transaction.amount > threshold else { return }

    let content = UNMutableNotificationContent()
    content.title = String(localized: "notification.suspicious.title")
    content.body = String(
      localized: "notification.suspicious.body",
      defaultValue: "Large expense detected: \(transaction.formattedAmount) for '\(transaction.description)'"
    )
    content.sound = .defaultCritical
    content.categoryIdentifier = NotificationCategory.suspiciousActivity.rawValue
    content.userInfo = ["transactionId": transaction.id, "type": "suspicious_activity"]
    content.badge = 1
    content.interruptionLevel = .timeSensitive

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(
      identifier: "suspicious-\(transaction.id)",
      content: content,
      trigger: trigger
    )

    do {
      try await center.add(request)
      print("✅ Suspicious activity alert sent for transaction: \(transaction.id)")
    } catch {
      print("❌ Error sending suspicious activity alert: \(error.localizedDescription)")
    }
  }

  // MARK: - Daily Summary

  /// Schedule daily financial summary notification
  func scheduleDailySummary() async {
    guard isAuthorized else { return }

    let content = UNMutableNotificationContent()
    content.title = String(localized: "notification.daily.summary.title")
    content.body = String(localized: "notification.daily.summary.body")
    content.sound = .default
    content.badge = 1

    var dateComponents = DateComponents()
    dateComponents.hour = 20 // 8 PM
    dateComponents.minute = 0

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(
      identifier: "daily-summary",
      content: content,
      trigger: trigger
    )

    do {
      try await center.add(request)
      print("✅ Daily summary notification scheduled")
    } catch {
      print("❌ Error scheduling daily summary: \(error.localizedDescription)")
    }
  }

  // MARK: - Notification Management

  /// Cancel a specific notification
  func cancelNotification(identifier: String) async {
    center.removePendingNotificationRequests(withIdentifiers: [identifier])
    print("🗑️ Cancelled notification: \(identifier)")
  }

  /// Cancel all budget notifications
  func cancelAllBudgetNotifications() async {
    let pending = await center.pendingNotificationRequests()
    let budgetIds = pending
      .filter { $0.identifier.hasPrefix("budget-") }
      .map { $0.identifier }

    center.removePendingNotificationRequests(withIdentifiers: budgetIds)
    print("🗑️ Cancelled all budget notifications")
  }

  /// Cancel all notifications
  func cancelAllNotifications() async {
    center.removeAllPendingNotificationRequests()
    center.removeAllDeliveredNotifications()
    print("🗑️ Cancelled all notifications")
  }

  /// Get pending notifications count
  func getPendingNotificationsCount() async -> Int {
    let pending = await center.pendingNotificationRequests()
    return pending.count
  }

  /// Get delivered notifications count
  func getDeliveredNotificationsCount() async -> Int {
    let delivered = await center.deliveredNotifications()
    return delivered.count
  }

  /// Clear badge count
  func clearBadge() {
    UNUserNotificationCenter.current().setBadgeCount(0)
  }
}
