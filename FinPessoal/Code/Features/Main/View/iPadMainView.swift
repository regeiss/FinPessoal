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
    NavigationSplitView(columnVisibility: .constant(.all)) {
      // Column 1: Sidebar Navigation
      SidebarView()
        .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
    } content: {
      // Column 2: Content Lists
      iPadContentView()
        .navigationSplitViewColumnWidth(min: 300, ideal: 400, max: 500)
    } detail: {
      // Column 3: Detail Views
      DetailView()
        .navigationSplitViewColumnWidth(min: 400, ideal: 500)
    }
    .navigationSplitViewStyle(.balanced)
    .task {
      await financeViewModel.loadData()
    }
  }
}

struct SidebarRow: View {
  let item: SidebarItem
  
  var body: some View {
    NavigationLink(value: item) {
      Label(item.displayName, systemImage: item.icon)
    }
  }
}

// Column 2: Content Lists
struct iPadContentView: View {
  @EnvironmentObject var navigationState: NavigationState
  
  var body: some View {
    NavigationStack {
      Group {
        switch navigationState.selectedSidebarItem {
        case .dashboard:
          DashboardScreen()
        case .accounts:
          iPadAccountsView()
        case .transactions:
          iPadTransactionsView()
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
      .navigationTitle(navigationState.selectedSidebarItem?.displayName ?? "Dashboard")
      .navigationBarTitleDisplayMode(.large)
    }
  }
}

// Column 3: Detail Views
struct DetailView: View {
  @EnvironmentObject var navigationState: NavigationState
  
  var body: some View {
    NavigationStack {
      Group {
        // Show detail screens if any are selected
        if navigationState.isShowingAddTransaction {
          iPadAddTransactionView()
        } else if navigationState.isShowingAddAccount {
          iPadAddAccountView()
        } else if let transaction = navigationState.selectedTransaction {
          iPadTransactionDetailView(transaction: transaction)
        } else if let account = navigationState.selectedAccount {
          iPadAccountDetailView(account: account)
        } else {
          // Default empty detail state
          EmptyDetailView()
        }
      }
      .navigationBarTitleDisplayMode(.large)
      .onAppear {
        print("DetailView onAppear - selectedAccount: \(navigationState.selectedAccount?.name ?? "nil"), isShowingAddAccount: \(navigationState.isShowingAddAccount)")
      }
      .onChange(of: navigationState.selectedAccount) { _, account in
        print("DetailView: selectedAccount changed to: \(account?.name ?? "nil")")
      }
    }
  }
}

// Empty state for detail column when no item is selected
struct EmptyDetailView: View {
  @EnvironmentObject var navigationState: NavigationState
  
  var body: some View {
    VStack(spacing: 24) {
      Image(systemName: "sidebar.right")
        .font(.system(size: 64))
        .foregroundColor(.secondary)
      
      Text("Select an item")
        .font(.title2)
        .fontWeight(.semibold)
        .foregroundColor(.secondary)
      
      Text("Choose an item from the list to view its details here")
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding(.horizontal, 32)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
  }
}

// iPad-specific wrapper views that coordinate with NavigationState
struct iPadTransactionsView: View {
  @EnvironmentObject var navigationState: NavigationState
  @StateObject private var transactionViewModel: TransactionViewModel
  
  init() {
    let repository = AppConfiguration.shared.createTransactionRepository()
    self._transactionViewModel = StateObject(wrappedValue: TransactionViewModel(repository: repository))
  }
  
  var body: some View {
    ZStack {
      TransactionsScreen()
    }
    .onReceive(transactionViewModel.$selectedTransaction) { transaction in
      if let transaction = transaction {
        navigationState.selectTransaction(transaction)
      }
    }
    .onChange(of: transactionViewModel.showingAddTransaction) { _, showing in
      if showing {
        navigationState.showAddTransaction()
        transactionViewModel.dismissAddTransaction()
      }
    }
    .environmentObject(transactionViewModel)
  }
}

struct iPadAccountsView: View {
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var accountViewModel: AccountViewModel
  
  var body: some View {
    AccountsView()
      .onReceive(accountViewModel.$selectedAccount) { account in
        print("iPadAccountsView: received selectedAccount: \(account?.name ?? "nil")")
        if let account = account {
          print("iPadAccountsView: calling navigationState.selectAccount")
          navigationState.selectAccount(account)
        }
      }
      .onChange(of: accountViewModel.showingAddAccount) { _, showing in
        if showing {
          navigationState.showAddAccount()
          accountViewModel.showingAddAccount = false
        }
      }
  }
}

struct iPadTransactionDetailView: View {
  let transaction: Transaction
  @EnvironmentObject var navigationState: NavigationState
  
  var body: some View {
    TransactionDetailView(transaction: transaction)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Back") {
            navigationState.clearDetailSelection()
          }
        }
      }
      .navigationTitle("Transaction Details")
      .navigationBarTitleDisplayMode(.inline)
  }
}

struct iPadAccountDetailView: View {
  let account: Account
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var accountViewModel: AccountViewModel
  
  var body: some View {
    AccountDetailView(account: account, accountViewModel: accountViewModel)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Back") {
            navigationState.clearDetailSelection()
          }
        }
      }
      .navigationTitle("Account Details")
      .navigationBarTitleDisplayMode(.inline)
  }
}

struct iPadAddTransactionView: View {
  @EnvironmentObject var navigationState: NavigationState
  @StateObject private var transactionViewModel: TransactionViewModel
  
  init() {
    let repository = AppConfiguration.shared.createTransactionRepository()
    self._transactionViewModel = StateObject(wrappedValue: TransactionViewModel(repository: repository))
  }
  
  var body: some View {
    AddTransactionView(transactionViewModel: transactionViewModel)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            navigationState.clearDetailSelection()
          }
        }
      }
      .navigationTitle("New Transaction")
      .navigationBarTitleDisplayMode(.inline)
  }
}

struct iPadAddAccountView: View {
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var accountViewModel: AccountViewModel
  
  var body: some View {
    AddAccountView(accountViewModel: accountViewModel)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            navigationState.clearDetailSelection()
          }
        }
      }
      .navigationTitle("New Account")
      .navigationBarTitleDisplayMode(.inline)
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
