//
//  MockAuthRepository.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 13/08/25.
//
//

import Foundation
import AuthenticationServices

class MockAuthRepository: AuthRepositoryProtocol {
  
  // MARK: - Private Properties
  private var currentUser: User?
  private let shouldAutoLogin: Bool
  
  // MARK: - Initialization
  init(shouldAutoLogin: Bool = true) {
    self.shouldAutoLogin = shouldAutoLogin
    
    // Se shouldAutoLogin for true, cria automaticamente um usuário logado
    if shouldAutoLogin {
      setupMockUser()
    }
  }
  
  // MARK: - Private Methods
  private func setupMockUser() {
    currentUser = User(
      id: "mock_user_123",
      name: "João Silva",
      email: "joao.silva@email.com",
      profileImageURL: nil,
      createdAt: Date().addingTimeInterval(-86400 * 30), // 30 dias atrás
      settings: UserSettings(
        currency: "BRL",
        language: "pt-BR",
        notifications: true,
        biometricAuth: false
      )
    )
  }
  
  private func simulateNetworkDelay() async {
    // Simula delay de rede entre 0.5 e 1.5 segundos
    let delay = Double.random(in: 0.5...1.5)
    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
  }
  
  // MARK: - AuthRepositoryProtocol Implementation
  
  func signIn(email: String, password: String) async throws -> User {
    await simulateNetworkDelay()
    
    // Simula validação básica
    guard !email.isEmpty, !password.isEmpty else {
      throw NSError(domain: "MockAuthError", code: 1001, userInfo: [
        NSLocalizedDescriptionKey: "Email e senha são obrigatórios"
      ])
    }
    
    // Simula falha de login para emails específicos
    if email == "error@test.com" {
      throw NSError(domain: "MockAuthError", code: 1002, userInfo: [
        NSLocalizedDescriptionKey: "Credenciais inválidas"
      ])
    }
    
    let user = User(
      id: UUID().uuidString,
      name: extractNameFromEmail(email),
      email: email,
      profileImageURL: nil,
      createdAt: Date()
    )
    
    currentUser = user
    return user
  }
  
  func signUp(email: String, password: String, name: String) async throws -> User {
    await simulateNetworkDelay()
    
    // Simula validação
    guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
      throw NSError(domain: "MockAuthError", code: 1003, userInfo: [
        NSLocalizedDescriptionKey: "Todos os campos são obrigatórios"
      ])
    }
    
    guard password.count >= 6 else {
      throw NSError(domain: "MockAuthError", code: 1004, userInfo: [
        NSLocalizedDescriptionKey: "Senha deve ter pelo menos 6 caracteres"
      ])
    }
    
    // Simula email já cadastrado
    if email == "existing@test.com" {
      throw NSError(domain: "MockAuthError", code: 1005, userInfo: [
        NSLocalizedDescriptionKey: "Este email já está cadastrado"
      ])
    }
    
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
  
  func signInWithGoogle() async throws -> User {
    await simulateNetworkDelay()
    
    let user = User(
      id: UUID().uuidString,
      name: "Usuário Google",
      email: "usuario@gmail.com",
      profileImageURL: "https://lh3.googleusercontent.com/a/default-user",
      createdAt: Date()
    )
    
    currentUser = user
    return user
  }
  
  func signInWithApple(authorization: ASAuthorization) async throws -> User {
    await simulateNetworkDelay()
    
    let user = User(
      id: UUID().uuidString,
      name: "Usuário Apple",
      email: "usuario@icloud.com",
      profileImageURL: nil,
      createdAt: Date()
    )
    
    currentUser = user
    return user
  }
  
  func signOut() async throws {
    await simulateNetworkDelay()
    currentUser = nil
  }
  
  func getCurrentUser() -> User? {
    return currentUser
  }
  
  func isUserSignedIn() -> Bool {
    return currentUser != nil
  }
  
  // MARK: - Helper Methods
  
  private func extractNameFromEmail(_ email: String) -> String {
    let username = email.components(separatedBy: "@").first ?? "Usuário"
    return username.capitalized
  }
  
  // MARK: - Mock Utilities for Testing
  
  /// Força o logout para testes
  func forceLogout() {
    currentUser = nil
  }
  
  /// Define um usuário customizado para testes
  func setMockUser(_ user: User) {
    currentUser = user
  }
  
  /// Cria diferentes tipos de usuários para testes
  func createTestUser(type: MockUserType) -> User {
    switch type {
    case .regular:
      return User(
        id: "test_regular_user",
        name: "Usuário Regular",
        email: "regular@test.com",
        profileImageURL: nil,
        createdAt: Date().addingTimeInterval(-86400 * 7)
      )
      
    case .premium:
      return User(
        id: "test_premium_user",
        name: "Usuário Premium",
        email: "premium@test.com",
        profileImageURL: nil,
        createdAt: Date().addingTimeInterval(-86400 * 90),
        settings: UserSettings(
          currency: "BRL",
          language: "pt-BR",
          notifications: true,
          biometricAuth: true
        )
      )
      
    case .newUser:
      return User(
        id: "test_new_user",
        name: "Usuário Novo",
        email: "novo@test.com",
        profileImageURL: nil,
        createdAt: Date()
      )
    }
  }
}

// MARK: - Mock User Types
enum MockUserType {
  case regular
  case premium
  case newUser
}

// MARK: - Mock Configuration
extension MockAuthRepository {
  
  /// Configuração para diferentes cenários de teste
  static func forTesting(scenario: MockScenario) -> MockAuthRepository {
    let repository = MockAuthRepository(shouldAutoLogin: false)
    
    switch scenario {
    case .loggedIn:
      repository.setupMockUser()
      
    case .loggedOut:
      repository.forceLogout()
      
    case .premiumUser:
      let premiumUser = repository.createTestUser(type: .premium)
      repository.setMockUser(premiumUser)
      
    case .newUser:
      let newUser = repository.createTestUser(type: .newUser)
      repository.setMockUser(newUser)
    }
    
    return repository
  }
}

enum MockScenario {
  case loggedIn
  case loggedOut
  case premiumUser
  case newUser
}
