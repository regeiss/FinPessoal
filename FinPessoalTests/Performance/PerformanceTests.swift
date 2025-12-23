//
//  PerformanceTests.swift
//  FinPessoalTests
//
//  Created by Claude Code on 01/09/25.
//

import XCTest
@testable import FinPessoal

final class PerformanceTests: XCTestCase {
    
    // MARK: - Model Performance Tests
    
    func testAccountDictionaryConversionPerformance() throws {
        let accounts = createLargeAccountDataset(count: 1000)
        
        measure {
            for account in accounts {
                _ = try! account.toDictionary()
            }
        }
    }
    
    func testTransactionDictionaryConversionPerformance() throws {
        let transactions = createLargeTransactionDataset(count: 1000)
        
        measure {
            for transaction in transactions {
                _ = try! transaction.toDictionary()
            }
        }
    }
    
    func testAccountFromDictionaryPerformance() throws {
        let accountDictionaries = try createLargeAccountDataset(count: 1000).map { try $0.toDictionary() }

        measure {
            for dictionary in accountDictionaries {
                _ = try! Account.fromDictionary(dictionary)
            }
        }
    }
    
    func testTransactionFromDictionaryPerformance() throws {
        let transactionDictionaries = try createLargeTransactionDataset(count: 1000).map { try $0.toDictionary() }

        measure {
            for dictionary in transactionDictionaries {
                _ = try! Transaction.fromDictionary(dictionary)
            }
        }
    }
    
    // MARK: - ViewModel Performance Tests
    
    @MainActor
    func testAccountViewModelLargeDatasetPerformance() async throws {
        let mockRepository = MockAccountRepository()
        let accounts = createLargeAccountDataset(count: 5000)
        mockRepository.mockAccounts = accounts
        
        let viewModel = AccountViewModel(repository: mockRepository)
        
        measure {
            Task {
                await viewModel.fetchAccounts()
            }
        }
    }
    
    @MainActor
    func testTransactionViewModelLargeDatasetPerformance() async throws {
        let mockRepository = MockTransactionRepository()
        let transactions = createLargeTransactionDataset(count: 10000)
        mockRepository.mockTransactions = transactions
        
        let viewModel = TransactionViewModel(repository: mockRepository)
        
        measure {
            Task {
                await viewModel.fetchTransactions()
            }
        }
    }
    
    @MainActor
    func testTransactionFilteringPerformance() async throws {
        let mockRepository = MockTransactionRepository()
        let transactions = createLargeTransactionDataset(count: 10000)
        mockRepository.mockTransactions = transactions
        
        let viewModel = TransactionViewModel(repository: mockRepository)
        await viewModel.fetchTransactions()
        
        measure {
            viewModel.searchQuery = "test"
            viewModel.selectedCategory = .food
            viewModel.selectedType = .expense
        }
    }
    
    // MARK: - Currency Formatting Performance Tests
    
    func testCurrencyFormattingPerformance() throws {
        let amounts = Array(stride(from: 0.01, through: 100000.00, by: 0.01))
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        
        measure {
            for amount in amounts.prefix(10000) {
                _ = formatter.string(from: NSNumber(value: amount))
            }
        }
    }
    
    // MARK: - Date Formatting Performance Tests
    
    func testDateFormattingPerformance() throws {
        let dates = createDateRange(count: 1000)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "pt_BR")
        
