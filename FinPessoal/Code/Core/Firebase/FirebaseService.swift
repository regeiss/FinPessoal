//
//  FirebaseService.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import AuthenticationServices
import UIKit
import FirebaseCore

class FirebaseService {
  static let shared = FirebaseService()
  
  private let database = Database.database().reference()
  private let auth = Auth.auth()
  
  private init() {}
  
  // MARK: - Authentication
  
  func signIn(email: String, password: String) async throws -> User {
    let result = try await auth.signIn(withEmail: email, password: password)
    let user = User(from: result.user)
    try await saveUserToDatabase(user)
    return user
  }
  
  func signUp(email: String, password: String, name: String) async throws -> User {
    let result = try await auth.createUser(withEmail: email, password: password)
    
    let changeRequest = result.user.createProfileChangeRequest()
    changeRequest.displayName = name
    try await changeRequest.commitChanges()
    
    let user = User(from: result.user)
    try await saveUserToDatabase(user)
    return user
  }
  
  func signInWithGoogle() async throws -> User {
    guard let presentingViewController = await MainActor.run(body: {
      UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .flatMap({ $0.windows })
        .first(where: { $0.isKeyWindow })?.rootViewController
    }) else {
      throw AuthError.noPresentingViewController
    }
    
    guard let clientID = FirebaseApp.app()?.options.clientID else {
      throw AuthError.noClientID
    }
    
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config
    
    let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
    
    guard let idToken = result.user.idToken?.tokenString else {
      throw AuthError.noIDToken
    }
    
    let credential = GoogleAuthProvider.credential(
      withIDToken: idToken,
      accessToken: result.user.accessToken.tokenString
    )
    
    let authResult = try await auth.signIn(with: credential)
    let user = User(from: authResult.user)
    try await saveUserToDatabase(user)
    return user
  }
  
  func signInWithApple(authorization: ASAuthorization) async throws -> User {
    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
          let nonce = NonceGenerator.currentNonce,
          let appleIDToken = appleIDCredential.identityToken,
          let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
      throw AuthError.invalidAppleCredential
    }
    
    let credential = OAuthProvider.credential(
      withProviderID: "apple.com",
      idToken: idTokenString,
      rawNonce: nonce
    )
    
