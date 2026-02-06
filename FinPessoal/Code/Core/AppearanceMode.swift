//
//  AppearanceMode.swift
//  FinPessoal
//
//  Created by Claude Code on 03/02/26.
//

import SwiftUI

/// Represents the user's preferred appearance mode for the app
enum AppearanceMode: String, CaseIterable {
  case system
  case light
  case dark

  /// Localized display name for the appearance mode
  var displayName: String {
    switch self {
    case .system:
      return String(localized: "appearance.system", defaultValue: "Automático")
    case .light:
      return String(localized: "appearance.light", defaultValue: "Claro")
    case .dark:
      return String(localized: "appearance.dark", defaultValue: "Escuro")
    }
  }

  /// SF Symbol icon name for the appearance mode
  var iconName: String {
    switch self {
    case .system:
      return "circle.lefthalf.filled"
    case .light:
      return "sun.max.fill"
    case .dark:
      return "moon.fill"
    }
  }

  /// SwiftUI ColorScheme corresponding to this appearance mode
  var colorScheme: ColorScheme? {
    switch self {
    case .system:
      return nil  // Use system preference
    case .light:
      return .light
    case .dark:
      return .dark
    }
  }
}
