//
//  AuthViewModel+Extension.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 03/08/25.
//

import Foundation
import AuthenticationServices

extension AuthViewModel: ASAuthorizationControllerDelegate {
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    Task {
      isLoading = true
      
      do {
        let user = try await authRepository.signInWithApple(authorization: authorization)
        await MainActor.run {
          self.currentUser = user
          self.isAuthenticated = true
          self.isLoading = false
        }
      } catch {
        await MainActor.run {
          self.errorMessage = "Erro ao fazer login com Apple: \(error.localizedDescription)"
          self.showError = true
          self.isLoading = false
        }
      }
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    errorMessage = "Erro no login com Apple: \(error.localizedDescription)"
    showError = true
    isLoading = false
  }
}

extension AuthViewModel: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else {
      fatalError("No window found")
    }
    return window
  }
}
