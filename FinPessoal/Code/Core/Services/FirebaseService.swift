//
//  FirebaseService.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 02/08/25.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import AuthenticationServices

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
    guard let presentingViewController = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap({ $0.windows })
      .first(where: { $0.isKeyWindow })?.rootViewController else {
        throw AuthError.noPresentingViewController
    }
    
    guard let clientID = FinPessoal.app()?.options.clientID else {
      throw AuthError.noClientID
    }
    
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config
    
    let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
    
    guard let idToken = result.user.idToken?.tokenString else {
      throw AuthError.noIDToken
    }
    
    let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
    
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
    
    let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
    
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
  
  // MARK: - Database Operations
  private func saveUserToDatabase(_ user: User) async throws {
    let userRef = database.child("users").child(user.id)
    let userData = try user.toDictionary()
    try await userRef.setValue(userData)
  }
  
  func saveAccount(_ account: Account, for userID: String) async throws {
    let accountRef = database.child("accounts").child(userID).child(account.id)
    let accountData = try account.toDictionary()
    try await accountRef.setValue(accountData)
  }
  
  func saveTransaction(_ transaction: Transaction, for userID: String) async throws {
    let transactionRef = database.child("transactions").child(userID).child(transaction.id)
    let transactionData = try transaction.toDictionary()
    try await transactionRef.setValue(transactionData)
    
    // Atualizar saldo da conta
    try await updateAccountBalance(accountID: transaction.accountId, amount: transaction.amount, type: transaction.type, userID: userID)
  }
  
  private func updateAccountBalance(accountID: String, amount: Double, type: TransactionType, userID: String) async throws {
    let accountRef = database.child("accounts").child(userID).child(accountID).child("balance")
    
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
  }
  
  func getAccounts(for userID: String) async throws -> [Account] {
    let snapshot = try await database.child("accounts").child(userID).getData()
    
    guard let data = snapshot.value as? [String: [String: Any]] else {
      return []
    }
    
    return try data.compactMap { (key, value) in
      var accountData = value
      accountData["id"] = key
      return try Account.fromDictionary(accountData)
    }
  }
  
  func getTransactions(for userID: String, limit: Int? = nil) async throws -> [Transaction] {
    var query = database.child("transactions").child(userID).queryOrdered(byChild: "date")
    
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
}

