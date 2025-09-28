//
//  FirebaseCreditCardRepository.swift
//  FinPessoal
//
//  Created by Claude on 25/09/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class FirebaseCreditCardRepository: CreditCardRepositoryProtocol {
  private let db = Firestore.firestore()
  private let creditCardsCollection = "creditCards"
  private let transactionsCollection = "creditCardTransactions"
  private let statementsCollection = "creditCardStatements"

  // MARK: - Credit Cards

  func getCreditCards() async throws -> [CreditCard] {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CreditCardError.userNotAuthenticated
    }

    let snapshot = try await db.collection(creditCardsCollection)
      .whereField("userId", isEqualTo: userId)
      .order(by: "createdAt", descending: false)
      .getDocuments()

    return snapshot.documents.compactMap { document in
      try? document.data(as: CreditCard.self)
    }
  }

  func getCreditCard(by id: String) async throws -> CreditCard? {
    let document = try await db.collection(creditCardsCollection).document(id)
      .getDocument()
    return try document.data(as: CreditCard.self)
  }

  func createCreditCard(_ creditCard: CreditCard) async throws -> CreditCard {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CreditCardError.userNotAuthenticated
    }

    let updatedCreditCard = CreditCard(
      id: creditCard.id,
      name: creditCard.name,
      lastFourDigits: creditCard.lastFourDigits,
      brand: creditCard.brand,
      creditLimit: creditCard.creditLimit,
      availableCredit: creditCard.availableCredit,
      currentBalance: creditCard.currentBalance,
      dueDate: creditCard.dueDate,
      closingDate: creditCard.closingDate,
      minimumPayment: creditCard.minimumPayment,
      annualFee: creditCard.annualFee,
      interestRate: creditCard.interestRate,
      isActive: creditCard.isActive,
      userId: userId,
      createdAt: Date(),
      updatedAt: Date()
    )

    try await db.collection(creditCardsCollection)
      .document(updatedCreditCard.id)
      .setData(from: updatedCreditCard)

    return updatedCreditCard
  }

  func updateCreditCard(_ creditCard: CreditCard) async throws -> CreditCard {
    let updatedCreditCard = CreditCard(
      id: creditCard.id,
      name: creditCard.name,
      lastFourDigits: creditCard.lastFourDigits,
      brand: creditCard.brand,
      creditLimit: creditCard.creditLimit,
      availableCredit: creditCard.availableCredit,
      currentBalance: creditCard.currentBalance,
      dueDate: creditCard.dueDate,
      closingDate: creditCard.closingDate,
      minimumPayment: creditCard.minimumPayment,
      annualFee: creditCard.annualFee,
      interestRate: creditCard.interestRate,
      isActive: creditCard.isActive,
      userId: creditCard.userId,
      createdAt: creditCard.createdAt,
      updatedAt: Date()
    )

    try await db.collection(creditCardsCollection)
      .document(updatedCreditCard.id)
      .setData(from: updatedCreditCard, merge: true)

    return updatedCreditCard
  }

  func deleteCreditCard(id: String) async throws {
    // Delete associated transactions and statements first
    let transactionsBatch = db.batch()
    let transactionsSnapshot = try await db.collection(transactionsCollection)
      .whereField("creditCardId", isEqualTo: id)
      .getDocuments()

    for document in transactionsSnapshot.documents {
      transactionsBatch.deleteDocument(document.reference)
    }

    let statementsBatch = db.batch()
    let statementsSnapshot = try await db.collection(statementsCollection)
      .whereField("creditCardId", isEqualTo: id)
      .getDocuments()

    for document in statementsSnapshot.documents {
      statementsBatch.deleteDocument(document.reference)
    }

    try await transactionsBatch.commit()
    try await statementsBatch.commit()

    // Delete the credit card
    try await db.collection(creditCardsCollection).document(id).delete()
  }

  // MARK: - Transactions

  func getCreditCardTransactions(for creditCardId: String) async throws
    -> [CreditCardTransaction]
  {
    let snapshot = try await db.collection(transactionsCollection)
      .whereField("creditCardId", isEqualTo: creditCardId)
      .order(by: "date", descending: true)
      .getDocuments()

    return snapshot.documents.compactMap { document in
      try? document.data(as: CreditCardTransaction.self)
    }
  }

  func createCreditCardTransaction(_ transaction: CreditCardTransaction)
    async throws -> CreditCardTransaction
  {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CreditCardError.userNotAuthenticated
    }

    let updatedTransaction = CreditCardTransaction(
      id: transaction.id,
      creditCardId: transaction.creditCardId,
      amount: transaction.amount,
      description: transaction.description,
      category: transaction.category,
      subcategory: transaction.subcategory,
      date: transaction.date,
      installments: transaction.installments,
      currentInstallment: transaction.currentInstallment,
      isRecurring: transaction.isRecurring,
      userId: userId,
      createdAt: Date(),
      updatedAt: Date()
    )

    // Use a transaction to ensure data consistency
    try await db.runTransaction { [weak self] transaction, errorPointer in
      guard let self = self else { return nil }

      do {
        // Add the transaction
        let transactionRef = self.db.collection(self.transactionsCollection)
          .document(updatedTransaction.id)
        try transaction.setData(
          from: updatedTransaction,
          forDocument: transactionRef
        )

        // Update credit card balance
        let creditCardRef = self.db.collection(self.creditCardsCollection)
          .document(updatedTransaction.creditCardId)
        let creditCardDoc = try transaction.getDocument(creditCardRef)

        if let creditCard = try? creditCardDoc.data(as: CreditCard.self) {
          let newBalance = creditCard.currentBalance + updatedTransaction.amount
          let newAvailableCredit = creditCard.creditLimit - newBalance

          let updatedCreditCard = CreditCard(
            id: creditCard.id,
            name: creditCard.name,
            lastFourDigits: creditCard.lastFourDigits,
            brand: creditCard.brand,
            creditLimit: creditCard.creditLimit,
            availableCredit: max(0, newAvailableCredit),
            currentBalance: newBalance,
            dueDate: creditCard.dueDate,
            closingDate: creditCard.closingDate,
            minimumPayment: max(creditCard.minimumPayment, newBalance * 0.02),
            annualFee: creditCard.annualFee,
            interestRate: creditCard.interestRate,
            isActive: creditCard.isActive,
            userId: creditCard.userId,
            createdAt: creditCard.createdAt,
            updatedAt: Date()
          )

          try transaction.setData(
            from: updatedCreditCard,
            forDocument: creditCardRef,
            merge: true
          )
        }

        return nil
      } catch {
        errorPointer?.pointee = error as NSError
        return nil
      }
    }

    return updatedTransaction
  }

  func updateCreditCardTransaction(_ transaction: CreditCardTransaction)
    async throws -> CreditCardTransaction
  {
    let updatedTransaction = CreditCardTransaction(
      id: transaction.id,
      creditCardId: transaction.creditCardId,
      amount: transaction.amount,
      description: transaction.description,
      category: transaction.category,
      subcategory: transaction.subcategory,
      date: transaction.date,
      installments: transaction.installments,
      currentInstallment: transaction.currentInstallment,
      isRecurring: transaction.isRecurring,
      userId: transaction.userId,
      createdAt: transaction.createdAt,
      updatedAt: Date()
    )

    try await db.collection(transactionsCollection)
      .document(updatedTransaction.id)
      .setData(from: updatedTransaction, merge: true)

    return updatedTransaction
  }

  func deleteCreditCardTransaction(id: String) async throws {
    try await db.collection(transactionsCollection).document(id).delete()
  }

  // MARK: - Statements

  func getCreditCardStatements(for creditCardId: String) async throws
    -> [CreditCardStatement]
  {
    let snapshot = try await db.collection(statementsCollection)
      .whereField("creditCardId", isEqualTo: creditCardId)
      .order(by: "createdAt", descending: true)
      .getDocuments()

    return snapshot.documents.compactMap { document in
      try? document.data(as: CreditCardStatement.self)
    }
  }

  func generateStatement(for creditCardId: String, period: StatementPeriod)
    async throws -> CreditCardStatement
  {
    let transactionsSnapshot = try await db.collection(transactionsCollection)
      .whereField("creditCardId", isEqualTo: creditCardId)
      .whereField("date", isGreaterThanOrEqualTo: period.startDate)
      .whereField("date", isLessThanOrEqualTo: period.endDate)
      .getDocuments()

    let periodTransactions = transactionsSnapshot.documents.compactMap {
      document in
      try? document.data(as: CreditCardTransaction.self)
    }

    let totalAmount = periodTransactions.reduce(0) { $0 + $1.amount }

    let statement = CreditCardStatement(
      id: UUID().uuidString,
      creditCardId: creditCardId,
      period: period,
      transactions: periodTransactions,
      totalAmount: totalAmount,
      minimumPayment: totalAmount * 0.02,
      dueDate: Calendar.current.date(
        byAdding: .day,
        value: 20,
        to: period.endDate
      ) ?? Date(),
      isPaid: false,
      paidAmount: 0,
      paidDate: nil,
      createdAt: Date()
    )

    try await db.collection(statementsCollection)
      .document(statement.id)
      .setData(from: statement)

    return statement
  }

  func payStatement(_ statement: CreditCardStatement, amount: Double)
    async throws -> CreditCardStatement
  {
    let updatedStatement = CreditCardStatement(
      id: statement.id,
      creditCardId: statement.creditCardId,
      period: statement.period,
      transactions: statement.transactions,
      totalAmount: statement.totalAmount,
      minimumPayment: statement.minimumPayment,
      dueDate: statement.dueDate,
      isPaid: amount >= statement.totalAmount,
      paidAmount: statement.paidAmount + amount,
      paidDate: Date(),
      createdAt: statement.createdAt
    )

    // Use a transaction to ensure data consistency
    try await db.runTransaction { [weak self] transaction, errorPointer in
      guard let self = self else { return nil }

      do {
        // Update statement
        let statementRef = self.db.collection(self.statementsCollection).document(
          updatedStatement.id
        )
        try transaction.setData(
          from: updatedStatement,
          forDocument: statementRef,
          merge: true
        )

        // Update credit card balance
        let creditCardRef = self.db.collection(self.creditCardsCollection)
          .document(updatedStatement.creditCardId)
        let creditCardDoc = try transaction.getDocument(creditCardRef)

        if let creditCard = try? creditCardDoc.data(as: CreditCard.self) {
          let newBalance = max(0, creditCard.currentBalance - amount)
          let newAvailableCredit = creditCard.creditLimit - newBalance

          let updatedCreditCard = CreditCard(
            id: creditCard.id,
            name: creditCard.name,
            lastFourDigits: creditCard.lastFourDigits,
            brand: creditCard.brand,
            creditLimit: creditCard.creditLimit,
            availableCredit: newAvailableCredit,
            currentBalance: newBalance,
            dueDate: creditCard.dueDate,
            closingDate: creditCard.closingDate,
            minimumPayment: max(0, newBalance * 0.02),
            annualFee: creditCard.annualFee,
            interestRate: creditCard.interestRate,
            isActive: creditCard.isActive,
            userId: creditCard.userId,
            createdAt: creditCard.createdAt,
            updatedAt: Date()
          )

          try transaction.setData(
            from: updatedCreditCard,
            forDocument: creditCardRef,
            merge: true
          )
        }

        return nil
      } catch {
        errorPointer?.pointee = error as NSError
        return nil
      }
    }

    return updatedStatement
  }
}

enum CreditCardError: LocalizedError {
  case userNotAuthenticated
  case creditCardNotFound
  case invalidData
  case networkError(Error)

  var errorDescription: String? {
    switch self {
    case .userNotAuthenticated:
      return String(localized: "creditcard.error.not_authenticated")
    case .creditCardNotFound:
      return String(localized: "creditcard.error.not_found")
    case .invalidData:
      return String(localized: "creditcard.error.invalid_data")
    case .networkError(let error):
      return String(localized: "creditcard.error.network")
        + ": \(error.localizedDescription)"
    }
  }
}
