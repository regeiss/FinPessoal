//
//  AuthenticationViewModel.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//
import Foundation
import AuthenticationServices
import Combine

@MainActor
class AuthViewModel: ObservableObject {
  @Published var isAuthenticated = false
  @Published var currentUser: User?
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published var showError = false
  
  private let authRepository: AuthRepositoryProtocol
  
  init(authRepository: AuthRepositoryProtocol = MockAuthRepository()) {
    self.authRepository = authRepository
    checkAuthenticationState()
  }
  
  func checkAuthenticationState() {
    self.currentUser = authRepository.getCurrentUser()
    self.isAuthenticated = currentUser != nil
  }
  
  func signInWithEmail(_ email: String, password: String) async {
    isLoading = true
    errorMessage = nil
    
    do {
      let user = try await authRepository.signInWithEmail(email, password: password)
      currentUser = user
      isAuthenticated = true
    } catch {
      errorMessage = "Erro ao fazer login: \(error.localizedDescription)"
      showError = true
    }
    
    isLoading = false
  }
  
  func signInWithGoogle() async {
    isLoading = true
    errorMessage = nil
    
    do {
      let user = try await authRepository.signInWithGoogle()
      currentUser = user
      isAuthenticated = true
    } catch {
      errorMessage = "Erro ao fazer login com Google: \(error.localizedDescription)"
      showError = true
    }
    
    isLoading = false
  }
  
  func signInWithApple() async {
    isLoading = true
    errorMessage = nil
    
    do {
      let user = try await authRepository.signInWithApple()
      currentUser = user
      isAuthenticated = true
    } catch {
      errorMessage = "Erro ao fazer login com Apple: \(error.localizedDescription)"
      showError = true
    }
    
    isLoading = false
  }
  
  func signOut() async {
    do {
      try await authRepository.signOut()
      currentUser = nil
      isAuthenticated = false
    } catch {
      errorMessage = "Erro ao fazer logout: \(error.localizedDescription)"
      showError = true
    }
  }
}
