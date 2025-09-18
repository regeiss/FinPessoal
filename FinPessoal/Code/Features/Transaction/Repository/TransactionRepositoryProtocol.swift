//
//  TransactionRepositoryProtocol.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 31/08/25.
//

import Foundation

protocol TransactionRepositoryProtocol {
    // MARK: - Basic CRUD Operations
    func getTransactions() async throws -> [Transaction]
    func getTransaction(by id: String) async throws -> Transaction?
    func addTransaction(_ transaction: Transaction) async throws
    func updateTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(_ transactionId: String) async throws
    
    // MARK: - Query Operations
    func getTransactions(for accountId: String) async throws -> [Transaction]
    func getTransactions(by category: TransactionCategory) async throws -> [Transaction]
    func getTransactions(by type: TransactionType) async throws -> [Transaction]
    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction]
    func getTransactions(for period: TransactionPeriod) async throws -> [Transaction]
    
    // MARK: - Statistics Operations
    func getTotalIncome(for period: TransactionPeriod) async throws -> Double
    func getTotalExpenses(for period: TransactionPeriod) async throws -> Double
    func getBalance(for period: TransactionPeriod) async throws -> Double
    func getExpensesByCategory(for period: TransactionPeriod) async throws -> [TransactionCategory: Double]
    func getIncomeByCategory(for period: TransactionPeriod) async throws -> [TransactionCategory: Double]
    
    // MARK: - Recent Transactions
    func getRecentTransactions(limit: Int) async throws -> [Transaction]
    func getRecentTransactions(for accountId: String, limit: Int) async throws -> [Transaction]
    
    // MARK: - Search and Filter
    func searchTransactions(query: String) async throws -> [Transaction]
    func getTransactionsWithFilters(
        accountId: String?,
        category: TransactionCategory?,
        type: TransactionType?,
        startDate: Date?,
        endDate: Date?,
        minAmount: Double?,
        maxAmount: Double?
    ) async throws -> [Transaction]
    
    // MARK: - Recurring Transactions
    func getRecurringTransactions() async throws -> [Transaction]
    func markAsRecurring(_ transactionId: String, isRecurring: Bool) async throws
    
    // MARK: - Import Operations
    func importTransactions(_ transactions: [Transaction]) async throws
    func checkDuplicateTransactions(_ transactions: [Transaction]) async throws -> [Transaction]
    func bulkAddTransactions(_ transactions: [Transaction]) async throws -> (successful: [Transaction], failed: [ImportError])
}