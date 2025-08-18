//
//  AuthRepository.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 17/08/25.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

protocol AuthRepositoryProtocol {
  func signIn(email: String, password: String) async throws -> User
  func signUp(email: String, password: String, name: String) async throws -> User
  func signInWithGoogle() async throws -> User
  func signInWithApple(authorization: ASAuthorization) async throws -> User
  func signOut() async throws
  func getCurrentUser() -> User?
  func isUserSignedIn() -> Bool
  
  // Additional methods for compatibility
  func signInWithEmail(_ email: String, password: String) async throws -> User
  func signInWithApple() async throws -> User
}

class AuthRepository: AuthRepositoryProtocol {
  private let firebaseService = FirebaseService.shared
  
  func signIn(email: String, password: String) async throws -> User {
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
  
  // MARK: - Additional Methods for Compatibility
  
  func signInWithEmail(_ email: String, password: String) async throws -> User {
    return try await signIn(email: email, password: password)
  }
  
  func signInWithApple() async throws -> User {
    // For programmatic Apple Sign In, we need to handle the authorization flow
    // This is typically handled by the UI layer, but we can provide a default implementation
    return try await withCheckedThrowingContinuation { continuation in
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = NonceGenerator.sha256(NonceGenerator.randomNonceString())
      
      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      
      // Create a delegate handler
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
  
  // MARK: - User Management
  
  func updateUserProfile(name: String?, photoURL: String?) async throws {
    guard let currentUser = firebaseService.getCurrentUser() else {
      throw AuthError.noCurrentUser
    }
    
    let changeRequest = currentUser.createProfileChangeRequest()
    
    if let name = name {
      changeRequest.displayName = name
    }
    
    if let photoURL = photoURL, let url = URL(string: photoURL) {
      changeRequest.photoURL = url
    }
    
    try await changeRequest.commitChanges()
  }
  
  func updateEmail(_ email: String) async throws {
    guard let currentUser = firebaseService.getCurrentUser() else {
      throw AuthError.noCurrentUser
    }
    
    try await currentUser.updateEmail(to: email)
  }
  
  func updatePassword(_ password: String) async throws {
    guard let currentUser = firebaseService.getCurrentUser() else {
      throw AuthError.noCurrentUser
    }
    
    try await currentUser.updatePassword(to: password)
  }
  
  func sendPasswordResetEmail(email: String) async throws {
    try await Auth.auth().sendPasswordReset(withEmail: email)
  }
  
  func deleteAccount() async throws {
    guard let currentUser = firebaseService.getCurrentUser() else {
      throw AuthError.noCurrentUser
    }
    
    // Delete all user data from Firebase Database
    try await firebaseService.batchDeleteUserData(userID: currentUser.uid)
    
    // Delete the user account
    try await currentUser.delete()
  }
  
  func reauthenticate(email: String, password: String) async throws {
    guard let currentUser = firebaseService.getCurrentUser() else {
      throw AuthError.noCurrentUser
    }
    
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
    try await currentUser.reauthenticate(with: credential)
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

// MARK: - Extended Auth Errors

//extension AuthError {
//  static let noCurrentUser = AuthError.noPresentingViewController
//}
