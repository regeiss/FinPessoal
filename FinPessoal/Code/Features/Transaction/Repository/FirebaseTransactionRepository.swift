//
//  FirebaseTransactionRepository.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 31/08/25.
//

import Foundation
import FirebaseAuth

class FirebaseTransactionRepository: TransactionRepositoryProtocol {
    private let firebaseService = FirebaseService.shared
    
    private func getCurrentUserID() throws -> String {
        guard let user = Auth.auth().currentUser else {
            print("FirebaseTransactionRepository: No current user found")
            throw AuthError.noCurrentUser
        }
        print("FirebaseTransactionRepository: Current user ID: \(user.uid)")
        return user.uid
    }
    
    // MARK: - Basic CRUD Operations
    
    func getTransactions() async throws -> [Transaction] {
        do {
            let userID = try getCurrentUserID()
            return try await firebaseService.getTransactions(for: userID)
        } catch let authError as AuthError {
            // Re-throw authentication errors as-is so they can be handled properly
            throw authError
        } catch {
            // Check if this is an offline error for a new user
            let errorMessage = error.localizedDescription.lowercased()
            if errorMessage.contains("offline") || errorMessage.contains("no active listeners") {
                // Try to initialize the user node and retry once
                do {
                    let userID = try getCurrentUserID()
                    print("FirebaseTransactionRepository: Attempting to initialize user node due to offline error")
                    try await firebaseService.initializeUserTransactionsNode(for: userID)
                    
                    // Retry the fetch once
                    return try await firebaseService.getTransactions(for: userID)
                } catch {
                    print("FirebaseTransactionRepository: Initialization retry failed, returning empty array")
                    // If initialization fails, return empty array instead of error for new users
                    return []
                }
            }
            
            // For other errors, convert to Firebase errors
            throw FirebaseError.from(error)
        }
    }
    
    func getTransaction(by id: String) async throws -> Transaction? {
        let transactions = try await getTransactions()
        return transactions.first { $0.id == id }
    }
    
    func addTransaction(_ transaction: Transaction) async throws {
        let userID = try getCurrentUserID()
        let newTransaction = Transaction(
            id: transaction.id,
            accountId: transaction.accountId,
            amount: transaction.amount,
            description: transaction.description,
            category: transaction.category,
            type: transaction.type,
            date: transaction.date,
            isRecurring: transaction.isRecurring,
            userId: userID,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            try await firebaseService.saveTransaction(newTransaction, for: userID)
        } catch {
            throw FirebaseError.from(error)
        }
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        let userID = try getCurrentUserID()
        let updatedTransaction = Transaction(
            id: transaction.id,
            accountId: transaction.accountId,
            amount: transaction.amount,
            description: transaction.description,
            category: transaction.category,
            type: transaction.type,
            date: transaction.date,
            isRecurring: transaction.isRecurring,
            userId: transaction.userId,
            createdAt: transaction.createdAt,
            updatedAt: Date()
        )
        
        do {
            try await firebaseService.updateTransaction(updatedTransaction, for: userID)
        } catch {
            throw FirebaseError.from(error)
        }
    }
    
    func deleteTransaction(_ transactionId: String) async throws {
        let userID = try getCurrentUserID()
        
        do {
            try await firebaseService.deleteTransaction(transactionId, for: userID)
        } catch {
            throw FirebaseError.from(error)
        }
    }
    
    // MARK: - Query Operations
    
    func getTransactions(for accountId: String) async throws -> [Transaction] {
        let userID = try getCurrentUserID()
        
        do {
            return try await firebaseService.getTransactionsByAccount(accountId, for: userID)
        } catch {
            throw FirebaseError.from(error)
        }
    }
    
    func getTransactions(by category: TransactionCategory) async throws -> [Transaction] {
        let userID = try getCurrentUserID()
        
        do {
            return try await firebaseService.getTransactionsByCategory(category, for: userID)
        } catch {
            throw FirebaseError.from(error)
        }
    }
    
