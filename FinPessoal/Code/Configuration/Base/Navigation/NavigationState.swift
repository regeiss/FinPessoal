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
}

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

enum SidebarItem: String, CaseIterable {
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
}
