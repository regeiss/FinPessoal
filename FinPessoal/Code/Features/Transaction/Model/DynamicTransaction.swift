//
//  DynamicTransaction.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import Foundation

struct DynamicTransaction: Identifiable, Codable, Hashable {
    let id: String
    let accountId: String
    let amount: Double
    let description: String
    let categoryId: String // Reference to Category ID
    let subcategoryId: String? // Reference to Subcategory ID
    let type: TransactionType
    let date: Date
    let isRecurring: Bool
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    
    // Convenience initializer
    init(id: String = UUID().uuidString, accountId: String, amount: Double, description: String, categoryId: String, subcategoryId: String? = nil, type: TransactionType, date: Date, isRecurring: Bool, userId: String, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.accountId = accountId
        self.amount = amount
        self.description = description
        self.categoryId = categoryId
        self.subcategoryId = subcategoryId
        self.type = type
        self.date = date
        self.isRecurring = isRecurring
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        let prefix = type == .expense ? "-" : type == .income ? "+" : ""
        return prefix + (formatter.string(from: NSNumber(value: abs(amount))) ?? "R$ 0,00")
    }
}

// MARK: - Migration Helper

extension DynamicTransaction {
    // Create DynamicTransaction from old Transaction model
    static func from(transaction: Transaction, categoryMapping: [TransactionCategory: String], subcategoryMapping: [TransactionSubcategory: String]) -> DynamicTransaction? {
        guard let categoryId = categoryMapping[transaction.category] else {
            return nil
        }
        
        let subcategoryId = transaction.subcategory != nil ? subcategoryMapping[transaction.subcategory!] : nil
        
        return DynamicTransaction(
            id: transaction.id,
            accountId: transaction.accountId,
            amount: transaction.amount,
            description: transaction.description,
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            type: transaction.type,
            date: transaction.date,
            isRecurring: transaction.isRecurring,
            userId: transaction.userId,
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt
        )
    }
    
    // Create old Transaction from DynamicTransaction (for backward compatibility)
    func toLegacyTransaction(categoryMapping: [String: TransactionCategory], subcategoryMapping: [String: TransactionSubcategory]) -> Transaction? {
        guard let category = categoryMapping[categoryId] else {
            return nil
        }
        
        let subcategory = subcategoryId != nil ? subcategoryMapping[subcategoryId!] : nil
        
        return Transaction(
            id: id,
            accountId: accountId,
            amount: amount,
            description: description,
            category: category,
            type: type,
            date: date,
            isRecurring: isRecurring,
            userId: userId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            subcategory: subcategory
        )
    }
}

// MARK: - Dynamic Credit Card Transaction

struct DynamicCreditCardTransaction: Identifiable, Codable, Hashable {
    let id: String
    let creditCardId: String
    let amount: Double
    let description: String
    let categoryId: String // Reference to Category ID
    let subcategoryId: String? // Reference to Subcategory ID
    let date: Date
    let installments: Int
    let currentInstallment: Int
    let isRecurring: Bool
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
    }
    
    var installmentText: String {
        if installments > 1 {
            return "\(currentInstallment)/\(installments)"
        }
        return String(localized: "creditcard.payment.single")
    }
    
    // Convenience initializer
    init(id: String = UUID().uuidString, creditCardId: String, amount: Double, description: String, categoryId: String, subcategoryId: String? = nil, date: Date, installments: Int = 1, currentInstallment: Int = 1, isRecurring: Bool = false, userId: String, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.creditCardId = creditCardId
        self.amount = amount
        self.description = description
        self.categoryId = categoryId
        self.subcategoryId = subcategoryId
        self.date = date
        self.installments = installments
        self.currentInstallment = currentInstallment
        self.isRecurring = isRecurring
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Migration Helper for Credit Card Transactions

extension DynamicCreditCardTransaction {
    // Create DynamicCreditCardTransaction from old CreditCardTransaction model
    static func from(transaction: CreditCardTransaction, categoryMapping: [TransactionCategory: String], subcategoryMapping: [TransactionSubcategory: String]) -> DynamicCreditCardTransaction? {
        guard let categoryId = categoryMapping[transaction.category] else {
            return nil
        }
        
        let subcategoryId = transaction.subcategory != nil ? subcategoryMapping[transaction.subcategory!] : nil
        
        return DynamicCreditCardTransaction(
            id: transaction.id,
            creditCardId: transaction.creditCardId,
            amount: transaction.amount,
            description: transaction.description,
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            date: transaction.date,
            installments: transaction.installments,
            currentInstallment: transaction.currentInstallment,
            isRecurring: transaction.isRecurring,
            userId: transaction.userId,
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt
        )
    }
    
    // Create old CreditCardTransaction from DynamicCreditCardTransaction (for backward compatibility)
    func toLegacyCreditCardTransaction(categoryMapping: [String: TransactionCategory], subcategoryMapping: [String: TransactionSubcategory]) -> CreditCardTransaction? {
        guard let category = categoryMapping[categoryId] else {
            return nil
        }
        
        let subcategory = subcategoryId != nil ? subcategoryMapping[subcategoryId!] : nil
        
        return CreditCardTransaction(
            id: id,
            creditCardId: creditCardId,
            amount: amount,
            description: description,
            category: category,
            subcategory: subcategory,
            date: date,
            installments: installments,
            currentInstallment: currentInstallment,
            isRecurring: isRecurring,
            userId: userId,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}