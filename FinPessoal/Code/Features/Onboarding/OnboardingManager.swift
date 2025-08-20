//
//  OnboardingManager.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 19/08/25.
//

import Foundation
import Combine

class OnboardingManager: ObservableObject {
  @Published var hasCompletedOnboarding: Bool {
    didSet {
      UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
    }
  }
  
  init() {
    self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
  }
  
  func completeOnboarding() {
    hasCompletedOnboarding = true
  }
  
  func resetOnboarding() {
    hasCompletedOnboarding = false
  }
}