    func getTransactions(by type: TransactionType) async throws -> [Transaction] {
        let transactions = try await getTransactions()
        return transactions.filter { $0.type == type }
    }
    
    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        let transactions = try await getTransactions()
        return transactions.filter { transaction in
            transaction.date >= startDate && transaction.date <= endDate
        }
    }
    
    func getTransactions(for period: TransactionPeriod) async throws -> [Transaction] {
        let transactions = try await getTransactions()
        let dateRange = getDateRange(for: period)
        
        return transactions.filter { transaction in
            transaction.date >= dateRange.start && transaction.date <= dateRange.end
        }
    }
    
    // MARK: - Statistics Operations
    
    func getTotalIncome(for period: TransactionPeriod) async throws -> Double {
        let transactions = try await getTransactions(for: period)
        return transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    func getTotalExpenses(for period: TransactionPeriod) async throws -> Double {
        let transactions = try await getTransactions(for: period)
        return transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    func getBalance(for period: TransactionPeriod) async throws -> Double {
        let income = try await getTotalIncome(for: period)
        let expenses = try await getTotalExpenses(for: period)
        return income - expenses
    }
    
    func getExpensesByCategory(for period: TransactionPeriod) async throws -> [TransactionCategory: Double] {
        let transactions = try await getTransactions(for: period)
        let expenses = transactions.filter { $0.type == .expense }
        
        var result: [TransactionCategory: Double] = [:]
        for transaction in expenses {
            result[transaction.category, default: 0] += transaction.amount
        }
        
        return result
    }
    
    func getIncomeByCategory(for period: TransactionPeriod) async throws -> [TransactionCategory: Double] {
        let transactions = try await getTransactions(for: period)
        let income = transactions.filter { $0.type == .income }
        
        var result: [TransactionCategory: Double] = [:]
        for transaction in income {
            result[transaction.category, default: 0] += transaction.amount
        }
        
        return result
    }
    
    // MARK: - Recent Transactions
    
    func getRecentTransactions(limit: Int) async throws -> [Transaction] {
        let userID = try getCurrentUserID()
        
        do {
            return try await firebaseService.getTransactions(for: userID, limit: limit)
        } catch {
            throw FirebaseError.from(error)
        }
    }
    
    func getRecentTransactions(for accountId: String, limit: Int) async throws -> [Transaction] {
        let transactions = try await getTransactions(for: accountId)
        return Array(transactions.sorted { $0.date > $1.date }.prefix(limit))
    }
    
    // MARK: - Search and Filter
    
    func searchTransactions(query: String) async throws -> [Transaction] {
        let transactions = try await getTransactions()
        let lowercaseQuery = query.lowercased()
        
        return transactions.filter { transaction in
            transaction.description.lowercased().contains(lowercaseQuery) ||
            transaction.category.displayName.lowercased().contains(lowercaseQuery)
        }
    }
    
    func getTransactionsWithFilters(
        accountId: String?,
        category: TransactionCategory?,
        type: TransactionType?,
        startDate: Date?,
        endDate: Date?,
        minAmount: Double?,
        maxAmount: Double?
    ) async throws -> [Transaction] {
        var transactions = try await getTransactions()
        
        // Apply filters
        if let accountId = accountId {
            transactions = transactions.filter { $0.accountId == accountId }
        }
        
        if let category = category {
            transactions = transactions.filter { $0.category == category }
        }
        
        if let type = type {
            transactions = transactions.filter { $0.type == type }
        }
        
        if let startDate = startDate {
            transactions = transactions.filter { $0.date >= startDate }
        }
        
        if let endDate = endDate {
            transactions = transactions.filter { $0.date <= endDate }
        }
        
        if let minAmount = minAmount {
            transactions = transactions.filter { $0.amount >= minAmount }
        }
        
        if let maxAmount = maxAmount {
            transactions = transactions.filter { $0.amount <= maxAmount }
        }
        
        return transactions
    }
    
    // MARK: - Recurring Transactions
    
    func getRecurringTransactions() async throws -> [Transaction] {
        let transactions = try await getTransactions()
        return transactions.filter { $0.isRecurring }
    }
    
    func markAsRecurring(_ transactionId: String, isRecurring: Bool) async throws {
        guard let transaction = try await getTransaction(by: transactionId) else {
            throw FirebaseError.transactionNotFound
        }
        
        let updatedTransaction = Transaction(
            id: transaction.id,
            accountId: transaction.accountId,
            amount: transaction.amount,
            description: transaction.description,
            category: transaction.category,
            type: transaction.type,
            date: transaction.date,
            isRecurring: isRecurring,
            userId: transaction.userId,
            createdAt: transaction.createdAt,
            updatedAt: Date()
        )
        
        try await updateTransaction(updatedTransaction)
    }
    
    // MARK: - Import Operations
    
    func importTransactions(_ transactions: [Transaction]) async throws {
        let userID = try getCurrentUserID()
        
        for transaction in transactions {
            let newTransaction = Transaction(
                id: transaction.id,
                accountId: transaction.accountId,
                amount: transaction.amount,
                description: transaction.description,
                category: transaction.category,
                type: transaction.type,
                date: transaction.date,
                isRecurring: transaction.isRecurring,
                userId: userID,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            try await firebaseService.saveTransaction(newTransaction, for: userID)
        }
    }
    
    func checkDuplicateTransactions(_ transactions: [Transaction]) async throws -> [Transaction] {
        let existingTransactions = try await getTransactions()
        var duplicates: [Transaction] = []
        
        for transaction in transactions {
            let isDuplicate = existingTransactions.contains { existing in
                existing.accountId == transaction.accountId &&
                abs(existing.amount - transaction.amount) < 0.01 &&
                Calendar.current.isDate(existing.date, inSameDayAs: transaction.date) &&
                existing.description.lowercased().contains(transaction.description.lowercased().prefix(10))
            }
            
            if isDuplicate {
                duplicates.append(transaction)
            }
        }
        
        return duplicates
    }
    
    func bulkAddTransactions(_ transactions: [Transaction]) async throws -> (successful: [Transaction], failed: [ImportError]) {
        var successful: [Transaction] = []
        var failed: [ImportError] = []
        
        for transaction in transactions {
            do {
                try await addTransaction(transaction)
                successful.append(transaction)
            } catch {
                failed.append(ImportError(transaction: transaction, error: error))
            }
        }
        
        return (successful, failed)
    }
    
    // MARK: - Helper Methods
    
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
            // Return a very wide date range for "all" transactions
            let distantPast = calendar.date(byAdding: .year, value: -10, to: now) ?? now
            let distantFuture = calendar.date(byAdding: .year, value: 1, to: now) ?? now
            return (distantPast, distantFuture)
        }
    }
}