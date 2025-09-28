//
//  MockCreditCardRepository.swift
//  FinPessoal
//
//  Created by Claude on 25/09/25.
//

import Foundation

class MockCreditCardRepository: CreditCardRepositoryProtocol {
    private var creditCards: [CreditCard] = []
    private var transactions: [CreditCardTransaction] = []
    private var statements: [CreditCardStatement] = []
    
    init() {
        setupMockData()
    }
    
    // MARK: - Credit Cards
    
    func getCreditCards() async throws -> [CreditCard] {
        try await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
        return creditCards
    }
    
    func getCreditCard(by id: String) async throws -> CreditCard? {
        try await Task.sleep(nanoseconds: 300_000_000)
        return creditCards.first { $0.id == id }
    }
    
    func createCreditCard(_ creditCard: CreditCard) async throws -> CreditCard {
        try await Task.sleep(nanoseconds: 500_000_000)
        creditCards.append(creditCard)
        return creditCard
    }
    
    func updateCreditCard(_ creditCard: CreditCard) async throws -> CreditCard {
        try await Task.sleep(nanoseconds: 500_000_000)
        if let index = creditCards.firstIndex(where: { $0.id == creditCard.id }) {
            creditCards[index] = creditCard
        }
        return creditCard
    }
    
    func deleteCreditCard(id: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        creditCards.removeAll { $0.id == id }
        transactions.removeAll { $0.creditCardId == id }
        statements.removeAll { $0.creditCardId == id }
    }
    
    // MARK: - Transactions
    
