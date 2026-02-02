//
//  TransactionViewModelTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 01/09/25.
//

import XCTest
import Combine
@testable import FinPessoal

@MainActor
final class TransactionViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var viewModel: TransactionViewModel!
    private var mockRepository: MockTransactionRepository!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    
    override func setUp() async throws {
        try await super.setUp()
        
        mockRepository = MockTransactionRepository()
        viewModel = TransactionViewModel(repository: mockRepository)
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
        XCTAssertTrue(viewModel.transactions.isEmpty)
        XCTAssertTrue(viewModel.filteredTransactions.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showingAddTransaction)
        XCTAssertNil(viewModel.selectedTransaction)
        XCTAssertFalse(viewModel.showingTransactionDetail)
        
        // Filter properties
        XCTAssertEqual(viewModel.searchQuery, "")
        XCTAssertEqual(viewModel.selectedPeriod, .all)
        XCTAssertNil(viewModel.selectedCategory)
        XCTAssertNil(viewModel.selectedType)
        XCTAssertNil(viewModel.selectedAccountId)
        
        // Statistics
        XCTAssertEqual(viewModel.totalIncome, 0.0)
        XCTAssertEqual(viewModel.totalExpenses, 0.0)
        XCTAssertEqual(viewModel.balance, 0.0)
    }
    
    // MARK: - Transaction Loading Tests
    
    func testFetchTransactionsSuccess() async throws {
        let testTransactions = [
            createTestTransaction(id: "trans1", amount: 100.0, type: .income, category: .salary),
            createTestTransaction(id: "trans2", amount: 50.0, type: .expense, category: .food)
        ]
        mockRepository.mockTransactions = testTransactions
        
        await viewModel.fetchTransactions()
        
        XCTAssertEqual(viewModel.transactions.count, 2)
        XCTAssertEqual(viewModel.filteredTransactions.count, 2)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchTransactionsFailure() async throws {
        mockRepository.shouldFail = true
        mockRepository.mockError = FirebaseError.databaseError("Database connection failed")
        
        await viewModel.fetchTransactions()
        
        XCTAssertTrue(viewModel.transactions.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Database connection failed")
    }
    
    func testFetchTransactionsLoadingState() async throws {
        let loadingExpectation = expectation(description: "Loading state should be true")
        let completedExpectation = expectation(description: "Loading state should be false when completed")
        
        var loadingStates: [Bool] = []
        
        viewModel.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if isLoading {
                    loadingExpectation.fulfill()
                } else if loadingStates.count > 1 {
                    completedExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        mockRepository.delay = 0.1
        
        Task {
            await viewModel.fetchTransactions()
        }
        
        await fulfillment(of: [loadingExpectation], timeout: 1.0)
        await fulfillment(of: [completedExpectation], timeout: 1.0)
        
        XCTAssertTrue(loadingStates.contains(true))
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - CRUD Operations Tests
    
    func testAddTransactionSuccess() async throws {
        let newTransaction = createTestTransaction(id: "new-trans", amount: 200.0, type: .expense, category: .shopping)
        
        let success = await viewModel.addTransaction(newTransaction)
        
        XCTAssertTrue(success)
        XCTAssertEqual(viewModel.transactions.count, 1)
        XCTAssertEqual(viewModel.transactions.first?.amount, 200.0)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testAddTransactionFailure() async throws {
        mockRepository.shouldFail = true
        mockRepository.mockError = AuthError.noCurrentUser

        let newTransaction = createTestTransaction(id: "new-trans", amount: 200.0, type: .expense, category: .shopping)

        let success = await viewModel.addTransaction(newTransaction)

        XCTAssertFalse(success)
        XCTAssertTrue(viewModel.transactions.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testUpdateTransactionSuccess() async throws {
        let originalTransaction = createTestTransaction(id: "update-trans", amount: 100.0, type: .expense, category: .food)
        mockRepository.mockTransactions = [originalTransaction]
        await viewModel.fetchTransactions()
        
        let updatedTransaction = createTestTransaction(id: "update-trans", amount: 150.0, type: .expense, category: .food)
        
        let success = await viewModel.updateTransaction(updatedTransaction)
        
        XCTAssertTrue(success)
        XCTAssertEqual(viewModel.transactions.count, 1)
        XCTAssertEqual(viewModel.transactions.first?.amount, 150.0)
    }
    
    func testDeleteTransactionSuccess() async throws {
        let transaction1 = createTestTransaction(id: "trans1", amount: 100.0, type: .income, category: .salary)
        let transaction2 = createTestTransaction(id: "trans2", amount: 50.0, type: .expense, category: .food)
        mockRepository.mockTransactions = [transaction1, transaction2]
        await viewModel.fetchTransactions()
        
        XCTAssertEqual(viewModel.transactions.count, 2)
        
        let success = await viewModel.deleteTransaction("trans1")
        
        XCTAssertTrue(success)
        XCTAssertEqual(viewModel.transactions.count, 1)
        XCTAssertEqual(viewModel.transactions.first?.id, "trans2")
    }
    
    // MARK: - Search and Filter Tests
    
    func testSearchQueryFilter() async throws {
        let transactions = [
            createTestTransaction(id: "trans1", amount: 100.0, type: .expense, category: .food, description: "Grocery shopping"),
            createTestTransaction(id: "trans2", amount: 50.0, type: .expense, category: .transport, description: "Bus ticket"),
            createTestTransaction(id: "trans3", amount: 200.0, type: .income, category: .salary, description: "Monthly salary")
        ]
        mockRepository.mockTransactions = transactions
        await viewModel.fetchTransactions()
        
        // Test search by description
        viewModel.searchQuery = "grocery"
        
        XCTAssertEqual(viewModel.filteredTransactions.count, 1)
        XCTAssertEqual(viewModel.filteredTransactions.first?.description, "Grocery shopping")
        
        // Test search by category
        viewModel.searchQuery = "transport"
        
        XCTAssertEqual(viewModel.filteredTransactions.count, 1)
        XCTAssertEqual(viewModel.filteredTransactions.first?.description, "Bus ticket")
    }
    
    func testCategoryFilter() async throws {
        let transactions = [
            createTestTransaction(id: "trans1", amount: 100.0, type: .expense, category: .food),
            createTestTransaction(id: "trans2", amount: 50.0, type: .expense, category: .transport),
            createTestTransaction(id: "trans3", amount: 200.0, type: .income, category: .salary)
        ]
        mockRepository.mockTransactions = transactions
        await viewModel.fetchTransactions()
        
        viewModel.selectedCategory = .food
        
        XCTAssertEqual(viewModel.filteredTransactions.count, 1)
        XCTAssertEqual(viewModel.filteredTransactions.first?.category, .food)
    }
    
    func testTypeFilter() async throws {
        let transactions = [
            createTestTransaction(id: "trans1", amount: 100.0, type: .expense, category: .food),
            createTestTransaction(id: "trans2", amount: 50.0, type: .expense, category: .transport),
            createTestTransaction(id: "trans3", amount: 200.0, type: .income, category: .salary)
        ]
        mockRepository.mockTransactions = transactions
        await viewModel.fetchTransactions()
        
        viewModel.selectedType = .income
        
        XCTAssertEqual(viewModel.filteredTransactions.count, 1)
        XCTAssertEqual(viewModel.filteredTransactions.first?.type, .income)
    }
    
    func testAccountFilter() async throws {
        let transactions = [
            createTestTransaction(id: "trans1", amount: 100.0, type: .expense, category: .food, accountId: "account1"),
            createTestTransaction(id: "trans2", amount: 50.0, type: .expense, category: .transport, accountId: "account2"),
            createTestTransaction(id: "trans3", amount: 200.0, type: .income, category: .salary, accountId: "account1")
        ]
        mockRepository.mockTransactions = transactions
        await viewModel.fetchTransactions()
        
        viewModel.selectedAccountId = "account1"
        
        XCTAssertEqual(viewModel.filteredTransactions.count, 2)
        XCTAssertTrue(viewModel.filteredTransactions.allSatisfy { $0.accountId == "account1" })
    }
    
    func testPeriodFilter() async throws {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let lastWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: now)!
        
        let transactions = [
            createTestTransaction(id: "trans1", amount: 100.0, type: .expense, category: .food, date: now),
            createTestTransaction(id: "trans2", amount: 50.0, type: .expense, category: .transport, date: yesterday),
            createTestTransaction(id: "trans3", amount: 200.0, type: .income, category: .salary, date: lastWeek)
        ]
        mockRepository.mockTransactions = transactions
        await viewModel.fetchTransactions()
        
        viewModel.selectedPeriod = .today
        
        XCTAssertEqual(viewModel.filteredTransactions.count, 1)
        XCTAssertEqual(viewModel.filteredTransactions.first?.id, "trans1")
    }
    
    func testClearFilters() async throws {
        // Set up filters
        viewModel.searchQuery = "test"
        viewModel.selectedCategory = .food
        viewModel.selectedType = .income
        viewModel.selectedAccountId = "account1"
        viewModel.selectedPeriod = .thisWeek
        
        viewModel.clearFilters()
        
        XCTAssertEqual(viewModel.searchQuery, "")
        XCTAssertEqual(viewModel.selectedPeriod, .all)
        XCTAssertNil(viewModel.selectedCategory)
        XCTAssertNil(viewModel.selectedType)
        XCTAssertNil(viewModel.selectedAccountId)
    }
    
    // MARK: - Statistics Tests
    
    func testStatisticsCalculation() async throws {
        let transactions = [
            createTestTransaction(id: "trans1", amount: 500.0, type: .income, category: .salary),
            createTestTransaction(id: "trans2", amount: 1000.0, type: .income, category: .investment),
            createTestTransaction(id: "trans3", amount: 200.0, type: .expense, category: .food),
            createTestTransaction(id: "trans4", amount: 100.0, type: .expense, category: .transport)
        ]
        mockRepository.mockTransactions = transactions
        mockRepository.mockTotalIncome = 1500.0
        mockRepository.mockTotalExpenses = 300.0

        await viewModel.fetchTransactions()

        XCTAssertEqual(viewModel.totalIncome, 1500.0)
        XCTAssertEqual(viewModel.totalExpenses, 300.0)
        XCTAssertEqual(viewModel.balance, 1200.0)
    }
    
    func testFormattedCurrencyValues() async throws {
        mockRepository.mockTotalIncome = 1500.50
        mockRepository.mockTotalExpenses = 899.99
        
        await viewModel.fetchTransactions()
        
        XCTAssertEqual(viewModel.formattedTotalIncome, "R$ 1.500,50")
        XCTAssertEqual(viewModel.formattedTotalExpenses, "R$ 899,99")
        XCTAssertEqual(viewModel.formattedBalance, "R$ 600,51")
    }
    
    // MARK: - UI State Tests
    
    func testSelectTransactionOniPhone() async throws {
        let transaction = createTestTransaction(id: "select-trans", amount: 100.0, type: .expense, category: .food)
        
        viewModel.selectTransaction(transaction)
        
        XCTAssertEqual(viewModel.selectedTransaction?.id, "select-trans")
        // Note: Device-specific behavior would need UIDevice mocking
    }
    
    func testShowAddTransaction() async throws {
        viewModel.showAddTransaction()
        
        // Note: Device-specific behavior would need UIDevice mocking
        // The actual behavior depends on device type
    }
    
    func testDismissAddTransaction() async throws {
        viewModel.showingAddTransaction = true
        
        viewModel.dismissAddTransaction()
        
        XCTAssertFalse(viewModel.showingAddTransaction)
    }
    
    func testDismissTransactionDetail() async throws {
        let transaction = createTestTransaction(id: "dismiss-trans", amount: 100.0, type: .expense, category: .food)
        viewModel.selectedTransaction = transaction
        viewModel.showingTransactionDetail = true
        
        viewModel.dismissTransactionDetail()
        
        XCTAssertFalse(viewModel.showingTransactionDetail)
        XCTAssertNil(viewModel.selectedTransaction)
    }
    
    // MARK: - Computed Properties Tests
    
    func testHasTransactions() async throws {
        XCTAssertFalse(viewModel.hasTransactions)
        
        let transactions = [createTestTransaction(id: "trans1", amount: 100.0, type: .expense, category: .food)]
        mockRepository.mockTransactions = transactions
        await viewModel.fetchTransactions()
        
        XCTAssertTrue(viewModel.hasTransactions)
    }
    
    func testHasFilteredTransactions() async throws {
        let transactions = [
            createTestTransaction(id: "trans1", amount: 100.0, type: .expense, category: .food),
            createTestTransaction(id: "trans2", amount: 50.0, type: .expense, category: .transport)
        ]
        mockRepository.mockTransactions = transactions
        await viewModel.fetchTransactions()
        
        XCTAssertTrue(viewModel.hasFilteredTransactions)
        
        // Apply filter that excludes all transactions
        viewModel.selectedCategory = .salary // No salary transactions in test data
        
        XCTAssertFalse(viewModel.hasFilteredTransactions)
    }
    
    func testIsFiltered() async throws {
        XCTAssertFalse(viewModel.isFiltered)
        
        viewModel.searchQuery = "test"
        XCTAssertTrue(viewModel.isFiltered)
        
        viewModel.searchQuery = ""
        viewModel.selectedCategory = .food
        XCTAssertTrue(viewModel.isFiltered)
        
        viewModel.selectedCategory = nil
        viewModel.selectedPeriod = .today
        XCTAssertTrue(viewModel.isFiltered)
    }
    
    // MARK: - Error Handling Tests
    
    func testClearError() async throws {
        viewModel.errorMessage = "Test error"
        
        viewModel.clearError()
        
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Helper Methods

    private func createTestTransaction(
        id: String,
        amount: Double,
        type: TransactionType,
        category: TransactionCategory,
        description: String = "Test Transaction",
        accountId: String = "test-account-id",
        date: Date = Date()
    ) -> Transaction {
        return Transaction(
            id: id,
            accountId: accountId,
            amount: amount,
            description: description,
            category: category,
            type: type,
            date: date,
            isRecurring: false,
            userId: "test-user-id",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}