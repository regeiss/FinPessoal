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
  private let crashlytics = CrashlyticsManager.shared

  init(authRepository: AuthRepositoryProtocol) {
    self.authRepository = authRepository
    Task { @MainActor in
      self.checkAuthenticationState()
    }
  }

  func checkAuthenticationState() {
    print("AuthViewModel: checkAuthenticationState() called")
    self.currentUser = authRepository.getCurrentUser()
    self.isAuthenticated = currentUser != nil
    print("AuthViewModel: currentUser = \(String(describing: currentUser))")
    print("AuthViewModel: isAuthenticated = \(isAuthenticated)")

    // Set Crashlytics user info if authenticated
    if let user = currentUser {
      crashlytics.setUserID(user.id)
      crashlytics.setUserEmail(user.email)
      crashlytics.setUserName(user.name)
    }
  }
  
  func signInWithEmail(_ email: String, password: String) async {
    isLoading = true
    errorMessage = nil

    do {
      let user = try await authRepository.signInWithEmail(email, password: password)
      currentUser = user
      isAuthenticated = true

      // Set Crashlytics user info
      crashlytics.setUserID(user.id)
      crashlytics.setUserEmail(user.email)
      crashlytics.setUserName(user.name)
      crashlytics.logEvent("user_login", parameters: ["method": "email"])
    } catch {
      errorMessage = "Erro ao fazer login: \(error.localizedDescription)"
      showError = true

      // Log authentication error
      if let authError = error as? AuthError {
        crashlytics.logAuthError(authError, authType: "Email")
      } else {
        crashlytics.logError(error, context: "Email sign-in")
      }
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

      // Set Crashlytics user info
      crashlytics.setUserID(user.id)
      crashlytics.setUserEmail(user.email)
      crashlytics.setUserName(user.name)
      crashlytics.logEvent("user_login", parameters: ["method": "google"])
    } catch {
      errorMessage = "Erro ao fazer login com Google: \(error.localizedDescription)"
      showError = true

      // Log authentication error
      if let authError = error as? AuthError {
        crashlytics.logAuthError(authError, authType: "Google")
      } else {
        crashlytics.logError(error, context: "Google sign-in")
      }
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

      // Set Crashlytics user info
      crashlytics.setUserID(user.id)
      crashlytics.setUserEmail(user.email)
      crashlytics.setUserName(user.name)
      crashlytics.logEvent("user_login", parameters: ["method": "apple"])
    } catch {
      errorMessage = "Erro ao fazer login com Apple: \(error.localizedDescription)"
      showError = true

      // Log authentication error
      if let authError = error as? AuthError {
        crashlytics.logAuthError(authError, authType: "Apple")
      } else {
        crashlytics.logError(error, context: "Apple sign-in")
      }
    }

    isLoading = false
  }
  
  func signOut() async {
    do {
      try await authRepository.signOut()
      currentUser = nil
      isAuthenticated = false

      // Clear Crashlytics user info
      crashlytics.clearUserID()
      crashlytics.logEvent("user_logout")
    } catch {
      errorMessage = "Erro ao fazer logout: \(error.localizedDescription)"
      showError = true
      crashlytics.logError(error, context: "Sign out")
    }
  }
  
  public func clearError() {
    self.errorMessage = nil
    self.showError = false
  }
}
