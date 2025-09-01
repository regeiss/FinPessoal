//
//  AccountViewModel.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 31/08/25.
//

import Foundation
import Combine

@MainActor
class AccountViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingAddAccount: Bool = false
    @Published var selectedAccount: Account?
    @Published var showingAccountDetail: Bool = false
    @Published var totalBalance: Double = 0.0
    
    private let repository: AccountRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: AccountRepositoryProtocol) {
        self.repository = repository
        setupBindings()
    }
    
    private func setupBindings() {
        $accounts
            .map { accounts in
                accounts.reduce(0) { $0 + $1.balance }
            }
            .assign(to: \.totalBalance, on: self)
            .store(in: &cancellables)
    }
    
    func loadAccounts() {
        Task {
            await fetchAccounts()
        }
    }
    
    func fetchAccounts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedAccounts = try await repository.getAccounts()
            accounts = fetchedAccounts
        } catch let authError as AuthError {
            // Handle authentication errors specifically
            errorMessage = authError.errorDescription ?? "Authentication error"
            print("Auth error fetching accounts: \(authError)")
        } catch let firebaseError as FirebaseError {
            // Handle Firebase errors specifically  
            errorMessage = firebaseError.errorDescription ?? "Database error"
            print("Firebase error fetching accounts: \(firebaseError)")
        } catch {
            // Handle other errors
            errorMessage = error.localizedDescription
            print("Error fetching accounts: \(error)")
        }
        
        isLoading = false
    }
    
    func addAccount(_ account: Account) async -> Bool {
        do {
            print("🔄 Attempting to add account: \(account.name)")
            print("🔄 Account ID: \(account.id)")
            print("🔄 User ID: \(account.userId)")
            
            try await repository.addAccount(account)
            
            print("✅ Account added successfully")
            await fetchAccounts()
            return true
        } catch let authError as AuthError {
            errorMessage = authError.errorDescription ?? "Authentication error"
            print("❌ Auth error adding account: \(authError)")
            print("❌ Auth error description: \(authError.localizedDescription)")
            return false
        } catch let firebaseError as FirebaseError {
            errorMessage = firebaseError.errorDescription ?? "Database error"
            print("❌ Firebase error adding account: \(firebaseError)")
            print("❌ Firebase error description: \(firebaseError.localizedDescription)")
            return false
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error adding account: \(error)")
            print("❌ Error details: \(error)")
            return false
        }
    }
    
    func updateAccount(_ account: Account) async -> Bool {
        do {
            try await repository.updateAccount(account)
            await fetchAccounts()
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Error updating account: \(error)")
            return false
        }
    }
    
    func deleteAccount(_ accountId: String) async -> Bool {
        do {
            try await repository.deleteAccount(accountId)
            await fetchAccounts()
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Error deleting account: \(error)")
            return false
        }
    }
    
    func deactivateAccount(_ accountId: String) async -> Bool {
        do {
            try await repository.deactivateAccount(accountId)
            await fetchAccounts()
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Error deactivating account: \(error)")
            return false
        }
    }
    
    func activateAccount(_ accountId: String) async -> Bool {
        do {
            try await repository.activateAccount(accountId)
            await fetchAccounts()
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Error activating account: \(error)")
            return false
        }
    }
    
    func updateAccountBalance(_ accountId: String, balance: Double) async -> Bool {
        do {
            try await repository.updateAccountBalance(accountId, balance: balance)
            await fetchAccounts()
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Error updating account balance: \(error)")
            return false
        }
    }
    
    func getAccountsByType(_ type: AccountType) async -> [Account] {
        do {
            return try await repository.getAccountsByType(type)
        } catch {
            errorMessage = error.localizedDescription
            print("Error getting accounts by type: \(error)")
            return []
        }
    }
    
    func selectAccount(_ account: Account) {
        selectedAccount = account
        showingAccountDetail = true
    }
    
    func showAddAccount() {
        showingAddAccount = true
    }
    
    func dismissAddAccount() {
        showingAddAccount = false
    }
    
    func dismissAccountDetail() {
        showingAccountDetail = false
        selectedAccount = nil
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    var accountsByType: [AccountType: [Account]] {
        Dictionary(grouping: accounts) { $0.type }
    }
    
    var hasAccounts: Bool {
        !accounts.isEmpty
    }
    
    var formattedTotalBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "BRL"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: totalBalance)) ?? "R$ 0,00"
    }
    
    func refreshData() {
        Task {
            await fetchAccounts()
        }
    }
}