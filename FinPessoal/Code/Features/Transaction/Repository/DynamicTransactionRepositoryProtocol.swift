//
//  DynamicTransactionRepositoryProtocol.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import Foundation

protocol DynamicTransactionRepositoryProtocol {
    // MARK: - Transaction Operations
    func getTransactions() async throws -> [DynamicTransaction]
    func getTransactions(forAccount accountId: String) async throws -> [DynamicTransaction]
    func getTransactions(forCategory categoryId: String) async throws -> [DynamicTransaction]
    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [DynamicTransaction]
    func getTransaction(by id: String) async throws -> DynamicTransaction?
    func createTransaction(_ transaction: DynamicTransaction) async throws -> DynamicTransaction
    func updateTransaction(_ transaction: DynamicTransaction) async throws -> DynamicTransaction
    func deleteTransaction(id: String) async throws
    
    // MARK: - Analytics and Filtering
    func getTransactionsByType(_ type: TransactionType) async throws -> [DynamicTransaction]
    func getTransactionsByCategory(_ categoryId: String, from startDate: Date, to endDate: Date) async throws -> [DynamicTransaction]
    func getTransactionsBySubcategory(_ subcategoryId: String, from startDate: Date, to endDate: Date) async throws -> [DynamicTransaction]
    func getTotalAmount(forCategory categoryId: String, from startDate: Date, to endDate: Date) async throws -> Double
    func getTotalAmount(forType type: TransactionType, from startDate: Date, to endDate: Date) async throws -> Double
    
    // MARK: - Recurring Transactions
    func getRecurringTransactions() async throws -> [DynamicTransaction]
    func createRecurringTransaction(_ transaction: DynamicTransaction, frequency: RecurringFrequency, endDate: Date?) async throws -> [DynamicTransaction]
    
    // MARK: - Migration Support
    func migrateLegacyTransaction(_ legacyTransaction: Transaction, categoryMapping: [TransactionCategory: String], subcategoryMapping: [TransactionSubcategory: String]) async throws -> DynamicTransaction
    func migrateAllLegacyTransactions(categoryMapping: [TransactionCategory: String], subcategoryMapping: [TransactionSubcategory: String]) async throws -> [DynamicTransaction]
}

enum RecurringFrequency: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .daily: return String(localized: "transaction.recurring.daily")
        case .weekly: return String(localized: "transaction.recurring.weekly")
        case .monthly: return String(localized: "transaction.recurring.monthly")
        case .yearly: return String(localized: "transaction.recurring.yearly")
        }
    }
    
    var calendarComponent: Calendar.Component {
        switch self {
        case .daily: return .day
        case .weekly: return .weekOfYear
        case .monthly: return .month
        case .yearly: return .year
        }
    }
}