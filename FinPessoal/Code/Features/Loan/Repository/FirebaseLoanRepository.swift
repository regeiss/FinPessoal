//
//  FirebaseLoanRepository.swift
//  FinPessoal
//
//  Created by Claude on 28/09/25.
//  Converted to Realtime Database on 24/12/25
//

import FirebaseAuth
import FirebaseDatabase
import Foundation

class FirebaseLoanRepository: LoanRepositoryProtocol {
  private let database = Database.database().reference()
  private let loansPath = "loans"

  // MARK: - Loans

  func getLoans() async throws -> [Loan] {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw LoanError.userNotAuthenticated
    }

    let snapshot = try await database
      .child(loansPath)
      .child(userId)
      .getData()

    guard let data = snapshot.value as? [String: [String: Any]] else {
      return []
    }

    let loans = try data.compactMap { (loanId, loanData) -> Loan? in
      var mutableData = loanData
      mutableData["id"] = loanId
      return try Loan.fromDictionary(mutableData)
    }

    return loans.sorted { $0.createdAt < $1.createdAt }
  }

  func getLoan(by id: String) async throws -> Loan? {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw LoanError.userNotAuthenticated
    }

    let snapshot = try await database
      .child(loansPath)
      .child(userId)
      .child(id)
      .getData()

    guard let data = snapshot.value as? [String: Any] else {
      return nil
    }

    var mutableData = data
    mutableData["id"] = id
    return try Loan.fromDictionary(mutableData)
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

    let loanData = try updatedLoan.toDictionary()

    try await database
      .child(loansPath)
      .child(userId)
      .child(updatedLoan.id)
      .setValue(loanData)

    return updatedLoan
  }

  func updateLoan(_ loan: Loan) async throws -> Loan {
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
      userId: loan.userId,
      createdAt: loan.createdAt,
      updatedAt: Date()
    )

    let loanData = try updatedLoan.toDictionary()

    try await database
      .child(loansPath)
      .child(userId)
      .child(updatedLoan.id)
      .updateChildValues(loanData)

    return updatedLoan
  }

  func deleteLoan(id: String) async throws {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw LoanError.userNotAuthenticated
    }

    try await database
      .child(loansPath)
      .child(userId)
      .child(id)
      .removeValue()
  }

  // MARK: - Loan Payments

  func getLoanPayments(for loanId: String) async throws -> [LoanPayment] {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw LoanError.userNotAuthenticated
    }

    let snapshot = try await database
      .child("loanPayments")
      .child(userId)
      .child(loanId)
      .getData()

    guard let data = snapshot.value as? [String: [String: Any]] else {
      return []
    }

    let payments = try data.compactMap { (paymentId, paymentData) -> LoanPayment? in
      var mutableData = paymentData
      mutableData["id"] = paymentId
      return try LoanPayment.fromDictionary(mutableData)
    }

    return payments.sorted { $0.paymentDate < $1.paymentDate }
  }

  func createLoanPayment(_ payment: LoanPayment) async throws -> LoanPayment {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw LoanError.userNotAuthenticated
    }

    let paymentData = try payment.toDictionary()

    try await database
      .child("loanPayments")
      .child(userId)
      .child(payment.loanId)
      .child(payment.id)
      .setValue(paymentData)

    return payment
  }

  func updateLoanPayment(_ payment: LoanPayment) async throws -> LoanPayment {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw LoanError.userNotAuthenticated
    }

    let paymentData = try payment.toDictionary()

    try await database
      .child("loanPayments")
      .child(userId)
      .child(payment.loanId)
      .child(payment.id)
      .updateChildValues(paymentData)

    return payment
  }

  func deleteLoanPayment(id: String) async throws {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw LoanError.userNotAuthenticated
    }

    // Find and delete the payment across all loans
    let snapshot = try await database
      .child("loanPayments")
      .child(userId)
      .getData()

    guard let loansData = snapshot.value as? [String: [String: Any]] else {
      return
    }

    for (loanId, _) in loansData {
      _ = try? await database
        .child("loanPayments")
        .child(userId)
        .child(loanId)
        .child(id)
        .removeValue()
    }
  }

  // MARK: - Amortization

  func generateAmortizationSchedule(for loan: Loan) -> [LoanAmortizationEntry] {
    var schedule: [LoanAmortizationEntry] = []
    var remainingBalance = loan.principalAmount
    let monthlyRate = loan.interestRate / 100 / 12
    let monthlyPayment = loan.monthlyPayment
    let calendar = Calendar.current

    for month in 1...loan.term {
      let interestPayment = remainingBalance * monthlyRate
      let principalPayment = monthlyPayment - interestPayment
      remainingBalance -= principalPayment

      // Calculate payment date for this month
      let paymentDate = calendar.date(byAdding: .month, value: month - 1, to: loan.startDate) ?? loan.startDate

      let entry = LoanAmortizationEntry(
        paymentNumber: month,
        paymentDate: paymentDate,
        totalPayment: monthlyPayment,
        principalPayment: principalPayment,
        interestPayment: interestPayment,
        remainingBalance: max(0, remainingBalance),
        isPaid: false
      )
      schedule.append(entry)
    }

    return schedule
  }
}

enum LoanError: LocalizedError {
  case userNotAuthenticated
  case loanNotFound
  case invalidData

  var errorDescription: String? {
    switch self {
    case .userNotAuthenticated:
      return "User not authenticated"
    case .loanNotFound:
      return "Loan not found"
    case .invalidData:
      return "Invalid loan data"
    }
  }
}
