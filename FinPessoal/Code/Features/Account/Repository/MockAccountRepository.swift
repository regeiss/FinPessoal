//
//  MockAccountRepository.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 31/08/25.
//

import Foundation

class MockAccountRepository: AccountRepositoryProtocol {
    private let mockUserId = "mock-user-123"
    private var accounts: [Account] = []
    
    init() {
        setupMockData()
    }
    
    private func setupMockData() {
        let baseDate = Date()
        accounts = [
            Account(
                id: "1",
                name: "Conta Principal",
                type: .checking,
                balance: 5420.30,
                currency: "BRL",
                isActive: true,
                userId: mockUserId,
                createdAt: baseDate.addingTimeInterval(-86400 * 30),
                updatedAt: baseDate
            ),
            Account(
                id: "2",
                name: "Poupança",
                type: .savings,
                balance: 12500.00,
                currency: "BRL",
                isActive: true,
                userId: mockUserId,
                createdAt: baseDate.addingTimeInterval(-86400 * 25),
                updatedAt: baseDate.addingTimeInterval(-86400 * 5)
            ),
            Account(
                id: "3",
                name: "Cartão Nubank",
                type: .credit,
                balance: -1250.45,
                currency: "BRL",
                isActive: true,
                userId: mockUserId,
                createdAt: baseDate.addingTimeInterval(-86400 * 20),
                updatedAt: baseDate.addingTimeInterval(-86400 * 2)
            ),
            Account(
                id: "4",
                name: "Investimentos XP",
                type: .investment,
                balance: 25780.90,
                currency: "BRL",
                isActive: true,
                userId: mockUserId,
                createdAt: baseDate.addingTimeInterval(-86400 * 15),
                updatedAt: baseDate.addingTimeInterval(-86400 * 1)
            ),
            Account(
                id: "5",
                name: "Conta Desativada",
                type: .checking,
                balance: 0.00,
                currency: "BRL",
                isActive: false,
                userId: mockUserId,
                createdAt: baseDate.addingTimeInterval(-86400 * 60),
                updatedAt: baseDate.addingTimeInterval(-86400 * 30)
            )
        ]
    }
    
    func getAccounts() async throws -> [Account] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return accounts.filter { $0.isActive }.sorted { $0.createdAt < $1.createdAt }
    }
    
    func getAccount(by id: String) async throws -> Account? {
        try await Task.sleep(nanoseconds: 200_000_000)
        return accounts.first { $0.id == id }
    }
    
    func addAccount(_ account: Account) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let newAccount = Account(
            id: account.id.isEmpty ? UUID().uuidString : account.id,
            name: account.name,
            type: account.type,
            balance: account.balance,
            currency: account.currency,
            isActive: account.isActive,
            userId: mockUserId,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        accounts.append(newAccount)
    }
    
    func updateAccount(_ account: Account) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let index = accounts.firstIndex(where: { $0.id == account.id }) else {
            throw FirebaseError.accountNotFound
        }
        
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
        
        accounts[index] = updatedAccount
    }
    
    func deleteAccount(_ accountId: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        accounts.removeAll { $0.id == accountId }
    }
    
    func updateAccountBalance(_ accountId: String, balance: Double) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else {
            throw FirebaseError.accountNotFound
        }
        
        let account = accounts[index]
        let updatedAccount = Account(
            id: account.id,
            name: account.name,
            type: account.type,
            balance: balance,
            currency: account.currency,
            isActive: account.isActive,
            userId: account.userId,
            createdAt: account.createdAt,
            updatedAt: Date()
        )
        
        accounts[index] = updatedAccount
    }
    
    func getAccountsByType(_ type: AccountType) async throws -> [Account] {
        try await Task.sleep(nanoseconds: 250_000_000)
        return accounts.filter { $0.type == type && $0.isActive }
    }
    
    func getTotalBalance() async throws -> Double {
        try await Task.sleep(nanoseconds: 200_000_000)
        return accounts.filter { $0.isActive }.reduce(0) { $0 + $1.balance }
    }
    
    func deactivateAccount(_ accountId: String) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else {
            throw FirebaseError.accountNotFound
        }
        
        let account = accounts[index]
        let deactivatedAccount = Account(
            id: account.id,
            name: account.name,
            type: account.type,
            balance: account.balance,
            currency: account.currency,
            isActive: false,
            userId: account.userId,
            createdAt: account.createdAt,
            updatedAt: Date()
        )
        
        accounts[index] = deactivatedAccount
    }
    
    func activateAccount(_ accountId: String) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else {
            throw FirebaseError.accountNotFound
        }
        
        let account = accounts[index]
        let activatedAccount = Account(
            id: account.id,
            name: account.name,
            type: account.type,
            balance: account.balance,
            currency: account.currency,
            isActive: true,
            userId: account.userId,
            createdAt: account.createdAt,
            updatedAt: Date()
        )
        
        accounts[index] = activatedAccount
    }
}