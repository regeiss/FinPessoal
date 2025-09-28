//
//  CreditCardService.swift
//  FinPessoal
//
//  Created by Claude on 25/09/25.
//

import Foundation
import Combine

class CreditCardService: ObservableObject {
    private let repository: CreditCardRepositoryProtocol
    
    @Published var creditCards: [CreditCard] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: CreditCardRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Credit Card Management
    
    func loadCreditCards() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let cards = try await repository.getCreditCards()
            await MainActor.run {
                self.creditCards = cards
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func createCreditCard(_ creditCard: CreditCard) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let newCard = try await repository.createCreditCard(creditCard)
            await MainActor.run {
                self.creditCards.append(newCard)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func updateCreditCard(_ creditCard: CreditCard) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let updatedCard = try await repository.updateCreditCard(creditCard)
            await MainActor.run {
                if let index = self.creditCards.firstIndex(where: { $0.id == updatedCard.id }) {
                    self.creditCards[index] = updatedCard
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func deleteCreditCard(id: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            try await repository.deleteCreditCard(id: id)
            await MainActor.run {
                self.creditCards.removeAll { $0.id == id }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Transaction Management
    
    func createTransaction(_ transaction: CreditCardTransaction) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            _ = try await repository.createCreditCardTransaction(transaction)
            
            // Reload credit cards to update balances
            await loadCreditCards()
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func getTransactions(for creditCardId: String) async -> [CreditCardTransaction] {
        do {
            return try await repository.getCreditCardTransactions(for: creditCardId)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return []
        }
    }
    
    // MARK: - Statement Management
    
    func generateStatement(for creditCardId: String, period: StatementPeriod) async -> CreditCardStatement? {
        do {
            return try await repository.generateStatement(for: creditCardId, period: period)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return nil
        }
    }
    
    func payStatement(_ statement: CreditCardStatement, amount: Double) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            _ = try await repository.payStatement(statement, amount: amount)
            
            // Reload credit cards to update balances
            await loadCreditCards()
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Utility Methods
    
    func calculateMonthlyUtilization() -> Double {
        guard !creditCards.isEmpty else { return 0 }
        
        let totalLimit = creditCards.reduce(0) { $0 + $1.creditLimit }
        let totalUsed = creditCards.reduce(0) { $0 + $1.usedCredit }
        
        guard totalLimit > 0 else { return 0 }
        return (totalUsed / totalLimit) * 100
    }
    
    func getTotalCreditLimit() -> Double {
        creditCards.reduce(0) { $0 + $1.creditLimit }
    }
    
    func getTotalAvailableCredit() -> Double {
        creditCards.reduce(0) { $0 + $1.availableCredit }
    }
    
    func getTotalCurrentBalance() -> Double {
        creditCards.reduce(0) { $0 + $1.currentBalance }
    }
    
    func getTotalMinimumPayment() -> Double {
        creditCards.reduce(0) { $0 + $1.minimumPayment }
    }
    
    func getCardsDueSoon(days: Int = 5) -> [CreditCard] {
        let calendar = Calendar.current
        let today = Date()
        
        return creditCards.filter { card in
            let daysUntilDue = calendar.dateComponents([.day], from: today, to: card.nextDueDate).day ?? 0
            return daysUntilDue <= days && daysUntilDue >= 0 && card.currentBalance > 0
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}