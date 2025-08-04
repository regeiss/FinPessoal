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
    return try await firebaseService.signIn(email: email, password: password)
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
    // Generate nonce for Apple Sign In
    let nonce = NonceGenerator.randomNonceString()
    NonceGenerator.currentNonce = nonce
    
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = NonceGenerator.sha256(nonce)
    
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    
    return try await withCheckedThrowingContinuation { continuation in
      let delegate = AppleSignInDelegate { result in
        switch result {
        case .success(let user):
          continuation.resume(returning: user)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
      
      authorizationController.delegate = delegate
      authorizationController.presentationContextProvider = delegate
      authorizationController.performRequests()
    }
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

// MARK: - Apple Sign In Delegate
private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  private let completion: (Result<User, Error>) -> Void
  
  init(completion: @escaping (Result<User, Error>) -> Void) {
    self.completion = completion
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    Task {
      do {
        let user = try await FirebaseService.shared.signInWithApple(authorization: authorization)
        completion(.success(user))
      } catch {
        completion(.failure(error))
      }
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    completion(.failure(error))
  }
  
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else {
      fatalError("No window found")
    }
    return window
  }
}
