//
//  FirebaseDynamicTransactionRepository.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class FirebaseDynamicTransactionRepository: DynamicTransactionRepositoryProtocol {
    private let db = Firestore.firestore()
    private let transactionsCollection = "dynamicTransactions"
    private let accountsCollection = "accounts"
    
    // MARK: - Transaction Operations
    
    func getTransactions() async throws -> [DynamicTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(transactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicTransaction.self)
        }
    }
    
    func getTransactions(for accountId: String) async throws -> [DynamicTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(transactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("accountId", isEqualTo: accountId)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicTransaction.self)
        }
    }
    
    func getTransactions(for categoryId: String) async throws -> [DynamicTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(transactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("categoryId", isEqualTo: categoryId)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicTransaction.self)
        }
    }
    
    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [DynamicTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(transactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicTransaction.self)
        }
    }
    
    func getTransaction(by id: String) async throws -> DynamicTransaction? {
        let document = try await db.collection(transactionsCollection).document(id)
            .getDocument()
        return try document.data(as: DynamicTransaction.self)
    }
    
    func createTransaction(_ transaction: DynamicTransaction) async throws -> DynamicTransaction {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicTransactionError.userNotAuthenticated
        }
        
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
            userId: userId,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Add the transaction document
        try await db.collection(transactionsCollection)
            .document(updatedTransaction.id)
            .setData(from: updatedTransaction)
        
        // Update account balance
        try await updateAccountBalance(accountId: updatedTransaction.accountId, amount: updatedTransaction.amount, type: updatedTransaction.type)
        
        return updatedTransaction
    }
    
    func updateTransaction(_ transaction: DynamicTransaction) async throws -> DynamicTransaction {
        // Get the original transaction to calculate balance difference
        guard let originalTransaction = try await getTransaction(by: transaction.id) else {
            throw DynamicTransactionError.transactionNotFound
        }
        
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
        
        try await db.collection(transactionsCollection)
            .document(updatedTransaction.id)
            .setData(from: updatedTransaction, merge: true)
        
        // Update account balance (reverse original, apply new)
        let reversalAmount = originalTransaction.type == .income ? -originalTransaction.amount : originalTransaction.amount
        try await updateAccountBalance(accountId: originalTransaction.accountId, amount: reversalAmount, type: .expense)
        try await updateAccountBalance(accountId: updatedTransaction.accountId, amount: updatedTransaction.amount, type: updatedTransaction.type)
        
        return updatedTransaction
    }
    
    func deleteTransaction(id: String) async throws {
        guard let transaction = try await getTransaction(by: id) else {
            throw DynamicTransactionError.transactionNotFound
        }
        
        // Reverse the account balance change
        let reversalAmount = transaction.type == .income ? -transaction.amount : transaction.amount
        try await updateAccountBalance(accountId: transaction.accountId, amount: reversalAmount, type: .expense)
        
        // Delete the transaction
        try await db.collection(transactionsCollection).document(id).delete()
    }
    
    // MARK: - Analytics and Filtering
    
    func getTransactionsByType(_ type: TransactionType) async throws -> [DynamicTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(transactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("type", isEqualTo: type.rawValue)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicTransaction.self)
        }
    }
    
    func getTransactionsByCategory(_ categoryId: String, from startDate: Date, to endDate: Date) async throws -> [DynamicTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(transactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("categoryId", isEqualTo: categoryId)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicTransaction.self)
        }
    }
    
    func getTransactionsBySubcategory(_ subcategoryId: String, from startDate: Date, to endDate: Date) async throws -> [DynamicTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(transactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("subcategoryId", isEqualTo: subcategoryId)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicTransaction.self)
        }
    }
    
    func getTotalAmount(for categoryId: String, from startDate: Date, to endDate: Date) async throws -> Double {
        let transactions = try await getTransactionsByCategory(categoryId, from: startDate, to: endDate)
        return transactions.reduce(0) { total, transaction in
            total + (transaction.type == .income ? transaction.amount : -transaction.amount)
        }
    }
    
    func getTotalAmount(for type: TransactionType, from startDate: Date, to endDate: Date) async throws -> Double {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(transactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("type", isEqualTo: type.rawValue)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .getDocuments()
        
        let transactions = snapshot.documents.compactMap { document in
            try? document.data(as: DynamicTransaction.self)
        }
        
        return transactions.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Recurring Transactions
    
    func getRecurringTransactions() async throws -> [DynamicTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(transactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("isRecurring", isEqualTo: true)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicTransaction.self)
        }
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
        // This would typically fetch from the old transactions collection
        // For now, return empty array as this is a complex migration
        return []
    }
    
    // MARK: - Helper Methods
    
    private func updateAccountBalance(accountId: String, amount: Double, type: TransactionType) async throws {
        let accountRef = db.collection(accountsCollection).document(accountId)
        let accountDoc = try await accountRef.getDocument()
        
        guard let accountData = accountDoc.data(),
              let currentBalance = accountData["balance"] as? Double else {
            throw DynamicTransactionError.accountNotFound
        }
        
        let balanceChange = type == .income ? amount : -amount
        let newBalance = currentBalance + balanceChange
        
        try await accountRef.updateData([
            "balance": newBalance,
            "updatedAt": Date().timeIntervalSince1970
        ])
    }
}

enum DynamicTransactionError: LocalizedError {
    case userNotAuthenticated
    case transactionNotFound
    case accountNotFound
    case invalidData
    case migrationFailed
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return String(localized: "transaction.error.not_authenticated")
        case .transactionNotFound:
            return String(localized: "transaction.error.not_found")
        case .accountNotFound:
            return String(localized: "transaction.error.account_not_found")
        case .invalidData:
            return String(localized: "transaction.error.invalid_data")
        case .migrationFailed:
            return String(localized: "transaction.error.migration_failed")
        case .networkError(let error):
            return String(localized: "transaction.error.network") + ": \(error.localizedDescription)"
        }
    }
}