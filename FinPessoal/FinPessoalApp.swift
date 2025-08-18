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
  @StateObject private var financeViewModel = FinanceViewModel()
  @StateObject private var navigationState = NavigationState()
  
  init() {
    // Configurar Firebase apenas se não estiver usando mock completo
    if !AppConfiguration.useMockAuth {
      FirebaseApp.configure()
      
      // Configurar persistência offline
      Database.database().isPersistenceEnabled = true
      
      // Configurar cache
      let settings = Database.database().reference().database.app?.options
      settings?.setCachePolicy(.cacheOnly)
    }
    
    // Inicializar AuthViewModel baseado na configuração
    if AppConfiguration.useMockAuth {
      _authViewModel = StateObject(wrappedValue: AuthViewModel(authRepository: MockAuthRepository(shouldAutoLogin: AppConfiguration.autoLogin)))
    } else {
      _authViewModel = StateObject(wrappedValue: AuthViewModel())
    }
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(authViewModel)
        .environmentObject(financeViewModel)
        .environmentObject(navigationState)
        .onAppear {
          authViewModel.checkAuthenticationState()
        }
    }
  }
}
