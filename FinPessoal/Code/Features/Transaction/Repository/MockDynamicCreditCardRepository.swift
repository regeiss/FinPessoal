//
//  MockDynamicCreditCardRepository.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import Foundation

class MockDynamicCreditCardRepository: DynamicCreditCardRepositoryProtocol {
    private var creditCardTransactions: [DynamicCreditCardTransaction] = []
    
    init() {
        setupMockData()
    }
    
    // MARK: - Credit Card Transaction Operations
    
    func getCreditCardTransactions() async throws -> [DynamicCreditCardTransaction] {
        return creditCardTransactions.sorted { $0.date > $1.date }
    }
    
    func getCreditCardTransactions(forCreditCard creditCardId: String) async throws -> [DynamicCreditCardTransaction] {
        return creditCardTransactions
            .filter { $0.creditCardId == creditCardId }
            .sorted { $0.date > $1.date }
    }
    
    func getCreditCardTransactions(forCategory categoryId: String) async throws -> [DynamicCreditCardTransaction] {
        return creditCardTransactions
            .filter { $0.categoryId == categoryId }
            .sorted { $0.date > $1.date }
    }
    
    func getCreditCardTransactions(from startDate: Date, to endDate: Date) async throws -> [DynamicCreditCardTransaction] {
        return creditCardTransactions
            .filter { $0.date >= startDate && $0.date <= endDate }
            .sorted { $0.date > $1.date }
    }
    
    func getCreditCardTransaction(by id: String) async throws -> DynamicCreditCardTransaction? {
        return creditCardTransactions.first { $0.id == id }
    }
    