    let authResult = try await auth.signIn(with: credential)
    let user = User(from: authResult.user)
    try await saveUserToDatabase(user)
    return user
  }
  
  func signOut() throws {
    try auth.signOut()
  }
  
  func getCurrentUser() -> FirebaseAuth.User? {
    return auth.currentUser
  }
  
  // MARK: - User Operations
  
  private func saveUserToDatabase(_ user: User) async throws {
    let userRef = database.child(FirebaseConstants.usersCollection).child(user.id)
    let userData = try user.toDictionary()
    try await userRef.setValue(userData)
  }
  
  func getUser(userID: String) async throws -> User {
    let snapshot = try await database.child(FirebaseConstants.usersCollection).child(userID).getData()
    
    guard let data = snapshot.value as? [String: Any] else {
      throw FirebaseError.userNotFound
    }
    
    return try User.fromDictionary(data)
  }
  
  func updateUser(_ user: User) async throws {
    let userRef = database.child(FirebaseConstants.usersCollection).child(user.id)
    let userData = try user.toDictionary()
    try await userRef.updateChildValues(userData)
  }
  
  // MARK: - Account Operations
  
  func saveAccount(_ account: Account, for userID: String) async throws {
    let accountRef = database
      .child(FirebaseConstants.accountsCollection)
      .child(userID)
      .child(account.id)
    
    let accountData = try account.toDictionary()
    try await accountRef.setValue(accountData)
  }
  
  func getAccounts(for userID: String) async throws -> [Account] {
    let snapshot = try await database
      .child(FirebaseConstants.accountsCollection)
      .child(userID)
      .getData()
    
    guard let data = snapshot.value as? [String: [String: Any]] else {
      return []
    }
    
    return try data.compactMap { (key, value) in
      var accountData = value
      accountData["id"] = key
      return try Account.fromDictionary(accountData)
    }.sorted { $0.createdAt < $1.createdAt }
  }
  
  func updateAccount(_ account: Account, for userID: String) async throws {
    let accountRef = database
      .child(FirebaseConstants.accountsCollection)
      .child(userID)
      .child(account.id)
    
    let accountData = try account.toDictionary()
    try await accountRef.updateChildValues(accountData)
  }
  
  func deleteAccount(_ accountID: String, for userID: String) async throws {
    let accountRef = database
      .child(FirebaseConstants.accountsCollection)
      .child(userID)
      .child(accountID)
    
    try await accountRef.removeValue()
  }
  
  // MARK: - Transaction Operations
  
  func saveTransaction(_ transaction: Transaction, for userID: String) async throws {
    let transactionRef = database
      .child(FirebaseConstants.transactionsCollection)
      .child(userID)
      .child(transaction.id)
    
    let transactionData = try transaction.toDictionary()
    try await transactionRef.setValue(transactionData)
    
    // Update account balance
    try await updateAccountBalance(
      accountID: transaction.accountId,
      amount: transaction.amount,
      type: transaction.type,
      userID: userID
    )
  }
  
  func getTransactions(for userID: String, limit: Int? = nil) async throws -> [Transaction] {
    var query = database
      .child(FirebaseConstants.transactionsCollection)
      .child(userID)
      .queryOrdered(byChild: "date")
    
    if let limit = limit {
      query = query.queryLimited(toLast: UInt(limit))
    }
    
    let snapshot = try await query.getData()
    
    guard let data = snapshot.value as? [String: [String: Any]] else {
      return []
    }
    
    return try data.compactMap { (key, value) in
      var transactionData = value
      transactionData["id"] = key
      return try Transaction.fromDictionary(transactionData)
    }.sorted { $0.date > $1.date }
  }
  
  func getTransactionsByAccount(_ accountID: String, for userID: String) async throws -> [Transaction] {
    let snapshot = try await database
      .child(FirebaseConstants.transactionsCollection)
      .child(userID)
      .queryOrdered(byChild: "accountId")
      .queryEqual(toValue: accountID)
      .getData()
    
    guard let data = snapshot.value as? [String: [String: Any]] else {
      return []
    }
    
    return try data.compactMap { (key, value) in
      var transactionData = value
      transactionData["id"] = key
      return try Transaction.fromDictionary(transactionData)
    }.sorted { $0.date > $1.date }
  }
  
  func getTransactionsByCategory(_ category: TransactionCategory, for userID: String) async throws -> [Transaction] {
    let snapshot = try await database
      .child(FirebaseConstants.transactionsCollection)
      .child(userID)
      .queryOrdered(byChild: "category")
      .queryEqual(toValue: category.rawValue)
      .getData()
    
    guard let data = snapshot.value as? [String: [String: Any]] else {
      return []
    }
    
    return try data.compactMap { (key, value) in
      var transactionData = value
      transactionData["id"] = key
      return try Transaction.fromDictionary(transactionData)
    }.sorted { $0.date > $1.date }
  }
  
  func updateTransaction(_ transaction: Transaction, for userID: String) async throws {
    let transactionRef = database
      .child(FirebaseConstants.transactionsCollection)
      .child(userID)
      .child(transaction.id)
    
    let transactionData = try transaction.toDictionary()
    try await transactionRef.updateChildValues(transactionData)
  }
  
  func deleteTransaction(_ transactionID: String, for userID: String) async throws {
    // Get the transaction first to reverse the balance change
    let snapshot = try await database
      .child(FirebaseConstants.transactionsCollection)
      .child(userID)
      .child(transactionID)
      .getData()
    
    guard let data = snapshot.value as? [String: Any],
          let transaction = try? Transaction.fromDictionary(data) else {
      throw FirebaseError.transactionNotFound
    }
    
    // Reverse the balance change
    let reverseAmount = transaction.type == .income ? -transaction.amount : transaction.amount
    try await updateAccountBalance(
      accountID: transaction.accountId,
      amount: reverseAmount,
      type: transaction.type == .income ? .expense : .income,
      userID: userID
    )
    
    // Delete the transaction
    let transactionRef = database
      .child(FirebaseConstants.transactionsCollection)
      .child(userID)
      .child(transactionID)
    
    try await transactionRef.removeValue()
  }
  
  // MARK: - Budget Operations
  
  func saveBudget(_ budget: Budget, for userID: String) async throws {
    let budgetRef = database
      .child(FirebaseConstants.budgetsCollection)
      .child(userID)
      .child(budget.id)
    
    let budgetData = try budget.toDictionary()
    try await budgetRef.setValue(budgetData)
  }
  
  func getBudgets(for userID: String) async throws -> [Budget] {
    let snapshot = try await database
      .child(FirebaseConstants.budgetsCollection)
      .child(userID)
      .getData()
    
    guard let data = snapshot.value as? [String: [String: Any]] else {
      return []
    }
    
    return try data.compactMap { (key, value) in
      var budgetData = value
      budgetData["id"] = key
      return try Budget.fromDictionary(budgetData)
    }.filter { $0.isActive }
      .sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }
  }
  
  func updateBudget(_ budget: Budget, for userID: String) async throws {
    let budgetRef = database
      .child(FirebaseConstants.budgetsCollection)
      .child(userID)
      .child(budget.id)
    
    let budgetData = try budget.toDictionary()
    try await budgetRef.updateChildValues(budgetData)
  }
  
  func deleteBudget(_ budgetID: String, for userID: String) async throws {
    let budgetRef = database
      .child(FirebaseConstants.budgetsCollection)
      .child(userID)
      .child(budgetID)
    
    try await budgetRef.removeValue()
  }
  
  func getBudgetProgress(_ budgetID: String, for userID: String) async throws -> Double {
    let snapshot = try await database
      .child(FirebaseConstants.budgetsCollection)
      .child(userID)
      .child(budgetID)
      .getData()
    
    guard let data = snapshot.value as? [String: Any],
          let budget = try? Budget.fromDictionary(data) else {
      throw FirebaseError.budgetNotFound
    }
    
    return budget.percentageUsed
  }
  
  func updateBudgetSpent(_ budgetID: String, amount: Double, for userID: String) async throws {
    let budgetRef = database
      .child(FirebaseConstants.budgetsCollection)
      .child(userID)
      .child(budgetID)
    
    try await database.runTransactionBlock { currentData in
      guard var budgetData = currentData.value as? [String: Any],
            let currentSpent = budgetData["spent"] as? Double else {
        return TransactionResult.abort()
      }
      
      budgetData["spent"] = currentSpent + amount
      budgetData["updatedAt"] = Date().timeIntervalSince1970
      currentData.value = budgetData
      
      return TransactionResult.success(withValue: currentData)
    }
  }
  
  // MARK: - Helper Methods
  
  private func updateAccountBalance(
    accountID: String,
    amount: Double,
    type: TransactionType,
    userID: String
  ) async throws {
    let accountRef = database
      .child(FirebaseConstants.accountsCollection)
      .child(userID)
      .child(accountID)
      .child("balance")
    
    try await database.runTransactionBlock { currentData in
      var currentBalance = currentData.value as? Double ?? 0.0
      
      switch type {
      case .income:
        currentBalance += amount
      case .expense:
        currentBalance -= amount
      }
      
      currentData.value = currentBalance
      return TransactionResult.success(withValue: currentData)
    }
    
    // Update the account's updatedAt timestamp
    let accountUpdateRef = database
      .child(FirebaseConstants.accountsCollection)
      .child(userID)
      .child(accountID)
      .child("updatedAt")
    
    try await accountUpdateRef.setValue(Date().timeIntervalSince1970)
  }
  
  // MARK: - Analytics and Reporting
  
  func getMonthlyExpensesByCategory(for userID: String, month: Date) async throws -> [TransactionCategory: Double] {
    let calendar = Calendar.current
    let startOfMonth = calendar.startOfMonth(for: month) ?? month
    let endOfMonth = calendar.endOfMonth(for: month) ?? month
    
    let startTimestamp = startOfMonth.timeIntervalSince1970
    let endTimestamp = endOfMonth.timeIntervalSince1970
    
    let snapshot = try await database
      .child(FirebaseConstants.transactionsCollection)
      .child(userID)
      .queryOrdered(byChild: "date")
      .queryStarting(atValue: startTimestamp)
      .queryEnding(atValue: endTimestamp)
      .getData()
    
    guard let data = snapshot.value as? [String: [String: Any]] else {
      return [:]
    }
    
    var expenses: [TransactionCategory: Double] = [:]
    
    for (_, transactionData) in data {
      guard let transaction = try? Transaction.fromDictionary(transactionData),
            transaction.type == .expense else {
        continue
      }
      
      expenses[transaction.category, default: 0] += transaction.amount
    }
    
    return expenses
  }
  
  func getTotalBalanceHistory(for userID: String, days: Int = 30) async throws -> [(Date, Double)] {
    let endDate = Date()
    let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
    
    let snapshot = try await database
      .child(FirebaseConstants.transactionsCollection)
      .child(userID)
      .queryOrdered(byChild: "date")
      .queryStarting(atValue: startDate.timeIntervalSince1970)
      .queryEnding(atValue: endDate.timeIntervalSince1970)
      .getData()
    
    guard let data = snapshot.value as? [String: [String: Any]] else {
      return []
    }
    
    let transactions = try data.compactMap { (_, value) in
      try Transaction.fromDictionary(value)
    }.sorted { $0.date < $1.date }
    
    var history: [(Date, Double)] = []
    var runningBalance = 0.0
    
    for transaction in transactions {
      switch transaction.type {
      case .income:
        runningBalance += transaction.amount
      case .expense:
        runningBalance -= transaction.amount
      }
      
      history.append((transaction.date, runningBalance))
    }
    
    return history
  }
  
  // MARK: - Batch Operations
  
  func batchUpdateBudgetsWithTransaction(_ transaction: Transaction, for userID: String) async throws {
    guard transaction.type == .expense else { return }
    
    let budgets = try await getBudgets(for: userID)
    let relevantBudgets = budgets.filter { budget in
      budget.category == transaction.category &&
      transaction.date >= budget.startDate &&
      transaction.date <= budget.endDate
    }
    
    for budget in relevantBudgets {
      try await updateBudgetSpent(budget.id, amount: transaction.amount, for: userID)
    }
  }
  
  func batchDeleteUserData(userID: String) async throws {
    async let deleteAccounts: () = database
      .child(FirebaseConstants.accountsCollection)
      .child(userID)
      .removeValue()
    
    async let deleteTransactions: () = database
      .child(FirebaseConstants.transactionsCollection)
      .child(userID)
      .removeValue()
    
    async let deleteBudgets: () = database
      .child(FirebaseConstants.budgetsCollection)
      .child(userID)
      .removeValue()
    
    async let deleteUser: () = database
      .child(FirebaseConstants.usersCollection)
      .child(userID)
      .removeValue()
    
    try await deleteAccounts
    try await deleteTransactions
    try await deleteBudgets
    try await deleteUser
  }
}

// MARK: - Firebase Errors

enum FirebaseError: LocalizedError {
  case userNotFound
  case accountNotFound
  case transactionNotFound
  case budgetNotFound
  case insufficientPermissions
  case networkError
  case invalidData
  
  var errorDescription: String? {
    switch self {
    case .userNotFound:
      return "Usuário não encontrado"
    case .accountNotFound:
      return "Conta não encontrada"
    case .transactionNotFound:
      return "Transação não encontrada"
    case .budgetNotFound:
      return "Orçamento não encontrado"
    case .insufficientPermissions:
      return "Permissões insuficientes"
    case .networkError:
      return "Erro de conexão"
    case .invalidData:
      return "Dados inválidos"
    }
  }
}
