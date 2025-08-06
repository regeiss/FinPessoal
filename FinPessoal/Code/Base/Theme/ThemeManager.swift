//
//  ThemeManager.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 05/08/25.
//

import Foundation
import SwiftUI
import Combine

enum AppTheme: String, CaseIterable {
  case system = "system"
  case light = "light"
  case dark = "dark"
  
  var displayName: String {
    switch self {
    case .system: return "Sistema"
    case .light: return "Claro"
    case .dark: return "Escuro"
    }
  }
  
  var icon: String {
    switch self {
    case .system: return "circle.lefthalf.filled"
    case .light: return "sun.max"
    case .dark: return "moon"
    }
  }
  
  var colorScheme: ColorScheme? {
    switch self {
    case .system: return nil
    case .light: return .light
    case .dark: return .dark
    }
  }
}

@MainActor
class ThemeManager: ObservableObject {
  @Published var currentTheme: AppTheme {
    didSet {
      saveTheme()
      updateAppearance()
    }
  }
  
  private let userDefaults = UserDefaults.standard
  private let themeKey = "app_theme"
  
  init() {
    // Carregar tema salvo ou usar sistema como padrão
    let savedTheme = userDefaults.string(forKey: themeKey) ?? AppTheme.system.rawValue
    self.currentTheme = AppTheme(rawValue: savedTheme) ?? .system
    updateAppearance()
  }
  
  private func saveTheme() {
    userDefaults.set(currentTheme.rawValue, forKey: themeKey)
  }
  
  private func updateAppearance() {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
      return
    }
    
    for window in windowScene.windows {
      window.overrideUserInterfaceStyle = currentTheme.colorScheme?.uiUserInterfaceStyle ?? .unspecified
    }
  }
  
  func setTheme(_ theme: AppTheme) {
    currentTheme = theme
  }
}
