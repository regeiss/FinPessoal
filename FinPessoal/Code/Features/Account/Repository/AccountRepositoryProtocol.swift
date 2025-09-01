//
//  AccountRepositoryProtocol.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 31/08/25.
//

import Foundation

protocol AccountRepositoryProtocol {
    func getAccounts() async throws -> [Account]
    func getAccount(by id: String) async throws -> Account?
    func addAccount(_ account: Account) async throws
    func updateAccount(_ account: Account) async throws
    func deleteAccount(_ accountId: String) async throws
    func updateAccountBalance(_ accountId: String, balance: Double) async throws
    func getAccountsByType(_ type: AccountType) async throws -> [Account]
    func getTotalBalance() async throws -> Double
    func deactivateAccount(_ accountId: String) async throws
    func activateAccount(_ accountId: String) async throws
}