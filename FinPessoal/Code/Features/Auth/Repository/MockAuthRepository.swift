//
//  MockAuthRepository.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import Foundation
import AuthenticationServices

class MockAuthRepository: AuthRepositoryProtocol {
  private var currentUser: User?
  
  func signIn(email: String, password: String) async throws -> User {
    try await Task.sleep(nanoseconds: 1_000_000_000)
    
    let user = User(
      id: UUID().uuidString,
      name: "João Silva",
      email: email,
      profileImageURL: nil,
      createdAt: Date()
    )
    currentUser = user
    return user
  }
  
  func signUp(email: String, password: String, name: String) async throws -> User {
    try await Task.sleep(nanoseconds: 1_000_000_000)
    
    let user = User(
      id: UUID().uuidString,
      name: name,
      email: email,
      profileImageURL: nil,
      createdAt: Date()
    )
    currentUser = user
    return user
  }
  
  func signInWithApple(authorization: ASAuthorization) async throws -> User {
    try await Task.sleep(nanoseconds: 1_500_000_000)
    
    let user = User(
      id: UUID().uuidString,
      name: "João Silva",
      email: "joao@icloud.com",
      profileImageURL: nil,
      createdAt: Date()
    )
    currentUser = user
    return user
  }
  
  func signInWithGoogle() async throws -> User {
    try await Task.sleep(nanoseconds: 1_500_000_000)
    
    let user = User(
      id: UUID().uuidString,
      name: "João Silva",
      email: "joao@gmail.com",
      profileImageURL: nil,
      createdAt: Date()
    )
    currentUser = user
    return user
  }
  
  func signOut() async throws {
    currentUser = nil
  }
  
  func getCurrentUser() -> User? {
    return currentUser
  }
  
  func isUserSignedIn() -> Bool {
    return currentUser != nil
  }
}

// Extension to add missing methods
extension MockAuthRepository {
  func signInWithEmail(_ email: String, password: String) async throws -> User {
    return try await signIn(email: email, password: password)
  }
  
  func signInWithApple() async throws -> User {
    try await Task.sleep(nanoseconds: 1_500_000_000)
    
    let user = User(
      id: UUID().uuidString,
      name: "João Silva",
      email: "joao@icloud.com",
      profileImageURL: nil,
      createdAt: Date()
    )
    currentUser = user
    return user
  }
}
