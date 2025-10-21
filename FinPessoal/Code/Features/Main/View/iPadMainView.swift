//
//  iPadMainView.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 18/08/25.
//  Modified by Roberto Edgar Geiss on 14/10/25.
//

import SwiftUI
import Firebase

struct iPadMainView: View {
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var financeViewModel: FinanceViewModel
  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.verticalSizeClass) private var verticalSizeClass
  @State private var columnVisibility: NavigationSplitViewVisibility = .all

  // Portrait: regular width, regular height
  // Landscape: regular width, compact height
  private var isLandscape: Bool {
    verticalSizeClass == .compact && horizontalSizeClass == .regular
  }

  var body: some View {
    Group {
      if isLandscape {
        // Landscape: 3-column layout (Sidebar + Content + Detail)
        landscapeLayout
      } else {
        // Portrait: 2-column layout (Sidebar + Content)
        portraitLayout
      }
    }
    .task {
      await financeViewModel.loadData()
    }
  }

  // MARK: - Portrait Layout (2 columns)
  private var portraitLayout: some View {
    NavigationSplitView {
      // Column 1: Sidebar Navigation
      SidebarView()
        .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
    } detail: {
      // Column 2: Main Content - Fills all remaining space to right edge
      iPadContentView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  // MARK: - Landscape Layout (3 columns)
  private var landscapeLayout: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      // Column 1: Sidebar Navigation
      SidebarView()
        .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 250)
    } content: {
      // Column 2: Content Lists
      iPadContentView()
        .navigationSplitViewColumnWidth(min: 300, ideal: 350, max: 400)
    } detail: {
      // Column 3: Detail Views
      DetailView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .navigationSplitViewStyle(.prominentDetail)
    .onChange(of: navigationState.selectedSidebarItem) { _, _ in
      updateColumnVisibility()
    }
    .onChange(of: navigationState.selectedAccount) { _, account in
      if account != nil {
        columnVisibility = .all
      }
    }
    .onChange(of: navigationState.selectedTransaction) { _, transaction in
      if transaction != nil {
        columnVisibility = .all
      }
    }
    .onAppear {
      updateColumnVisibility()
    }
  }

  private func updateColumnVisibility() {
    // In landscape, intelligently show/hide detail column
    switch navigationState.selectedSidebarItem {
    case .accounts, .transactions:
      // Show detail for list-detail patterns
      if navigationState.selectedAccount != nil || navigationState.selectedTransaction != nil {
        columnVisibility = .all
      } else {
        columnVisibility = .all // Keep all visible for selection
      }
    case .dashboard, .reports, .budgets, .goals, .settings, .categories:
      // For full-screen views, show detail with helpful content
      columnVisibility = .all
    default:
      columnVisibility = .all
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
        case .categories:
          CategoriesManagementScreen(
            transactionRepository: AppConfiguration.shared.createTransactionRepository(),
            categoryRepository: AppConfiguration.shared.createCategoryRepository(),
            forcePhoneLayout: true
          )
        case .settings:
          SettingsScreen()
        case .none:
          DashboardScreen()
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .navigationTitle(navigationState.selectedSidebarItem?.displayName ?? String(localized: "navigation.dashboard.title", defaultValue: "Dashboard"))
      .navigationBarTitleDisplayMode(.large)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

// Column 3: Detail Views
struct DetailView: View {
    @EnvironmentObject var navigationState: NavigationState

    var body: some View {
      NavigationStack {
        Group {
          if navigationState.isShowingAddTransaction {
            iPadAddTransactionView()
          } else if navigationState.isShowingAddAccount {
            iPadAddAccountView()
          } else if let transaction = navigationState.selectedTransaction {
            iPadTransactionDetailView(transaction: transaction)
          } else if let account = navigationState.selectedAccount {
            iPadAccountDetailView(account: account)
          } else {
            // Default content based on selected sidebar item, like Settings app
            DefaultDetailView()
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
  
  // Default detail view that shows contextual content like Apple Settings
  struct DefaultDetailView: View {
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var financeViewModel: FinanceViewModel
    
    var body: some View {
      ScrollView {
        LazyVStack(spacing: 0) {
          switch navigationState.selectedSidebarItem {
          case .dashboard:
            DashboardDetailView()
          case .accounts:
            AccountsDetailView()
          case .transactions:
            TransactionsDetailView()
          case .reports:
            ReportsDetailView()
          case .budgets:
            BudgetsDetailView()
          case .goals:
            GoalsDetailView()
          case .categories:
            CategoriesDetailView()
          case .settings:
            SettingsDetailView()
          case .none:
            DashboardDetailView()
          }
        }
      }
      .background(Color(.systemGroupedBackground))
      .navigationTitle(navigationState.selectedSidebarItem?.displayName ?? String(localized: "navigation.dashboard.title", defaultValue: "Dashboard"))
      .navigationBarTitleDisplayMode(.large)
    }
  }
  
  // Default detail views for each section
  struct DashboardDetailView: View {
    var body: some View {
      VStack(spacing: 24) {
        Image(systemName: "chart.line.uptrend.xyaxis")
          .font(.system(size: 64))
          .foregroundColor(.blue)
        
        Text("Dashboard Overview")
          .font(.title2)
          .fontWeight(.semibold)
        
        Text("Your financial overview and key metrics will be displayed here.")
          .multilineTextAlignment(.center)
          .foregroundColor(.secondary)
          .padding(.horizontal, 32)
        
        // TODO: Add finance stats when data is available
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.vertical, 40)
    }
  }
  
  struct AccountsDetailView: View {
    var body: some View {
      VStack(spacing: 24) {
        Image(systemName: "creditcard")
          .font(.system(size: 64))
          .foregroundColor(.green)
        
        Text("Accounts")
          .font(.title2)
          .fontWeight(.semibold)
        
        Text("Select an account from the list to view its details and transactions.")
          .multilineTextAlignment(.center)
          .foregroundColor(.secondary)
          .padding(.horizontal, 32)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.vertical, 40)
    }
  }
  
  struct TransactionsDetailView: View {
    var body: some View {
      VStack(spacing: 24) {
        Image(systemName: "list.bullet.rectangle")
          .font(.system(size: 64))
          .foregroundColor(.orange)
        
        Text("Transactions")
          .font(.title2)
          .fontWeight(.semibold)
        
        Text("Select a transaction from the list to view its details.")
          .multilineTextAlignment(.center)
          .foregroundColor(.secondary)
          .padding(.horizontal, 32)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.vertical, 40)
    }
  }
  
  struct ReportsDetailView: View {
    var body: some View {
      VStack(spacing: 24) {
        Image(systemName: "chart.bar.doc.horizontal")
          .font(.system(size: 64))
          .foregroundColor(.purple)
        
        Text("Reports")
          .font(.title2)
          .fontWeight(.semibold)
        
        Text("Financial reports and analytics will be displayed here.")
          .multilineTextAlignment(.center)
          .foregroundColor(.secondary)
          .padding(.horizontal, 32)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.vertical, 40)
    }
  }
  
  struct BudgetsDetailView: View {
    var body: some View {
      VStack(spacing: 24) {
        Image(systemName: "target")
          .font(.system(size: 64))
          .foregroundColor(.red)
        
        Text("Budgets")
          .font(.title2)
          .fontWeight(.semibold)
        
        Text("Create and manage your budgets to track your spending.")
          .multilineTextAlignment(.center)
          .foregroundColor(.secondary)
          .padding(.horizontal, 32)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.vertical, 40)
    }
  }
  
  struct GoalsDetailView: View {
    var body: some View {
      VStack(spacing: 24) {
        Image(systemName: "flag.checkered")
          .font(.system(size: 64))
          .foregroundColor(.indigo)
        
        Text("Goals")
          .font(.title2)
          .fontWeight(.semibold)
        
        Text("Set and track your financial goals.")
          .multilineTextAlignment(.center)
          .foregroundColor(.secondary)
          .padding(.horizontal, 32)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.vertical, 40)
    }
  }
  
struct SettingsDetailView: View {
  var body: some View {
    VStack(spacing: 24) {
      Image(systemName: "gear")
        .font(.system(size: 64))
        .foregroundColor(.gray)
      
      Text("Settings")
        .font(.title2)
        .fontWeight(.semibold)
      
      Text("Configure your app preferences and account settings.")
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding(.horizontal, 32)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.vertical, 40)
  }
}
   
  // iPad-specific wrapper views that coordinate with NavigationState
  struct iPadTransactionsView: View {
    @EnvironmentObject var navigationState: NavigationState
    @StateObject private var transactionViewModel: TransactionViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isLandscape: Bool {
      verticalSizeClass == .compact && horizontalSizeClass == .regular
    }

    init() {
      let repository = AppConfiguration.shared.createTransactionRepository()
      self._transactionViewModel = StateObject(wrappedValue: TransactionViewModel(repository: repository))
    }

    var body: some View {
      TransactionsScreen(transactionViewModel: transactionViewModel)
        .environmentObject(transactionViewModel)
        .onReceive(transactionViewModel.$selectedTransaction) { transaction in
          if isLandscape, let transaction = transaction {
            navigationState.selectTransaction(transaction)
          }
        }
        .onChange(of: transactionViewModel.showingAddTransaction) { _, showing in
          if isLandscape && showing {
            navigationState.showAddTransaction()
            transactionViewModel.dismissAddTransaction()
          }
        }
    }
  }

  struct iPadAccountsView: View {
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var accountViewModel: AccountViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isLandscape: Bool {
      verticalSizeClass == .compact && horizontalSizeClass == .regular
    }

    var body: some View {
      AccountsView()
        .onReceive(accountViewModel.$selectedAccount) { account in
          if isLandscape, let account = account {
            navigationState.selectAccount(account)
          }
        }
        .onChange(of: accountViewModel.showingAddAccount) { _, showing in
          if isLandscape && showing {
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
      VStack(spacing: 0) {
        TransactionDetailView(transaction: transaction)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.close", defaultValue: "Fechar")) {
            navigationState.clearDetailSelection()
          }
        }
      }
      .navigationTitle(String(localized: "transaction.detail.title", defaultValue: "Detalhes da Transação"))
      .navigationBarTitleDisplayMode(.inline)
    }
  }
  
  struct iPadAccountDetailView: View {
    let account: Account
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var financeViewModel: FinanceViewModel
    @State private var showingEditAccount = false
    @State private var showingConfirmation = false
    
    private var accountTransactions: [Transaction] {
      financeViewModel.transactions.filter { $0.accountId == account.id }
    }
    
    var body: some View {
      ScrollView {
        VStack(spacing: 24) {
          accountHeaderSection
          accountStatsSection
          recentTransactionsSection
        }
        .padding(.top)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color(.systemGroupedBackground))
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String(localized: "common.back", defaultValue: "Back")) {
            navigationState.clearDetailSelection()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            Button(String(localized: "accounts.edit.button", defaultValue: "Edit")) {
              showingEditAccount = true
            }
            Button(String(localized: "accounts.view.statement", defaultValue: "View Statement")) {
              // Navigate to transactions screen for this account
            }
            Divider()
            if account.isActive {
              Button(String(localized: "accounts.deactivate", defaultValue: "Deactivate"), role: .destructive) {
                showingConfirmation = true
              }
            } else {
              Button(String(localized: "accounts.activate", defaultValue: "Activate")) {
                Task {
                  await accountViewModel.activateAccount(account.id)
                  navigationState.clearDetailSelection()
                }
              }
            }
          } label: {
            Image(systemName: "ellipsis.circle")
          }
        }
      }
      .navigationTitle(account.name)
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $showingEditAccount) {
        EditAccountView(account: account, accountViewModel: accountViewModel)
      }
      .confirmationDialog(
        String(localized: "accounts.deactivate.confirm.title", defaultValue: "Deactivate Account"),
        isPresented: $showingConfirmation
      ) {
        Button(String(localized: "accounts.deactivate", defaultValue: "Deactivate"), role: .destructive) {
          Task {
            await accountViewModel.deactivateAccount(account.id)
            navigationState.clearDetailSelection()
          }
        }
        Button(String(localized: "common.cancel", defaultValue: "Cancel"), role: .cancel) { }
      } message: {
        Text(String(localized: "accounts.deactivate.confirm.message", defaultValue: "Are you sure you want to deactivate this account?"))
      }
    }
    
    private var accountHeaderSection: some View {
      VStack(spacing: 20) {
        Image(systemName: account.type.icon)
          .font(.system(size: 80))
          .foregroundColor(account.type.color)
          .frame(width: 120, height: 120)
          .background(account.type.color.opacity(0.15))
          .cornerRadius(30)
        
        VStack(spacing: 6) {
          Text(LocalizedStringKey(account.type.rawValue))
            .font(.title3)
            .foregroundColor(.secondary)
          
          Text(account.formattedBalance)
            .font(.system(size: 42, weight: .bold, design: .rounded))
            .foregroundColor(account.balance >= 0 ? .green : .red)
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 30)
      .background(Color(.systemGray6))
      .cornerRadius(20)
    }
    
    private var accountStatsSection: some View {
      LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
      ], spacing: 16) {
        DetailStatCard(
          title: String(localized: "transactions.title", defaultValue: "Transactions"),
          value: "\(accountTransactions.count)",
          icon: "list.bullet",
          color: .blue
        )
        
        DetailStatCard(
          title: String(localized: "common.status", defaultValue: "Status"),
          value: String(localized: account.isActive ? "common.active" : "common.inactive", defaultValue: account.isActive ? "Active" : "Inactive"),
          icon: account.isActive ? "checkmark.circle.fill" : "pause.circle.fill",
          color: account.isActive ? .green : .orange
        )
        
        DetailStatCard(
          title: String(localized: "account.type", defaultValue: "Type"),
          value: account.type.rawValue,
          icon: account.type.icon,
          color: account.type.color
        )
      }
    }
    
    private var recentTransactionsSection: some View {
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          Text(String(localized: "transactions.recent", defaultValue: "Recent Transactions"))
            .font(.title2)
            .fontWeight(.semibold)
          Spacer()
          if !accountTransactions.isEmpty {
            Text(String(localized: "transactions.total.count", defaultValue: "\(accountTransactions.count) total"))
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        
        if accountTransactions.isEmpty {
          VStack(spacing: 16) {
            Image(systemName: "tray")
              .font(.system(size: 50))
              .foregroundColor(.secondary)
            
            Text(String(localized: "transactions.empty.title", defaultValue: "No Transactions"))
              .font(.title3)
              .fontWeight(.medium)
              .foregroundColor(.secondary)
            
            Text(String(localized: "transactions.empty.account.description", defaultValue: "This account has no transactions yet."))
              .font(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 60)
        } else {
          LazyVStack(spacing: 12) {
            ForEach(accountTransactions.prefix(10)) { transaction in
              EnhancedTransactionRow(transaction: transaction)
            }
          }
          
          if accountTransactions.count > 10 {
            Button(String(localized: "transactions.view.all.count", defaultValue: "View all \(accountTransactions.count) transactions")) {
              // Navigate to full transactions list
            }
            .font(.body)
            .foregroundColor(.blue)
            .padding(.top, 16)
            .frame(maxWidth: .infinity)
          }
        }
      }
    }
  }

struct DetailStatCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color
  
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundColor(color)
      
      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)
      
      Text(value)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(.primary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity, minHeight: 100)
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(16)
    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
  }
}

