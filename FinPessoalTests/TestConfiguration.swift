//
//  TestConfiguration.swift
//  FinPessoalTests
//
//  Created by Claude Code on 01/09/25.
//

import Foundation
import XCTest
@testable import FinPessoal

/// Configuration and utilities for testing
struct TestConfiguration {
    
    // MARK: - Test Data Factory
    
    static func createTestUser(
        id: String = "test-user-id",
        name: String = "Test User",
        email: String = "test@example.com"
    ) -> User {
        return User(
            id: id,
            name: name,
            email: email,
            phoneNumber: "+55 11 99999-9999",
            currency: "BRL",
            profileImageURL: nil,
            createdAt: Date(),
            lastLoginAt: Date(),
            isEmailVerified: true,
            settings: UserSettings()
        )
    }
    
    static func createTestAccount(
        id: String = "test-account-id",
        name: String = "Test Account",
        type: AccountType = .checking,
        balance: Double = 1000.0
    ) -> Account {
        return Account(
            id: id,
            name: name,
            type: type,
            balance: balance,
            currency: "BRL",
            isActive: true,
            userId: "test-user-id",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    static func createTestTransaction(
        id: String = "test-transaction-id",
        amount: Double = 100.0,
        type: TransactionType = .expense,
        category: TransactionCategory = .food,
        description: String = "Test Transaction"
    ) -> Transaction {
        return Transaction(
            id: id,
            accountId: "test-account-id",
            amount: amount,
            description: description,
            category: category,
            type: type,
            date: Date(),
            isRecurring: false,
            userId: "test-user-id",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    static func createTestBudget(
        id: String = "test-budget-id",
        name: String = "Test Budget",
        amount: Double = 500.0
    ) -> Budget {
        return Budget(
            id: id,
            name: name,
            category: .food,
            budgetAmount: amount,
            spent: 200.0,
            period: .monthly,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
            isActive: true,
            alertThreshold: 0.8,
            userId: "test-user-id",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    static func createTestGoal(
        id: String = "test-goal-id",
        name: String = "Test Goal",
        targetAmount: Double = 10000.0
    ) -> Goal {
        return Goal(
            id: id,
            userId: "test-user-id",
            name: name,
            targetAmount: targetAmount,
            currentAmount: 2500.0,
            targetDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date(),
            category: "savings",
            isActive: true,
            createdAt: Date()
        )
    }
    
    // MARK: - Test Data Collections
    
    static func createSampleAccounts() -> [Account] {
        return [
            createTestAccount(id: "checking-1", name: "Main Checking", type: .checking, balance: 2500.00),
            createTestAccount(id: "savings-1", name: "Emergency Fund", type: .savings, balance: 10000.00),
            createTestAccount(id: "credit-1", name: "Credit Card", type: .credit, balance: -1200.00),
            createTestAccount(id: "investment-1", name: "Investment Account", type: .investment, balance: 15000.00),
            createTestAccount(id: "investment-2", name: "Investment Portfolio", type: .investment, balance: 200.00)
        ]
    }
    
    static func createSampleTransactions() -> [Transaction] {
        return [
            createTestTransaction(id: "trans-1", amount: 50.00, type: .expense, category: .food, description: "Grocery Store"),
            createTestTransaction(id: "trans-2", amount: 3000.00, type: .income, category: .salary, description: "Monthly Salary"),
            createTestTransaction(id: "trans-3", amount: 25.00, type: .expense, category: .transport, description: "Bus Ticket"),
            createTestTransaction(id: "trans-4", amount: 120.00, type: .expense, category: .shopping, description: "Clothing"),
            createTestTransaction(id: "trans-5", amount: 500.00, type: .income, category: .other, description: "Freelance Project"),
            createTestTransaction(id: "trans-6", amount: 80.00, type: .expense, category: .entertainment, description: "Movie Night"),
            createTestTransaction(id: "trans-7", amount: 40.00, type: .expense, category: .healthcare, description: "Pharmacy"),
            createTestTransaction(id: "trans-8", amount: 200.00, type: .expense, category: .bills, description: "Electric Bill")
        ]
    }
    
    static func createSampleBudgets() -> [Budget] {
        return [
            createTestBudget(id: "budget-1", name: "Food Budget", amount: 600.00),
            createTestBudget(id: "budget-2", name: "Transport Budget", amount: 200.00),
            createTestBudget(id: "budget-3", name: "Entertainment Budget", amount: 300.00)
        ]
    }
    
    static func createSampleGoals() -> [Goal] {
        return [
            createTestGoal(id: "goal-1", name: "Emergency Fund", targetAmount: 20000.00),
            createTestGoal(id: "goal-2", name: "Vacation Fund", targetAmount: 5000.00),
            createTestGoal(id: "goal-3", name: "New Car", targetAmount: 30000.00)
        ]
    }
    
    // MARK: - Date Utilities
    
    static func createDateInPast(daysAgo: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }
    
    static func createDateInFuture(daysFromNow: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: daysFromNow, to: Date()) ?? Date()
    }
    
    static func startOfCurrentMonth() -> Date {
        return Calendar.current.startOfMonth(for: Date()) ?? Date()
    }
    
    static func endOfCurrentMonth() -> Date {
        return Calendar.current.endOfMonth(for: Date()) ?? Date()
    }
    
    // MARK: - Mock Repository Helpers
    
    static func setupMockAccountRepository() -> MockAccountRepository {
        return MockAccountRepository()
    }
    
    static func setupMockTransactionRepository() -> MockTransactionRepository {
        return MockTransactionRepository()
    }
    
    // MARK: - Assertion Helpers
    
    static func assertCurrencyFormat(_ amount: Double, expectedFormat: String, file: StaticString = #file, line: UInt = #line) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        
        let formattedAmount = formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
        
        if formattedAmount != expectedFormat {
            XCTFail("Currency format mismatch. Expected: \(expectedFormat), Got: \(formattedAmount)", file: file, line: line)
        }
    }
    
    static func assertDateWithinRange(_ date: Date, expectedDate: Date, tolerance: TimeInterval = 1.0, file: StaticString = #file, line: UInt = #line) {
        let timeDifference = abs(date.timeIntervalSince(expectedDate))
        
        if timeDifference > tolerance {
            XCTFail("Date outside expected range. Difference: \(timeDifference) seconds", file: file, line: line)
        }
    }
    
    // MARK: - Performance Helpers
    
    static func measureAsyncOperation<T>(_ operation: @escaping () async throws -> T) -> (result: T?, duration: TimeInterval) {
        var result: T?
        var error: Error?
        let startTime = Date()
        
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                result = try await operation()
            } catch let operationError {
                error = operationError
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        let endTime = Date()
        
        if let error = error {
            print("Async operation failed with error: \(error)")
        }
        
        return (result: result, duration: endTime.timeIntervalSince(startTime))
    }
    
    // MARK: - Test Environment
    
    static var isRunningTests: Bool {
        return NSClassFromString("XCTestCase") != nil
    }
    
    static var isRunningUITests: Bool {
        return ProcessInfo.processInfo.arguments.contains("--uitesting")
    }
    
    static func enableMockMode() {
        // Set environment variables in a different way since environment is read-only
        // In actual implementation, you might use UserDefaults or a different mechanism
    }
    
    // MARK: - Error Testing
    
    enum TestError: Error, LocalizedError, Equatable {
        case mockNetworkError
        case mockAuthError
        case mockDatabaseError
        case mockValidationError(String)
        
        var errorDescription: String? {
            switch self {
            case .mockNetworkError:
                return "Mock network error for testing"
            case .mockAuthError:
                return "Mock authentication error for testing"
            case .mockDatabaseError:
                return "Mock database error for testing"
            case .mockValidationError(let message):
                return "Mock validation error: \(message)"
            }
        }
    }
}

// MARK: - XCTest Extensions

extension XCTestCase {
    
    /// Helper to wait for async operations in tests
    func waitForAsync<T>(
        timeout: TimeInterval = 5.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let result = try await operation()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            // Timeout handling
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                continuation.resume(throwing: TestConfiguration.TestError.mockNetworkError)
            }
        }
    }
    
    /// Helper to create expectation for async operations
    func asyncExpectation<T>(
        description: String,
        operation: @escaping () async throws -> T
    ) -> XCTestExpectation {
        let expectation = XCTestExpectation(description: description)
        
        Task {
            do {
                _ = try await operation()
                expectation.fulfill()
            } catch {
                XCTFail("Async operation failed: \(error)")
            }
        }
        
        return expectation
    }
}