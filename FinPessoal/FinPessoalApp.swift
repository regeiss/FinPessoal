//
//  PersonalFinanceApp.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseAnalytics
import FirebaseCrashlytics
import GoogleSignIn

@main
struct MoneyManagerApp: App {
  @StateObject private var authViewModel: AuthViewModel
  @StateObject private var financeViewModel: FinanceViewModel
  @StateObject private var accountViewModel: AccountViewModel
  @StateObject private var navigationState = NavigationState()
  @StateObject private var appState = AppState()
  @StateObject private var onboardingManager = OnboardingManager()
  
  init() {
    // Always configure Firebase to prevent initialization warnings
    FirebaseApp.configure()
    
    // Only configure additional Firebase features if not using mocks
    if !AppConfiguration.shared.useMockData {
      // Configure Google Sign-In
      guard let clientID = FirebaseApp.app()?.options.clientID else {
        fatalError("No client ID found in Firebase configuration")
      }
      GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
      
      // Configure offline persistence
      if AppConfiguration.shared.shouldUsePersistence {
        Database.database().isPersistenceEnabled = true
      }
    }
    
    // Create repositories based on configuration
    let authRepo = AppConfiguration.shared.createAuthRepository()
    let financeRepo = AppConfiguration.shared.createFinanceRepository()
    let accountRepo = AppConfiguration.shared.createAccountRepository()
    
    // Initialize ViewModels with appropriate repositories
    _authViewModel = StateObject(wrappedValue: AuthViewModel(authRepository: authRepo))
    _financeViewModel = StateObject(wrappedValue: FinanceViewModel(financeRepository: financeRepo))
    _accountViewModel = StateObject(wrappedValue: AccountViewModel(repository: accountRepo))
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(authViewModel)
        .environmentObject(financeViewModel)
        .environmentObject(accountViewModel)
        .environmentObject(navigationState)
        .environmentObject(appState)
        .environmentObject(onboardingManager)
        .onAppear {
          authViewModel.checkAuthenticationState()
        }
        .onOpenURL { url in
          if !AppConfiguration.shared.useMockData {
            GIDSignIn.sharedInstance.handle(url)
          }
        }
    }
  }
}
