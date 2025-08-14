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
struct PersonalFinanceApp: App {
  @StateObject private var appState = AppState()
  @StateObject private var authViewModel = AuthenticationViewModel()
  @StateObject private var themeManager = ThemeManager()
  
  init() {
    FirebaseApp.configure()
    Analytics.setAnalyticsCollectionEnabled(true)
    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(appState)
        .environmentObject(authViewModel)
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.colorScheme)
    }
  }
}
