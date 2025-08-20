//
//  PersonalFinanceApp.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseAnalytics
import FirebaseCrashlytics

@main
struct MoneyManagerApp: App {
  @StateObject private var authViewModel: AuthViewModel
  @StateObject private var financeViewModel: FinanceViewModel
  @StateObject private var navigationState = NavigationState()
  @StateObject private var appState = AppState()
  
  init() {
    // Configure Firebase only if not using mocks
    if !AppConfiguration.shared.useMockData {
      FirebaseApp.configure()
      
      // Configure offline persistence
      if AppConfiguration.shared.shouldUsePersistence {
        Database.database().isPersistenceEnabled = true
      }
    }
    
    // Create repositories based on configuration
    let authRepo = AppConfiguration.shared.createAuthRepository()
    let financeRepo = AppConfiguration.shared.createFinanceRepository()
    
    // Initialize ViewModels with appropriate repositories
    _authViewModel = StateObject(wrappedValue: AuthViewModel(authRepository: authRepo))
    _financeViewModel = StateObject(wrappedValue: FinanceViewModel(financeRepository: financeRepo))
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(authViewModel)
        .environmentObject(financeViewModel)
        .environmentObject(navigationState)
        .environmentObject(appState)
        .onAppear {
          authViewModel.checkAuthenticationState()
        }
    }
  }
}
