//
//  DynamicCreditCardTransaction.swift
//  FinPessoal
//
//  Created by Claude on 29/09/25.
//

import Foundation

struct DynamicCreditCardTransaction: Identifiable, Codable, Hashable {
    let id: String
    let creditCardId: String
    let amount: Double
    let description: String
    let categoryId: String
    let subcategoryId: String?
    let type: TransactionType
    let date: Date
    let dueDate: Date
    let installments: Int
    let currentInstallment: Int
    let isPaid: Bool
    let paymentDate: Date?
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        creditCardId: String,
        amount: Double,
        description: String,
        categoryId: String,
        subcategoryId: String? = nil,
        type: TransactionType,
        date: Date,
        dueDate: Date,
        installments: Int = 1,
        currentInstallment: Int = 1,
        isPaid: Bool = false,
        paymentDate: Date? = nil,
        userId: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.creditCardId = creditCardId
        self.amount = amount
        self.description = description
        self.categoryId = categoryId
        self.subcategoryId = subcategoryId
        self.type = type
        self.date = date
        self.dueDate = dueDate
        self.installments = installments
        self.currentInstallment = currentInstallment
        self.isPaid = isPaid
        self.paymentDate = paymentDate
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Computed Properties
extension DynamicCreditCardTransaction {
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: dueDate)
    }
    
    var isInstallment: Bool {
        return installments > 1
    }
    
    var installmentText: String {
        guard isInstallment else { return "" }
        return "\(currentInstallment)/\(installments)"
    }
    
    var isOverdue: Bool {
        return !isPaid && dueDate < Date()
    }
    
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        return days
    }
    
    var statusText: String {
        if isPaid {
            return String(localized: "creditcard.transaction.status.paid")
        } else if isOverdue {
            return String(localized: "creditcard.transaction.status.overdue")
        } else if daysUntilDue <= 7 {
            return String(localized: "creditcard.transaction.status.due_soon")
        } else {
            return String(localized: "creditcard.transaction.status.pending")
        }
    }
}

// MARK: - Migration Support
extension DynamicCreditCardTransaction {
    static func from(
        creditCardTransaction: CreditCardTransaction,
        categoryMapping: [TransactionCategory: String],
        subcategoryMapping: [TransactionSubcategory: String]
    ) -> DynamicCreditCardTransaction? {
        guard let categoryId = categoryMapping[creditCardTransaction.category] else {
            return nil
        }
        
        let subcategoryId = creditCardTransaction.subcategory.flatMap { subcategoryMapping[$0] }
        
        // Calculate due date (assuming 30 days from transaction date)
        let calendar = Calendar.current
        let dueDate = calendar.date(byAdding: .day, value: 30, to: creditCardTransaction.date) ?? creditCardTransaction.date
        
        return DynamicCreditCardTransaction(
            id: creditCardTransaction.id,
            creditCardId: creditCardTransaction.creditCardId,
            amount: creditCardTransaction.amount,
            description: creditCardTransaction.description,
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            type: .expense, // Credit card transactions are always expenses
            date: creditCardTransaction.date,
            dueDate: dueDate,
            installments: creditCardTransaction.installments,
            currentInstallment: creditCardTransaction.currentInstallment,
            isPaid: false, // Default to unpaid during migration
            paymentDate: nil,
            userId: creditCardTransaction.userId,
            createdAt: creditCardTransaction.createdAt,
            updatedAt: creditCardTransaction.updatedAt
        )
    }
}

// MARK: - Sample Data
extension DynamicCreditCardTransaction {
    static var sampleData: [DynamicCreditCardTransaction] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            DynamicCreditCardTransaction(
                creditCardId: "cc-1",
                amount: 299.90,
                description: "Compras Online",
                categoryId: "cat-shopping",
                subcategoryId: "sub-online-shopping",
                type: .expense,
                date: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                dueDate: calendar.date(byAdding: .day, value: 28, to: now) ?? now,
                userId: "sample-user"
            ),
            DynamicCreditCardTransaction(
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
                userId: "sample-user"
            ),
            DynamicCreditCardTransaction(
                creditCardId: "cc-2",
                amount: 89.50,
                description: "Restaurante",
                categoryId: "cat-food",
                subcategoryId: "sub-restaurant",
                type: .expense,
                date: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                dueDate: calendar.date(byAdding: .day, value: 29, to: now) ?? now,
                userId: "sample-user"
            )
        ]
    }
}
