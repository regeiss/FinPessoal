//
//  CrashlyticsManager.swift
//  FinPessoal
//
//  Created by Claude Code on 24/12/25.
//

import Foundation
import FirebaseCrashlytics

/// Manager for Firebase Crashlytics integration
/// Provides centralized crash reporting and error logging
class CrashlyticsManager {
  static let shared = CrashlyticsManager()

  private let crashlytics = Crashlytics.crashlytics()

  private init() {}

  // MARK: - User Identification

  /// Set user identifier for crash reports
  /// - Parameter userId: The user's unique identifier
  func setUserID(_ userId: String) {
    crashlytics.setUserID(userId)
    print("📊 Crashlytics: User ID set - \(userId)")
  }

  /// Clear user identifier (e.g., on logout)
  func clearUserID() {
    crashlytics.setUserID("")
    print("📊 Crashlytics: User ID cleared")
  }

  // MARK: - Custom Attributes

  /// Set custom key-value pair for crash context
  /// - Parameters:
  ///   - key: The attribute key
  ///   - value: The attribute value
  func setAttribute(key: String, value: String) {
    crashlytics.setCustomValue(value, forKey: key)
  }

  /// Set user's email for crash reports
  /// - Parameter email: User's email address
  func setUserEmail(_ email: String) {
    setAttribute(key: "email", value: email)
  }

  /// Set user's name for crash reports
  /// - Parameter name: User's name
  func setUserName(_ name: String) {
    setAttribute(key: "name", value: name)
  }

  /// Set app environment (development, staging, production)
  /// - Parameter environment: The current environment
  func setEnvironment(_ environment: String) {
    setAttribute(key: "environment", value: environment)
  }

  // MARK: - Error Logging

  /// Log a non-fatal error to Crashlytics
  /// - Parameters:
  ///   - error: The error to log
  ///   - context: Additional context about where/why the error occurred
  func logError(_ error: Error, context: String? = nil) {
    if let context = context {
      crashlytics.log("Error context: \(context)")
    }
    crashlytics.record(error: error)
    print("❌ Crashlytics: Logged error - \(error.localizedDescription)")
  }

  /// Log a custom message to Crashlytics
  /// - Parameter message: The message to log
  func log(_ message: String) {
    crashlytics.log(message)
  }

  /// Log a Firebase-specific error with additional details
  /// - Parameters:
  ///   - error: Firebase error
  ///   - operation: The operation that failed (e.g., "fetch transactions", "save budget")
  func logFirebaseError(_ error: FirebaseError, operation: String) {
    crashlytics.log("Firebase operation failed: \(operation)")
    crashlytics.log("Error type: \(error)")
    crashlytics.record(error: error)
  }

  /// Log an authentication error
  /// - Parameters:
  ///   - error: Authentication error
  ///   - authType: Type of authentication (e.g., "Google", "Apple", "Email")
  func logAuthError(_ error: AuthError, authType: String) {
    crashlytics.log("Authentication failed: \(authType)")
    crashlytics.log("Error type: \(error)")
    crashlytics.record(error: error)
  }

  // MARK: - Custom Events

  /// Log a custom event for analytics context
  /// - Parameters:
  ///   - event: Event name
  ///   - parameters: Optional parameters dictionary
  func logEvent(_ event: String, parameters: [String: Any]? = nil) {
    crashlytics.log("Event: \(event)")
    if let parameters = parameters {
      crashlytics.log("Parameters: \(parameters)")
    }
  }

  // MARK: - Force Crash (Testing Only)

  /// Force a crash for testing (USE ONLY IN DEBUG/TEST BUILDS)
  /// This helps verify Crashlytics is properly configured
  func forceCrashForTesting() {
    #if DEBUG
    fatalError("🧪 Crashlytics Test Crash - This is intentional for testing")
    #else
    print("⚠️ Force crash is disabled in production builds")
    #endif
  }

  // MARK: - Breadcrumbs

  /// Log a breadcrumb for crash context
  /// Useful for tracking user flow before a crash
  /// - Parameters:
  ///   - screen: Screen name
  ///   - action: User action
  func logBreadcrumb(screen: String, action: String) {
    crashlytics.log("[\(screen)] \(action)")
  }

  /// Log screen view for navigation tracking
  /// - Parameter screenName: Name of the screen
  func logScreenView(_ screenName: String) {
    crashlytics.log("Screen: \(screenName)")
  }
}

// MARK: - Convenience Extensions

extension CrashlyticsManager {
  /// Log transaction-related error
  func logTransactionError(_ error: Error, transactionId: String) {
    crashlytics.log("Transaction error - ID: \(transactionId)")
    logError(error)
  }

  /// Log budget-related error
  func logBudgetError(_ error: Error, budgetId: String) {
    crashlytics.log("Budget error - ID: \(budgetId)")
    logError(error)
  }

  /// Log goal-related error
  func logGoalError(_ error: Error, goalId: String) {
    crashlytics.log("Goal error - ID: \(goalId)")
    logError(error)
  }

  /// Log account-related error
  func logAccountError(_ error: Error, accountId: String) {
    crashlytics.log("Account error - ID: \(accountId)")
    logError(error)
  }
}