    func getCreditCardTransactions(for creditCardId: String) async throws -> [CreditCardTransaction] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return transactions.filter { $0.creditCardId == creditCardId }
    }
    
    func createCreditCardTransaction(_ transaction: CreditCardTransaction) async throws -> CreditCardTransaction {
        try await Task.sleep(nanoseconds: 500_000_000)
        transactions.append(transaction)
        
        // Update credit card balance
        if let cardIndex = creditCards.firstIndex(where: { $0.id == transaction.creditCardId }) {
            let currentCard = creditCards[cardIndex]
            let newBalance = currentCard.currentBalance + transaction.amount
            let newAvailableCredit = currentCard.creditLimit - newBalance
            
            let updatedCard = CreditCard(
                id: currentCard.id,
                name: currentCard.name,
                lastFourDigits: currentCard.lastFourDigits,
                brand: currentCard.brand,
                creditLimit: currentCard.creditLimit,
                availableCredit: max(0, newAvailableCredit),
                currentBalance: newBalance,
                dueDate: currentCard.dueDate,
                closingDate: currentCard.closingDate,
                minimumPayment: max(currentCard.minimumPayment, newBalance * 0.02), // 2% minimum
                annualFee: currentCard.annualFee,
                interestRate: currentCard.interestRate,
                isActive: currentCard.isActive,
                userId: currentCard.userId,
                createdAt: currentCard.createdAt,
                updatedAt: Date()
            )
            
            creditCards[cardIndex] = updatedCard
        }
        
        return transaction
    }
    
    func updateCreditCardTransaction(_ transaction: CreditCardTransaction) async throws -> CreditCardTransaction {
        try await Task.sleep(nanoseconds: 500_000_000)
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
        }
        return transaction
    }
    
    func deleteCreditCardTransaction(id: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        transactions.removeAll { $0.id == id }
    }
    
    // MARK: - Statements
    
    func getCreditCardStatements(for creditCardId: String) async throws -> [CreditCardStatement] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return statements.filter { $0.creditCardId == creditCardId }
    }
    
    func generateStatement(for creditCardId: String, period: StatementPeriod) async throws -> CreditCardStatement {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let periodTransactions = transactions.filter { transaction in
            transaction.creditCardId == creditCardId &&
            transaction.date >= period.startDate &&
            transaction.date <= period.endDate
        }
        
        let totalAmount = periodTransactions.reduce(0) { $0 + $1.amount }
        
        let statement = CreditCardStatement(
            id: UUID().uuidString,
            creditCardId: creditCardId,
            period: period,
            transactions: periodTransactions,
            totalAmount: totalAmount,
            minimumPayment: totalAmount * 0.02, // 2% minimum
            dueDate: Calendar.current.date(byAdding: .day, value: 20, to: period.endDate) ?? Date(),
            isPaid: false,
            paidAmount: 0,
            paidDate: nil,
            createdAt: Date()
        )
        
        statements.append(statement)
        return statement
    }
    
    func payStatement(_ statement: CreditCardStatement, amount: Double) async throws -> CreditCardStatement {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let updatedStatement = CreditCardStatement(
            id: statement.id,
            creditCardId: statement.creditCardId,
            period: statement.period,
            transactions: statement.transactions,
            totalAmount: statement.totalAmount,
            minimumPayment: statement.minimumPayment,
            dueDate: statement.dueDate,
            isPaid: amount >= statement.totalAmount,
            paidAmount: statement.paidAmount + amount,
            paidDate: Date(),
            createdAt: statement.createdAt
        )
        
        if let index = statements.firstIndex(where: { $0.id == statement.id }) {
            statements[index] = updatedStatement
        }
        
        // Update credit card balance
        if let cardIndex = creditCards.firstIndex(where: { $0.id == statement.creditCardId }) {
            let currentCard = creditCards[cardIndex]
            let newBalance = max(0, currentCard.currentBalance - amount)
            let newAvailableCredit = currentCard.creditLimit - newBalance
            
            let updatedCard = CreditCard(
                id: currentCard.id,
                name: currentCard.name,
                lastFourDigits: currentCard.lastFourDigits,
                brand: currentCard.brand,
                creditLimit: currentCard.creditLimit,
                availableCredit: newAvailableCredit,
                currentBalance: newBalance,
                dueDate: currentCard.dueDate,
                closingDate: currentCard.closingDate,
                minimumPayment: max(0, newBalance * 0.02),
                annualFee: currentCard.annualFee,
                interestRate: currentCard.interestRate,
                isActive: currentCard.isActive,
                userId: currentCard.userId,
                createdAt: currentCard.createdAt,
                updatedAt: Date()
            )
            
            creditCards[cardIndex] = updatedCard
        }
        
        return updatedStatement
    }
    
    // MARK: - Mock Data Setup
    
    private func setupMockData() {
        let userId = "mock-user-id"
        let now = Date()
        
        // Mock Credit Cards
        creditCards = [
            CreditCard(
                id: "cc-1",
                name: "Cartão Principal",
                lastFourDigits: "1234",
                brand: .visa,
                creditLimit: 5000.0,
                availableCredit: 3500.0,
                currentBalance: 1500.0,
                dueDate: 15,
                closingDate: 20,
                minimumPayment: 75.0,
                annualFee: 120.0,
                interestRate: 12.5,
                isActive: true,
                userId: userId,
                createdAt: Calendar.current.date(byAdding: .month, value: -6, to: now) ?? now,
                updatedAt: now
            ),
            CreditCard(
                id: "cc-2",
                name: "Cartão Gold",
                lastFourDigits: "5678",
                brand: .mastercard,
                creditLimit: 10000.0,
                availableCredit: 8200.0,
                currentBalance: 1800.0,
                dueDate: 10,
                closingDate: 5,
                minimumPayment: 90.0,
                annualFee: 200.0,
                interestRate: 10.8,
                isActive: true,
                userId: userId,
                createdAt: Calendar.current.date(byAdding: .month, value: -12, to: now) ?? now,
                updatedAt: now
            ),
            CreditCard(
                id: "cc-3",
                name: "Cartão Empresarial",
                lastFourDigits: "9012",
                brand: .amex,
                creditLimit: 15000.0,
                availableCredit: 14500.0,
                currentBalance: 500.0,
                dueDate: 25,
                closingDate: 30,
                minimumPayment: 25.0,
                annualFee: 350.0,
                interestRate: 8.9,
                isActive: true,
                userId: userId,
                createdAt: Calendar.current.date(byAdding: .month, value: -3, to: now) ?? now,
                updatedAt: now
            )
        ]
        
        // Mock Transactions
        transactions = [
            CreditCardTransaction(
                id: "cct-1",
                creditCardId: "cc-1",
                amount: 250.0,
                description: "Supermercado ABC",
                category: .food,
                subcategory: nil,
                date: Calendar.current.date(byAdding: .day, value: -5, to: now) ?? now,
                installments: 1,
                currentInstallment: 1,
                isRecurring: false,
                userId: userId,
                createdAt: Calendar.current.date(byAdding: .day, value: -5, to: now) ?? now,
                updatedAt: Calendar.current.date(byAdding: .day, value: -5, to: now) ?? now
            ),
            CreditCardTransaction(
                id: "cct-2",
                creditCardId: "cc-1",
                amount: 120.0,
                description: "Posto de Gasolina",
                category: .transport,
                subcategory: nil,
                date: Calendar.current.date(byAdding: .day, value: -3, to: now) ?? now,
                installments: 1,
                currentInstallment: 1,
                isRecurring: false,
                userId: userId,
                createdAt: Calendar.current.date(byAdding: .day, value: -3, to: now) ?? now,
                updatedAt: Calendar.current.date(byAdding: .day, value: -3, to: now) ?? now
            ),
            CreditCardTransaction(
                id: "cct-3",
                creditCardId: "cc-2",
                amount: 50.0,
                description: "Smartphone - Parcela 2/12",
                category: .shopping,
                subcategory: nil,
                date: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now,
                installments: 12,
                currentInstallment: 2,
                isRecurring: true,
                userId: userId,
                createdAt: Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now,
                updatedAt: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now
            )
        ]
    }
}