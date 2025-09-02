//
//  AccountTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 01/09/25.
//

import XCTest
@testable import FinPessoal

final class AccountTests: XCTestCase {
    
    // MARK: - Test Data
    
    private let testAccount = Account(
        id: "test-account-id",
        name: "Test Checking Account",
        type: .checking,
        balance: 1500.00,
        currency: "BRL",
        isActive: true,
        userId: "test-user-id",
        createdAt: Date(),
        updatedAt: Date()
    )
     
    // MARK: - Initialization Tests
    
    func testAccountInitialization() throws {
        XCTAssertEqual(testAccount.id, "test-account-id")
        XCTAssertEqual(testAccount.name, "Test Checking Account")
        XCTAssertEqual(testAccount.type, .checking)
        XCTAssertEqual(testAccount.balance, 1500.00)
        XCTAssertEqual(testAccount.currency, "BRL")
        XCTAssertTrue(testAccount.isActive)
        XCTAssertEqual(testAccount.userId, "test-user-id")
    }
    
    // MARK: - Computed Properties Tests
    
    func testFormattedBalance() throws {
        XCTAssertEqual(testAccount.formattedBalance, "R$ 1.500,00")
        
        let negativeAccount = Account(
            id: "negative-account",
            name: "Negative Account",
            type: .checking,
            balance: -250.50,
            currency: "BRL",
            isActive: true,
            userId: "test-user-id",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(negativeAccount.formattedBalance, "-R$ 250,50")
    }
    
    // MARK: - Account Type Tests
    
    func testAccountTypeProperties() throws {
        XCTAssertEqual(AccountType.checking.icon, "creditcard.fill")
        XCTAssertEqual(AccountType.savings.icon, "wallet.bifold.fill")
        XCTAssertEqual(AccountType.investment.icon, "chart.line.uptrend.xyaxis")
        XCTAssertEqual(AccountType.credit.icon, "creditcard")
        
        XCTAssertNotNil(AccountType.checking.color)
        XCTAssertNotNil(AccountType.savings.color)
        XCTAssertNotNil(AccountType.investment.color)
        XCTAssertNotNil(AccountType.credit.color)
    }
    
    // MARK: - Dictionary Conversion Tests
    
    func testToDictionary() throws {
        let dictionary = try testAccount.toDictionary()
        
        XCTAssertEqual(dictionary["id"] as? String, "test-account-id")
        XCTAssertEqual(dictionary["name"] as? String, "Test Checking Account")
        XCTAssertEqual(dictionary["type"] as? String, "Conta Corrente")
        XCTAssertEqual(dictionary["balance"] as? Double, 1500.00)
        XCTAssertEqual(dictionary["currency"] as? String, "BRL")
        XCTAssertEqual(dictionary["isActive"] as? Bool, true)
        XCTAssertEqual(dictionary["userId"] as? String, "test-user-id")
        XCTAssertNotNil(dictionary["createdAt"])
        XCTAssertNotNil(dictionary["updatedAt"])
    }
    
    func testFromDictionary() throws {
        let dictionary: [String: Any] = [
            "id": "dict-account-id",
            "name": "Dictionary Account",
            "type": "Poupança",
            "balance": 2000.00,
            "currency": "BRL",
            "isActive": false,
            "userId": "dict-user-id",
            "createdAt": Date().timeIntervalSince1970,
            "updatedAt": Date().timeIntervalSince1970
        ]
        
        let account = try Account.fromDictionary(dictionary)
        
        XCTAssertEqual(account.id, "dict-account-id")
        XCTAssertEqual(account.name, "Dictionary Account")
        XCTAssertEqual(account.type, .savings)
        XCTAssertEqual(account.balance, 2000.00)
        XCTAssertEqual(account.currency, "BRL")
        XCTAssertFalse(account.isActive)
        XCTAssertEqual(account.userId, "dict-user-id")
    }
    
    func testFromDictionaryWithInvalidData() throws {
        let invalidDictionary: [String: Any] = [
            "id": "invalid-account",
            "name": "Invalid Account"
            // Missing required fields
        ]
        
        XCTAssertThrowsError(try Account.fromDictionary(invalidDictionary))
    }
    
    // MARK: - Edge Cases Tests
    
    func testZeroBalance() throws {
        let zeroAccount = Account(
            id: "zero-account",
            name: "Zero Balance Account",
            type: .checking,
            balance: 0.0,
            currency: "BRL",
            isActive: true,
            userId: "test-user-id",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertEqual(zeroAccount.formattedBalance, "R$ 0,00")
    }
    
    func testVeryLargeBalance() throws {
        let largeAccount = Account(
            id: "large-account",
            name: "Large Balance Account",
            type: .investment,
            balance: 999999999.99,
            currency: "BRL",
            isActive: true,
            userId: "test-user-id",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        XCTAssertTrue(largeAccount.formattedBalance.contains("999.999.999,99"))
    }
}