    func createCreditCardTransaction(_ transaction: DynamicCreditCardTransaction) async throws -> DynamicCreditCardTransaction {
        let updatedTransaction = DynamicCreditCardTransaction(
            id: transaction.id,
            creditCardId: transaction.creditCardId,
            amount: transaction.amount,
            description: transaction.description,
            categoryId: transaction.categoryId,
            subcategoryId: transaction.subcategoryId,
            type: transaction.type,
            date: transaction.date,
            dueDate: transaction.dueDate,
            installments: transaction.installments,
            currentInstallment: transaction.currentInstallment,
            isPaid: transaction.isPaid,
            paymentDate: transaction.paymentDate,
            userId: "mock-user-id",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        creditCardTransactions.append(updatedTransaction)
        return updatedTransaction
    }
    
    func updateCreditCardTransaction(_ transaction: DynamicCreditCardTransaction) async throws -> DynamicCreditCardTransaction {
        guard let index = creditCardTransactions.firstIndex(where: { $0.id == transaction.id }) else {
            throw DynamicCreditCardTransactionError.transactionNotFound
        }
        
        let updatedTransaction = DynamicCreditCardTransaction(
            id: transaction.id,
            creditCardId: transaction.creditCardId,
            amount: transaction.amount,
            description: transaction.description,
            categoryId: transaction.categoryId,
            subcategoryId: transaction.subcategoryId,
            type: transaction.type,
            date: transaction.date,
            dueDate: transaction.dueDate,
            installments: transaction.installments,
            currentInstallment: transaction.currentInstallment,
            isPaid: transaction.isPaid,
            paymentDate: transaction.paymentDate,
            userId: transaction.userId,
            createdAt: transaction.createdAt,
            updatedAt: Date()
        )
        
        creditCardTransactions[index] = updatedTransaction
        return updatedTransaction
    }
    
    func deleteCreditCardTransaction(id: String) async throws {
        guard let index = creditCardTransactions.firstIndex(where: { $0.id == id }) else {
            throw DynamicCreditCardTransactionError.transactionNotFound
        }
        
        creditCardTransactions.remove(at: index)
    }
    
    // MARK: - Installment Management
    
    func getCreditCardTransactionsWithInstallments() async throws -> [DynamicCreditCardTransaction] {
        return creditCardTransactions
            .filter { $0.installments > 1 }
            .sorted { $0.date > $1.date }
    }
    
    func getCreditCardTransactions(installmentNumber: Int) async throws -> [DynamicCreditCardTransaction] {
        return creditCardTransactions
            .filter { $0.currentInstallment == installmentNumber }
            .sorted { $0.date > $1.date }
    }
    
    func getNextInstallments(from date: Date, limit: Int) async throws -> [DynamicCreditCardTransaction] {
        return creditCardTransactions
            .filter { $0.dueDate >= date && !$0.isPaid }
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Credit Card Specific Analytics
    
    func getCreditCardTransactionsByType(_ type: TransactionType) async throws -> [DynamicCreditCardTransaction] {
        return creditCardTransactions
            .filter { $0.type == type }
            .sorted { $0.date > $1.date }
    }
    
    func getCreditCardTransactionsByCategory(_ categoryId: String, from startDate: Date, to endDate: Date) async throws -> [DynamicCreditCardTransaction] {
        return creditCardTransactions
            .filter { $0.categoryId == categoryId && $0.date >= startDate && $0.date <= endDate }
            .sorted { $0.date > $1.date }
    }
    
    func getCreditCardTransactionsBySubcategory(_ subcategoryId: String, from startDate: Date, to endDate: Date) async throws -> [DynamicCreditCardTransaction] {
        return creditCardTransactions
            .filter { $0.subcategoryId == subcategoryId && $0.date >= startDate && $0.date <= endDate }
            .sorted { $0.date > $1.date }
    }
    
    func getTotalCreditCardAmount(forCategory categoryId: String, from startDate: Date, to endDate: Date) async throws -> Double {
        let categoryTransactions = try await getCreditCardTransactionsByCategory(categoryId, from: startDate, to: endDate)
        return categoryTransactions.reduce(0) { total, transaction in
            total + (transaction.type == .income ? transaction.amount : -transaction.amount)
        }
    }
    
    func getTotalCreditCardAmount(forType type: TransactionType, from startDate: Date, to endDate: Date) async throws -> Double {
        return creditCardTransactions
            .filter { $0.type == type && $0.date >= startDate && $0.date <= endDate }
            .reduce(0) { $0 + $1.amount }
    }
    
    func getTotalCreditCardAmount(forCreditCard creditCardId: String, from startDate: Date, to endDate: Date) async throws -> Double {
        return creditCardTransactions
            .filter { $0.creditCardId == creditCardId && $0.date >= startDate && $0.date <= endDate }
            .reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Statement and Billing
    
    func getCreditCardTransactionsForBillingCycle(creditCardId: String, billingDate: Date) async throws -> [DynamicCreditCardTransaction] {
        let calendar = Calendar.current
        let startOfBilling = calendar.date(byAdding: .month, value: -1, to: billingDate) ?? billingDate
        
        return creditCardTransactions
            .filter { $0.creditCardId == creditCardId && $0.date > startOfBilling && $0.date <= billingDate }
            .sorted { $0.date > $1.date }
    }
    
    func getUnpaidCreditCardTransactions(creditCardId: String) async throws -> [DynamicCreditCardTransaction] {
        return creditCardTransactions
            .filter { $0.creditCardId == creditCardId && !$0.isPaid }
            .sorted { $0.dueDate < $1.dueDate }
    }
    
    func markTransactionsAsPaid(transactionIds: [String], paymentDate: Date) async throws {
        for transactionId in transactionIds {
            if let index = creditCardTransactions.firstIndex(where: { $0.id == transactionId }) {
                var transaction = creditCardTransactions[index]
                transaction = DynamicCreditCardTransaction(
                    id: transaction.id,
                    creditCardId: transaction.creditCardId,
                    amount: transaction.amount,
                    description: transaction.description,
                    categoryId: transaction.categoryId,
                    subcategoryId: transaction.subcategoryId,
                    type: transaction.type,
                    date: transaction.date,
                    dueDate: transaction.dueDate,
                    installments: transaction.installments,
                    currentInstallment: transaction.currentInstallment,
                    isPaid: true,
                    paymentDate: paymentDate,
                    userId: transaction.userId,
                    createdAt: transaction.createdAt,
                    updatedAt: Date()
                )
                creditCardTransactions[index] = transaction
            }
        }
    }
    
    // MARK: - Migration Support
    
    func migrateLegacyCreditCardTransaction(_ legacyTransaction: CreditCardTransaction, categoryMapping: [TransactionCategory: String], subcategoryMapping: [TransactionSubcategory: String]) async throws -> DynamicCreditCardTransaction {
        guard let dynamicTransaction = DynamicCreditCardTransaction.from(
            creditCardTransaction: legacyTransaction,
            categoryMapping: categoryMapping,
            subcategoryMapping: subcategoryMapping
        ) else {
            throw DynamicCreditCardTransactionError.migrationFailed
        }
        
        return try await createCreditCardTransaction(dynamicTransaction)
    }
    
    func migrateAllLegacyCreditCardTransactions(categoryMapping: [TransactionCategory: String], subcategoryMapping: [TransactionSubcategory: String]) async throws -> [DynamicCreditCardTransaction] {
        // Return empty array for mock implementation
        return []
    }
    
    // MARK: - Helper Methods
    
    private func setupMockData() {
        let calendar = Calendar.current
        let now = Date()
        
        let mockTransactions = [
            DynamicCreditCardTransaction(
                id: "cc-tx-1",
                creditCardId: "cc-1",
                amount: 299.90,
                description: "Compras Online",
                categoryId: "cat-shopping",
                subcategoryId: "sub-online-shopping",
                type: .expense,
                date: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                dueDate: calendar.date(byAdding: .day, value: 28, to: now) ?? now,
                installments: 1,
                currentInstallment: 1,
                isPaid: false,
                paymentDate: nil,
                userId: "mock-user-id"
            ),
            DynamicCreditCardTransaction(
                id: "cc-tx-2",
                creditCardId: "cc-1",
                amount: 1200.00,
                description: "Celular - Parcela 1/12",
                categoryId: "cat-electronics",
                subcategoryId: "sub-smartphone",
                type: .expense,
                date: calendar.date(byAdding: .day, value: -10, to: now) ?? now,
                dueDate: calendar.date(byAdding: .day, value: 20, to: now) ?? now,
                installments: 12,
                currentInstallment: 1,
                isPaid: false,
                paymentDate: nil,
                userId: "mock-user-id"
            ),
            DynamicCreditCardTransaction(
                id: "cc-tx-3",
                creditCardId: "cc-2",
                amount: 89.50,
                description: "Restaurante",
                categoryId: "cat-food",
                subcategoryId: "sub-restaurant",
                type: .expense,
                date: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                dueDate: calendar.date(byAdding: .day, value: 29, to: now) ?? now,
                installments: 1,
                currentInstallment: 1,
                isPaid: false,
                paymentDate: nil,
                userId: "mock-user-id"
            ),
            DynamicCreditCardTransaction(
                id: "cc-tx-4",
                creditCardId: "cc-1",
                amount: 450.00,
                description: "Curso Online - Parcela 2/6",
                categoryId: "cat-education",
                subcategoryId: "sub-online-course",
                type: .expense,
                date: calendar.date(byAdding: .day, value: -15, to: now) ?? now,
                dueDate: calendar.date(byAdding: .day, value: 15, to: now) ?? now,
                installments: 6,
                currentInstallment: 2,
                isPaid: true,
                paymentDate: calendar.date(byAdding: .day, value: 15, to: now),
                userId: "mock-user-id"
            )
        ]
        
        creditCardTransactions = mockTransactions
    }
}