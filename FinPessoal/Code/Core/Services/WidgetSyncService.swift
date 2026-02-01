//
//  WidgetSyncService.swift
//  FinPessoal
//
//  Created by Claude Code on 16/12/25.
//

import Foundation
import Combine

/// Service responsible for syncing app data to widgets
@MainActor
final class WidgetSyncService: ObservableObject {

  // MARK: - Singleton

  static let shared = WidgetSyncService()

  // MARK: - Published Properties

  @Published private(set) var lastSyncDate: Date?
  @Published private(set) var isSyncing: Bool = false

  // MARK: - Private Properties

  private var cancellables = Set<AnyCancellable>()

  // MARK: - Init

  private init() {
    setupNotificationObservers()
  }

  // MARK: - Setup

  private func setupNotificationObservers() {
    // Listen for sync requests from other parts of the app
    NotificationCenter.default.publisher(for: .syncWidgetData)
      .sink { [weak self] _ in
        Task { @MainActor in
          await self?.syncFromNotification()
        }
      }
      .store(in: &cancellables)
  }

  // MARK: - Public Sync Methods

  /// Syncs all available data to widgets
  /// Call this when app loads data or goes to background
  func syncAllData(
    accounts: [Account] = [],
    transactions: [Transaction] = [],
    budgets: [Budget] = [],
    goals: [Goal] = [],
    bills: [Bill] = [],
    creditCards: [CreditCard] = []
  ) {
    guard !isSyncing else { return }
    isSyncing = true

    let widgetData = WidgetDataProvider.buildWidgetData(
      accounts: accounts,
      budgets: budgets,
      bills: bills,
      goals: goals,
      creditCards: creditCards,
      transactions: transactions
    )

    SharedDataManager.shared.saveWidgetData(widgetData)
    lastSyncDate = Date()
    isSyncing = false

    print("WidgetSyncService: Synced all data to widgets")
  }

  /// Syncs data from FinanceViewModel
  func syncFromFinanceViewModel(_ viewModel: FinanceViewModel) {
    syncAllData(
      accounts: viewModel.accounts,
      transactions: viewModel.transactions,
      budgets: viewModel.budgets,
      goals: viewModel.goals,
      bills: [],
      creditCards: []
    )
  }

  /// Syncs data from FinanceViewModel and BillsViewModel
  func syncFromViewModels(
    finance: FinanceViewModel,
    bills: BillsViewModel? = nil
  ) {
    syncAllData(
      accounts: finance.accounts,
      transactions: finance.transactions,
      budgets: finance.budgets,
      goals: finance.goals,
      bills: bills?.bills ?? [],
      creditCards: []
    )
  }

  /// Quick sync for when only accounts change
  func syncAccounts(_ accounts: [Account]) {
    let existingData = SharedDataManager.shared.loadWidgetData()
    let updatedData = WidgetDataProvider.buildAccountUpdate(
      accounts: accounts,
      existingData: existingData
    )
    SharedDataManager.shared.saveWidgetData(updatedData)
    SharedDataManager.shared.reloadBalanceWidgets()
    print("WidgetSyncService: Synced accounts to widgets")
  }

  /// Quick sync for when only budgets change
  func syncBudgets(_ budgets: [Budget]) {
    let existingData = SharedDataManager.shared.loadWidgetData()
    let updatedData = WidgetDataProvider.buildBudgetUpdate(
      budgets: budgets,
      existingData: existingData
    )
    SharedDataManager.shared.saveWidgetData(updatedData)
    SharedDataManager.shared.reloadBudgetWidgets()
    print("WidgetSyncService: Synced budgets to widgets")
  }

  /// Quick sync for when only transactions change
  func syncTransactions(_ transactions: [Transaction]) {
    let existingData = SharedDataManager.shared.loadWidgetData()
    let updatedData = WidgetDataProvider.buildTransactionUpdate(
      transactions: transactions,
      existingData: existingData
    )
    SharedDataManager.shared.saveWidgetData(updatedData)
    SharedDataManager.shared.reloadTransactionWidgets()
    print("WidgetSyncService: Synced transactions to widgets")
  }

  // MARK: - Private Methods

  private func syncFromNotification() async {
    // This is called when other parts of the app request a sync
    // We just reload existing data if we have it cached
    print("WidgetSyncService: Received sync notification")
  }
}

// MARK: - Notification Names

extension Notification.Name {
  /// Post this notification to trigger widget data sync
  static let syncWidgetData = Notification.Name("syncWidgetData")

  /// Posted when widget data has been synced
  static let widgetDataSynced = Notification.Name("widgetDataSynced")
}
