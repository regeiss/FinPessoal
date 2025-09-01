//
//  MockRepositoryTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 01/09/25.
//

import XCTest
@testable import FinPessoal

final class MockRepositoryTests: XCTestCase {
    
    // MARK: - MockAccountRepository Tests
    
    func testMockAccountRepositorySuccess() async throws {
        let mockRepository = MockAccountRepository()
        
        // Test data setup
        let testAccount = Account(
            id: "test-account",
            name: "Test Account",
            type: .checking,
            balance: 1000.0,
            currency: "BRL",
            isActive: true,
            userId: "test-user",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        mockRepository.mockAccounts = [testAccount]
        
        // Test getAccounts
        let accounts = try await mockRepository.getAccounts()
        XCTAssertEqual(accounts.count, 1)
        XCTAssertEqual(accounts.first?.name, "Test Account")
        
        // Test addAccount
        let newAccount = Account(
            id: "new-account",
            name: "New Account",
            type: .savings,
            balance: 500.0,
            currency: "BRL",
            isActive: true,
            userId: "test-user",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await mockRepository.addAccount(newAccount)
        let updatedAccounts = try await mockRepository.getAccounts()
        XCTAssertEqual(updatedAccounts.count, 2)
    }
    
    func testMockAccountRepositoryFailure() async throws {
        let mockRepository = MockAccountRepository()
        mockRepository.shouldFail = true
        mockRepository.mockError = AuthError.userNotAuthenticated
        
        do {
            _ = try await mockRepository.getAccounts()
            XCTFail("Expected error to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .userNotAuthenticated)
        } catch {
            XCTFail("Wrong error type thrown: \(error)")
        }
    }
    
    func testMockAccountRepositoryDelay() async throws {
        let mockRepository = MockAccountRepository()
        mockRepository.delay = 0.5
        
        let startTime = Date()
        _ = try await mockRepository.getAccounts()
        let endTime = Date()
        
        let duration = endTime.timeIntervalSince(startTime)
        XCTAssertGreaterThanOrEqual(duration, 0.5)
        XCTAssertLessThan(duration, 0.7) // Allow some margin
    }
    
    func testMockAccountRepositoryUpdateAccount() async throws {
        let mockRepository = MockAccountRepository()
        
        let originalAccount = Account(
            id: "update-account",
            name: "Original Name",
            type: .checking,
            balance: 1000.0,
            currency: "BRL",
            isActive: true,
            userId: "test-user",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        mockRepository.mockAccounts = [originalAccount]
        
        let updatedAccount = Account(
            id: "update-account",
            name: "Updated Name",
            type: .checking,
            balance: 1500.0,
            currency: "BRL",
            isActive: true,
            userId: "test-user",
            createdAt: originalAccount.createdAt,
            updatedAt: Date()
        )
        
        try await mockRepository.updateAccount(updatedAccount)
        let accounts = try await mockRepository.getAccounts()
        
        XCTAssertEqual(accounts.count, 1)
        XCTAssertEqual(accounts.first?.name, "Updated Name")
        XCTAssertEqual(accounts.first?.balance, 1500.0)
    }
    
    func testMockAccountRepositoryDeleteAccount() async throws {
        let mockRepository = MockAccountRepository()
        
        let account1 = Account(
            id: "account1",
            name: "Account 1",
            type: .checking,
            balance: 1000.0,
            currency: "BRL",
            isActive: true,
            userId: "test-user",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let account2 = Account(
            id: "account2",
            name: "Account 2",
            type: .savings,
            balance: 2000.0,
            currency: "BRL",
            isActive: true,
            userId: "test-user",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        mockRepository.mockAccounts = [account1, account2]
        
        try await mockRepository.deleteAccount("account1")
        let accounts = try await mockRepository.getAccounts()
        
        XCTAssertEqual(accounts.count, 1)
        XCTAssertEqual(accounts.first?.id, "account2")
    }
    
    // MARK: - MockTransactionRepository Tests
    
    func testMockTransactionRepositorySuccess() async throws {
        let mockRepository = MockTransactionRepository()
        
        let testTransaction = Transaction(
            id: "test-transaction",
            accountId: "test-account",
            amount: 100.0,
            type: .expense,
            category: .food,
            description: "Test Transaction",
            date: Date(),
            userId: "test-user",
            isRecurring: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        mockRepository.mockTransactions = [testTransaction]
        
        // Test getTransactions
        let transactions = try await mockRepository.getTransactions()
        XCTAssertEqual(transactions.count, 1)
        XCTAssertEqual(transactions.first?.description, "Test Transaction")
        
        // Test addTransaction
        let newTransaction = Transaction(
            id: "new-transaction",
            accountId: "test-account",
            amount: 200.0,
            type: .income,
            category: .salary,
            description: "New Transaction",
            date: Date(),
            userId: "test-user",
            isRecurring: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await mockRepository.addTransaction(newTransaction)
        let updatedTransactions = try await mockRepository.getTransactions()
        XCTAssertEqual(updatedTransactions.count, 2)
    }
    
    func testMockTransactionRepositoryGetTransactionsForAccount() async throws {
        let mockRepository = MockTransactionRepository()
        
        let transaction1 = Transaction(
            id: "trans1",
            accountId: "account1",
            amount: 100.0,
            type: .expense,
            category: .food,
            description: "Transaction 1",
            date: Date(),
            userId: "test-user",
            isRecurring: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let transaction2 = Transaction(
            id: "trans2",
            accountId: "account2",
            amount: 200.0,
            type: .income,
            category: .salary,
            description: "Transaction 2",
            date: Date(),
            userId: "test-user",
            isRecurring: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        mockRepository.mockTransactions = [transaction1, transaction2]
        
        let account1Transactions = try await mockRepository.getTransactions(for: "account1")
        XCTAssertEqual(account1Transactions.count, 1)
        XCTAssertEqual(account1Transactions.first?.id, "trans1")
    }
    
    func testMockTransactionRepositoryStatistics() async throws {
        let mockRepository = MockTransactionRepository()
        mockRepository.mockTotalIncome = 1500.0
        mockRepository.mockTotalExpenses = 800.0
        
        let income = try await mockRepository.getTotalIncome(for: .all)
        let expenses = try await mockRepository.getTotalExpenses(for: .all)
        
        XCTAssertEqual(income, 1500.0)
        XCTAssertEqual(expenses, 800.0)
    }
    
    func testMockTransactionRepositorySearchTransactions() async throws {
        let mockRepository = MockTransactionRepository()
        
        let transaction1 = Transaction(
            id: "trans1",
            accountId: "account1",
            amount: 100.0,
            type: .expense,
            category: .food,
            description: "Grocery store",
            date: Date(),
            userId: "test-user",
            isRecurring: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let transaction2 = Transaction(
            id: "trans2",
            accountId: "account1",
            amount: 200.0,
            type: .expense,
            category: .transport,
            description: "Gas station",
            date: Date(),
            userId: "test-user",
            isRecurring: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        mockRepository.mockTransactions = [transaction1, transaction2]
        
        let searchResults = try await mockRepository.searchTransactions(query: "grocery")
        XCTAssertEqual(searchResults.count, 1)
        XCTAssertEqual(searchResults.first?.description, "Grocery store")
    }
    
    func testMockTransactionRepositoryRecentTransactions() async throws {
        let mockRepository = MockTransactionRepository()
        
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: now)!
        
        let transactions = [
            Transaction(
                id: "trans1",
                accountId: "account1",
                amount: 100.0,
                type: .expense,
                category: .food,
                description: "Recent Transaction 1",
                date: now,
                userId: "test-user",
                isRecurring: false,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Transaction(
                id: "trans2",
                accountId: "account1",
                amount: 200.0,
                type: .expense,
                category: .transport,
                description: "Recent Transaction 2",
                date: yesterday,
                userId: "test-user",
                isRecurring: false,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Transaction(
                id: "trans3",
                accountId: "account1",
                amount: 300.0,
                type: .income,
                category: .salary,
                description: "Old Transaction",
                date: twoDaysAgo,
                userId: "test-user",
                isRecurring: false,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        
        mockRepository.mockTransactions = transactions
        
        let recentTransactions = try await mockRepository.getRecentTransactions(limit: 2)
        XCTAssertEqual(recentTransactions.count, 2)
        
        // Should be sorted by date (most recent first)
        XCTAssertEqual(recentTransactions.first?.description, "Recent Transaction 1")
        XCTAssertEqual(recentTransactions.last?.description, "Recent Transaction 2")
    }
    
    // MARK: - Error Handling Tests
    
    func testMockRepositoryErrorPropagation() async throws {
        let mockAccountRepository = MockAccountRepository()
        let mockTransactionRepository = MockTransactionRepository()
        
        let testError = FirebaseError.networkError
        
        mockAccountRepository.shouldFail = true
        mockAccountRepository.mockError = testError
        
        mockTransactionRepository.shouldFail = true
        mockTransactionRepository.mockError = testError
        
        // Test account repository error
        do {
            _ = try await mockAccountRepository.getAccounts()
            XCTFail("Expected error to be thrown")
        } catch let error as FirebaseError {
            XCTAssertEqual(error, .networkError)
        }
        
        // Test transaction repository error
        do {
            _ = try await mockTransactionRepository.getTransactions()
            XCTFail("Expected error to be thrown")
        } catch let error as FirebaseError {
            XCTAssertEqual(error, .networkError)
        }
    }
    
    // MARK: - Performance Tests
    
    func testMockRepositoryPerformanceWithLargeDataset() async throws {
        let mockRepository = MockTransactionRepository()
        
        // Create a large dataset
        var transactions: [Transaction] = []
        for i in 0..<1000 {
            transactions.append(Transaction(
                id: "trans\(i)",
                accountId: "account1",
                amount: Double(i * 10),
                type: i % 2 == 0 ? .income : .expense,
                category: .food,
                description: "Transaction \(i)",
                date: Date(),
                userId: "test-user",
                isRecurring: false,
                createdAt: Date(),
                updatedAt: Date()
            ))
        }
        
        mockRepository.mockTransactions = transactions
        
        // Measure performance
        let startTime = Date()
        let result = try await mockRepository.getTransactions()
        let endTime = Date()
        
        let duration = endTime.timeIntervalSince(startTime)
        
        XCTAssertEqual(result.count, 1000)
        XCTAssertLessThan(duration, 1.0) // Should complete within 1 second
    }
}