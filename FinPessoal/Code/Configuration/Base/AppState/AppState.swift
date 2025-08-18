//
//  AppState.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import Combine
import Firebase

class AppState: ObservableObject {
  @Published var hasCompletedOnboarding = false
  @Published var selectedTab = 0
  @Published var errorToShow: AppError?
  
  init() {
    hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
  }
  
  func completeOnboarding() {
    hasCompletedOnboarding = true
    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    Analytics.logEvent("onboarding_completed", parameters: nil)
  }
  
  func showError(_ error: AppError) {
    errorToShow = error
    Crashlytics.crashlytics().record(error: error)
  }
}
