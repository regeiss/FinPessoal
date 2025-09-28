//
//  LoanRepositoryProtocol.swift
//  FinPessoal
//
//  Created by Claude on 28/09/25.
//

import Foundation

protocol LoanRepositoryProtocol {
  // MARK: - Loans
  func getLoans() async throws -> [Loan]
  func getLoan(by id: String) async throws -> Loan?
  func createLoan(_ loan: Loan) async throws -> Loan
  func updateLoan(_ loan: Loan) async throws -> Loan
  func deleteLoan(id: String) async throws
  
  // MARK: - Payments
  func getLoanPayments(for loanId: String) async throws -> [LoanPayment]
  func createLoanPayment(_ payment: LoanPayment) async throws -> LoanPayment
  func updateLoanPayment(_ payment: LoanPayment) async throws -> LoanPayment
  func deleteLoanPayment(id: String) async throws
  
  // MARK: - Amortization
  func generateAmortizationSchedule(for loan: Loan) -> [LoanAmortizationEntry]
}