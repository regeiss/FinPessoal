//
//  MockDynamicTransactionRepository.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import Foundation

class MockDynamicTransactionRepository: DynamicTransactionRepositoryProtocol {
    private var transactions: [DynamicTransaction] = []
    private var accounts: [String: Double] = [:]
    
    init() {
        setupMockData()
    }
    
    // MARK: - Transaction Operations
    
    func getTransactions() async throws -> [DynamicTransaction] {
        return transactions.sorted { $0.date > $1.date }
    }
    
    func getTransactions(for accountId: String) async throws -> [DynamicTransaction] {
        return transactions
            .filter { $0.accountId == accountId }
            .sorted { $0.date > $1.date }
    }
    
    func getTransactions(for categoryId: String) async throws -> [DynamicTransaction] {
        return transactions
            .filter { $0.categoryId == categoryId }
            .sorted { $0.date > $1.date }
    }
    
    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [DynamicTransaction] {
        return transactions
            .filter { $0.date >= startDate && $0.date <= endDate }
            .sorted { $0.date > $1.date }
    }
    
    func getTransaction(by id: String) async throws -> DynamicTransaction? {
        return transactions.first { $0.id == id }
    }
    
    func createTransaction(_ transaction: DynamicTransaction) async throws -> DynamicTransaction {
        let updatedTransaction = DynamicTransaction(
            id: transaction.id,
            accountId: transaction.accountId,
            amount: transaction.amount,
            description: transaction.description,
            categoryId: transaction.categoryId,
            subcategoryId: transaction.subcategoryId,
            type: transaction.type,
            date: transaction.date,
            isRecurring: transaction.isRecurring,
            userId: "mock-user-id",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        transactions.append(updatedTransaction)
        updateAccountBalanceMock(accountId: transaction.accountId, amount: transaction.amount, type: transaction.type)
        
        return updatedTransaction
    }
    
    func updateTransaction(_ transaction: DynamicTransaction) async throws -> DynamicTransaction {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else {
            throw DynamicTransactionError.transactionNotFound
        }
        
        let originalTransaction = transactions[index]
        
        let updatedTransaction = DynamicTransaction(
            id: transaction.id,
            accountId: transaction.accountId,
            amount: transaction.amount,
            description: transaction.description,
            categoryId: transaction.categoryId,
            subcategoryId: transaction.subcategoryId,
            type: transaction.type,
            date: transaction.date,
            isRecurring: transaction.isRecurring,
            userId: transaction.userId,
            createdAt: transaction.createdAt,
            updatedAt: Date()
        )
        
        transactions[index] = updatedTransaction
        
        // Reverse original transaction effect and apply new one
        let reversalAmount = originalTransaction.type == .income ? -originalTransaction.amount : originalTransaction.amount
        updateAccountBalanceMock(accountId: originalTransaction.accountId, amount: reversalAmount, type: .expense)
        updateAccountBalanceMock(accountId: updatedTransaction.accountId, amount: updatedTransaction.amount, type: updatedTransaction.type)
        
        return updatedTransaction
    }
    
    func deleteTransaction(id: String) async throws {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else {
            throw DynamicTransactionError.transactionNotFound
        }
        
        let transaction = transactions[index]
        
        // Reverse account balance change
        let reversalAmount = transaction.type == .income ? -transaction.amount : transaction.amount
        updateAccountBalanceMock(accountId: transaction.accountId, amount: reversalAmount, type: .expense)
        
        transactions.remove(at: index)
    }
    
    // MARK: - Analytics and Filtering
    
    func getTransactionsByType(_ type: TransactionType) async throws -> [DynamicTransaction] {
        return transactions
            .filter { $0.type == type }
            .sorted { $0.date > $1.date }
    }
    
    func getTransactionsByCategory(_ categoryId: String, from startDate: Date, to endDate: Date) async throws -> [DynamicTransaction] {
        return transactions
            .filter { $0.categoryId == categoryId && $0.date >= startDate && $0.date <= endDate }
            .sorted { $0.date > $1.date }
    }
    
    func getTransactionsBySubcategory(_ subcategoryId: String, from startDate: Date, to endDate: Date) async throws -> [DynamicTransaction] {
        return transactions
            .filter { $0.subcategoryId == subcategoryId && $0.date >= startDate && $0.date <= endDate }
            .sorted { $0.date > $1.date }
    }
    
    func getTotalAmount(for categoryId: String, from startDate: Date, to endDate: Date) async throws -> Double {
        let categoryTransactions = try await getTransactionsByCategory(categoryId, from: startDate, to: endDate)
        return categoryTransactions.reduce(0) { total, transaction in
            total + (transaction.type == .income ? transaction.amount : -transaction.amount)
        }
    }
    
    func getTotalAmount(for type: TransactionType, from startDate: Date, to endDate: Date) async throws -> Double {
        return transactions
            .filter { $0.type == type && $0.date >= startDate && $0.date <= endDate }
            .reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Recurring Transactions
    
    func getRecurringTransactions() async throws -> [DynamicTransaction] {
        return transactions
            .filter { $0.isRecurring }
            .sorted { $0.date > $1.date }
    }
    
    func createRecurringTransaction(_ transaction: DynamicTransaction, frequency: RecurringFrequency, endDate: Date?) async throws -> [DynamicTransaction] {
        var createdTransactions: [DynamicTransaction] = []
        let calendar = Calendar.current
        var currentDate = transaction.date
        let finalEndDate = endDate ?? calendar.date(byAdding: .year, value: 1, to: transaction.date) ?? transaction.date
        
        while currentDate <= finalEndDate {
            let recurringTransaction = DynamicTransaction(
                id: UUID().uuidString,
                accountId: transaction.accountId,
                amount: transaction.amount,
                description: transaction.description,
                categoryId: transaction.categoryId,
                subcategoryId: transaction.subcategoryId,
                type: transaction.type,
                date: currentDate,
                isRecurring: true,
                userId: transaction.userId
            )
            
            let createdTransaction = try await createTransaction(recurringTransaction)
            createdTransactions.append(createdTransaction)
            
            guard let nextDate = calendar.date(byAdding: frequency.calendarComponent, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return createdTransactions
    }
    
    // MARK: - Migration Support
    
    func migrateLegacyTransaction(_ legacyTransaction: Transaction, categoryMapping: [TransactionCategory: String], subcategoryMapping: [TransactionSubcategory: String]) async throws -> DynamicTransaction {
        guard let dynamicTransaction = DynamicTransaction.from(
            transaction: legacyTransaction,
            categoryMapping: categoryMapping,
            subcategoryMapping: subcategoryMapping
        ) else {
            throw DynamicTransactionError.migrationFailed
        }
        
        return try await createTransaction(dynamicTransaction)
    }
    
    func migrateAllLegacyTransactions(categoryMapping: [TransactionCategory: String], subcategoryMapping: [TransactionSubcategory: String]) async throws -> [DynamicTransaction] {
        // Return empty array for mock implementation
        return []
    }
    
    // MARK: - Helper Methods
    
    private func updateAccountBalanceMock(accountId: String, amount: Double, type: TransactionType) {
        let currentBalance = accounts[accountId] ?? 0.0
        let balanceChange = type == .income ? amount : -amount
        accounts[accountId] = currentBalance + balanceChange
    }
    
    private func setupMockData() {
        let calendar = Calendar.current
        let now = Date()
        
        // Mock account balances
        accounts = [
            "account-1": 5000.0,
            "account-2": 2500.0
        ]
        
        // Mock transactions
        let mockTransactions = [
            DynamicTransaction(
                id: "tx-1",
                accountId: "account-1",
                amount: 150.0,
                description: "Supermercado",
                categoryId: "cat-food",
                subcategoryId: "sub-groceries",
                type: .expense,
                date: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                isRecurring: false,
                userId: "mock-user-id"
            ),
            DynamicTransaction(
                id: "tx-2",
                accountId: "account-1",
                amount: 3000.0,
                description: "Salário",
                categoryId: "cat-salary",
                subcategoryId: nil,
                type: .income,
                date: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                isRecurring: true,
                userId: "mock-user-id"
            ),
            DynamicTransaction(
                id: "tx-3",
                accountId: "account-2",
                amount: 45.0,
                description: "Combustível",
                categoryId: "cat-transport",
                subcategoryId: "sub-fuel",
                type: .expense,
                date: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                isRecurring: false,
                userId: "mock-user-id"
            ),
            DynamicTransaction(
                id: "tx-4",
                accountId: "account-1",
                amount: 80.0,
                description: "Cinema",
                categoryId: "cat-entertainment",
                subcategoryId: "sub-movies",
                type: .expense,
                date: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                isRecurring: false,
                userId: "mock-user-id"
            )
        ]
        
        transactions = mockTransactions
    }
}