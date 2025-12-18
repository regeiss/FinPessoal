//
//  DeepLinkHandler.swift
//  FinPessoal
//
//  Created by Claude Code on 16/12/25.
//

import Foundation
import SwiftUI
import Combine

/// Handles deep links from widgets and other sources
@MainActor
final class DeepLinkHandler: ObservableObject {

  // MARK: - Singleton

  static let shared = DeepLinkHandler()

  // MARK: - Published Properties

  @Published var pendingDestination: DeepLinkDestination?

  // MARK: - URL Scheme

  static let urlScheme = "finpessoal"

  // MARK: - Init

  private init() {}

  // MARK: - Handle URL

  /// Handles an incoming deep link URL
  /// - Parameter url: The deep link URL to handle
  /// - Returns: True if the URL was handled successfully
  @discardableResult
  func handleURL(_ url: URL) -> Bool {
    guard url.scheme == Self.urlScheme else {
      print("DeepLinkHandler: Unknown URL scheme - \(url.scheme ?? "nil")")
      return false
    }

    guard let destination = parseURL(url) else {
      print("DeepLinkHandler: Could not parse URL - \(url)")
      return false
    }

    pendingDestination = destination
    print("DeepLinkHandler: Navigating to \(destination)")
    return true
  }

  // MARK: - Parse URL

  private func parseURL(_ url: URL) -> DeepLinkDestination? {
    let host = url.host ?? ""
    let pathComponents = url.pathComponents.filter { $0 != "/" }
    let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []

    switch host {
    // Dashboard
    case "dashboard":
      return .dashboard

    // Accounts
    case "accounts":
      if let accountId = pathComponents.first {
        return .accountDetail(id: accountId)
      }
      return .accounts

    // Transactions
    case "transactions":
      if let transactionId = pathComponents.first {
        return .transactionDetail(id: transactionId)
      }
      return .transactions

    // Add transaction
    case "add-transaction":
      let type = queryItems.first(where: { $0.name == "type" })?.value
      return .addTransaction(type: type)

    // Budgets
    case "budgets":
      if let budgetId = pathComponents.first {
        return .budgetDetail(id: budgetId)
      }
      return .budgets

    // Bills
    case "bills":
      if let billId = pathComponents.first {
        return .billDetail(id: billId)
      }
      return .bills

    // Goals
    case "goals":
      if let goalId = pathComponents.first {
        return .goalDetail(id: goalId)
      }
      return .goals

    // Credit Cards
    case "creditcards":
      if let cardId = pathComponents.first {
        return .creditCardDetail(id: cardId)
      }
      return .creditCards

    // Reports
    case "reports":
      return .reports

    // Settings
    case "settings":
      return .settings

    default:
      return nil
    }
  }

  // MARK: - Create URLs

  /// Creates a deep link URL for a destination
  static func url(for destination: DeepLinkDestination) -> URL? {
    var components = URLComponents()
    components.scheme = urlScheme

    switch destination {
    case .dashboard:
      components.host = "dashboard"

    case .accounts:
      components.host = "accounts"

    case .accountDetail(let id):
      components.host = "accounts"
      components.path = "/\(id)"

    case .transactions:
      components.host = "transactions"

    case .transactionDetail(let id):
      components.host = "transactions"
      components.path = "/\(id)"

    case .addTransaction(let type):
      components.host = "add-transaction"
      if let type = type {
        components.queryItems = [URLQueryItem(name: "type", value: type)]
      }

    case .budgets:
      components.host = "budgets"

    case .budgetDetail(let id):
      components.host = "budgets"
      components.path = "/\(id)"

    case .bills:
      components.host = "bills"

    case .billDetail(let id):
      components.host = "bills"
      components.path = "/\(id)"

    case .goals:
      components.host = "goals"

    case .goalDetail(let id):
      components.host = "goals"
      components.path = "/\(id)"

    case .creditCards:
      components.host = "creditcards"

    case .creditCardDetail(let id):
      components.host = "creditcards"
      components.path = "/\(id)"

    case .reports:
      components.host = "reports"

    case .settings:
      components.host = "settings"
    }

    return components.url
  }

  // MARK: - Clear Pending

  func clearPendingDestination() {
    pendingDestination = nil
  }
}

// MARK: - Deep Link Destination

enum DeepLinkDestination: Equatable, Hashable {
  case dashboard
  case accounts
  case accountDetail(id: String)
  case transactions
  case transactionDetail(id: String)
  case addTransaction(type: String?)
  case budgets
  case budgetDetail(id: String)
  case bills
  case billDetail(id: String)
  case goals
  case goalDetail(id: String)
  case creditCards
  case creditCardDetail(id: String)
  case reports
  case settings
}

// MARK: - Widget URL Extensions

extension URL {
  /// Creates a widget deep link URL
  static func widgetURL(host: String, path: String? = nil) -> URL? {
    var components = URLComponents()
    components.scheme = DeepLinkHandler.urlScheme
    components.host = host
    if let path = path {
      components.path = "/\(path)"
    }
    return components.url
  }

  // Common widget URLs
  static var dashboardURL: URL? { widgetURL(host: "dashboard") }
  static var accountsURL: URL? { widgetURL(host: "accounts") }
  static var transactionsURL: URL? { widgetURL(host: "transactions") }
  static var budgetsURL: URL? { widgetURL(host: "budgets") }
  static var billsURL: URL? { widgetURL(host: "bills") }
  static var goalsURL: URL? { widgetURL(host: "goals") }
  static var creditCardsURL: URL? { widgetURL(host: "creditcards") }
  static var addExpenseURL: URL? {
    var components = URLComponents()
    components.scheme = DeepLinkHandler.urlScheme
    components.host = "add-transaction"
    components.queryItems = [URLQueryItem(name: "type", value: "expense")]
    return components.url
  }
}
