//
//  FirebaseAccountRepository.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 31/08/25.
//

import Foundation
import FirebaseAuth

class FirebaseAccountRepository: AccountRepositoryProtocol {
    private let firebaseService = FirebaseService.shared
    
    private func getCurrentUserID() throws -> String {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw AuthError.noCurrentUser
        }
        return userID
    }
    
    func getAccounts() async throws -> [Account] {
        let userID = try getCurrentUserID()
        
        do {
            return try await firebaseService.getAccounts(for: userID)
        } catch {
            throw FirebaseError.from(error)
        }
    }
    
    func getAccount(by id: String) async throws -> Account? {
        let accounts = try await getAccounts()
        return accounts.first { $0.id == id }
    }
    
    func addAccount(_ account: Account) async throws {
        print("🔄 FirebaseAccountRepository.addAccount called")
        
        let userID = try getCurrentUserID()
        print("🔄 Current user ID: \(userID)")
        
        let newAccount = Account(
            id: account.id,
            name: account.name,
            type: account.type,
            balance: account.balance,
            currency: account.currency,
            isActive: account.isActive,
            userId: userID,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        print("🔄 Account prepared for saving: \(newAccount.name)")
        print("🔄 Firebase path will be: /accounts/\(userID)/\(newAccount.id)")
        
        do {
            try await firebaseService.saveAccount(newAccount, for: userID)
            print("✅ Firebase service saveAccount completed")
        } catch {
            print("❌ Firebase service saveAccount failed: \(error)")
            throw FirebaseError.from(error)
        }
    }
    
    func updateAccount(_ account: Account) async throws {
        let userID = try getCurrentUserID()
        let updatedAccount = Account(
            id: account.id,
            name: account.name,
            type: account.type,
            balance: account.balance,
            currency: account.currency,
            isActive: account.isActive,
            userId: account.userId,
            createdAt: account.createdAt,
            updatedAt: Date()
        )
        
        try await firebaseService.updateAccount(updatedAccount, for: userID)
    }
    
    func deleteAccount(_ accountId: String) async throws {
        let userID = try getCurrentUserID()
        try await firebaseService.deleteAccount(accountId, for: userID)
    }
    
    func updateAccountBalance(_ accountId: String, balance: Double) async throws {
        guard let currentAccount = try await getAccount(by: accountId) else {
            throw FirebaseError.accountNotFound
        }
        
        let updatedAccount = Account(
            id: currentAccount.id,
            name: currentAccount.name,
            type: currentAccount.type,
            balance: balance,
            currency: currentAccount.currency,
            isActive: currentAccount.isActive,
            userId: currentAccount.userId,
            createdAt: currentAccount.createdAt,
            updatedAt: Date()
        )
        
        try await updateAccount(updatedAccount)
    }
    
    func getAccountsByType(_ type: AccountType) async throws -> [Account] {
        let accounts = try await getAccounts()
        return accounts.filter { $0.type == type }
    }
    
    func getTotalBalance() async throws -> Double {
        let accounts = try await getAccounts()
        return accounts.reduce(0) { $0 + $1.balance }
    }
    
    func deactivateAccount(_ accountId: String) async throws {
        guard let currentAccount = try await getAccount(by: accountId) else {
            throw FirebaseError.accountNotFound
        }
        
        let deactivatedAccount = Account(
            id: currentAccount.id,
            name: currentAccount.name,
            type: currentAccount.type,
            balance: currentAccount.balance,
            currency: currentAccount.currency,
            isActive: false,
            userId: currentAccount.userId,
            createdAt: currentAccount.createdAt,
            updatedAt: Date()
        )
        
        try await updateAccount(deactivatedAccount)
    }
    
    func activateAccount(_ accountId: String) async throws {
        guard let currentAccount = try await getAccount(by: accountId) else {
            throw FirebaseError.accountNotFound
        }
        
        let activatedAccount = Account(
            id: currentAccount.id,
            name: currentAccount.name,
            type: currentAccount.type,
            balance: currentAccount.balance,
            currency: currentAccount.currency,
            isActive: true,
            userId: currentAccount.userId,
            createdAt: currentAccount.createdAt,
            updatedAt: Date()
        )
        
        try await updateAccount(activatedAccount)
    }
}