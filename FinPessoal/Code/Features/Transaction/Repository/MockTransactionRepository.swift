//
//  MockTransactionRepository.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 31/08/25.
//

import Foundation

class MockTransactionRepository: TransactionRepositoryProtocol {
    private let mockUserId = "mock-user-123"
    private var transactions: [Transaction] = []
    
    init() {
        setupMockData()
    }
    
    private func setupMockData() {
        let baseDate = Date()
        let calendar = Calendar.current
        
        transactions = [
            Transaction(
                id: "trans1",
                accountId: "1", // Conta Principal
                amount: 3500.00,
                description: "Salário Mensal",
                category: .salary,
                type: .income,
                date: calendar.date(byAdding: .day, value: -2, to: baseDate) ?? baseDate,
                isRecurring: true,
                userId: mockUserId,
                createdAt: calendar.date(byAdding: .day, value: -2, to: baseDate) ?? baseDate,
                updatedAt: calendar.date(byAdding: .day, value: -2, to: baseDate) ?? baseDate
            ),
            Transaction(
                id: "trans2",
                accountId: "1",
                amount: 250.50,
                description: "Supermercado Pão de Açúcar",
                category: .food,
                type: .expense,
                date: calendar.date(byAdding: .day, value: -1, to: baseDate) ?? baseDate,
                isRecurring: false,
                userId: mockUserId,
                createdAt: calendar.date(byAdding: .day, value: -1, to: baseDate) ?? baseDate,
                updatedAt: calendar.date(byAdding: .day, value: -1, to: baseDate) ?? baseDate
            ),
            Transaction(
                id: "trans3",
                accountId: "3", // Cartão Nubank
                amount: 80.00,
                description: "Posto Shell - Combustível",
                category: .transport,
                type: .expense,
                date: baseDate,
                isRecurring: false,
                userId: mockUserId,
                createdAt: baseDate,
                updatedAt: baseDate
            ),
            Transaction(
                id: "trans4",
                accountId: "1",
                amount: 1200.00,
                description: "Aluguel Apartamento",
                category: .housing,
                type: .expense,
                date: calendar.date(byAdding: .day, value: -3, to: baseDate) ?? baseDate,
                isRecurring: true,
                userId: mockUserId,
                createdAt: calendar.date(byAdding: .day, value: -3, to: baseDate) ?? baseDate,
                updatedAt: calendar.date(byAdding: .day, value: -3, to: baseDate) ?? baseDate
            ),
            Transaction(
                id: "trans5",
                accountId: "2", // Poupança
                amount: 500.00,
                description: "Aplicação Poupança",
                category: .investment,
                type: .income,
                date: calendar.date(byAdding: .day, value: -5, to: baseDate) ?? baseDate,
                isRecurring: false,
                userId: mockUserId,
                createdAt: calendar.date(byAdding: .day, value: -5, to: baseDate) ?? baseDate,
                updatedAt: calendar.date(byAdding: .day, value: -5, to: baseDate) ?? baseDate
            ),
            Transaction(
                id: "trans6",
                accountId: "1",
                amount: 150.00,
                description: "Restaurante Japonês",
                category: .food,
                type: .expense,
                date: calendar.date(byAdding: .day, value: -1, to: baseDate) ?? baseDate,
                isRecurring: false,
                userId: mockUserId,
                createdAt: calendar.date(byAdding: .day, value: -1, to: baseDate) ?? baseDate,
                updatedAt: calendar.date(byAdding: .day, value: -1, to: baseDate) ?? baseDate
            ),
            Transaction(
                id: "trans7",
                accountId: "1",
                amount: 45.00,
                description: "Uber - Centro",
                category: .transport,
                type: .expense,
                date: calendar.date(byAdding: .day, value: -2, to: baseDate) ?? baseDate,
                isRecurring: false,
                userId: mockUserId,
                createdAt: calendar.date(byAdding: .day, value: -2, to: baseDate) ?? baseDate,
                updatedAt: calendar.date(byAdding: .day, value: -2, to: baseDate) ?? baseDate
            ),
            Transaction(
                id: "trans8",
                accountId: "1",
                amount: 200.00,
                description: "Cinema Shopping",
                category: .entertainment,
                type: .expense,
                date: calendar.date(byAdding: .day, value: -4, to: baseDate) ?? baseDate,
                isRecurring: false,
                userId: mockUserId,
                createdAt: calendar.date(byAdding: .day, value: -4, to: baseDate) ?? baseDate,
                updatedAt: calendar.date(byAdding: .day, value: -4, to: baseDate) ?? baseDate
            ),
            Transaction(
                id: "trans9",
                accountId: "1",
                amount: 320.00,
                description: "Conta de Luz",
                category: .bills,
                type: .expense,
                date: calendar.date(byAdding: .day, value: -6, to: baseDate) ?? baseDate,
                isRecurring: true,
                userId: mockUserId,
                createdAt: calendar.date(byAdding: .day, value: -6, to: baseDate) ?? baseDate,
                updatedAt: calendar.date(byAdding: .day, value: -6, to: baseDate) ?? baseDate
            ),
            Transaction(
                id: "trans10",
                accountId: "1",
                amount: 180.00,
                description: "Farmácia - Medicamentos",
                category: .healthcare,
                type: .expense,
                date: calendar.date(byAdding: .day, value: -3, to: baseDate) ?? baseDate,
                isRecurring: false,
                userId: mockUserId,
                createdAt: calendar.date(byAdding: .day, value: -3, to: baseDate) ?? baseDate,
                updatedAt: calendar.date(byAdding: .day, value: -3, to: baseDate) ?? baseDate
            ),
            Transaction(
                id: "trans11",
                accountId: "4", // Investimentos
                amount: 1000.00,
                description: "Dividendos Ações",
                category: .investment,
                type: .income,
                date: calendar.date(byAdding: .day, value: -7, to: baseDate) ?? baseDate,
                isRecurring: false,
                userId: mockUserId,
                createdAt: calendar.date(byAdding: .day, value: -7, to: baseDate) ?? baseDate,
                updatedAt: calendar.date(byAdding: .day, value: -7, to: baseDate) ?? baseDate
            ),
            Transaction(
                id: "trans12",
                accountId: "1",
                amount: 89.90,
                description: "Compras Online - Amazon",
                category: .shopping,
                type: .expense,
                date: calendar.date(byAdding: .day, value: -8, to: baseDate) ?? baseDate,
                isRecurring: false,
                userId: mockUserId,
                createdAt: calendar.date(byAdding: .day, value: -8, to: baseDate) ?? baseDate,
                updatedAt: calendar.date(byAdding: .day, value: -8, to: baseDate) ?? baseDate
            )
        ]
    }
    