struct EnhancedTransactionRow: View {
  let transaction: Transaction
  
  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: transaction.category.icon)
        .font(.title2)
        .foregroundColor(transaction.type == .expense ? .red : .green)
        .frame(width: 44, height: 44)
        .background((transaction.type == .expense ? Color.red : Color.green).opacity(0.15))
        .cornerRadius(12)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(transaction.description)
          .font(.headline)
          .fontWeight(.medium)
          .foregroundColor(.primary)
        
        HStack {
          Text(transaction.category.displayName)
            .font(.caption)
            .foregroundColor(.secondary)
          
          Spacer()
          
          Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      
      Spacer()
      
      Text(transaction.formattedAmount)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(transaction.type == .expense ? .red : .green)
    }
    .padding(16)
    .background(Color(.systemBackground))
    .cornerRadius(16)
    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
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
            Button(String(localized: "common.cancel", defaultValue: "Cancel")) {
              navigationState.clearDetailSelection()
            }
          }
        }
        .navigationTitle(String(localized: "transaction.add.title", defaultValue: "New Transaction"))
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
            Button(String(localized: "common.cancel", defaultValue: "Cancel")) {
              navigationState.clearDetailSelection()
            }
          }
        }
        .navigationTitle(String(localized: "account.add.title", defaultValue: "New Account"))
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
        
        Button(String(localized: "auth.signout.button", defaultValue: "Sair")) {
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

struct CategoriesDetailView: View {
    var body: some View {
      VStack(spacing: 24) {
        Image(systemName: "tag.circle.fill")
          .font(.system(size: 64))
          .foregroundColor(.gray)
        
        Text("Categories")
          .font(.title2)
          .fontWeight(.semibold)
        
        Text("Manage your transaction categories and subcategories")
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 32)
      }
      .padding(.vertical, 16)
      .frame(maxWidth: .infinity)
    }
  }
  
  @ViewBuilder
  private var iPadDashboardContent: some View {
    iPadDashboardView()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  struct iPadDashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingSettings = false

    var body: some View {
      ScrollView {
        LazyVStack(spacing: 20) {
          // Balance Card
          BalanceCardView(
            totalBalance: viewModel.totalBalance,
            monthlyExpenses: viewModel.monthlyExpenses
          )
          .redacted(reason: viewModel.isLoading ? .placeholder : [])

          // Budget Alerts (only show if there are alerts)
          if !viewModel.budgetAlerts.isEmpty {
            BudgetAlertsView(budgets: viewModel.budgetAlerts)
          }

          // Recent Transactions
          RecentTransactionScreen(transactions: viewModel.recentTransactions)
            .redacted(reason: viewModel.isLoading ? .placeholder : [])

          // Quick Actions
          QuickActionsView()
        }
        .frame(maxWidth: 1200, alignment: .leading)
        .frame(maxWidth: .infinity)
        .padding(20)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color(.systemBackground))
      .refreshable {
        await MainActor.run {
          viewModel.loadDashboardData()
        }
      }
      .overlay {
        if viewModel.isLoading && viewModel.recentTransactions.isEmpty {
          ProgressView(String(localized: "dashboard.loading", defaultValue: "Carregando..."))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
      }
      .alert("Erro", isPresented: .constant(viewModel.error != nil)) {
        Button("OK") {
          viewModel.error = nil
        }
        Button(String(localized: "common.try.again", defaultValue: "Tentar Novamente")) {
          viewModel.error = nil
          viewModel.loadDashboardData()
        }
      } message: {
        if let error = viewModel.error {
          Text(error.localizedDescription)
        }
      }
      .onAppear {
        viewModel.loadDashboardData()

        // Only log analytics if not using mock data
        if !AppConfiguration.shared.useMockData {
          Analytics.logEvent("dashboard_viewed", parameters: nil)
        }
      }
    }
  }

  @ViewBuilder
  private var iPadGoalsContent: some View {
    GoalScreen()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  @ViewBuilder
  private var iPadCategoriesContent: some View {
    CategoriesManagementScreen(
      transactionRepository: AppConfiguration.shared.createTransactionRepository(),
      categoryRepository: AppConfiguration.shared.createCategoryRepository(),
      forcePhoneLayout: true
    )
  }

#Preview("iPad Main View") {
  iPadMainView()
    .environmentObject(NavigationState())
    .environmentObject(FinanceViewModel(
      financeRepository: AppConfiguration.shared.createFinanceRepository()
    ))
    .environmentObject(AuthViewModel(
      authRepository: AppConfiguration.shared.createAuthRepository()
    ))
    .environmentObject(AccountViewModel(repository: AppConfiguration.shared.createAccountRepository()))
}
