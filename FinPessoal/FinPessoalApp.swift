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
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @Environment(\.scenePhase) private var scenePhase

  @StateObject private var authViewModel: AuthViewModel
  @StateObject private var financeViewModel: FinanceViewModel
  @StateObject private var accountViewModel: AccountViewModel
  @StateObject private var navigationState = NavigationState()
  @StateObject private var appState = AppState()
  @StateObject private var onboardingManager = OnboardingManager()
  @StateObject private var notificationManager = NotificationManager.shared
  @StateObject private var deepLinkHandler = DeepLinkHandler.shared
  
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
        .environmentObject(notificationManager)
        .environmentObject(deepLinkHandler)
        .onAppear {
          authViewModel.checkAuthenticationState()
          requestNotificationPermissions()
        }
        .onOpenURL { url in
          handleOpenURL(url)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
          handleScenePhaseChange(from: oldPhase, to: newPhase)
        }
    }
  }

  // MARK: - Scene Phase Handling

  private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
    switch newPhase {
    case .background:
      // Sync widget data when app goes to background
      financeViewModel.syncWidgetData()
      print("App entering background - widget data synced")
    case .active:
      // Could trigger data refresh when app becomes active
      break
    case .inactive:
      break
    @unknown default:
      break
    }
  }

  // MARK: - URL Handling

  private func handleOpenURL(_ url: URL) {
    // Try to handle as widget deep link first
    if url.scheme == DeepLinkHandler.urlScheme {
      deepLinkHandler.handleURL(url)
      return
    }

    // Handle Google Sign-In URL
    if !AppConfiguration.shared.useMockData {
      GIDSignIn.sharedInstance.handle(url)
    }
  }

  // MARK: - Private Methods

  private func requestNotificationPermissions() {
    Task {
      do {
        let granted = try await NotificationManager.shared.requestAuthorization()
        if granted {
          print("✅ Notification permissions granted")
          await NotificationManager.shared.scheduleDailySummary()
        } else {
          print("⚠️ Notification permissions denied")
        }
      } catch {
        print("❌ Error requesting notification permissions: \(error.localizedDescription)")
      }
    }
  }
}
