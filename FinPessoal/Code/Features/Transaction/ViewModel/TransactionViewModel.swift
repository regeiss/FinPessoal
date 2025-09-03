//
//  TransactionViewModel.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 31/08/25.
//

import Foundation
import Combine
import FirebaseAuth
import UIKit

@MainActor
class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingAddTransaction: Bool = false
    @Published var selectedTransaction: Transaction?
    @Published var showingTransactionDetail: Bool = false
    
    // Filter and search properties
    @Published var searchQuery: String = "" {
        didSet {
            applyFilters()
        }
    }
    @Published var selectedPeriod: TransactionPeriod = .all {
        didSet {
            applyFilters()
        }
    }
    @Published var selectedCategory: TransactionCategory? = nil {
        didSet {
            applyFilters()
        }
    }
    @Published var selectedType: TransactionType? = nil {
        didSet {
            applyFilters()
        }
    }
    @Published var selectedAccountId: String? = nil {
        didSet {
            applyFilters()
        }
    }
    
    // Statistics properties
    @Published var totalIncome: Double = 0.0
    @Published var totalExpenses: Double = 0.0
    @Published var balance: Double = 0.0
    @Published var expensesByCategory: [TransactionCategory: Double] = [:]
    @Published var incomeByCategory: [TransactionCategory: Double] = [:]
    
    private let repository: TransactionRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
        setupBindings()
    }
    
    private func setupBindings() {
        // Update statistics when transactions change
        $transactions
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.updateStatistics()
                }
            }
            .store(in: &cancellables)
        
        // Apply filters when transactions change
        $transactions
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    func loadTransactions() {
        Task {
            await fetchTransactions()
        }
    }
    
    func fetchTransactions() async {
        print("TransactionViewModel: Starting to fetch transactions")
        isLoading = true
        errorMessage = nil
        
        // Double-check authentication before making the call (skip for mock data)
        if !AppConfiguration.shared.useMockData {
            guard Auth.auth().currentUser != nil else {
                print("TransactionViewModel: No authenticated user, skipping fetch")
                isLoading = false
                return
            }
        }
        
        do {
            let fetchedTransactions = try await repository.getTransactions()
            transactions = fetchedTransactions
            print("Successfully fetched \(fetchedTransactions.count) transactions")
            
            // Clear any previous error since fetch was successful
            if errorMessage != nil {
                errorMessage = nil
            }
        } catch let authError as AuthError {
            errorMessage = authError.errorDescription ?? "Authentication error"
            print("Auth error fetching transactions: \(authError)")
        } catch let firebaseError as FirebaseError {
            errorMessage = firebaseError.errorDescription ?? "Database error"
            print("Firebase error fetching transactions: \(firebaseError)")
        } catch {
            print("Unexpected error fetching transactions: \(error)")
            print("Error type: \(type(of: error))")
            
            // For development, if we get persistent offline errors, don't show error to user
            // This is likely just because the user has no transactions yet
            let errorDescription = error.localizedDescription.lowercased()
            if errorDescription.contains("offline") || errorDescription.contains("no active listeners") {
                print("TransactionViewModel: Treating as empty state rather than error")
                // Don't set errorMessage, just keep empty transactions array
                transactions = []
            } else {
                // For other errors, show to user
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    func refreshData() {
        Task {
            await fetchTransactions()
        }
    }
    
    // MARK: - CRUD Operations
    
    func addTransaction(_ transaction: Transaction) async -> Bool {
        do {
            try await repository.addTransaction(transaction)
            await fetchTransactions()
            return true
        } catch let authError as AuthError {
            errorMessage = authError.errorDescription ?? "Authentication error"
            print("Auth error adding transaction: \(authError)")
            return false
        } catch let firebaseError as FirebaseError {
            errorMessage = firebaseError.errorDescription ?? "Database error"
            print("Firebase error adding transaction: \(firebaseError)")
            return false
        } catch {
            errorMessage = error.localizedDescription
            print("Error adding transaction: \(error)")
            return false
        }
    }
    
    func updateTransaction(_ transaction: Transaction) async -> Bool {
        do {
            try await repository.updateTransaction(transaction)
            await fetchTransactions()
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Error updating transaction: \(error)")
            return false
        }
    }
    
    func deleteTransaction(_ transactionId: String) async -> Bool {
        do {
            try await repository.deleteTransaction(transactionId)
            await fetchTransactions()
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Error deleting transaction: \(error)")
            return false
        }
    }
    
    // MARK: - Query Operations
    
    func getTransactions(for accountId: String) async -> [Transaction] {
        do {
            return try await repository.getTransactions(for: accountId)
        } catch {
            errorMessage = error.localizedDescription
            print("Error getting transactions for account: \(error)")
            return []
        }
    }
    
    func getRecentTransactions(limit: Int = 10) async -> [Transaction] {
        do {
            return try await repository.getRecentTransactions(limit: limit)
        } catch {
            errorMessage = error.localizedDescription
            print("Error getting recent transactions: \(error)")
            return []
        }
    }
    
    func searchTransactions(query: String) async -> [Transaction] {
        do {
            return try await repository.searchTransactions(query: query)
        } catch {
            errorMessage = error.localizedDescription
            print("Error searching transactions: \(error)")
            return []
        }
    }
    
    // MARK: - Filter and Search
    
    private func applyFilters() {
        print("TransactionViewModel: applyFilters() called with \(transactions.count) total transactions")
        print("TransactionViewModel: Filters - search: '\(searchQuery)', period: \(selectedPeriod), category: \(selectedCategory?.rawValue ?? "nil"), type: \(selectedType?.rawValue ?? "nil"), accountId: \(selectedAccountId ?? "nil")")
        
        var filtered = transactions
        
        // Apply search filter
        if !searchQuery.isEmpty {
            let lowercaseQuery = searchQuery.lowercased()
            filtered = filtered.filter { transaction in
                transaction.description.lowercased().contains(lowercaseQuery) ||
                transaction.category.displayName.lowercased().contains(lowercaseQuery)
            }
            print("TransactionViewModel: After search filter: \(filtered.count) transactions")
        }
        
        // Apply period filter
        if selectedPeriod != .all {
            let dateRange = getDateRange(for: selectedPeriod)
            print("TransactionViewModel: Period filter range: \(dateRange.start) to \(dateRange.end)")
            filtered = filtered.filter { transaction in
                let inRange = transaction.date >= dateRange.start && transaction.date <= dateRange.end
                print("TransactionViewModel: Transaction '\(transaction.description)' date \(transaction.date) in range: \(inRange)")
                return inRange
            }
            print("TransactionViewModel: After period filter: \(filtered.count) transactions")
        }
        
        // Apply category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
            print("TransactionViewModel: After category filter: \(filtered.count) transactions")
        }
        
        // Apply type filter
        if let type = selectedType {
            filtered = filtered.filter { $0.type == type }
            print("TransactionViewModel: After type filter: \(filtered.count) transactions")
        }
        
        // Apply account filter
        if let accountId = selectedAccountId {
            filtered = filtered.filter { $0.accountId == accountId }
            print("TransactionViewModel: After account filter: \(filtered.count) transactions")
        }
        
        filteredTransactions = filtered.sorted { $0.date > $1.date }
        print("TransactionViewModel: Final filtered transactions: \(filteredTransactions.count)")
        
        for (index, transaction) in filteredTransactions.enumerated() {
            print("TransactionViewModel: [\(index)] \(transaction.description) - \(transaction.amount) - \(transaction.date)")
        }
    }
    
    func clearFilters() {
        searchQuery = ""
        selectedPeriod = .all
        selectedCategory = nil
        selectedType = nil
        selectedAccountId = nil
    }
    
    // MARK: - Statistics
    
    private func updateStatistics() async {
        do {
            let income = try await repository.getTotalIncome(for: selectedPeriod)
            let expenses = try await repository.getTotalExpenses(for: selectedPeriod)
            let expensesMap = try await repository.getExpensesByCategory(for: selectedPeriod)
            let incomeMap = try await repository.getIncomeByCategory(for: selectedPeriod)
            
            totalIncome = income
            totalExpenses = expenses
            balance = income - expenses
            expensesByCategory = expensesMap
            incomeByCategory = incomeMap
        } catch {
            print("Error updating statistics: \(error)")
        }
    }
    
    func updateStatisticsForPeriod(_ period: TransactionPeriod) async {
        do {
            let income = try await repository.getTotalIncome(for: period)
            let expenses = try await repository.getTotalExpenses(for: period)
            
            totalIncome = income
            totalExpenses = expenses
            balance = income - expenses
        } catch {
            print("Error updating statistics for period: \(error)")
        }
    }
    
    // MARK: - UI Actions
    
    func selectTransaction(_ transaction: Transaction) {
        selectedTransaction = transaction
        if UIDevice.current.userInterfaceIdiom == .pad {
            // On iPad, NavigationState will handle detail view presentation
            print("TransactionViewModel: iPad - selected transaction \(transaction.description)")
        } else {
            showingTransactionDetail = true
        }
    }
    
    func showAddTransaction() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // On iPad, NavigationState will handle detail view presentation
            print("TransactionViewModel: iPad - showing add transaction")
        } else {
            showingAddTransaction = true
        }
    }
    
    func dismissAddTransaction() {
        showingAddTransaction = false
    }
    
    func dismissTransactionDetail() {
        showingTransactionDetail = false
        selectedTransaction = nil
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Computed Properties
    
    var hasTransactions: Bool {
        !transactions.isEmpty
    }
    
    var hasFilteredTransactions: Bool {
        !filteredTransactions.isEmpty
    }
    
    var formattedTotalIncome: String {
        formatCurrency(totalIncome)
    }
    
    var formattedTotalExpenses: String {
        formatCurrency(totalExpenses)
    }
    
    var formattedBalance: String {
        formatCurrency(balance)
    }
    
    var isFiltered: Bool {
        !searchQuery.isEmpty || 
        selectedPeriod != .all || 
        selectedCategory != nil || 
        selectedType != nil || 
        selectedAccountId != nil
    }
    
    // MARK: - Helper Methods
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
    }
    
    private func getDateRange(for period: TransactionPeriod) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? now
            return (startOfDay, endOfDay)
            
        case .thisWeek:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
            return (startOfWeek, endOfWeek)
            
        case .thisMonth:
            let startOfMonth = calendar.startOfMonth(for: now) ?? now
            let endOfMonth = calendar.endOfMonth(for: now) ?? now
            return (startOfMonth, endOfMonth)
            
        case .all:
            let distantPast = calendar.date(byAdding: .year, value: -10, to: now) ?? now
            let distantFuture = calendar.date(byAdding: .year, value: 1, to: now) ?? now
            return (distantPast, distantFuture)
        }
    }
}