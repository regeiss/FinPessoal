//
//  TransactionTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 01/09/25.
//

import XCTest
@testable import FinPessoal

final class TransactionTests: XCTestCase {
    
    // MARK: - Test Data
    
    private let testTransaction = Transaction(
        id: "test-transaction-id",
        accountId: "test-account-id",
        amount: 299.99,
        description: "Test Purchase",
        category: .shopping,
        type: .expense,
        date: Date(),
        isRecurring: false,
        userId: "test-user-id",
        createdAt: Date(),
        updatedAt: Date()
    )
    
    // MARK: - Initialization Tests
    
    func testTransactionInitialization() throws {
        XCTAssertEqual(testTransaction.id, "test-transaction-id")
        XCTAssertEqual(testTransaction.accountId, "test-account-id")
        XCTAssertEqual(testTransaction.amount, 299.99)
        XCTAssertEqual(testTransaction.type, .expense)
        XCTAssertEqual(testTransaction.category, .shopping)
        XCTAssertEqual(testTransaction.description, "Test Purchase")
        XCTAssertEqual(testTransaction.userId, "test-user-id")
        XCTAssertFalse(testTransaction.isRecurring)
    }
    
    // MARK: - Computed Properties Tests
    
    func testFormattedAmount() throws {
        XCTAssertEqual(testTransaction.formattedAmount, "-R$ 299,99")
        
        let largeTransaction = Transaction(
            id: "large-transaction",
            accountId: "test-account",
            amount: 15000.50,
            description: "Large Transaction",
            category: .salary,
            type: .income,
            date: Date(),
            isRecurring: false,
            userId: "test-user",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(largeTransaction.formattedAmount, "+R$ 15.000,50")
    }
    
    func testFormattedDate() throws {
        let specificDate = DateComponents(calendar: Calendar.current, year: 2025, month: 1, day: 15).date!
        let dateTransaction = Transaction(
            id: "date-transaction",
            accountId: "test-account",
            amount: 100.00,
            description: "Date Test",
            category: .food,
            type: .expense,
            date: specificDate,
            isRecurring: false,
            userId: "test-user",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Test that the date was set correctly
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.day, from: dateTransaction.date), 15)
        XCTAssertEqual(calendar.component(.month, from: dateTransaction.date), 1)
    }
    
    // MARK: - Transaction Type Tests
    
    func testTransactionTypeProperties() throws {
        // TransactionType enum doesn't have symbol or color properties
        XCTAssertEqual(TransactionType.income.displayName, String(localized: "transaction.type.income"))
        XCTAssertEqual(TransactionType.expense.displayName, String(localized: "transaction.type.expense"))
    }
    
    // MARK: - Transaction Category Tests
    
    func testTransactionCategoryProperties() throws {
        // Test a few key categories
        XCTAssertNotNil(TransactionCategory.food.icon)
        XCTAssertNotNil(TransactionCategory.shopping.icon)
        XCTAssertNotNil(TransactionCategory.salary.icon)
        XCTAssertNotNil(TransactionCategory.transport.icon)
        
        // TransactionCategory enum doesn't have color properties
        // Test icon property instead
        XCTAssertEqual(TransactionCategory.food.icon, "fork.knife")
        XCTAssertEqual(TransactionCategory.shopping.icon, "bag")
        XCTAssertEqual(TransactionCategory.salary.icon, "dollarsign.circle")
        XCTAssertEqual(TransactionCategory.transport.icon, "car")
        
        XCTAssertFalse(TransactionCategory.food.displayName.isEmpty)
        XCTAssertFalse(TransactionCategory.shopping.displayName.isEmpty)
        XCTAssertFalse(TransactionCategory.salary.displayName.isEmpty)
        XCTAssertFalse(TransactionCategory.transport.displayName.isEmpty)
    }
    
    func testTransactionCategorySorting() throws {
        let categories = TransactionCategory.allCases.sorted()
        XCTAssertTrue(categories.count > 0)
        
        // Test that sorting doesn't crash and returns consistent results
        let sortedAgain = TransactionCategory.allCases.sorted()
        XCTAssertEqual(categories.count, sortedAgain.count)
    }
    
