//
//  CreditCardRepositoryProtocol.swift
//  FinPessoal
//
//  Created by Claude on 25/09/25.
//

import Foundation
import Combine

protocol CreditCardRepositoryProtocol {
    func getCreditCards() async throws -> [CreditCard]
    func getCreditCard(by id: String) async throws -> CreditCard?
    func createCreditCard(_ creditCard: CreditCard) async throws -> CreditCard
    func updateCreditCard(_ creditCard: CreditCard) async throws -> CreditCard
    func deleteCreditCard(id: String) async throws
    
    // Transactions
    func getCreditCardTransactions(for creditCardId: String) async throws -> [CreditCardTransaction]
    func createCreditCardTransaction(_ transaction: CreditCardTransaction) async throws -> CreditCardTransaction
    func updateCreditCardTransaction(_ transaction: CreditCardTransaction) async throws -> CreditCardTransaction
    func deleteCreditCardTransaction(id: String) async throws
    
    // Statements
    func getCreditCardStatements(for creditCardId: String) async throws -> [CreditCardStatement]
    func generateStatement(for creditCardId: String, period: StatementPeriod) async throws -> CreditCardStatement
    func payStatement(_ statement: CreditCardStatement, amount: Double) async throws -> CreditCardStatement
}