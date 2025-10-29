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
  
  // MARK: - Debug/Test Methods
  
  func testFirebaseConnection() async -> Bool {
    do {
      let snapshot = try await database.child(".info/connected").getData()
      let isConnected = snapshot.value as? Bool ?? false
      print("FirebaseService: Connection test result: \(isConnected)")
      return isConnected
    } catch {
      print("FirebaseService: Connection test failed: \(error)")
      return false
    }
  }
  
  func initializeUserTransactionsNode(for userID: String) async throws {
    print("FirebaseService: Initializing transactions node for user: \(userID)")
    let userTransactionsRef = database
      .child(FirebaseConstants.transactionsCollection)
      .child(userID)
    
    // Check if node already exists
    let snapshot = try await withCheckedThrowingContinuation { continuation in
      userTransactionsRef.observeSingleEvent(of: .value) { snapshot in
        continuation.resume(returning: snapshot)
      } withCancel: { error in
        continuation.resume(throwing: error)
      }
    }
    
    if !snapshot.exists() {
      // Create empty node to establish the path
      try await userTransactionsRef.setValue([String: Any]())
      print("FirebaseService: Created empty transactions node for user")
    } else {
      print("FirebaseService: Transactions node already exists for user")
    }
  }
  
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
    
    let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
     
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
    print("FirebaseService: Starting to fetch transactions for user: \(userID)")
    
    // Try a simpler approach first - just get the user's transactions node without complex queries
    let userTransactionsRef = database
      .child(FirebaseConstants.transactionsCollection)
      .child(userID)
    
    print("FirebaseService: Querying simple path: /\(FirebaseConstants.transactionsCollection)/\(userID)")
    
    do {
      // Use observeSingleEvent instead of getData() which might be more reliable
      let snapshot = try await withCheckedThrowingContinuation { continuation in
        userTransactionsRef.observeSingleEvent(of: .value) { snapshot in
          continuation.resume(returning: snapshot)
        } withCancel: { error in
          continuation.resume(throwing: error)
        }
      }
      
      print("FirebaseService: Got snapshot via observeSingleEvent, exists: \(snapshot.exists()), childrenCount: \(snapshot.childrenCount)")
      
      // If no data exists, return empty array (this is normal for new users)
      guard snapshot.exists(), let data = snapshot.value as? [String: Any] else {
        print("FirebaseService: No transactions found for user, returning empty array")
        return []
      }
      
      print("FirebaseService: Found \(data.count) transactions in database")
      
      // Parse transactions without complex queries first
      var transactions: [Transaction] = []
      for (key, value) in data {
        guard let transactionDict = value as? [String: Any] else {
          print("FirebaseService: Skipping invalid transaction data for key: \(key)")
          continue
        }
        
        do {
          var transactionData = transactionDict
          transactionData["id"] = key
          let transaction = try Transaction.fromDictionary(transactionData)
          transactions.append(transaction)
        } catch {
          print("FirebaseService: Error parsing transaction \(key): \(error)")
        }
      }
      
      // Sort by date descending
      transactions.sort { $0.date > $1.date }
      
      // Apply limit if needed
      if let limit = limit {
        transactions = Array(transactions.prefix(limit))
      }
      
      print("FirebaseService: Successfully parsed \(transactions.count) transactions")
      return transactions
      
    } catch {
      print("FirebaseService: Error fetching transactions: \(error)")
      print("FirebaseService: Error type: \(type(of: error))")
      
      // If it's a specific Firebase offline error, return empty array instead of throwing
      let errorMessage = error.localizedDescription.lowercased()
      if errorMessage.contains("offline") || errorMessage.contains("no active listeners") {
        print("FirebaseService: Treating offline error as empty state for new user")
        return []
      }
      
      throw error
    }
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
    if transaction.type != .transfer {
      let reverseAmount = transaction.type == .income ? -transaction.amount : transaction.amount
      try await updateAccountBalance(
        accountID: transaction.accountId,
        amount: reverseAmount,
        type: transaction.type == .income ? .expense : .income,
        userID: userID
      )
    }
    // Transfers don't affect account balance, so no need to reverse
    
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
    _ = database
      .child(FirebaseConstants.budgetsCollection)
      .child(userID)
      .child(budgetID)
    
    _ = try await database.runTransactionBlock { currentData in
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
    _ = database
      .child(FirebaseConstants.accountsCollection)
      .child(userID)
      .child(accountID)
      .child("balance")
    
    _ = try await database.runTransactionBlock { currentData in
      var currentBalance = currentData.value as? Double ?? 0.0
      
      switch type {
      case .income:
        currentBalance += amount
      case .expense:
        currentBalance -= amount
      case .transfer:
        // Transfers don't change the account balance in this context
        // as they represent movement between accounts, not net gain/loss
        break
      @unknown default:
        break
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
      case .transfer:
        // Transfers don't affect the total balance history
        // as they represent movement between accounts
        break
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
    try await withThrowingTaskGroup(of: Void.self) { group in
      group.addTask {
        try await self.database
          .child(FirebaseConstants.accountsCollection)
          .child(userID)
          .removeValue()
      }
      group.addTask {
        try await self.database
          .child(FirebaseConstants.transactionsCollection)
          .child(userID)
          .removeValue()
      }
      group.addTask {
        try await self.database
          .child(FirebaseConstants.budgetsCollection)
          .child(userID)
          .removeValue()
      }
      group.addTask {
        try await self.database
          .child(FirebaseConstants.usersCollection)
          .child(userID)
          .removeValue()
      }

      try await group.waitForAll()
    }
  }
}

// MARK: - Firebase Errors

enum FirebaseError: LocalizedError {
  case userNotFound
  case accountNotFound
  case transactionNotFound
  case budgetNotFound
  case documentNotFound
  case databaseError(String)
  case insufficientPermissions
  case networkError
  case invalidData(String)
  case offlineError
  case permissionDenied
  case databaseUnavailable
  
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
    case .documentNotFound:
      return "Documento não encontrado"
    case .databaseError(let message):
      return "Erro no banco de dados: \(message)"
    case .insufficientPermissions, .permissionDenied:
      return "Permissões insuficientes. Verifique se você está autenticado."
    case .networkError:
      return "Erro de conexão"
    case .invalidData(let message):
      return "Dados inválidos: \(message)"
    case .offlineError:
      return "Aplicativo está offline. Verifique sua conexão com a internet."
    case .databaseUnavailable:
      return "Banco de dados indisponível. Tente novamente mais tarde."
    }
  }
  
  static func from(_ error: Error) -> FirebaseError {
    let errorMessage = error.localizedDescription.lowercased()
    
    if errorMessage.contains("permission denied") {
      return .permissionDenied
    } else if errorMessage.contains("offline") || errorMessage.contains("no active listeners") {
      return .offlineError
    } else if errorMessage.contains("network") || errorMessage.contains("connection") {
      return .networkError
    } else if errorMessage.contains("user") && errorMessage.contains("not found") {
      return .userNotFound
    } else if errorMessage.contains("account") && errorMessage.contains("not found") {
      return .accountNotFound
    } else if errorMessage.contains("invalid") {
      return .invalidData(error.localizedDescription)
    } else {
      return .databaseUnavailable
    }
  }
}

