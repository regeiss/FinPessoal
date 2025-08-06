//
//  AuthRepository.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 02/08/25.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

protocol AuthRepositoryProtocol {
  func signIn(email: String, password: String) async throws -> User
  func signInWithEmail(_ email: String, password: String) async throws -> User
  func signUp(email: String, password: String, name: String) async throws -> User
  func signInWithGoogle() async throws -> User
  func signInWithApple(authorization: ASAuthorization) async throws -> User
  func signInWithApple() async throws -> User
  func signOut() async throws
  func getCurrentUser() -> User?
  func isUserSignedIn() -> Bool
}

class AuthRepository: AuthRepositoryProtocol {
  private let firebaseService = FirebaseService.shared
  
  func signIn(email: String, password: String) async throws -> User {
    return try await firebaseService.signIn(email: email, password: password)
  }
  
  func signInWithEmail(_ email: String, password: String) async throws -> User {
    return try await signIn(email: email, password: password)
  }
  
  func signUp(email: String, password: String, name: String) async throws -> User {
    return try await firebaseService.signUp(email: email, password: password, name: name)
  }
  
  func signInWithGoogle() async throws -> User {
    return try await firebaseService.signInWithGoogle()
  }
  
  func signInWithApple(authorization: ASAuthorization) async throws -> User {
    return try await firebaseService.signInWithApple(authorization: authorization)
  }
  
  func signInWithApple() async throws -> User {
    // Implementação para iniciar o fluxo do Apple Sign In
    // Esta seria uma implementação mais complexa que iniciaria o ASAuthorizationController
    throw AuthError.invalidAppleCredential
  }
  
  func signOut() async throws {
    try firebaseService.signOut()
  }
  
  func getCurrentUser() -> User? {
    guard let firebaseUser = firebaseService.getCurrentUser() else {
      return nil
    }
    return User(from: firebaseUser)
  }
  
  func isUserSignedIn() -> Bool {
    return firebaseService.getCurrentUser() != nil
  }
}
