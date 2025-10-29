//
//  BillsViewModel.swift
//  FinPessoal
//
//  Created by Claude Code on 26/10/25.
//

import Foundation
import Combine

@MainActor
class BillsViewModel: ObservableObject {

  // MARK: - Published Properties

  @Published var bills: [Bill] = []
  @Published var filteredBills: [Bill] = []
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?

  // Filter properties
  @Published var searchQuery: String = ""
  @Published var selectedFilter: BillFilter = .all
  @Published var selectedCategory: TransactionCategory?

  // UI State
  @Published var showingAddBill: Bool = false
  @Published var selectedBill: Bill?
  @Published var showingBillDetail: Bool = false

  // Statistics
  @Published var totalUnpaid: Double = 0.0
  @Published var totalOverdue: Double = 0.0
  @Published var billsDueSoonCount: Int = 0
  @Published var overdueCount: Int = 0

  // MARK: - Private Properties

  private let repository: BillRepositoryProtocol
  private var cancellables = Set<AnyCancellable>()

  // MARK: - Initialization

  init(repository: BillRepositoryProtocol) {
    self.repository = repository
    setupBindings()
  }

  private func setupBindings() {
    // Update statistics when bills change
    $bills
      .sink { [weak self] bills in
        Task { @MainActor in
          await self?.updateStatistics()
        }
      }
      .store(in: &cancellables)

    // Apply filters when bills OR any filter property changes
    Publishers.CombineLatest3(
      $bills,
      $searchQuery,
      $selectedFilter
    )
    .combineLatest($selectedCategory)
    .sink { [weak self] (billsAndFilters, category) in
      DispatchQueue.main.async {
        self?.applyFilters()
      }
    }
    .store(in: &cancellables)
  }

  // MARK: - Data Loading

  func fetchBills() async {
    isLoading = true
    errorMessage = nil

    do {
      let fetchedBills = try await repository.fetchBills()
      bills = fetchedBills
    } catch let authError as AuthError {
      errorMessage = authError.errorDescription ?? "Authentication error"
      print("Auth error fetching bills: \(authError)")
    } catch let firebaseError as FirebaseError {
      errorMessage = firebaseError.errorDescription ?? "Database error"
      print("Firebase error fetching bills: \(firebaseError)")
    } catch {
      errorMessage = error.localizedDescription
      print("Error fetching bills: \(error)")
    }

    isLoading = false
  }

  func refreshData() {
    Task {
      await fetchBills()
    }
  }

  // MARK: - CRUD Operations

  func addBill(_ bill: Bill) async -> Bool {
    do {
      try await repository.addBill(bill)

      // Schedule reminder notification
      await NotificationManager.shared.scheduleBillReminder(
        billId: bill.id,
        billName: bill.name,
        amount: bill.amount,
        dueDate: bill.nextDueDate,
        daysBeforeDue: bill.reminderDaysBefore
      )

      await fetchBills()
      return true
    } catch {
      errorMessage = error.localizedDescription
      print("Error adding bill: \(error)")
      return false
    }
  }

  func updateBill(_ bill: Bill) async -> Bool {
    do {
      try await repository.updateBill(bill)

      // Update reminder notification
      await NotificationManager.shared.updateBillReminder(
        billId: bill.id,
        billName: bill.name,
        amount: bill.amount,
        dueDate: bill.nextDueDate,
        daysBeforeDue: bill.reminderDaysBefore
      )

      await fetchBills()
      return true
    } catch {
      errorMessage = error.localizedDescription
      print("Error updating bill: \(error)")
      return false
    }
  }

  func deleteBill(_ billId: String) async -> Bool {
    do {
      // Cancel notification
      await NotificationManager.shared.cancelNotification(identifier: "bill-\(billId)")

      try await repository.deleteBill(billId)
      await fetchBills()
      return true
    } catch {
      errorMessage = error.localizedDescription
      print("Error deleting bill: \(error)")
      return false
    }
  }

  func markBillAsPaid(_ billId: String) async -> Bool {
    do {
      try await repository.markBillAsPaid(billId)

      // Update notification for next due date
      if let bill = bills.first(where: { $0.id == billId }) {
        var updatedBill = bill
        updatedBill.markAsPaid()

        await NotificationManager.shared.updateBillReminder(
          billId: updatedBill.id,
          billName: updatedBill.name,
          amount: updatedBill.amount,
          dueDate: updatedBill.nextDueDate,
          daysBeforeDue: updatedBill.reminderDaysBefore
        )
      }

      await fetchBills()
      return true
    } catch {
      errorMessage = error.localizedDescription
      print("Error marking bill as paid: \(error)")
      return false
    }
  }

  func markBillAsUnpaid(_ billId: String) async -> Bool {
    do {
      try await repository.markBillAsUnpaid(billId)
      await fetchBills()
      return true
    } catch {
      errorMessage = error.localizedDescription
      print("Error marking bill as unpaid: \(error)")
      return false
    }
  }

  // MARK: - Filtering

  private func applyFilters() {
    var filtered = bills

    // Apply filter
    switch selectedFilter {
    case .all:
      break
    case .active:
      filtered = filtered.filter { $0.isActive }
    case .paid:
      filtered = filtered.filter { $0.isPaid }
    case .unpaid:
      filtered = filtered.filter { !$0.isPaid }
    case .overdue:
      filtered = filtered.filter { $0.isOverdue }
    case .dueSoon:
      filtered = filtered.filter { $0.isDueSoon }
    }

    // Apply category filter
    if let category = selectedCategory {
      filtered = filtered.filter { $0.category == category }
    }

    // Apply search query
    if !searchQuery.isEmpty {
      let query = searchQuery.lowercased()
      filtered = filtered.filter { bill in
        bill.name.lowercased().contains(query) ||
        bill.category.displayName.lowercased().contains(query) ||
        (bill.notes?.lowercased().contains(query) ?? false)
      }
    }

    filteredBills = filtered.sorted { $0.nextDueDate < $1.nextDueDate }
  }

  func clearFilters() {
    searchQuery = ""
    selectedFilter = .all
    selectedCategory = nil
  }

  // MARK: - Statistics

  private func updateStatistics() async {
    do {
      totalUnpaid = try await repository.calculateTotalUnpaidAmount()

      let overdueBills = try await repository.fetchOverdueBills()
      totalOverdue = overdueBills.reduce(0) { $0 + $1.amount }
      overdueCount = overdueBills.count

      let dueSoonBills = try await repository.fetchBillsDueSoon()
      billsDueSoonCount = dueSoonBills.count

    } catch {
      print("Error updating bill statistics: \(error)")
    }
  }

  // MARK: - Computed Properties

  var hasBills: Bool {
    return !bills.isEmpty
  }

  var hasFilteredBills: Bool {
    return !filteredBills.isEmpty
  }

  var isFiltered: Bool {
    return !searchQuery.isEmpty || selectedFilter != .all || selectedCategory != nil
  }

  var formattedTotalUnpaid: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: totalUnpaid)) ?? "R$ 0,00"
  }

  var formattedTotalOverdue: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: totalOverdue)) ?? "R$ 0,00"
  }

  // MARK: - UI Actions

  func selectBill(_ bill: Bill) {
    selectedBill = bill
    showingBillDetail = true
  }

  func dismissBillDetail() {
    showingBillDetail = false
    selectedBill = nil
  }

  func showAddBill() {
    showingAddBill = true
  }

  func dismissAddBill() {
    showingAddBill = false
  }

  // MARK: - Error Handling

  func clearError() {
    errorMessage = nil
  }
}
