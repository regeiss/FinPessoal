//
//  NavigationState.swift (Cross-Platform)
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class NavigationState: ObservableObject {
  @Published var selectedTab: MainTab = .dashboard
  @Published var selectedSidebarItem: SidebarItem? = .dashboard
  @Published var navigationPath = NavigationPath()
  @Published var columnVisibility: NavigationSplitViewVisibility = .automatic
  
  // Navegação programática
  func navigate(to item: SidebarItem) {
    selectedSidebarItem = item
  }
  
  func pushToPath<T: Hashable>(_ value: T) {
    navigationPath.append(value)
  }
  
  func popToRoot() {
    navigationPath = NavigationPath()
  }
  
  func resetNavigation() {
    selectedSidebarItem = .dashboard
    navigationPath = NavigationPath()
  }
}

// MARK: - Tab Items

enum MainTab: String, CaseIterable {
  case dashboard = "Dashboard"
  case accounts = "Contas"
  case transactions = "Transações"
  case reports = "Relatórios"
  case settings = "Configurações"
  
  var icon: String {
    switch self {
    case .dashboard: return "house.fill"
    case .accounts: return "creditcard.fill"
    case .transactions: return "list.bullet"
    case .reports: return "chart.bar.fill"
    case .settings: return "gear"
    }
  }
}

// MARK: - Sidebar Items

enum SidebarItem: String, CaseIterable, Hashable {
  case dashboard = "Dashboard"
  case accounts = "Contas"
  case transactions = "Transações"
  case reports = "Relatórios"
  case budgets = "Orçamentos"
  case goals = "Metas"
  case settings = "Configurações"
  
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
  
  var title: String {
    return self.rawValue
  }
}

// MARK: - Navigation Destination

struct NavigationDestination: Hashable {
  let screen: SidebarItem
  let id: String?
  
  init(screen: SidebarItem, id: String? = nil) {
    self.screen = screen
    self.id = id
  }
}
