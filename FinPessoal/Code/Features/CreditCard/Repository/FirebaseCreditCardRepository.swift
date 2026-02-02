//
//  FirebaseCreditCardRepository.swift
//  FinPessoal
//
//  Created by Claude on 25/09/25.
//  Converted to Realtime Database on 24/12/25
//

import FirebaseAuth
import FirebaseDatabase
import Foundation

class FirebaseCreditCardRepository: CreditCardRepositoryProtocol {
  private let database = Database.database().reference()
  private let creditCardsPath = "creditCards"

  // MARK: - Credit Cards

  func getCreditCards() async throws -> [CreditCard] {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CreditCardError.userNotAuthenticated
    }

    let snapshot = try await database
      .child(creditCardsPath)
      .child(userId)
      .getData()

    guard let data = snapshot.value as? [String: [String: Any]] else {
      return []
    }

    let creditCards = try data.compactMap { (cardId, cardData) -> CreditCard? in
      var mutableData = cardData
      mutableData["id"] = cardId
      return try CreditCard.fromDictionary(mutableData)
    }

    return creditCards.sorted { $0.createdAt < $1.createdAt }
  }

  func getCreditCard(by id: String) async throws -> CreditCard? {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CreditCardError.userNotAuthenticated
    }

    let snapshot = try await database
      .child(creditCardsPath)
      .child(userId)
      .child(id)
      .getData()

    guard let data = snapshot.value as? [String: Any] else {
      return nil
    }

    var mutableData = data
    mutableData["id"] = id
    return try CreditCard.fromDictionary(mutableData)
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

    let cardData = try updatedCreditCard.toDictionary()

    try await database
      .child(creditCardsPath)
      .child(userId)
      .child(updatedCreditCard.id)
      .setValue(cardData)

    return updatedCreditCard
  }

  func updateCreditCard(_ creditCard: CreditCard) async throws -> CreditCard {
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
      userId: creditCard.userId,
      createdAt: creditCard.createdAt,
      updatedAt: Date()
    )

    let cardData = try updatedCreditCard.toDictionary()

    try await database
      .child(creditCardsPath)
      .child(userId)
      .child(updatedCreditCard.id)
      .updateChildValues(cardData)

    return updatedCreditCard
  }

  func deleteCreditCard(id: String) async throws {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CreditCardError.userNotAuthenticated
    }

    try await database
      .child(creditCardsPath)
      .child(userId)
      .child(id)
      .removeValue()
  }

  // MARK: - Credit Card Transactions

  func getCreditCardTransactions(for creditCardId: String) async throws -> [CreditCardTransaction] {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CreditCardError.userNotAuthenticated
    }

    let snapshot = try await database
      .child("creditCardTransactions")
      .child(userId)
      .child(creditCardId)
      .getData()

    guard let data = snapshot.value as? [String: [String: Any]] else {
      return []
    }

    let transactions = try data.compactMap { (txId, txData) -> CreditCardTransaction? in
      var mutableData = txData
      mutableData["id"] = txId
      return try CreditCardTransaction.fromDictionary(mutableData)
    }

    return transactions.sorted { $0.date > $1.date }
  }

  func createCreditCardTransaction(_ transaction: CreditCardTransaction) async throws -> CreditCardTransaction {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CreditCardError.userNotAuthenticated
    }

    let txData = try transaction.toDictionary()

    try await database
      .child("creditCardTransactions")
      .child(userId)
      .child(transaction.creditCardId)
      .child(transaction.id)
      .setValue(txData)

    return transaction
  }

  func updateCreditCardTransaction(_ transaction: CreditCardTransaction) async throws -> CreditCardTransaction {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CreditCardError.userNotAuthenticated
    }

    let txData = try transaction.toDictionary()

    try await database
      .child("creditCardTransactions")
      .child(userId)
      .child(transaction.creditCardId)
      .child(transaction.id)
      .updateChildValues(txData)

    return transaction
  }

  func deleteCreditCardTransaction(id: String) async throws {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CreditCardError.userNotAuthenticated
    }

    // Find and delete across all cards
    let snapshot = try await database
      .child("creditCardTransactions")
      .child(userId)
      .getData()

    guard let cardsData = snapshot.value as? [String: [String: Any]] else {
      return
    }

    for (cardId, _) in cardsData {
      _ = try? await database
        .child("creditCardTransactions")
        .child(userId)
        .child(cardId)
        .child(id)
        .removeValue()
    }
  }

  // MARK: - Credit Card Statements

  func getCreditCardStatements(for creditCardId: String) async throws -> [CreditCardStatement] {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CreditCardError.userNotAuthenticated
    }

    let snapshot = try await database
      .child("creditCardStatements")
      .child(userId)
      .child(creditCardId)
      .getData()

    guard let data = snapshot.value as? [String: [String: Any]] else {
      return []
    }

    let statements = try data.compactMap { (stmtId, stmtData) -> CreditCardStatement? in
      var mutableData = stmtData
      mutableData["id"] = stmtId
      return try CreditCardStatement.fromDictionary(mutableData)
    }

    return statements.sorted { $0.period.endDate > $1.period.endDate }
  }

  func generateStatement(for creditCardId: String, period: StatementPeriod) async throws -> CreditCardStatement {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CreditCardError.userNotAuthenticated
    }

    let transactions = try await getCreditCardTransactions(for: creditCardId)
    let periodTransactions = transactions.filter { transaction in
      transaction.date >= period.startDate && transaction.date <= period.endDate
    }

    let totalAmount = periodTransactions.reduce(0) { $0 + $1.amount }
    let dueDate = Calendar.current.date(byAdding: .day, value: 15, to: period.endDate) ?? period.endDate

    let statement = CreditCardStatement(
      id: UUID().uuidString,
      creditCardId: creditCardId,
      period: period,
      transactions: periodTransactions,
      totalAmount: totalAmount,
      minimumPayment: totalAmount * 0.15,
      dueDate: dueDate,
      isPaid: false,
      paidAmount: 0.0,
      paidDate: nil,
      createdAt: Date()
    )

    let statementData = try statement.toDictionary()

    try await database
      .child("creditCardStatements")
      .child(userId)
      .child(creditCardId)
      .child(statement.id)
      .setValue(statementData)

    return statement
  }

  func payStatement(_ statement: CreditCardStatement, amount: Double) async throws -> CreditCardStatement {
    guard let userId = Auth.auth().currentUser?.uid else {
      throw CreditCardError.userNotAuthenticated
    }

    let newPaidAmount = statement.paidAmount + amount
    let isPaid = (newPaidAmount >= statement.totalAmount)

    let updatedStatement = CreditCardStatement(
      id: statement.id,
      creditCardId: statement.creditCardId,
      period: statement.period,
      transactions: statement.transactions,
      totalAmount: statement.totalAmount,
      minimumPayment: statement.minimumPayment,
      dueDate: statement.dueDate,
      isPaid: isPaid,
      paidAmount: newPaidAmount,
      paidDate: isPaid ? Date() : statement.paidDate,
      createdAt: statement.createdAt
    )

    let statementData = try updatedStatement.toDictionary()

    try await database
      .child("creditCardStatements")
      .child(userId)
      .child(statement.creditCardId)
      .child(statement.id)
      .updateChildValues(statementData)

    return updatedStatement
  }
}

enum CreditCardError: LocalizedError {
  case userNotAuthenticated
  case creditCardNotFound
  case invalidData

  var errorDescription: String? {
    switch self {
    case .userNotAuthenticated:
      return "User not authenticated"
    case .creditCardNotFound:
      return "Credit card not found"
    case .invalidData:
      return "Invalid credit card data"
    }
  }
}