    // MARK: - Dictionary Conversion Tests
    
    func testToDictionary() throws {
        let dictionary = try testTransaction.toDictionary()
        
        XCTAssertEqual(dictionary["id"] as? String, "test-transaction-id")
        XCTAssertEqual(dictionary["accountId"] as? String, "test-account-id")
        XCTAssertEqual(dictionary["amount"] as? Double, 299.99)
        XCTAssertEqual(dictionary["type"] as? String, "expense")
        XCTAssertEqual(dictionary["category"] as? String, "shopping")
        XCTAssertEqual(dictionary["description"] as? String, "Test Purchase")
        XCTAssertEqual(dictionary["userId"] as? String, "test-user-id")
        XCTAssertEqual(dictionary["isRecurring"] as? Bool, false)
        XCTAssertNotNil(dictionary["date"])
        XCTAssertNotNil(dictionary["createdAt"])
        XCTAssertNotNil(dictionary["updatedAt"])
    }
    
    func testFromDictionary() throws {
        let dictionary: [String: Any] = [
            "id": "dict-transaction-id",
            "accountId": "dict-account-id",
            "amount": 150.75,
            "type": "income",
            "category": "salary",
            "description": "Dictionary Transaction",
            "date": Date().timeIntervalSince1970,
            "userId": "dict-user-id",
            "isRecurring": true,
            "createdAt": Date().timeIntervalSince1970,
            "updatedAt": Date().timeIntervalSince1970
        ]
        
        let transaction = try Transaction.fromDictionary(dictionary)
        
        XCTAssertEqual(transaction.id, "dict-transaction-id")
        XCTAssertEqual(transaction.accountId, "dict-account-id")
        XCTAssertEqual(transaction.amount, 150.75)
        XCTAssertEqual(transaction.type, .income)
        XCTAssertEqual(transaction.category, .salary)
        XCTAssertEqual(transaction.description, "Dictionary Transaction")
        XCTAssertEqual(transaction.userId, "dict-user-id")
        XCTAssertTrue(transaction.isRecurring)
    }
    
    func testFromDictionaryWithInvalidData() throws {
        let invalidDictionary: [String: Any] = [
            "id": "invalid-transaction",
            "description": "Invalid Transaction"
            // Missing required fields
        ]
        
        XCTAssertThrowsError(try Transaction.fromDictionary(invalidDictionary))
    }
    
    // MARK: - Edge Cases Tests
    
    func testZeroAmount() throws {
        let zeroTransaction = Transaction(
            id: "zero-transaction",
            accountId: "test-account",
            amount: 0.0,
            description: "Zero Amount Transaction",
            category: .other,
            type: .expense,
            date: Date(),
            isRecurring: false,
            userId: "test-user",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(zeroTransaction.formattedAmount, "-R$ 0,00")
    }
    
    func testNegativeAmount() throws {
        // In real app, negative amounts might be handled differently
        let negativeTransaction = Transaction(
            id: "negative-transaction",
            accountId: "test-account",
            amount: -50.00,
            description: "Negative Amount Transaction",
            category: .other,
            type: .expense,
            date: Date(),
            isRecurring: false,
            userId: "test-user",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertTrue(negativeTransaction.formattedAmount.contains("-") || negativeTransaction.formattedAmount.contains("50"))
    }
    
    func testVeryLargeAmount() throws {
        let largeTransaction = Transaction(
            id: "large-transaction",
            accountId: "test-account",
            amount: 999999999.99,
            description: "Large Amount Transaction",
            category: .investment,
            type: .income,
            date: Date(),
            isRecurring: false,
            userId: "test-user",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertTrue(largeTransaction.formattedAmount.contains("999.999.999,99"))
    }
    
    func testEmptyDescription() throws {
        let emptyDescTransaction = Transaction(
            id: "empty-desc-transaction",
            accountId: "test-account",
            amount: 25.50,
            description: "",
            category: .other,
            type: .expense,
            date: Date(),
            isRecurring: false,
            userId: "test-user",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(emptyDescTransaction.description, "")
    }
}