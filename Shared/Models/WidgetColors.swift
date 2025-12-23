//
//  WidgetColors.swift
//  FinPessoal
//
//  Created by Claude Code on 18/12/25.
//
//  Lightweight color definitions for widget extension
//  Mirrors OldMoneyColors without main app dependencies
//

import SwiftUI

/// Old Money color palette for widgets
/// Lightweight version that works in widget extension without main app dependencies
struct WidgetColors: Equatable {

  // MARK: - Singleton

  static let shared = WidgetColors()
  private init() {}

  // MARK: - Base Colors (Light Mode)

  /// Primary background - #E8E4DD (darker for card contrast)
  var backgroundLight: Color {
    Color(red: 232/255, green: 228/255, blue: 221/255)
  }

  /// Card/surface backgrounds - #FAF8F5 (lighter for cards to pop)
  var surfaceLight: Color {
    Color(red: 250/255, green: 248/255, blue: 245/255)
  }

  /// Dividers, borders - #D8D4CC
  var dividerLight: Color {
    Color(red: 216/255, green: 212/255, blue: 204/255)
  }

  /// Secondary text - Stone #9C9589
  var textSecondaryLight: Color {
    Color(red: 156/255, green: 149/255, blue: 137/255)
  }

  /// Primary text - Charcoal #3D3A36
  var textLight: Color {
    Color(red: 61/255, green: 58/255, blue: 54/255)
  }

  // MARK: - Base Colors (Dark Mode)

  /// Primary background - Charcoal Dark #1C1B19
  var backgroundDark: Color {
    Color(red: 28/255, green: 27/255, blue: 25/255)
  }

  /// Card/surface backgrounds - Slate #2A2826
  var surfaceDark: Color {
    Color(red: 42/255, green: 40/255, blue: 38/255)
  }

  /// Dividers, borders - Dark Stone #3D3A36
  var dividerDark: Color {
    Color(red: 61/255, green: 58/255, blue: 54/255)
  }

  /// Secondary text - Muted Ivory #A8A49C
  var textSecondaryDark: Color {
    Color(red: 168/255, green: 164/255, blue: 156/255)
  }

  /// Primary text - Ivory #FAF8F5
  var textDark: Color {
    Color(red: 250/255, green: 248/255, blue: 245/255)
  }

  // MARK: - Accent Colors (Both Modes)

  /// Primary accent - Antique Gold #B8965C
  var accent: Color {
    Color(red: 184/255, green: 150/255, blue: 92/255)
  }

  /// Secondary accent - Soft Gold #D4BA8A
  var accentSecondary: Color {
    Color(red: 212/255, green: 186/255, blue: 138/255)
  }

  // MARK: - Semantic Colors (Light Mode)

  /// Income - Green #5C8A6B
  var incomeLight: Color {
    Color(red: 92/255, green: 138/255, blue: 107/255)
  }

  /// Expense - Rose #A67070
  var expenseLight: Color {
    Color(red: 166/255, green: 112/255, blue: 112/255)
  }

  /// Warning - Amber #B89A5C
  var warningLight: Color {
    Color(red: 184/255, green: 154/255, blue: 92/255)
  }

  /// Error - Burgundy #8B5A5A
  var errorLight: Color {
    Color(red: 139/255, green: 90/255, blue: 90/255)
  }

  /// Success - Sage #7A8B73
  var successLight: Color {
    Color(red: 122/255, green: 139/255, blue: 115/255)
  }

  // MARK: - Semantic Colors (Dark Mode)

  /// Income - Green #6B9E7A
  var incomeDark: Color {
    Color(red: 107/255, green: 158/255, blue: 122/255)
  }

  /// Expense - Rose #B88080
  var expenseDark: Color {
    Color(red: 184/255, green: 128/255, blue: 128/255)
  }

  /// Warning - Amber #C9AB6D
  var warningDark: Color {
    Color(red: 201/255, green: 171/255, blue: 109/255)
  }

  /// Error - Burgundy #9E6B6B
  var errorDark: Color {
    Color(red: 158/255, green: 107/255, blue: 107/255)
  }

  /// Success - Sage #8A9B83
  var successDark: Color {
    Color(red: 138/255, green: 155/255, blue: 131/255)
  }

  // MARK: - Adaptive Colors

  /// Background that adapts to color scheme
  var background: Color {
    Color(uiColor: UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(backgroundDark)
        : UIColor(backgroundLight)
    })
  }

  /// Surface that adapts to color scheme
  var surface: Color {
    Color(uiColor: UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(surfaceDark)
        : UIColor(surfaceLight)
    })
  }

  /// Text that adapts to color scheme
  var text: Color {
    Color(uiColor: UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(textDark)
        : UIColor(textLight)
    })
  }

  /// Secondary text that adapts to color scheme
  var textSecondary: Color {
    Color(uiColor: UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(textSecondaryDark)
        : UIColor(textSecondaryLight)
    })
  }

  /// Divider that adapts to color scheme
  var divider: Color {
    Color(uiColor: UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(dividerDark)
        : UIColor(dividerLight)
    })
  }

  /// Income color that adapts to color scheme
  var income: Color {
    Color(uiColor: UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(incomeDark)
        : UIColor(incomeLight)
    })
  }

  /// Expense color that adapts to color scheme
  var expense: Color {
    Color(uiColor: UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(expenseDark)
        : UIColor(expenseLight)
    })
  }

  /// Warning color that adapts to color scheme
  var warning: Color {
    Color(uiColor: UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(warningDark)
        : UIColor(warningLight)
    })
  }

  /// Error color that adapts to color scheme
  var error: Color {
    Color(uiColor: UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(errorDark)
        : UIColor(errorLight)
    })
  }

  /// Success color that adapts to color scheme
  var success: Color {
    Color(uiColor: UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(successDark)
        : UIColor(successLight)
    })
  }

  // MARK: - Gradient

  /// Subtle gold gradient for premium elements
  var goldGradient: LinearGradient {
    LinearGradient(
      colors: [accentSecondary, accent],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
}

// MARK: - Convenience Access

extension Color {
  /// Widget-specific color palette access
  static var widget: WidgetColors {
    WidgetColors.shared
  }
}

