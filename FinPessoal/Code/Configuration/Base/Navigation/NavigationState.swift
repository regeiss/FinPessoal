//
//  NavigationState.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import Foundation
import Combine

class NavigationState: ObservableObject {
  @Published var selectedTab: MainTab = .dashboard
  @Published var selectedSidebarItem: SidebarItem? = .dashboard
  
  // iPad detail navigation
  @Published var selectedTransaction: Transaction?
  @Published var selectedAccount: Account?
  @Published var isShowingAddTransaction: Bool = false
  @Published var isShowingAddAccount: Bool = false
  
  func selectTab(_ tab: MainTab) {
    selectedTab = tab
  }
  
  func selectSidebarItem(_ item: SidebarItem) {
    selectedSidebarItem = item
    // Clear any selected details when changing sidebar items
    clearDetailSelection()
  }
  
  func selectTransaction(_ transaction: Transaction) {
    selectedTransaction = transaction
    // Clear other detail selections when selecting a transaction
    selectedAccount = nil
    isShowingAddTransaction = false
    isShowingAddAccount = false
  }
  
  func selectAccount(_ account: Account) {
    print("NavigationState: selectAccount called with account: \(account.name)")
    selectedAccount = account
    // Clear other detail selections when selecting an account
    selectedTransaction = nil
    isShowingAddTransaction = false
    isShowingAddAccount = false
    print("NavigationState: selectedAccount set to: \(selectedAccount?.name ?? "nil")")
  }
  
  func showAddTransaction() {
    isShowingAddTransaction = true
    // Clear other detail selections when showing add transaction
    selectedTransaction = nil
    selectedAccount = nil
    isShowingAddAccount = false
  }
  
  func showAddAccount() {
    isShowingAddAccount = true
    // Clear other detail selections when showing add account
    selectedTransaction = nil
    selectedAccount = nil
    isShowingAddTransaction = false
  }
  
  func clearDetailSelection() {
    selectedTransaction = nil
    selectedAccount = nil
    isShowingAddTransaction = false
    isShowingAddAccount = false
  }
  
  func resetNavigation() {
    selectedTab = .dashboard
    selectedSidebarItem = .dashboard
    clearDetailSelection()
  }
}

enum MainTab: String, CaseIterable, Identifiable {
  case dashboard = "dashboard"
  case accounts = "accounts"
  case transactions = "transactions"
  case bills = "bills"
  case budgets = "budgets"
  case more = "more"

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .dashboard: return String(localized: "tab.dashboard")
    case .accounts: return String(localized: "tab.accounts")
    case .transactions: return String(localized: "tab.transactions")
    case .bills: return String(localized: "tab.bills")
    case .budgets: return String(localized: "tab.budgets")
    case .more: return String(localized: "tab.more")
    }
  }

  var icon: String {
    switch self {
    case .dashboard: return "house.fill"
    case .accounts: return "creditcard.fill"
    case .transactions: return "list.bullet"
    case .bills: return "doc.text.fill"
    case .budgets: return "chart.pie.fill"
    case .more: return "ellipsis"
    }
  }

  var description: String {
    switch self {
    case .dashboard: return String(localized: "tab.dashboard.description")
    case .accounts: return String(localized: "tab.accounts.description")
    case .transactions: return String(localized: "tab.transactions.description")
    case .bills: return String(localized: "tab.bills.description")
    case .budgets: return String(localized: "tab.budgets.description")
    case .more: return String(localized: "tab.more.description")
    }
  }
}

enum SidebarItem: String, CaseIterable, Identifiable {
  case dashboard = "dashboard"
  case accounts = "accounts"
  case transactions = "transactions"
  case bills = "bills"
  case reports = "reports"
  case budgets = "budgets"
  case goals = "goals"
  case categories = "categories"
  case settings = "settings"

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .dashboard: return String(localized: "sidebar.dashboard")
    case .accounts: return String(localized: "sidebar.accounts")
    case .transactions: return String(localized: "sidebar.transactions")
    case .bills: return String(localized: "sidebar.bills")
    case .reports: return String(localized: "sidebar.reports")
    case .budgets: return String(localized: "sidebar.budgets")
    case .goals: return String(localized: "sidebar.goals")
    case .categories: return String(localized: "sidebar.categories")
    case .settings: return String(localized: "sidebar.settings")
    }
  }

  var icon: String {
    switch self {
    case .dashboard: return "house.fill"
    case .accounts: return "creditcard.fill"
    case .transactions: return "list.bullet"
    case .bills: return "doc.text.fill"
    case .reports: return "chart.bar.fill"
    case .budgets: return "chart.pie.fill"
    case .goals: return "target"
    case .categories: return "tag.circle.fill"
    case .settings: return "gear"
    }
  }

  var description: String {
    switch self {
    case .dashboard: return String(localized: "sidebar.dashboard.description")
    case .accounts: return String(localized: "sidebar.accounts.description")
    case .transactions: return String(localized: "sidebar.transactions.description")
    case .bills: return String(localized: "sidebar.bills.description")
    case .reports: return String(localized: "sidebar.reports.description")
    case .budgets: return String(localized: "sidebar.budgets.description")
    case .goals: return String(localized: "sidebar.goals.description")
    case .categories: return String(localized: "sidebar.categories.description")
    case .settings: return String(localized: "sidebar.settings.description")
    }
  }
}
