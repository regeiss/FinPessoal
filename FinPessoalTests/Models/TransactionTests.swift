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
        type: .expense,
        category: .shopping,
        description: "Test Purchase",
        date: Date(),
        userId: "test-user-id",
        isRecurring: false,
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
        XCTAssertEqual(testTransaction.formattedAmount, "R$ 299,99")
        
        let largeTransaction = Transaction(
            id: "large-transaction",
            accountId: "test-account",
            amount: 15000.50,
            type: .income,
            category: .salary,
            description: "Large Transaction",
            date: Date(),
            userId: "test-user",
            isRecurring: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(largeTransaction.formattedAmount, "R$ 15.000,50")
    }
    
    func testFormattedDate() throws {
        let specificDate = DateComponents(calendar: Calendar.current, year: 2025, month: 1, day: 15).date!
        let dateTransaction = Transaction(
            id: "date-transaction",
            accountId: "test-account",
            amount: 100.00,
            type: .expense,
            category: .food,
            description: "Date Test",
            date: specificDate,
            userId: "test-user",
            isRecurring: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertTrue(dateTransaction.formattedDate.contains("15"))
        XCTAssertTrue(dateTransaction.formattedDate.contains("jan") || dateTransaction.formattedDate.contains("Jan"))
    }
    
    // MARK: - Transaction Type Tests
    
    func testTransactionTypeProperties() throws {
        XCTAssertEqual(TransactionType.income.symbol, "+")
        XCTAssertEqual(TransactionType.expense.symbol, "-")
        
        XCTAssertNotNil(TransactionType.income.color)
        XCTAssertNotNil(TransactionType.expense.color)
    }
    
    // MARK: - Transaction Category Tests
    
    func testTransactionCategoryProperties() throws {
        // Test a few key categories
        XCTAssertNotNil(TransactionCategory.food.icon)
        XCTAssertNotNil(TransactionCategory.shopping.icon)
        XCTAssertNotNil(TransactionCategory.salary.icon)
        XCTAssertNotNil(TransactionCategory.transport.icon)
        
        XCTAssertNotNil(TransactionCategory.food.color)
        XCTAssertNotNil(TransactionCategory.shopping.color)
        XCTAssertNotNil(TransactionCategory.salary.color)
        XCTAssertNotNil(TransactionCategory.transport.color)
        
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
        let dictionary = testTransaction.toDictionary()
        
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
        
        let transaction = try XCTUnwrap(Transaction.fromDictionary(dictionary))
        
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
        
        XCTAssertNil(Transaction.fromDictionary(invalidDictionary))
    }
    
    // MARK: - Edge Cases Tests
    
    func testZeroAmount() throws {
        let zeroTransaction = Transaction(
            id: "zero-transaction",
            accountId: "test-account",
            amount: 0.0,
            type: .expense,
            category: .other,
            description: "Zero Amount Transaction",
            date: Date(),
            userId: "test-user",
            isRecurring: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(zeroTransaction.formattedAmount, "R$ 0,00")
    }
    
    func testNegativeAmount() throws {
        // In real app, negative amounts might be handled differently
        let negativeTransaction = Transaction(
            id: "negative-transaction",
            accountId: "test-account",
            amount: -50.00,
            type: .expense,
            category: .other,
            description: "Negative Amount Transaction",
            date: Date(),
            userId: "test-user",
            isRecurring: false,
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
            type: .income,
            category: .investment,
            description: "Large Amount Transaction",
            date: Date(),
            userId: "test-user",
            isRecurring: false,
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
            type: .expense,
            category: .other,
            description: "",
            date: Date(),
            userId: "test-user",
            isRecurring: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(emptyDescTransaction.description, "")
    }
}