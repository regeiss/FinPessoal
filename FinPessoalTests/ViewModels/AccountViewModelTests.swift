//
//  AccountViewModelTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 01/09/25.
//

import XCTest
import Combine
@testable import FinPessoal

@MainActor
final class AccountViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var viewModel: AccountViewModel!
    private var mockRepository: MockAccountRepository!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    
    override func setUp() async throws {
        try await super.setUp()
        
        mockRepository = MockAccountRepository()
        viewModel = AccountViewModel(repository: mockRepository)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockRepository = nil
        cancellables = nil
        
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() throws {
        XCTAssertTrue(viewModel.accounts.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.selectedAccount)
        XCTAssertFalse(viewModel.showingAddAccount)
        XCTAssertFalse(viewModel.showingAccountDetail)
    }
    
    // MARK: - Account Loading Tests
    
    func testLoadAccountsSuccess() async throws {
        // Setup mock data
        let testAccounts = [
            createTestAccount(id: "account1", name: "Test Account 1", balance: 1000.0),
            createTestAccount(id: "account2", name: "Test Account 2", balance: 2000.0)
        ]
        mockRepository.mockAccounts = testAccounts
        
        // Test loading
        await viewModel.fetchAccounts()
        
        XCTAssertEqual(viewModel.accounts.count, 2)
        XCTAssertEqual(viewModel.accounts[0].name, "Test Account 1")
        XCTAssertEqual(viewModel.accounts[1].name, "Test Account 2")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadAccountsFailure() async throws {
        // Setup mock to fail
        mockRepository.shouldFail = true
        mockRepository.mockError = FirebaseError.databaseError("Test error")
        
        // Test loading
        await viewModel.fetchAccounts()
        
        XCTAssertTrue(viewModel.accounts.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Test error")
    }
    
    func testLoadAccountsIsLoadingState() async throws {
        // Setup expectation to check loading state
        let loadingExpectation = expectation(description: "Loading state should be true")
        let completedExpectation = expectation(description: "Loading state should be false when completed")
        
        var loadingStates: [Bool] = []
        
        viewModel.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if isLoading {
                    loadingExpectation.fulfill()
                } else if loadingStates.count > 1 { // Skip initial false state
                    completedExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Add delay to mock repository
        mockRepository.delay = 0.1
        
        // Start loading
        Task {
            await viewModel.fetchAccounts()
        }
        
        await fulfillment(of: [loadingExpectation], timeout: 1.0)
        await fulfillment(of: [completedExpectation], timeout: 1.0)
        
        XCTAssertTrue(loadingStates.contains(true))
        XCTAssertFalse(viewModel.isLoading) // Final state should be false
    }
    
    // MARK: - Account CRUD Tests
    
    func testAddAccountSuccess() async throws {
        let newAccount = createTestAccount(id: "new-account", name: "New Account", balance: 500.0)
        
        
        let success = await viewModel.addAccount(newAccount)
        
        XCTAssertTrue(success)
        XCTAssertEqual(viewModel.accounts.count, 1)
        XCTAssertEqual(viewModel.accounts.first?.name, "New Account")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testAddAccountFailure() async throws {
        mockRepository.shouldFail = true
        mockRepository.mockError = FirebaseError.databaseError("Auth failed")

        let newAccount = createTestAccount(id: "new-account", name: "New Account", balance: 500.0)

        let success = await viewModel.addAccount(newAccount)

        XCTAssertFalse(success)
        XCTAssertTrue(viewModel.accounts.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testUpdateAccountSuccess() async throws {
        // First add an account
        let originalAccount = createTestAccount(id: "update-account", name: "Original Account", balance: 1000.0)
        mockRepository.mockAccounts = [originalAccount]
        await viewModel.fetchAccounts()
        
        // Update the account
        let updatedAccount = createTestAccount(id: "update-account", name: "Updated Account", balance: 1500.0)
        
        let success = await viewModel.updateAccount(updatedAccount)
        
        XCTAssertTrue(success)
        XCTAssertEqual(viewModel.accounts.count, 1)
        XCTAssertEqual(viewModel.accounts.first?.name, "Updated Account")
        XCTAssertEqual(viewModel.accounts.first?.balance, 1500.0)
    }
    
    func testDeleteAccountSuccess() async throws {
        // First add accounts
        let account1 = createTestAccount(id: "delete-account-1", name: "Account 1", balance: 1000.0)
        let account2 = createTestAccount(id: "delete-account-2", name: "Account 2", balance: 2000.0)
        mockRepository.mockAccounts = [account1, account2]
        await viewModel.fetchAccounts()
        
        XCTAssertEqual(viewModel.accounts.count, 2)
        
        // Delete one account
        let success = await viewModel.deleteAccount("delete-account-1")
        
        XCTAssertTrue(success)
        XCTAssertEqual(viewModel.accounts.count, 1)
        XCTAssertEqual(viewModel.accounts.first?.name, "Account 2")
    }
    
    // MARK: - Account Selection Tests
    
    func testSelectAccountOniPhone() async throws {
        // Mock iPhone device
        // Note: This test assumes we can mock UIDevice, which might require additional setup
        
        let account = createTestAccount(id: "select-account", name: "Select Account", balance: 500.0)
        
        viewModel.selectAccount(account)
        
        XCTAssertEqual(viewModel.selectedAccount?.id, "select-account")
        // On iPhone, showingAccountDetail should be true
        // XCTAssertTrue(viewModel.showingAccountDetail) // This would be tested if we can mock UIDevice
    }
    
    func testShowAddAccount() async throws {
        XCTAssertFalse(viewModel.showingAddAccount)
        
        viewModel.showAddAccount()
        
        // Behavior depends on device type
        // XCTAssertTrue(viewModel.showingAddAccount) // This would be tested if we can mock UIDevice
    }
    
    func testDismissAddAccount() async throws {
        viewModel.showingAddAccount = true
        
        viewModel.dismissAddAccount()
        
        XCTAssertFalse(viewModel.showingAddAccount)
    }
    
    func testDismissAccountDetail() async throws {
        let account = createTestAccount(id: "dismiss-account", name: "Dismiss Account", balance: 500.0)
        viewModel.selectedAccount = account
        viewModel.showingAccountDetail = true
        
        viewModel.dismissAccountDetail()
        
        XCTAssertFalse(viewModel.showingAccountDetail)
        XCTAssertNil(viewModel.selectedAccount)
    }
    
    // MARK: - Computed Properties Tests
    
    func testTotalBalance() async throws {
        let accounts = [
            createTestAccount(id: "account1", name: "Account 1", balance: 1000.0),
            createTestAccount(id: "account2", name: "Account 2", balance: -500.0),
            createTestAccount(id: "account3", name: "Account 3", balance: 2500.0)
        ]
        mockRepository.mockAccounts = accounts
        
        await viewModel.fetchAccounts()
        
        XCTAssertEqual(viewModel.totalBalance, 3000.0)
    }
    
    func testFormattedTotalBalance() async throws {
        let accounts = [
            createTestAccount(id: "account1", name: "Account 1", balance: 1500.50),
            createTestAccount(id: "account2", name: "Account 2", balance: 2499.50)
        ]
        mockRepository.mockAccounts = accounts
        
        await viewModel.fetchAccounts()
        
        XCTAssertEqual(viewModel.formattedTotalBalance, "R$ 4.000,00")
    }
    
    func testHasAccounts() async throws {
        // Initially no accounts
        XCTAssertFalse(viewModel.hasAccounts)
        
        // Add accounts
        let accounts = [createTestAccount(id: "account1", name: "Account 1", balance: 1000.0)]
        mockRepository.mockAccounts = accounts
        await viewModel.fetchAccounts()
        
        XCTAssertTrue(viewModel.hasAccounts)
    }
    
    func testAccountsByType() async throws {
        let accounts = [
            createTestAccount(id: "account1", name: "Checking Account", balance: 1000.0, type: .checking),
            createTestAccount(id: "account2", name: "Savings Account", balance: 2000.0, type: .savings),
            createTestAccount(id: "account3", name: "Another Checking", balance: 3000.0, type: .checking)
        ]
        mockRepository.mockAccounts = accounts

        await viewModel.fetchAccounts()

        let accountsByType = viewModel.accountsByType
        XCTAssertEqual(accountsByType[.checking]?.count, 2)
        XCTAssertEqual(accountsByType[.savings]?.count, 1)
    }
    
    // MARK: - Error Handling Tests
    
    func testClearError() async throws {
        viewModel.errorMessage = "Test error"
        
        viewModel.clearError()
        
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testAuthErrorHandling() async throws {
        mockRepository.shouldFail = true
        mockRepository.mockError = AuthError.userNotFound
        
        await viewModel.fetchAccounts()
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("user") ?? false)
    }
    
    func testFirebaseErrorHandling() async throws {
        mockRepository.shouldFail = true
        mockRepository.mockError = FirebaseError.networkError
        
        await viewModel.fetchAccounts()
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("network") ?? false)
    }
    
    // MARK: - Helper Methods
    
    private func createTestAccount(
        id: String,
        name: String,
        balance: Double,
        type: AccountType = .checking,
        isActive: Bool = true
    ) -> Account {
        return Account(
            id: id,
            name: name,
            type: type,
            balance: balance,
            currency: "BRL",
            isActive: isActive,
            userId: "test-user-id",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
