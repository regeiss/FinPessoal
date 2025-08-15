//
//  AuthenticationViewModel.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import Combine
import FirebaseAuth
import Firebase

class AuthViewModel: ObservableObject {
  @Published var isAuthenticated = false
  @Published var currentUser: User?
  @Published var isLoading = false
  @Published var error: AppError?
  
  private let userRepository: UserRepositoryProtocol
  private var cancellables = Set<AnyCancellable>()
  
  init(userRepository: UserRepositoryProtocol = UserRepository()) {
    self.userRepository = userRepository
    setupAuthStateListener()
  }
  
  private func setupAuthStateListener() {
    Auth.auth().addStateDidChangeListener { [weak self] _, user in
      DispatchQueue.main.async {
        self?.isAuthenticated = user != nil
        if user != nil {
          self?.loadCurrentUser()
        } else {
          self?.currentUser = nil
        }
      }
    }
  }
  
  private func loadCurrentUser() {
    userRepository.getCurrentUser()
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          if case .failure(let error) = completion {
            self?.error = error
          }
        },
        receiveValue: { [weak self] user in
          self?.currentUser = user
        }
      )
      .store(in: &cancellables)
  }
  
  func signInWithApple() {
    // Implementation for Apple Sign In
    Analytics.logEvent("sign_in_apple_initiated", parameters: nil)
  }
  
  func signInWithGoogle() {
    // Implementation for Google Sign In
    Analytics.logEvent("sign_in_google_initiated", parameters: nil)
  }
  
  func signInWithEmail(email: String, password: String) {
    isLoading = true
    error = nil
    
    Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
      DispatchQueue.main.async {
        self?.isLoading = false
        if let error = error {
          self?.error = .authenticationFailed(error.localizedDescription)
          Analytics.logEvent("sign_in_email_failed", parameters: ["error": error.localizedDescription])
        } else {
          Analytics.logEvent("sign_in_email_success", parameters: nil)
        }
      }
    }
  }
  
  func signUp(name: String, email: String, password: String) {
    isLoading = true
    error = nil
    
    Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
      DispatchQueue.main.async {
        self?.isLoading = false
        if let error = error {
          self?.error = .authenticationFailed(error.localizedDescription)
        } else if let user = result?.user {
          let newUser = User(
            id: user.uid,
            name: name,
            email: email,
            createdAt: Date(),
            isActive: true
          )
          self?.createUserProfile(newUser)
          Analytics.logEvent("sign_up_success", parameters: nil)
        }
      }
    }
  }
  
  private func createUserProfile(_ user: User) {
    userRepository.updateUser(user)
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          if case .failure(let error) = completion {
            self?.error = error
          }
        },
        receiveValue: { [weak self] _ in
          self?.currentUser = user
        }
      )
      .store(in: &cancellables)
  }
  
  func signOut() {
    do {
      try Auth.auth().signOut()
      Analytics.logEvent("sign_out", parameters: nil)
    } catch {
      self.error = .authenticationFailed(error.localizedDescription)
    }
  }
}
