//
//  NavigationStateTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 01/09/25.
//

import XCTest
import Combine
@testable import FinPessoal

@MainActor
final class NavigationStateTests: XCTestCase {
    
    // MARK: - Properties
    
    private var navigationState: NavigationState!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    
    override func setUp() async throws {
        try await super.setUp()
        
        navigationState = NavigationState()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() async throws {
        navigationState = nil
        cancellables = nil
        
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() throws {
        XCTAssertEqual(navigationState.selectedTab, .dashboard)
        XCTAssertEqual(navigationState.selectedSidebarItem, .dashboard)
        XCTAssertNil(navigationState.selectedTransaction)
        XCTAssertNil(navigationState.selectedAccount)
        XCTAssertFalse(navigationState.isShowingAddTransaction)
        XCTAssertFalse(navigationState.isShowingAddAccount)
    }
    
    // MARK: - Tab Selection Tests
    
    func testSelectTab() throws {
        let tabChangeExpectation = expectation(description: "Tab should change")
        
        navigationState.$selectedTab
            .dropFirst() // Skip initial value
            .sink { tab in
                if tab == .accounts {
                    tabChangeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        navigationState.selectTab(.accounts)
        
        wait(for: [tabChangeExpectation], timeout: 1.0)
        XCTAssertEqual(navigationState.selectedTab, .accounts)
    }
    
    func testSelectAllTabs() throws {
        let allTabs = MainTab.allCases
        
        for tab in allTabs {
            navigationState.selectTab(tab)
            XCTAssertEqual(navigationState.selectedTab, tab)
        }
    }
    
    // MARK: - Sidebar Selection Tests
    
    func testSelectSidebarItem() throws {
        let sidebarChangeExpectation = expectation(description: "Sidebar item should change")
        
        navigationState.$selectedSidebarItem
            .dropFirst()
            .sink { item in
                if item == .transactions {
                    sidebarChangeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        navigationState.selectSidebarItem(.transactions)
        
        wait(for: [sidebarChangeExpectation], timeout: 1.0)
        XCTAssertEqual(navigationState.selectedSidebarItem, .transactions)
    }
    
    func testSelectSidebarItemClearsDetailSelection() throws {
        // Set up some detail selections
        let testTransaction = createTestTransaction()
        let testAccount = createTestAccount()
        
        navigationState.selectedTransaction = testTransaction
        navigationState.selectedAccount = testAccount
        navigationState.isShowingAddTransaction = true
        navigationState.isShowingAddAccount = true
        
        // Select a different sidebar item
        navigationState.selectSidebarItem(.reports)
        
        // Verify detail selections are cleared
        XCTAssertNil(navigationState.selectedTransaction)
        XCTAssertNil(navigationState.selectedAccount)
        XCTAssertFalse(navigationState.isShowingAddTransaction)
        XCTAssertFalse(navigationState.isShowingAddAccount)
        XCTAssertEqual(navigationState.selectedSidebarItem, .reports)
    }
    
    // MARK: - Transaction Selection Tests
    
    func testSelectTransaction() throws {
        let testTransaction = createTestTransaction()
        let transactionChangeExpectation = expectation(description: "Transaction should be selected")
        
        navigationState.$selectedTransaction
            .dropFirst()
            .sink { transaction in
                if transaction?.id == "test-transaction-id" {
                    transactionChangeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        navigationState.selectTransaction(testTransaction)
        
        wait(for: [transactionChangeExpectation], timeout: 1.0)
        XCTAssertEqual(navigationState.selectedTransaction?.id, "test-transaction-id")
    }
    
    func testSelectTransactionClearsOtherSelections() throws {
        let testAccount = createTestAccount()
        let testTransaction = createTestTransaction()
        
        // Set up conflicting state
        navigationState.selectedAccount = testAccount
        navigationState.isShowingAddTransaction = true
        navigationState.isShowingAddAccount = true
        
        // Select transaction
        navigationState.selectTransaction(testTransaction)
        
        // Verify other selections are cleared
        XCTAssertEqual(navigationState.selectedTransaction?.id, "test-transaction-id")
        XCTAssertNil(navigationState.selectedAccount)
        XCTAssertFalse(navigationState.isShowingAddTransaction)
        XCTAssertFalse(navigationState.isShowingAddAccount)
    }
    
    // MARK: - Account Selection Tests
    
    func testSelectAccount() throws {
        let testAccount = createTestAccount()
        let accountChangeExpectation = expectation(description: "Account should be selected")
        
        navigationState.$selectedAccount
            .dropFirst()
            .sink { account in
                if account?.id == "test-account-id" {
                    accountChangeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        navigationState.selectAccount(testAccount)
        
        wait(for: [accountChangeExpectation], timeout: 1.0)
        XCTAssertEqual(navigationState.selectedAccount?.id, "test-account-id")
    }
    
    func testSelectAccountClearsOtherSelections() throws {
        let testTransaction = createTestTransaction()
        let testAccount = createTestAccount()
        
        // Set up conflicting state
        navigationState.selectedTransaction = testTransaction
        navigationState.isShowingAddTransaction = true
        navigationState.isShowingAddAccount = true
        
        // Select account
        navigationState.selectAccount(testAccount)
        
        // Verify other selections are cleared
        XCTAssertEqual(navigationState.selectedAccount?.id, "test-account-id")
        XCTAssertNil(navigationState.selectedTransaction)
        XCTAssertFalse(navigationState.isShowingAddTransaction)
        XCTAssertFalse(navigationState.isShowingAddAccount)
    }
    
    // MARK: - Add Transaction Tests
    
    func testShowAddTransaction() throws {
        let addTransactionExpectation = expectation(description: "Add transaction should be shown")
        
        navigationState.$isShowingAddTransaction
            .dropFirst()
            .sink { isShowing in
                if isShowing {
                    addTransactionExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        navigationState.showAddTransaction()
        
        wait(for: [addTransactionExpectation], timeout: 1.0)
        XCTAssertTrue(navigationState.isShowingAddTransaction)
    }
    
    func testShowAddTransactionClearsOtherSelections() throws {
        let testTransaction = createTestTransaction()
        let testAccount = createTestAccount()
        
        // Set up conflicting state
        navigationState.selectedTransaction = testTransaction
        navigationState.selectedAccount = testAccount
        navigationState.isShowingAddAccount = true
        
        // Show add transaction
        navigationState.showAddTransaction()
        
        // Verify other selections are cleared
        XCTAssertTrue(navigationState.isShowingAddTransaction)
        XCTAssertNil(navigationState.selectedTransaction)
        XCTAssertNil(navigationState.selectedAccount)
        XCTAssertFalse(navigationState.isShowingAddAccount)
    }
    
    // MARK: - Add Account Tests
    
    func testShowAddAccount() throws {
        let addAccountExpectation = expectation(description: "Add account should be shown")
        
        navigationState.$isShowingAddAccount
            .dropFirst()
            .sink { isShowing in
                if isShowing {
                    addAccountExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        navigationState.showAddAccount()
        
        wait(for: [addAccountExpectation], timeout: 1.0)
        XCTAssertTrue(navigationState.isShowingAddAccount)
    }
    
    func testShowAddAccountClearsOtherSelections() throws {
        let testTransaction = createTestTransaction()
        let testAccount = createTestAccount()
        
        // Set up conflicting state
        navigationState.selectedTransaction = testTransaction
        navigationState.selectedAccount = testAccount
        navigationState.isShowingAddTransaction = true
        
        // Show add account
        navigationState.showAddAccount()
        
        // Verify other selections are cleared
        XCTAssertTrue(navigationState.isShowingAddAccount)
        XCTAssertNil(navigationState.selectedTransaction)
        XCTAssertNil(navigationState.selectedAccount)
        XCTAssertFalse(navigationState.isShowingAddTransaction)
    }
    
    // MARK: - Clear Detail Selection Tests
    
    func testClearDetailSelection() throws {
        let testTransaction = createTestTransaction()
        let testAccount = createTestAccount()
        
        // Set up all detail states
        navigationState.selectedTransaction = testTransaction
        navigationState.selectedAccount = testAccount
        navigationState.isShowingAddTransaction = true
        navigationState.isShowingAddAccount = true
        
        // Clear all detail selections
        navigationState.clearDetailSelection()
        
        // Verify all are cleared
        XCTAssertNil(navigationState.selectedTransaction)
        XCTAssertNil(navigationState.selectedAccount)
        XCTAssertFalse(navigationState.isShowingAddTransaction)
        XCTAssertFalse(navigationState.isShowingAddAccount)
    }
    
    // MARK: - Reset Navigation Tests
    
    func testResetNavigation() throws {
        let testTransaction = createTestTransaction()
        let testAccount = createTestAccount()
        
        // Set up non-default state
        navigationState.selectedTab = .reports
        navigationState.selectedSidebarItem = .budgets
        navigationState.selectedTransaction = testTransaction
        navigationState.selectedAccount = testAccount
        navigationState.isShowingAddTransaction = true
        navigationState.isShowingAddAccount = true
        
        // Reset navigation
        navigationState.resetNavigation()
        
        // Verify everything is reset to defaults
        XCTAssertEqual(navigationState.selectedTab, .dashboard)
        XCTAssertEqual(navigationState.selectedSidebarItem, .dashboard)
        XCTAssertNil(navigationState.selectedTransaction)
        XCTAssertNil(navigationState.selectedAccount)
        XCTAssertFalse(navigationState.isShowingAddTransaction)
        XCTAssertFalse(navigationState.isShowingAddAccount)
    }
    
    // MARK: - Combined Navigation Flow Tests
    
    func testComplexNavigationFlow() throws {
        // Start with selecting accounts tab
        navigationState.selectTab(.accounts)
        navigationState.selectSidebarItem(.accounts)
        XCTAssertEqual(navigationState.selectedTab, .accounts)
        XCTAssertEqual(navigationState.selectedSidebarItem, .accounts)
        
        // Select an account
        let testAccount = createTestAccount()
        navigationState.selectAccount(testAccount)
        XCTAssertEqual(navigationState.selectedAccount?.id, "test-account-id")
        
        // Switch to transactions and select a transaction
        navigationState.selectSidebarItem(.transactions)
        XCTAssertNil(navigationState.selectedAccount) // Should be cleared
        
        let testTransaction = createTestTransaction()
        navigationState.selectTransaction(testTransaction)
        XCTAssertEqual(navigationState.selectedTransaction?.id, "test-transaction-id")
        
        // Show add transaction screen
        navigationState.showAddTransaction()
        XCTAssertTrue(navigationState.isShowingAddTransaction)
        XCTAssertNil(navigationState.selectedTransaction) // Should be cleared
        
        // Reset everything
        navigationState.resetNavigation()
        XCTAssertEqual(navigationState.selectedTab, .dashboard)
        XCTAssertEqual(navigationState.selectedSidebarItem, .dashboard)
        XCTAssertFalse(navigationState.isShowingAddTransaction)
    }
    
    // MARK: - Reactive Updates Tests
    
    func testMultipleSelectionUpdates() throws {
        let expectation = XCTestExpectation(description: "Should receive multiple updates")
        expectation.expectedFulfillmentCount = 3
        
        var receivedAccounts: [Account?] = []
        
        navigationState.$selectedAccount
            .sink { account in
                receivedAccounts.append(account)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Make multiple selections
        let account1 = createTestAccount(id: "account1", name: "Account 1")
        let account2 = createTestAccount(id: "account2", name: "Account 2")
        
        navigationState.selectAccount(account1)
        navigationState.selectAccount(account2)
        navigationState.clearDetailSelection()
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(receivedAccounts.count, 4) // Initial nil + 3 updates
        XCTAssertNil(receivedAccounts[0]) // Initial
        XCTAssertEqual(receivedAccounts[1]?.id, "account1")
        XCTAssertEqual(receivedAccounts[2]?.id, "account2")
        XCTAssertNil(receivedAccounts[3]) // After clear
    }
    
    // MARK: - Helper Methods
    
    private func createTestTransaction(
        id: String = "test-transaction-id",
        amount: Double = 100.0
    ) -> Transaction {
        return Transaction(
            id: id,
            accountId: "test-account-id",
            amount: amount,
            type: .expense,
            category: .food,
            description: "Test Transaction",
            date: Date(),
            userId: "test-user-id",
            isRecurring: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    private func createTestAccount(
        id: String = "test-account-id",
        name: String = "Test Account"
    ) -> Account {
        return Account(
            id: id,
            name: name,
            type: .checking,
            balance: 1000.0,
            currency: "BRL",
            isActive: true,
            userId: "test-user-id",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}