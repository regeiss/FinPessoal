//
//  FirebaseLoanRepository.swift
//  FinPessoal
//
//  Created by Claude on 28/09/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class FirebaseLoanRepository: LoanRepositoryProtocol {
  private let db = Firestore.firestore()
  private let loansCollection = "loans"
  private let paymentsCollection = "loanPayments"
  
  // MARK: - Loans
  
  func getLoans() async throws -> [Loan] {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw LoanError.userNotAuthenticated
    }
    
    let snapshot = try await db.collection(loansCollection)
      .whereField("userId", isEqualTo: userId)
      .order(by: "createdAt", descending: false)
      .getDocuments()
    
    return snapshot.documents.compactMap { document in
      try? document.data(as: Loan.self)
    }
  }
  
  func getLoan(by id: String) async throws -> Loan? {
    let document = try await db.collection(loansCollection).document(id)
      .getDocument()
    return try document.data(as: Loan.self)
  }
  
  func createLoan(_ loan: Loan) async throws -> Loan {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw LoanError.userNotAuthenticated
    }
    
    let updatedLoan = Loan(
      id: loan.id,
      name: loan.name,
      loanType: loan.loanType,
      principalAmount: loan.principalAmount,
      currentBalance: loan.currentBalance,
      interestRate: loan.interestRate,
      term: loan.term,
      startDate: loan.startDate,
      paymentDay: loan.paymentDay,
      bankName: loan.bankName,
      purpose: loan.purpose,
      isActive: loan.isActive,
      userId: userId,
      createdAt: Date(),
      updatedAt: Date()
    )
    
    try db.collection(loansCollection)
      .document(updatedLoan.id)
      .setData(from: updatedLoan)
    
    return updatedLoan
  }
  
  func updateLoan(_ loan: Loan) async throws -> Loan {
    let updatedLoan = Loan(
      id: loan.id,
      name: loan.name,
      loanType: loan.loanType,
      principalAmount: loan.principalAmount,
      currentBalance: loan.currentBalance,
      interestRate: loan.interestRate,
      term: loan.term,
      startDate: loan.startDate,
      paymentDay: loan.paymentDay,
      bankName: loan.bankName,
      purpose: loan.purpose,
      isActive: loan.isActive,
      userId: loan.userId,
      createdAt: loan.createdAt,
      updatedAt: Date()
    )
    
    try db.collection(loansCollection)
      .document(updatedLoan.id)
      .setData(from: updatedLoan, merge: true)
    
    return updatedLoan
  }
  
  func deleteLoan(id: String) async throws {
    // Delete associated payments first
    let paymentsBatch = db.batch()
    let paymentsSnapshot = try await db.collection(paymentsCollection)
      .whereField("loanId", isEqualTo: id)
      .getDocuments()
    
    for document in paymentsSnapshot.documents {
      paymentsBatch.deleteDocument(document.reference)
    }
    
    try await paymentsBatch.commit()
    
    // Delete the loan
    try await db.collection(loansCollection).document(id).delete()
  }
  
  // MARK: - Payments
  
  func getLoanPayments(for loanId: String) async throws -> [LoanPayment] {
    let snapshot = try await db.collection(paymentsCollection)
      .whereField("loanId", isEqualTo: loanId)
      .order(by: "paymentDate", descending: true)
      .getDocuments()
    
    return snapshot.documents.compactMap { document in
      try? document.data(as: LoanPayment.self)
    }
  }
  
  func createLoanPayment(_ payment: LoanPayment) async throws -> LoanPayment {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw LoanError.userNotAuthenticated
    }
    
    let updatedPayment = LoanPayment(
      id: payment.id,
      loanId: payment.loanId,
      amount: payment.amount,
      principalAmount: payment.principalAmount,
      interestAmount: payment.interestAmount,
      paymentDate: payment.paymentDate,
      paymentMethod: payment.paymentMethod,
      notes: payment.notes,
      userId: userId,
      createdAt: Date()
    )
    
    // Use a transaction to ensure data consistency
    _ = try await db.runTransaction { [weak self] transaction, errorPointer in
      guard let self = self else { return nil }
      
      do {
        // Add the payment
        let paymentRef = self.db.collection(self.paymentsCollection)
          .document(updatedPayment.id)
        try transaction.setData(
          from: updatedPayment,
          forDocument: paymentRef
        )
        
        // Update loan balance
        let loanRef = self.db.collection(self.loansCollection)
          .document(updatedPayment.loanId)
        let loanDoc = try transaction.getDocument(loanRef)
        
        if let loan = try? loanDoc.data(as: Loan.self) {
          let newBalance = max(0, loan.currentBalance - updatedPayment.principalAmount)
          
          let updatedLoan = Loan(
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
          
          try transaction.setData(
            from: updatedLoan,
            forDocument: loanRef,
            merge: true
          )
        }
        
        return nil
      } catch {
        errorPointer?.pointee = error as NSError
        return nil
      }
    }
    
    return updatedPayment
  }
  
  func updateLoanPayment(_ payment: LoanPayment) async throws -> LoanPayment {
    let updatedPayment = LoanPayment(
      id: payment.id,
      loanId: payment.loanId,
      amount: payment.amount,
      principalAmount: payment.principalAmount,
      interestAmount: payment.interestAmount,
      paymentDate: payment.paymentDate,
      paymentMethod: payment.paymentMethod,
      notes: payment.notes,
      userId: payment.userId,
      createdAt: payment.createdAt
    )
    
    try db.collection(paymentsCollection)
      .document(updatedPayment.id)
      .setData(from: updatedPayment, merge: true)
    
    return updatedPayment
  }
  
  func deleteLoanPayment(id: String) async throws {
    try await db.collection(paymentsCollection).document(id).delete()
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

enum LoanError: LocalizedError {
  case userNotAuthenticated
  case loanNotFound
  case invalidData
  case networkError(Error)
  
  var errorDescription: String? {
    switch self {
    case .userNotAuthenticated:
      return String(localized: "loan.error.not_authenticated")
    case .loanNotFound:
      return String(localized: "loan.error.not_found")
    case .invalidData:
      return String(localized: "loan.error.invalid_data")
    case .networkError(let error):
      return String(localized: "loan.error.network")
        + ": \(error.localizedDescription)"
    }
  }
}

