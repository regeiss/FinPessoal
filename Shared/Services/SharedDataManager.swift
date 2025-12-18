//
//  SharedDataManager.swift
//  FinPessoal
//
//  Created by Claude Code on 16/12/25.
//

import Foundation
import WidgetKit

/// Manages data sharing between main app and widgets via App Groups
final class SharedDataManager {

  // MARK: - Singleton

  static let shared = SharedDataManager()

  // MARK: - Constants

  private let appGroupIdentifier = "group.com.finpessoal.shared"
  private let widgetDataKey = "widgetData"

  // MARK: - Properties

  private var sharedDefaults: UserDefaults? {
    UserDefaults(suiteName: appGroupIdentifier)
  }

  // MARK: - Init

  private init() {}

  // MARK: - Save Data

  /// Saves widget data to shared storage and reloads all widget timelines
  /// - Parameter data: The widget data to save
  func saveWidgetData(_ data: WidgetData) {
    guard let defaults = sharedDefaults else {
      print("SharedDataManager: Failed to access App Group")
      return
    }

    do {
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601
      let encoded = try encoder.encode(data)
      defaults.set(encoded, forKey: widgetDataKey)
      defaults.synchronize()

      // Reload all widget timelines to reflect new data
      WidgetCenter.shared.reloadAllTimelines()
    } catch {
      print("SharedDataManager: Failed to encode data - \(error)")
    }
  }

  // MARK: - Load Data

  /// Loads widget data from shared storage
  /// - Returns: The stored widget data or empty data if none exists
  func loadWidgetData() -> WidgetData {
    guard let defaults = sharedDefaults,
          let data = defaults.data(forKey: widgetDataKey) else {
      return .empty
    }

    do {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      return try decoder.decode(WidgetData.self, from: data)
    } catch {
      print("SharedDataManager: Failed to decode data - \(error)")
      return .empty
    }
  }

  // MARK: - Clear Data

  /// Clears all widget data from shared storage
  func clearData() {
    sharedDefaults?.removeObject(forKey: widgetDataKey)
    sharedDefaults?.synchronize()
    WidgetCenter.shared.reloadAllTimelines()
  }

  // MARK: - Utility

  /// Returns the last update time of widget data
  var lastUpdateTime: Date? {
    let data = loadWidgetData()
    return data.lastUpdated
  }

  /// Checks if cached data is stale (older than specified interval)
  /// - Parameter interval: Time interval in seconds (default: 30 minutes)
  /// - Returns: True if data is stale or doesn't exist
  func isDataStale(olderThan interval: TimeInterval = 1800) -> Bool {
    guard let lastUpdate = lastUpdateTime else { return true }
    return Date().timeIntervalSince(lastUpdate) > interval
  }

  // MARK: - Reload Specific Widgets

  /// Reloads timeline for a specific widget kind
  /// - Parameter kind: The widget kind identifier
  func reloadWidget(kind: String) {
    WidgetCenter.shared.reloadTimelines(ofKind: kind)
  }

  /// Reloads all balance-related widgets
  func reloadBalanceWidgets() {
    reloadWidget(kind: "BalanceWidget")
    reloadWidget(kind: "BalanceLockWidget")
  }

  /// Reloads all budget-related widgets
  func reloadBudgetWidgets() {
    reloadWidget(kind: "BudgetWidget")
    reloadWidget(kind: "BudgetLockWidget")
  }

  /// Reloads all bill-related widgets
  func reloadBillsWidgets() {
    reloadWidget(kind: "BillsWidget")
    reloadWidget(kind: "BillsLockWidget")
  }

  /// Reloads all goal-related widgets
  func reloadGoalsWidgets() {
    reloadWidget(kind: "GoalsWidget")
    reloadWidget(kind: "GoalsLockWidget")
  }

  /// Reloads transaction widgets
  func reloadTransactionWidgets() {
    reloadWidget(kind: "TransactionsWidget")
  }

  /// Reloads credit card widgets
  func reloadCreditCardWidgets() {
    reloadWidget(kind: "CreditCardWidget")
  }
}