        measure {
            for date in dates {
                _ = formatter.string(from: date)
            }
        }
    }
    
    // MARK: - Navigation State Performance Tests
    
    @MainActor
    func testNavigationStateUpdatePerformance() throws {
        let navigationState = NavigationState()
        let accounts = createLargeAccountDataset(count: 1000)
        let transactions = createLargeTransactionDataset(count: 1000)
        
        measure {
            for account in accounts.prefix(100) {
                navigationState.selectAccount(account)
            }
            
            for transaction in transactions.prefix(100) {
                navigationState.selectTransaction(transaction)
            }
        }
    }
    
    // MARK: - Memory Performance Tests
    
    func testLargeDatasetMemoryUsage() throws {
        measure(metrics: [XCTMemoryMetric()]) {
            let accounts = createLargeAccountDataset(count: 10000)
            let transactions = createLargeTransactionDataset(count: 50000)

            // Simulate processing the data
            var totalBalance: Double = 0
            var totalTransactionAmount: Double = 0

            for account in accounts {
                totalBalance += account.balance
            }

            for transaction in transactions {
                totalTransactionAmount += transaction.amount
            }

            XCTAssertTrue(totalBalance > 0)
            XCTAssertTrue(totalTransactionAmount > 0)
        }
    }
    
    // MARK: - Sorting Performance Tests
    
    func testTransactionSortingPerformance() throws {
        let transactions = createLargeTransactionDataset(count: 10000)
        
        measure {
            _ = transactions.sorted { $0.date > $1.date }
        }
    }
    
    func testAccountSortingPerformance() throws {
        let accounts = createLargeAccountDataset(count: 5000)
        
        measure {
            _ = accounts.sorted { $0.name < $1.name }
        }
    }
    
    // MARK: - Search Performance Tests
    
    func testTransactionSearchPerformance() throws {
        let transactions = createLargeTransactionDataset(count: 10000)
        let searchQueries = ["food", "salary", "transport", "shopping", "entertainment"]
        
        measure {
            for query in searchQueries {
                let lowercaseQuery = query.lowercased()
                _ = transactions.filter { transaction in
                    transaction.description.lowercased().contains(lowercaseQuery) ||
                    transaction.category.displayName.lowercased().contains(lowercaseQuery)
                }
            }
        }
    }
    
    // MARK: - Concurrent Operations Performance Tests
    
    @MainActor
    func testConcurrentViewModelOperations() async throws {
        let mockAccountRepository = MockAccountRepository()
        let mockTransactionRepository = MockTransactionRepository()
        
        mockAccountRepository.mockAccounts = createLargeAccountDataset(count: 1000)
        mockTransactionRepository.mockTransactions = createLargeTransactionDataset(count: 5000)
        
        let accountViewModel = AccountViewModel(repository: mockAccountRepository)
        let transactionViewModel = TransactionViewModel(repository: mockTransactionRepository)
        
        measure {
            Task {
                async let accountsTask = accountViewModel.fetchAccounts()
                async let transactionsTask = transactionViewModel.fetchTransactions()
                
                await accountsTask
                await transactionsTask
            }
        }
    }
    
    // MARK: - Launch Performance Tests
    
    func testAppLaunchPerformance() throws {
        // This measures the performance of key initialization components
        measure {
            _ = AppConfiguration.shared
            _ = NavigationState()
            _ = MockAccountRepository()
            _ = MockTransactionRepository()
        }
    }
    
    // MARK: - Helper Methods
    
    private func createLargeAccountDataset(count: Int) -> [Account] {
        return (0..<count).map { index in
            Account(
                id: "account-\(index)",
                name: "Test Account \(index)",
                type: AccountType.allCases.randomElement() ?? .checking,
                balance: Double.random(in: -1000...10000),
                currency: "BRL",
                isActive: Bool.random(),
                userId: "user-\(index % 100)",
                createdAt: Date().addingTimeInterval(Double(-index * 3600)),
                updatedAt: Date()
            )
        }
    }
    
    private func createLargeTransactionDataset(count: Int) -> [Transaction] {
        return (0..<count).map { index in
            let randomType: TransactionType = TransactionType.allCases.randomElement() ?? .expense
            let randomCategory: TransactionCategory = TransactionCategory.allCases.randomElement() ?? .other
            let timeOffset = Double(-index * 3600)
            let transactionDate = Date().addingTimeInterval(timeOffset)
            let createdDate = Date().addingTimeInterval(timeOffset)

            return Transaction(
                id: "transaction-\(index)",
                accountId: "account-\(index % 100)",
                amount: Double.random(in: 1...1000),
                description: "Test Transaction \(index)",
                category: randomCategory,
                type: randomType,
                date: transactionDate,
                isRecurring: Bool.random(),
                userId: "user-\(index % 100)",
                createdAt: createdDate,
                updatedAt: Date()
            )
        }
    }
    
    private func createDateRange(count: Int) -> [Date] {
        let now = Date()
        return (0..<count).map { index in
            Calendar.current.date(byAdding: .day, value: -index, to: now) ?? now
        }
    }
}