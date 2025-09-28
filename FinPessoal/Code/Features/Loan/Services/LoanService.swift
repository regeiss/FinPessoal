//
//  LoanService.swift
//  FinPessoal
//
//  Created by Claude on 28/09/25.
//

import Foundation
import Combine

@MainActor
class LoanService: ObservableObject {
  @Published var loans: [Loan] = []
  @Published var isLoading = false
  @Published var errorMessage: String?
  
  private let repository: LoanRepositoryProtocol
  
  init(repository: LoanRepositoryProtocol) {
    self.repository = repository
  }
  
  // MARK: - Loans
  
  func loadLoans() async {
    isLoading = true
    errorMessage = nil
    
    do {
      loans = try await repository.getLoans()
    } catch {
      errorMessage = error.localizedDescription
    }
    
    isLoading = false
  }
  
  func createLoan(_ loan: Loan) async -> Bool {
    isLoading = true
    errorMessage = nil
    
    do {
      let createdLoan = try await repository.createLoan(loan)
      loans.append(createdLoan)
      loans.sort { $0.createdAt > $1.createdAt }
      isLoading = false
      return true
    } catch {
      errorMessage = error.localizedDescription
      isLoading = false
      return false
    }
  }
  
  func updateLoan(_ loan: Loan) async -> Bool {
    isLoading = true
    errorMessage = nil
    
    do {
      let updatedLoan = try await repository.updateLoan(loan)
      if let index = loans.firstIndex(where: { $0.id == loan.id }) {
        loans[index] = updatedLoan
      }
      isLoading = false
      return true
    } catch {
      errorMessage = error.localizedDescription
      isLoading = false
      return false
    }
  }
  
  func deleteLoan(_ loan: Loan) async -> Bool {
    isLoading = true
    errorMessage = nil
    
    do {
      try await repository.deleteLoan(id: loan.id)
      loans.removeAll { $0.id == loan.id }
      isLoading = false
      return true
    } catch {
      errorMessage = error.localizedDescription
      isLoading = false
      return false
    }
  }
  
  // MARK: - Payments
  
  func getPayments(for loanId: String) async -> [LoanPayment] {
    do {
      return try await repository.getLoanPayments(for: loanId)
    } catch {
      errorMessage = error.localizedDescription
      return []
    }
  }
  
  func makePayment(_ payment: LoanPayment) async -> Bool {
    isLoading = true
    errorMessage = nil
    
    do {
      _ = try await repository.createLoanPayment(payment)
      
      // Update the loan in our local list
      if let loanIndex = loans.firstIndex(where: { $0.id == payment.loanId }) {
        let loan = loans[loanIndex]
        let newBalance = max(0, loan.currentBalance - payment.principalAmount)
        
        loans[loanIndex] = Loan(
          id: loan.id,
          name: loan.name,
          loanType: loan.loanType,
          principalAmount: loan.principalAmount,
          currentBalance: newBalance,
          interestRate: loan.interestRate,
          term: loan.term,
          startDate: loan.startDate,
          paymentDay: loan.paymentDay,
          bankName: loan.bankName,
          purpose: loan.purpose,
          isActive: newBalance > 0,
          userId: loan.userId,
          createdAt: loan.createdAt,
          updatedAt: Date()
        )
      }
      
      isLoading = false
      return true
    } catch {
      errorMessage = error.localizedDescription
      isLoading = false
      return false
    }
  }
  
  // MARK: - Analytics
  
  func getTotalLoanAmount() -> Double {
    return loans.reduce(0) { $0 + $1.principalAmount }
  }
  
  func getTotalCurrentBalance() -> Double {
    return loans
      .filter { $0.isActive }
      .reduce(0) { $0 + $1.currentBalance }
  }
  
  func getTotalMonthlyPayments() -> Double {
    return loans
      .filter { $0.isActive }
      .reduce(0) { $0 + $1.monthlyPayment }
  }
  
  func getTotalInterestPaid() -> Double {
    return loans.reduce(0) { $0 + $1.totalInterestPaid }
  }
  
  func getActiveLoans() -> [Loan] {
    return loans.filter { $0.isActive }
  }
  
  func getInactiveLoans() -> [Loan] {
    return loans.filter { !$0.isActive }
  }
  
  func getLoansDueSoon() -> [Loan] {
    let calendar = Calendar.current
    let today = Date()
    
    return loans.filter { loan in
      guard loan.isActive else { return false }
      let daysUntilPayment = calendar.dateComponents([.day], from: today, to: loan.nextPaymentDate).day ?? 0
      return daysUntilPayment <= 7
    }
  }
  
  func getLoansByType() -> [LoanType: [Loan]] {
    return Dictionary(grouping: loans.filter { $0.isActive }) { $0.loanType }
  }
  
  // MARK: - Amortization
  
  func getAmortizationSchedule(for loan: Loan) -> [LoanAmortizationEntry] {
    return repository.generateAmortizationSchedule(for: loan)
  }
  
  // MARK: - Utility
  
  func clearError() {
    errorMessage = nil
  }
  
  func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "BRL"
    formatter.locale = Locale(identifier: "pt_BR")
    return formatter.string(from: NSNumber(value: amount)) ?? "R$ 0,00"
  }
}