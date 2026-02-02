//
//  AppDelegate.swift
//  FinPessoal
//
//  Created by Claude Code on 26/10/25.
//

import UIKit
import UserNotifications
import FirebaseCrashlytics

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {

    // Initialize Crashlytics
    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)

    // Set notification delegate
    UNUserNotificationCenter.current().delegate = self

    print("✅ Firebase Crashlytics initialized")

    return true
  }

  // MARK: - UNUserNotificationCenterDelegate

  /// Handle notification when app is in foreground
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Show notification even when app is in foreground
    completionHandler([.banner, .sound, .badge])

    print("📬 Received notification while in foreground: \(notification.request.identifier)")
  }

  /// Handle notification tap
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {

    let userInfo = response.notification.request.content.userInfo
    let actionIdentifier = response.actionIdentifier

    print("👆 Notification tapped: \(response.notification.request.identifier)")
    print("Action: \(actionIdentifier)")

    // Handle different notification types
    if let notificationType = userInfo["type"] as? String {
      handleNotificationAction(type: notificationType, userInfo: userInfo, actionIdentifier: actionIdentifier)
    }

    completionHandler()
  }

  // MARK: - Private Methods

  private func handleNotificationAction(type: String, userInfo: [AnyHashable: Any], actionIdentifier: String) {
    switch type {
    case "budget_alert":
      handleBudgetAlert(userInfo: userInfo, actionIdentifier: actionIdentifier)

    case "bill_reminder":
      handleBillReminder(userInfo: userInfo, actionIdentifier: actionIdentifier)

    case "goal_progress":
      handleGoalProgress(userInfo: userInfo, actionIdentifier: actionIdentifier)

    case "suspicious_activity":
      handleSuspiciousActivity(userInfo: userInfo, actionIdentifier: actionIdentifier)

    default:
      print("⚠️ Unknown notification type: \(type)")
    }
  }

  private func handleBudgetAlert(userInfo: [AnyHashable: Any], actionIdentifier: String) {
    guard let budgetId = userInfo["budgetId"] as? String else { return }

    switch actionIdentifier {
    case "VIEW_BUDGET":
      print("Navigate to budget details: \(budgetId)")
      // Post notification to navigate to budget
      NotificationCenter.default.post(
        name: NSNotification.Name("NavigateToBudget"),
        object: nil,
        userInfo: ["budgetId": budgetId]
      )

    case "DISMISS":
      print("Budget alert dismissed")

    default:
      print("Default action for budget alert")
    }
  }

  private func handleBillReminder(userInfo: [AnyHashable: Any], actionIdentifier: String) {
    guard let transactionId = userInfo["transactionId"] as? String else { return }

    switch actionIdentifier {
    case "VIEW_BILL":
      print("Navigate to bill: \(transactionId)")
      NotificationCenter.default.post(
        name: NSNotification.Name("NavigateToBill"),
        object: nil,
        userInfo: ["transactionId": transactionId]
      )

    case "DISMISS":
      print("Bill reminder dismissed")

    default:
      print("Default action for bill reminder")
    }
  }

  private func handleGoalProgress(userInfo: [AnyHashable: Any], actionIdentifier: String) {
    guard let goalId = userInfo["goalId"] as? String else { return }

    switch actionIdentifier {
    case "VIEW_GOAL":
      print("Navigate to goal: \(goalId)")
      NotificationCenter.default.post(
        name: NSNotification.Name("NavigateToGoal"),
        object: nil,
        userInfo: ["goalId": goalId]
      )

    case "DISMISS":
      print("Goal progress dismissed")

    default:
      print("Default action for goal progress")
    }
  }

  private func handleSuspiciousActivity(userInfo: [AnyHashable: Any], actionIdentifier: String) {
    guard let transactionId = userInfo["transactionId"] as? String else { return }

    switch actionIdentifier {
    case "REVIEW_TRANSACTION":
      print("Navigate to transaction: \(transactionId)")
      NotificationCenter.default.post(
        name: NSNotification.Name("NavigateToTransaction"),
        object: nil,
        userInfo: ["transactionId": transactionId]
      )

    case "DISMISS":
      print("Suspicious activity alert dismissed")

    default:
      print("Default action for suspicious activity")
    }
  }
}