    // MARK: - Basic CRUD Operations
    
    func getTransactions() async throws -> [Transaction] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return transactions.sorted { $0.date > $1.date }
    }
    
    func getTransaction(by id: String) async throws -> Transaction? {
        try await Task.sleep(nanoseconds: 200_000_000)
        return transactions.first { $0.id == id }
    }
    
    func addTransaction(_ transaction: Transaction) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let newTransaction = Transaction(
            id: transaction.id.isEmpty ? UUID().uuidString : transaction.id,
            accountId: transaction.accountId,
            amount: transaction.amount,
            description: transaction.description,
            category: transaction.category,
            type: transaction.type,
            date: transaction.date,
            isRecurring: transaction.isRecurring,
            userId: mockUserId,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        transactions.append(newTransaction)
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else {
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
            isRecurring: transaction.isRecurring,
            userId: transaction.userId,
            createdAt: transaction.createdAt,
            updatedAt: Date()
        )
        
        transactions[index] = updatedTransaction
    }
    
    func deleteTransaction(_ transactionId: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        transactions.removeAll { $0.id == transactionId }
    }
    
    // MARK: - Query Operations
    
    func getTransactions(for accountId: String) async throws -> [Transaction] {
        try await Task.sleep(nanoseconds: 250_000_000)
        return transactions.filter { $0.accountId == accountId }.sorted { $0.date > $1.date }
    }
    
    func getTransactions(by category: TransactionCategory) async throws -> [Transaction] {
        try await Task.sleep(nanoseconds: 250_000_000)
        return transactions.filter { $0.category == category }.sorted { $0.date > $1.date }
    }
    
    func getTransactions(by type: TransactionType) async throws -> [Transaction] {
        try await Task.sleep(nanoseconds: 250_000_000)
        return transactions.filter { $0.type == type }.sorted { $0.date > $1.date }
    }
    
    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        try await Task.sleep(nanoseconds: 250_000_000)
        return transactions.filter { transaction in
            transaction.date >= startDate && transaction.date <= endDate
        }.sorted { $0.date > $1.date }
    }
    
    func getTransactions(for period: TransactionPeriod) async throws -> [Transaction] {
        let dateRange = getDateRange(for: period)
        return try await getTransactions(from: dateRange.start, to: dateRange.end)
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
        let allTransactions = try await getTransactions()
        return Array(allTransactions.prefix(limit))
    }
    
    func getRecentTransactions(for accountId: String, limit: Int) async throws -> [Transaction] {
        let accountTransactions = try await getTransactions(for: accountId)
        return Array(accountTransactions.prefix(limit))
    }
    
    // MARK: - Search and Filter
    
    func searchTransactions(query: String) async throws -> [Transaction] {
        try await Task.sleep(nanoseconds: 200_000_000)
        let lowercaseQuery = query.lowercased()
        
        return transactions.filter { transaction in
            transaction.description.lowercased().contains(lowercaseQuery) ||
            transaction.category.displayName.lowercased().contains(lowercaseQuery)
        }.sorted { $0.date > $1.date }
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
        try await Task.sleep(nanoseconds: 250_000_000)
        
        var filtered = transactions
        
        if let accountId = accountId {
            filtered = filtered.filter { $0.accountId == accountId }
        }
        
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        if let type = type {
            filtered = filtered.filter { $0.type == type }
        }
        
        if let startDate = startDate {
            filtered = filtered.filter { $0.date >= startDate }
        }
        
        if let endDate = endDate {
            filtered = filtered.filter { $0.date <= endDate }
        }
        
        if let minAmount = minAmount {
            filtered = filtered.filter { $0.amount >= minAmount }
        }
        
        if let maxAmount = maxAmount {
            filtered = filtered.filter { $0.amount <= maxAmount }
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    // MARK: - Recurring Transactions
    
    func getRecurringTransactions() async throws -> [Transaction] {
        try await Task.sleep(nanoseconds: 200_000_000)
        return transactions.filter { $0.isRecurring }.sorted { $0.date > $1.date }
    }
    
    func markAsRecurring(_ transactionId: String, isRecurring: Bool) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        guard let index = transactions.firstIndex(where: { $0.id == transactionId }) else {
            throw FirebaseError.transactionNotFound
        }
        
        let transaction = transactions[index]
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
        
        transactions[index] = updatedTransaction
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
            let distantPast = calendar.date(byAdding: .year, value: -10, to: now) ?? now
            let distantFuture = calendar.date(byAdding: .year, value: 1, to: now) ?? now
            return (distantPast, distantFuture)
        }
    }
}