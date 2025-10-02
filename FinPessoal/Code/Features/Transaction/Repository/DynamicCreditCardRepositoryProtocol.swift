//
//  DynamicCreditCardRepositoryProtocol.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import Foundation

protocol DynamicCreditCardRepositoryProtocol {
    // MARK: - Credit Card Transaction Operations
    func getCreditCardTransactions() async throws -> [DynamicCreditCardTransaction]
    func getCreditCardTransactions(forCreditCard creditCardId: String) async throws -> [DynamicCreditCardTransaction]
    func getCreditCardTransactions(forCategory categoryId: String) async throws -> [DynamicCreditCardTransaction]
    func getCreditCardTransactions(from startDate: Date, to endDate: Date) async throws -> [DynamicCreditCardTransaction]
    func getCreditCardTransaction(by id: String) async throws -> DynamicCreditCardTransaction?
    func createCreditCardTransaction(_ transaction: DynamicCreditCardTransaction) async throws -> DynamicCreditCardTransaction
    func updateCreditCardTransaction(_ transaction: DynamicCreditCardTransaction) async throws -> DynamicCreditCardTransaction
    func deleteCreditCardTransaction(id: String) async throws
    
    // MARK: - Installment Management
    func getCreditCardTransactionsWithInstallments() async throws -> [DynamicCreditCardTransaction]
    func getCreditCardTransactions(installmentNumber: Int) async throws -> [DynamicCreditCardTransaction]
    func getNextInstallments(from date: Date, limit: Int) async throws -> [DynamicCreditCardTransaction]
    
    // MARK: - Credit Card Specific Analytics
    func getCreditCardTransactionsByType(_ type: TransactionType) async throws -> [DynamicCreditCardTransaction]
    func getCreditCardTransactionsByCategory(_ categoryId: String, from startDate: Date, to endDate: Date) async throws -> [DynamicCreditCardTransaction]
    func getCreditCardTransactionsBySubcategory(_ subcategoryId: String, from startDate: Date, to endDate: Date) async throws -> [DynamicCreditCardTransaction]
    func getTotalCreditCardAmount(forCategory categoryId: String, from startDate: Date, to endDate: Date) async throws -> Double
    func getTotalCreditCardAmount(forType type: TransactionType, from startDate: Date, to endDate: Date) async throws -> Double
    func getTotalCreditCardAmount(forCreditCard creditCardId: String, from startDate: Date, to endDate: Date) async throws -> Double
    
    // MARK: - Statement and Billing
    func getCreditCardTransactionsForBillingCycle(creditCardId: String, billingDate: Date) async throws -> [DynamicCreditCardTransaction]
    func getUnpaidCreditCardTransactions(creditCardId: String) async throws -> [DynamicCreditCardTransaction]
    func markTransactionsAsPaid(transactionIds: [String], paymentDate: Date) async throws
    
    // MARK: - Migration Support
    func migrateLegacyCreditCardTransaction(_ legacyTransaction: CreditCardTransaction, categoryMapping: [TransactionCategory: String], subcategoryMapping: [TransactionSubcategory: String]) async throws -> DynamicCreditCardTransaction
    func migrateAllLegacyCreditCardTransactions(categoryMapping: [TransactionCategory: String], subcategoryMapping: [TransactionSubcategory: String]) async throws -> [DynamicCreditCardTransaction]
}