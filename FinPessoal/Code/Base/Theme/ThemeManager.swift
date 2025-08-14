//
//  ThemeManager.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 11/08/25.
//

import Foundation
import Combine
import Firebase
import SwiftUI

class ThemeManager: ObservableObject {
  @Published var isDarkMode = false
  
  var colorScheme: ColorScheme? {
    isDarkMode ? .dark : .light
  }
  
  init() {
    isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
  }
  
  func toggleDarkMode() {
    isDarkMode.toggle()
    UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
    Analytics.logEvent("theme_changed", parameters: ["dark_mode": isDarkMode])
  }
}
