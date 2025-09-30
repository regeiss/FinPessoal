//
//  FirebaseDynamicCreditCardRepository.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class FirebaseDynamicCreditCardRepository: DynamicCreditCardRepositoryProtocol {
    private let db = Firestore.firestore()
    private let creditCardTransactionsCollection = "dynamicCreditCardTransactions"
    private let creditCardsCollection = "creditCards"
    
    // MARK: - Credit Card Transaction Operations
    
    func getCreditCardTransactions() async throws -> [DynamicCreditCardTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(creditCardTransactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicCreditCardTransaction.self)
        }
    }
    
    func getCreditCardTransactions(for creditCardId: String) async throws -> [DynamicCreditCardTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(creditCardTransactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("creditCardId", isEqualTo: creditCardId)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicCreditCardTransaction.self)
        }
    }
    
    func getCreditCardTransactions(for categoryId: String) async throws -> [DynamicCreditCardTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(creditCardTransactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("categoryId", isEqualTo: categoryId)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicCreditCardTransaction.self)
        }
    }
    
    func getCreditCardTransactions(from startDate: Date, to endDate: Date) async throws -> [DynamicCreditCardTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(creditCardTransactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicCreditCardTransaction.self)
        }
    }
    
    func getCreditCardTransaction(by id: String) async throws -> DynamicCreditCardTransaction? {
        let document = try await db.collection(creditCardTransactionsCollection).document(id)
            .getDocument()
        return try document.data(as: DynamicCreditCardTransaction.self)
    }
    
    func createCreditCardTransaction(_ transaction: DynamicCreditCardTransaction) async throws -> DynamicCreditCardTransaction {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
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
            userId: userId,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await db.collection(creditCardTransactionsCollection)
            .document(updatedTransaction.id)
            .setData(from: updatedTransaction)
        
        return updatedTransaction
    }
    
    func updateCreditCardTransaction(_ transaction: DynamicCreditCardTransaction) async throws -> DynamicCreditCardTransaction {
        guard try await getCreditCardTransaction(by: transaction.id) != nil else {
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
        
        try await db.collection(creditCardTransactionsCollection)
            .document(updatedTransaction.id)
            .setData(from: updatedTransaction, merge: true)
        
        return updatedTransaction
    }
    
    func deleteCreditCardTransaction(id: String) async throws {
        guard try await getCreditCardTransaction(by: id) != nil else {
            throw DynamicCreditCardTransactionError.transactionNotFound
        }
        
        try await db.collection(creditCardTransactionsCollection).document(id).delete()
    }
    
    // MARK: - Installment Management
    
    func getCreditCardTransactionsWithInstallments() async throws -> [DynamicCreditCardTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(creditCardTransactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("installments", isGreaterThan: 1)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicCreditCardTransaction.self)
        }
    }
    
    func getCreditCardTransactions(installmentNumber: Int) async throws -> [DynamicCreditCardTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(creditCardTransactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("currentInstallment", isEqualTo: installmentNumber)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicCreditCardTransaction.self)
        }
    }
    
    func getNextInstallments(from date: Date, limit: Int) async throws -> [DynamicCreditCardTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(creditCardTransactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("dueDate", isGreaterThanOrEqualTo: date)
            .whereField("isPaid", isEqualTo: false)
            .order(by: "dueDate")
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicCreditCardTransaction.self)
        }
    }
    
    // MARK: - Credit Card Specific Analytics
    
    func getCreditCardTransactionsByType(_ type: TransactionType) async throws -> [DynamicCreditCardTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(creditCardTransactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("type", isEqualTo: type.rawValue)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicCreditCardTransaction.self)
        }
    }
    
    func getCreditCardTransactionsByCategory(_ categoryId: String, from startDate: Date, to endDate: Date) async throws -> [DynamicCreditCardTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(creditCardTransactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("categoryId", isEqualTo: categoryId)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicCreditCardTransaction.self)
        }
    }
    
    func getCreditCardTransactionsBySubcategory(_ subcategoryId: String, from startDate: Date, to endDate: Date) async throws -> [DynamicCreditCardTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(creditCardTransactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("subcategoryId", isEqualTo: subcategoryId)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicCreditCardTransaction.self)
        }
    }
    
    func getTotalCreditCardAmount(for categoryId: String, from startDate: Date, to endDate: Date) async throws -> Double {
        let transactions = try await getCreditCardTransactionsByCategory(categoryId, from: startDate, to: endDate)
        return transactions.reduce(0) { total, transaction in
            total + (transaction.type == .income ? transaction.amount : -transaction.amount)
        }
    }
    
    func getTotalCreditCardAmount(for type: TransactionType, from startDate: Date, to endDate: Date) async throws -> Double {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(creditCardTransactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("type", isEqualTo: type.rawValue)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .getDocuments()
        
        let transactions = snapshot.documents.compactMap { document in
            try? document.data(as: DynamicCreditCardTransaction.self)
        }
        
        return transactions.reduce(0) { $0 + $1.amount }
    }
    
    func getTotalCreditCardAmount(for creditCardId: String, from startDate: Date, to endDate: Date) async throws -> Double {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(creditCardTransactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("creditCardId", isEqualTo: creditCardId)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)
            .getDocuments()
        
        let transactions = snapshot.documents.compactMap { document in
            try? document.data(as: DynamicCreditCardTransaction.self)
        }
        
        return transactions.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Statement and Billing
    
    func getCreditCardTransactionsForBillingCycle(creditCardId: String, billingDate: Date) async throws -> [DynamicCreditCardTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
        }
        
        let calendar = Calendar.current
        let startOfBilling = calendar.date(byAdding: .month, value: -1, to: billingDate) ?? billingDate
        
        let snapshot = try await db.collection(creditCardTransactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("creditCardId", isEqualTo: creditCardId)
            .whereField("date", isGreaterThan: startOfBilling)
            .whereField("date", isLessThanOrEqualTo: billingDate)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicCreditCardTransaction.self)
        }
    }
    
    func getUnpaidCreditCardTransactions(creditCardId: String) async throws -> [DynamicCreditCardTransaction] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DynamicCreditCardTransactionError.userNotAuthenticated
        }
        
        let snapshot = try await db.collection(creditCardTransactionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("creditCardId", isEqualTo: creditCardId)
            .whereField("isPaid", isEqualTo: false)
            .order(by: "dueDate")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: DynamicCreditCardTransaction.self)
        }
    }
    
    func markTransactionsAsPaid(transactionIds: [String], paymentDate: Date) async throws {
        let batch = db.batch()
        
        for transactionId in transactionIds {
            let transactionRef = db.collection(creditCardTransactionsCollection).document(transactionId)
            batch.updateData([
                "isPaid": true,
                "paymentDate": paymentDate,
                "updatedAt": Date()
            ], forDocument: transactionRef)
        }
        
        try await batch.commit()
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
        // This would typically fetch from the old credit card transactions collection
        // For now, return empty array as this is a complex migration
        return []
    }
}

enum DynamicCreditCardTransactionError: LocalizedError {
    case userNotAuthenticated
    case transactionNotFound
    case creditCardNotFound
    case invalidData
    case migrationFailed
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return String(localized: "creditcard.transaction.error.not_authenticated")
        case .transactionNotFound:
            return String(localized: "creditcard.transaction.error.not_found")
        case .creditCardNotFound:
            return String(localized: "creditcard.transaction.error.creditcard_not_found")
        case .invalidData:
            return String(localized: "creditcard.transaction.error.invalid_data")
        case .migrationFailed:
            return String(localized: "creditcard.transaction.error.migration_failed")
        case .networkError(let error):
            return String(localized: "creditcard.transaction.error.network") + ": \(error.localizedDescription)"
        }
    }
}