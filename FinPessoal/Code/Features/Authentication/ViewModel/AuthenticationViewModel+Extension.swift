//
//  AuthenticationViewModel+Extension.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 13/08/25.
//

import Foundation

// MARK: - AuthViewModel Extension for Mock Support
extension AuthenticationViewModel {
  @Published var showError = false
  
  /// Inicializador para uso com mock (bypass de login)
  convenience init(mockScenario: MockScenario) {
    let mockRepository = MockAuthRepository.forTesting(scenario: mockScenario)
    self.init(authRepository: mockRepository)
  }
  
  /// Inicializador para desenvolvimento com auto-login
  convenience init(enableAutoLogin: Bool = true) {
    let mockRepository = MockAuthRepository(shouldAutoLogin: enableAutoLogin)
    self.init(authRepository: mockRepository)
  }
  
  /// Método para verificar estado de autenticação (usado no app startup)
  func checkAuthenticationState() {
    let user = authRepository.getCurrentUser()
    if let user = user {
      currentUser = user
      isAuthenticated = true
    } else {
      currentUser = nil
      isAuthenticated = false
    }
  }
  
  /// Método para fazer login rápido em desenvolvimento
  func quickMockLogin(userType: MockUserType = .regular) async {
    guard let mockRepo = authRepository as? MockAuthRepository else { return }
    
    isLoading = true
    
    let user = mockRepo.createTestUser(type: userType)
    mockRepo.setMockUser(user)
    
    await MainActor.run {
      self.currentUser = user
      self.isAuthenticated = true
      self.isLoading = false
    }
  }
  
  /// Método para simular diferentes estados de erro
  func simulateAuthError(_ errorType: MockAuthError) {
    switch errorType {
    case .networkError:
      errorMessage = "Erro de conexão. Verifique sua internet."
    case .invalidCredentials:
      errorMessage = "Email ou senha incorretos."
    case .accountLocked:
      errorMessage = "Conta temporariamente bloqueada."
    case .serverError:
      errorMessage = "Erro interno do servidor. Tente novamente."
    }
  }
}

// MARK: - Mock Error Types
enum MockAuthError {
  case networkError
  case invalidCredentials
  case accountLocked
  case serverError
}

// MARK: - Development Helpers
extension AuthenticationViewModel {
  
  /// Estado atual de autenticação para debugging
  var debugInfo: String {
    return """
    Authenticated: \(isAuthenticated)
    User: \(currentUser?.name ?? "None")
    Email: \(currentUser?.email ?? "None")
    Loading: \(isLoading)
    Error: \(errorMessage ?? "None")
    """
  }
  
  /// Força logout para testes
  func forceLogout() {
    currentUser = nil
    isAuthenticated = false
    errorMessage = nil
  }
}
