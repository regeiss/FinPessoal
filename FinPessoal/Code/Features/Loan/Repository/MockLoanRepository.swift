//
//  MockLoanRepository.swift
//  FinPessoal
//
//  Created by Claude on 28/09/25.
//

import Foundation

class MockLoanRepository: LoanRepositoryProtocol {
  private var loans: [Loan] = []
  private var payments: [LoanPayment] = []
  
  init() {
    createMockData()
  }
  
  private func createMockData() {
    let calendar = Calendar.current
    let startDate1 = calendar.date(byAdding: .month, value: -12, to: Date()) ?? Date()
    let startDate2 = calendar.date(byAdding: .month, value: -6, to: Date()) ?? Date()
    
    loans = [
      Loan(
        name: "Financiamento Imobiliário",
        loanType: .home,
        principalAmount: 250000,
        currentBalance: 235000,
        interestRate: 8.5,
        term: 360,
        startDate: startDate1,
        paymentDay: 15,
        bankName: "Banco do Brasil",
        purpose: "Compra de imóvel residencial",
        userId: "mock_user"
      ),
      Loan(
        name: "Financiamento Veículo",
        loanType: .auto,
        principalAmount: 45000,
        currentBalance: 38000,
        interestRate: 12.0,
        term: 48,
        startDate: startDate2,
        paymentDay: 10,
        bankName: "Itaú",
        purpose: "Compra de veículo 0km",
        userId: "mock_user"
      ),
      Loan(
        name: "Empréstimo Pessoal",
        loanType: .personal,
        principalAmount: 15000,
        currentBalance: 0,
        interestRate: 15.5,
        term: 24,
        startDate: calendar.date(byAdding: .month, value: -24, to: Date()) ?? Date(),
        paymentDay: 5,
        bankName: "Santander",
        purpose: "Reforma da casa",
        isActive: false,
        userId: "mock_user"
      )
    ]
    
    // Create some mock payments
    for loan in loans {
      let paymentCount = Int.random(in: 1...5)
      for i in 0..<paymentCount {
        let paymentDate = calendar.date(byAdding: .month, value: -i, to: Date()) ?? Date()
        let payment = LoanPayment(
          loanId: loan.id,
          amount: loan.monthlyPayment,
          principalAmount: loan.monthlyPayment * 0.7,
          interestAmount: loan.monthlyPayment * 0.3,
          paymentDate: paymentDate,
          paymentMethod: "Débito Automático",
          userId: "mock_user"
        )
        payments.append(payment)
      }
    }
  }
  
  // MARK: - Loans
  
  func getLoans() async throws -> [Loan] {
    try await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
    return loans.sorted { $0.createdAt > $1.createdAt }
  }
  
  func getLoan(by id: String) async throws -> Loan? {
    try await Task.sleep(nanoseconds: 300_000_000)
    return loans.first { $0.id == id }
  }
  
  func createLoan(_ loan: Loan) async throws -> Loan {
    try await Task.sleep(nanoseconds: 500_000_000)
    loans.append(loan)
    return loan
  }
  
  func updateLoan(_ loan: Loan) async throws -> Loan {
    try await Task.sleep(nanoseconds: 400_000_000)
    if let index = loans.firstIndex(where: { $0.id == loan.id }) {
      loans[index] = loan
    }
    return loan
  }
  
  func deleteLoan(id: String) async throws {
    try await Task.sleep(nanoseconds: 400_000_000)
    loans.removeAll { $0.id == id }
    payments.removeAll { $0.loanId == id }
  }
  
  // MARK: - Payments
  
  func getLoanPayments(for loanId: String) async throws -> [LoanPayment] {
    try await Task.sleep(nanoseconds: 300_000_000)
    return payments
      .filter { $0.loanId == loanId }
      .sorted { $0.paymentDate > $1.paymentDate }
  }
  
  func createLoanPayment(_ payment: LoanPayment) async throws -> LoanPayment {
    try await Task.sleep(nanoseconds: 400_000_000)
    payments.append(payment)
    
    // Update loan balance
    if let loanIndex = loans.firstIndex(where: { $0.id == payment.loanId }) {
      let updatedBalance = max(0, loans[loanIndex].currentBalance - payment.principalAmount)
      loans[loanIndex] = Loan(
        id: loans[loanIndex].id,
        name: loans[loanIndex].name,
        loanType: loans[loanIndex].loanType,
        principalAmount: loans[loanIndex].principalAmount,
        currentBalance: updatedBalance,
        interestRate: loans[loanIndex].interestRate,
        term: loans[loanIndex].term,
        startDate: loans[loanIndex].startDate,
        paymentDay: loans[loanIndex].paymentDay,
        bankName: loans[loanIndex].bankName,
        purpose: loans[loanIndex].purpose,
        isActive: updatedBalance > 0,
        userId: loans[loanIndex].userId,
        createdAt: loans[loanIndex].createdAt,
        updatedAt: Date()
      )
    }
    
    return payment
  }
  
  func updateLoanPayment(_ payment: LoanPayment) async throws -> LoanPayment {
    try await Task.sleep(nanoseconds: 400_000_000)
    if let index = payments.firstIndex(where: { $0.id == payment.id }) {
      payments[index] = payment
    }
    return payment
  }
  
  func deleteLoanPayment(id: String) async throws {
    try await Task.sleep(nanoseconds: 300_000_000)
    payments.removeAll { $0.id == id }
  }
  
  // MARK: - Amortization
  
  func generateAmortizationSchedule(for loan: Loan) -> [LoanAmortizationEntry] {
    var schedule: [LoanAmortizationEntry] = []
    var remainingBalance = loan.principalAmount
    let monthlyRate = loan.interestRate / 100 / 12
    let calendar = Calendar.current
    
    for paymentNumber in 1...loan.term {
      let paymentDate = calendar.date(byAdding: .month, value: paymentNumber - 1, to: loan.startDate) ?? loan.startDate
      
      let interestPayment = remainingBalance * monthlyRate
      let principalPayment = loan.monthlyPayment - interestPayment
      remainingBalance = max(0, remainingBalance - principalPayment)
      
      let entry = LoanAmortizationEntry(
        paymentNumber: paymentNumber,
        paymentDate: paymentDate,
        totalPayment: loan.monthlyPayment,
        principalPayment: principalPayment,
        interestPayment: interestPayment,
        remainingBalance: remainingBalance
      )
      
      schedule.append(entry)
      
      if remainingBalance <= 0 {
        break
      }
    }
    
    return schedule
  }
}