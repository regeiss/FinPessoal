//
//  iPadMainView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 18/08/25.
//

import SwiftUI

struct iPadMainView: View {
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @EnvironmentObject var authViewModel: AuthViewModel
  
  var body: some View {
    NavigationSplitView {
      SidebarView()
        .navigationSplitViewColumnWidth(min: 250, ideal: 300)
    } detail: {
      DetailView()
    }
    .navigationSplitViewStyle(.prominentDetail)
    .task {
      await financeViewModel.loadData()
    }
  }
}

struct SidebarRow: View {
  let item: SidebarItem
  
  var body: some View {
    NavigationLink(value: item) {
      Label(item.rawValue, systemImage: item.icon)
    }
  }
}

struct DetailView: View {
  @EnvironmentObject var navigationState: NavigationState
  
  var body: some View {
    Group {
      switch navigationState.selectedSidebarItem {
      case .dashboard:
        DashboardScreen()
      case .accounts:
        AccountsView()
      case .transactions:
        TransactionsScreen()
      case .reports:
        ReportsScreen()
      case .budgets:
        BudgetsScreen()
      case .goals:
        GoalScreen()
      case .settings:
        SettingsScreen()
      case .none:
        DashboardScreen()
      }
    }
    .navigationBarTitleDisplayMode(.large)
  }
}

struct UserProfileRow: View {
  let user: User
  @EnvironmentObject var authViewModel: AuthViewModel
  
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "person.circle.fill")
        .font(.system(size: 50))
        .foregroundColor(.blue)
      
      VStack(spacing: 4) {
        Text(user.name)
          .font(.headline)
          .fontWeight(.medium)
        
        Text(user.email)
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Button("Sair") {
        Task {
          await authViewModel.signOut()
        }
      }
      .buttonStyle(.bordered)
      .controlSize(.small)
    }
    .padding(.vertical, 16)
    .frame(maxWidth: .infinity)
  }
}
