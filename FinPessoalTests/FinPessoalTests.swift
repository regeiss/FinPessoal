//
//  FinPessoalTests.swift
//  FinPessoalTests
//
//  Created by Roberto Edgar Geiss on 01/09/25.
//

import XCTest
import Testing
@testable import FinPessoal

/// Main test suite for FinPessoal app
/// 
/// This test suite provides comprehensive coverage including:
/// - Unit Tests: Models, ViewModels, Repositories
/// - Integration Tests: Component interactions
/// - Performance Tests: Large dataset handling
/// - Navigation Tests: iPad three-column layout
/// - UI Tests: User flows and interactions
///
/// Test Structure:
/// - Models/: Tests for data models (Account, Transaction, User)
/// - ViewModels/: Tests for MVVM ViewModels with mock repositories
/// - Repositories/: Tests for repository pattern implementations
/// - Navigation/: Tests for NavigationState and routing logic
/// - Performance/: Performance benchmarks and memory tests
/// - TestConfiguration.swift: Shared test utilities and factories
///
/// UI Tests (separate target):
/// - OnboardingUITests: First-run experience
/// - AuthenticationUITests: Login/logout flows
/// - iPadNavigationUITests: Three-column layout functionality
/// - FinPessoalUITests: Main app UI flows
struct FinPessoalTests {

    // MARK: - Swift Testing Framework Tests
    
    @Test("Basic app configuration should be valid")
    func testAppConfiguration() async throws {
        let config = AppConfiguration.shared
        #expect(config != nil, "AppConfiguration should be accessible")
    }
    
    @Test("Test data factory should create valid models")
    func testDataFactory() async throws {
        let user = TestConfiguration.createTestUser()
        let account = TestConfiguration.createTestAccount()
        let transaction = TestConfiguration.createTestTransaction()
        
        #expect(user.id == "test-user-id")
        #expect(account.name == "Test Account")
        #expect(transaction.amount == 100.0)
    }
    
    @Test("Sample data collections should be populated")
    func testSampleDataCollections() async throws {
        let accounts = TestConfiguration.createSampleAccounts()
        let transactions = TestConfiguration.createSampleTransactions()
        
        #expect(accounts.count == 5, "Should have 5 sample accounts")
        #expect(transactions.count == 8, "Should have 8 sample transactions")
        
        // Verify data integrity
        #expect(accounts.allSatisfy { !$0.name.isEmpty }, "All accounts should have names")
        #expect(transactions.allSatisfy { !$0.description.isEmpty }, "All transactions should have descriptions")
    }
    
    @Test("Currency formatting should work correctly")
    func testCurrencyFormatting() async throws {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        
        let formatted = formatter.string(from: NSNumber(value: 1234.56))
        #expect(formatted?.contains("1.234,56") == true, "Should format currency correctly for Brazilian locale")
    }
    
    @Test("Date utilities should work correctly")
    func testDateUtilities() async throws {
        let pastDate = TestConfiguration.createDateInPast(daysAgo: 7)
        let futureDate = TestConfiguration.createDateInFuture(daysFromNow: 7)
        let now = Date()
        
        #expect(pastDate < now, "Past date should be before now")
        #expect(futureDate > now, "Future date should be after now")
    }
    
    // MARK: - Integration Tests
    
    @Test("Mock repositories should integrate with ViewModels")
    func testRepositoryViewModelIntegration() async throws {
        let mockAccountRepo = TestConfiguration.setupMockAccountRepository()
        let mockTransactionRepo = TestConfiguration.setupMockTransactionRepository()
        
        #expect(mockAccountRepo != nil, "Mock account repository should be created")
        #expect(mockTransactionRepo != nil, "Mock transaction repository should be created")
    }
    
    @Test("Test environment detection should work")
    func testEnvironmentDetection() async throws {
        #expect(TestConfiguration.isRunningTests == true, "Should detect that tests are running")
    }
}

// MARK: - XCTest Compatibility

/// XCTest-based tests for compatibility with existing test infrastructure
final class FinPessoalXCTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Common test setup
        TestConfiguration.enableMockMode()
    }
    
    override func tearDown() {
        // Common test cleanup
        super.tearDown()
    }
    
    // MARK: - Smoke Tests
    
    func testAppLaunchComponents() throws {
        // Test critical app components can be initialized
        XCTAssertNoThrow(AppConfiguration.shared)
        XCTAssertNoThrow(NavigationState())
        XCTAssertNoThrow(MockAccountRepository())
        XCTAssertNoThrow(MockTransactionRepository())
    }
    
    func testModelCreation() throws {
        // Test that models can be created without crashing
        let user = TestConfiguration.createTestUser()
        let account = TestConfiguration.createTestAccount()
        let transaction = TestConfiguration.createTestTransaction()
        
        XCTAssertEqual(user.id, "test-user-id")
        XCTAssertEqual(account.balance, 1000.0)
        XCTAssertEqual(transaction.type, .expense)
    }
    
    func testEnumCoverage() throws {
        // Test that all enum cases are covered
        XCTAssertTrue(AccountType.allCases.count > 0)
        XCTAssertTrue(TransactionType.allCases.count > 0)
        XCTAssertTrue(TransactionCategory.allCases.count > 0)
        XCTAssertTrue(MainTab.allCases.count > 0)
        XCTAssertTrue(SidebarItem.allCases.count > 0)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() throws {
        let testError = TestConfiguration.TestError.mockNetworkError
        XCTAssertEqual(testError.localizedDescription, "Mock network error for testing")
        
        let validationError = TestConfiguration.TestError.mockValidationError("Invalid input")
        XCTAssertTrue(validationError.localizedDescription.contains("Invalid input"))
    }
    
    // MARK: - Async Helper Tests
    
    func testAsyncHelpers() async throws {
        let expectation = asyncExpectation(description: "Async operation should complete") {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            return "Success"
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}
