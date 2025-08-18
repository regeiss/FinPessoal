//
//  UserDefaults+Extension.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 18/08/25.
//

import Foundation

extension UserDefaults {
  // MARK: - Onboarding
  var hasShownOnboarding: Bool {
    get { bool(forKey: "hasShownOnboarding") }
    set { set(newValue, forKey: "hasShownOnboarding") }
  }
  
  // MARK: - User Preferences
  var selectedCurrency: String {
    get { string(forKey: "selectedCurrency") ?? "BRL" }
    set { set(newValue, forKey: "selectedCurrency") }
  }
  
  var enableNotifications: Bool {
    get { object(forKey: "enableNotifications") as? Bool ?? true }
    set { set(newValue, forKey: "enableNotifications") }
  }
  
  var enableBiometricAuth: Bool {
    get { bool(forKey: "enableBiometricAuth") }
    set { set(newValue, forKey: "enableBiometricAuth") }
  }
  
  var lastSyncDate: Date? {
    get { object(forKey: "lastSyncDate") as? Date }
    set { set(newValue, forKey: "lastSyncDate") }
  }
  
  // MARK: - App Settings
  var useMockData: Bool {
    get { object(forKey: "useMockData") as? Bool ?? true }
    set { set(newValue, forKey: "useMockData") }
  }
  
  var enableDebugMode: Bool {
    get { bool(forKey: "enableDebugMode") }
    set { set(newValue, forKey: "enableDebugMode") }
  }
}
