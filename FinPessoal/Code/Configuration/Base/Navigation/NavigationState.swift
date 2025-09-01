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
  }
  
  func selectAccount(_ account: Account) {
    selectedAccount = account
  }
  
  func showAddTransaction() {
    isShowingAddTransaction = true
  }
  
  func showAddAccount() {
    isShowingAddAccount = true
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
  case reports = "reports"
  case settings = "settings"
  
  var id: String { rawValue }
  
  var displayName: String {
    switch self {
    case .dashboard: return String(localized: "tab.dashboard")
    case .accounts: return String(localized: "tab.accounts")
    case .transactions: return String(localized: "tab.transactions")
    case .reports: return String(localized: "tab.reports")
    case .settings: return String(localized: "tab.settings")
    }
  }
  
  var icon: String {
    switch self {
    case .dashboard: return "house.fill"
    case .accounts: return "creditcard.fill"
    case .transactions: return "list.bullet"
    case .reports: return "chart.bar.fill"
    case .settings: return "gear"
    }
  }
  
  var description: String {
    switch self {
    case .dashboard: return String(localized: "tab.dashboard.description")
    case .accounts: return String(localized: "tab.accounts.description")
    case .transactions: return String(localized: "tab.transactions.description")
    case .reports: return String(localized: "tab.reports.description")
    case .settings: return String(localized: "tab.settings.description")
    }
  }
}

enum SidebarItem: String, CaseIterable, Identifiable {
  case dashboard = "dashboard"
  case accounts = "accounts"
  case transactions = "transactions"
  case reports = "reports"
  case budgets = "budgets"
  case goals = "goals"
  case settings = "settings"
  
  var id: String { rawValue }
  
  var displayName: String {
    switch self {
    case .dashboard: return String(localized: "sidebar.dashboard")
    case .accounts: return String(localized: "sidebar.accounts")
    case .transactions: return String(localized: "sidebar.transactions")
    case .reports: return String(localized: "sidebar.reports")
    case .budgets: return String(localized: "sidebar.budgets")
    case .goals: return String(localized: "sidebar.goals")
    case .settings: return String(localized: "sidebar.settings")
    }
  }
  
  var icon: String {
    switch self {
    case .dashboard: return "house.fill"
    case .accounts: return "creditcard.fill"
    case .transactions: return "list.bullet"
    case .reports: return "chart.bar.fill"
    case .budgets: return "chart.pie.fill"
    case .goals: return "target"
    case .settings: return "gear"
    }
  }
  
  var description: String {
    switch self {
    case .dashboard: return String(localized: "sidebar.dashboard.description")
    case .accounts: return String(localized: "sidebar.accounts.description")
    case .transactions: return String(localized: "sidebar.transactions.description")
    case .reports: return String(localized: "sidebar.reports.description")
    case .budgets: return String(localized: "sidebar.budgets.description")
    case .goals: return String(localized: "sidebar.goals.description")
    case .settings: return String(localized: "sidebar.settings.description")
    }
  }
}
