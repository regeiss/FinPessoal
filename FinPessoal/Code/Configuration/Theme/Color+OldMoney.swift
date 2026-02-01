//
//  Color+OldMoney.swift
//  FinPessoal
//
//  Created by Claude Code on 18/12/25.
//

import SwiftUI

// MARK: - Color Extension

extension Color {
  /// Access to Old Money color palette
  static let oldMoney = OldMoneyColorScheme()
}

// MARK: - Old Money Color Scheme

struct OldMoneyColorScheme {

  // MARK: - Environment Access

  @Environment(\.colorScheme) private var colorScheme

  // MARK: - Base Colors

  /// Primary background color (Ivory / Charcoal)
  var background: Color {
    Color(light: OldMoneyColors.Light.ivory, dark: OldMoneyColors.Dark.charcoal)
  }

  /// Secondary background for cards and surfaces (Cream / Slate)
  var surface: Color {
    Color(light: OldMoneyColors.Light.cream, dark: OldMoneyColors.Dark.slate)
  }

  /// Tertiary background for grouped content
  var surfaceSecondary: Color {
    Color(light: OldMoneyColors.Light.warmGray, dark: OldMoneyColors.Dark.darkStone)
  }

  /// Dividers and subtle borders
  var divider: Color {
    Color(light: OldMoneyColors.Light.warmGray, dark: OldMoneyColors.Dark.darkStone)
  }

  // MARK: - Text Colors

  /// Primary text color
  var text: Color {
    Color(light: OldMoneyColors.Light.charcoal, dark: OldMoneyColors.Dark.ivory)
  }

  /// Secondary text color for less important content
  var textSecondary: Color {
    Color(light: OldMoneyColors.Light.stone, dark: OldMoneyColors.Dark.mutedIvory)
  }

  /// Tertiary text color for hints and placeholders
  var textTertiary: Color {
    Color(light: OldMoneyColors.Light.stone.opacity(0.7), dark: OldMoneyColors.Dark.mutedIvory.opacity(0.7))
  }

  // MARK: - Accent Colors

  /// Primary accent color (Antique Gold)
  var accent: Color {
    OldMoneyColors.Accent.antiqueGold
  }

  /// Secondary accent color (Soft Gold)
  var accentSecondary: Color {
    OldMoneyColors.Accent.softGold
  }

  /// Accent color with reduced opacity for backgrounds
  var accentBackground: Color {
    OldMoneyColors.Accent.antiqueGold.opacity(0.12)
  }

  // MARK: - Semantic Colors

  /// Income and positive amounts
  var income: Color {
    Color(light: OldMoneyColors.SemanticLight.income, dark: OldMoneyColors.SemanticDark.income)
  }

  /// Expenses and negative amounts
  var expense: Color {
    Color(light: OldMoneyColors.SemanticLight.expense, dark: OldMoneyColors.SemanticDark.expense)
  }

  /// Warning state
  var warning: Color {
    Color(light: OldMoneyColors.SemanticLight.warning, dark: OldMoneyColors.SemanticDark.warning)
  }

  /// Error state
  var error: Color {
    Color(light: OldMoneyColors.SemanticLight.error, dark: OldMoneyColors.SemanticDark.error)
  }

  /// Success state
  var success: Color {
    Color(light: OldMoneyColors.SemanticLight.success, dark: OldMoneyColors.SemanticDark.success)
  }

  /// Neutral state
  var neutral: Color {
    Color(light: OldMoneyColors.SemanticLight.neutral, dark: OldMoneyColors.SemanticDark.neutral)
  }

  /// Attention/due soon state
  var attention: Color {
    Color(light: OldMoneyColors.SemanticLight.attention, dark: OldMoneyColors.SemanticDark.attention)
  }

  // MARK: - Category Colors

  /// Get color for transaction category
  func category(_ category: TransactionCategory) -> Color {
    switch category {
    case .food:
      return OldMoneyColors.Category.food
    case .transport:
      return OldMoneyColors.Category.transport
    case .entertainment:
      return OldMoneyColors.Category.entertainment
    case .healthcare:
      return OldMoneyColors.Category.healthcare
    case .shopping:
      return OldMoneyColors.Category.shopping
    case .bills:
      return OldMoneyColors.Category.bills
    case .salary:
      return OldMoneyColors.Category.salary
    case .investment:
      return OldMoneyColors.Category.investment
    case .housing:
      return OldMoneyColors.Category.housing
    case .other:
      return OldMoneyColors.Category.other
    }
  }

  // MARK: - Gradient

  /// Subtle gold gradient for premium elements
  var goldGradient: LinearGradient {
    LinearGradient(
      colors: [OldMoneyColors.Accent.softGold, OldMoneyColors.Accent.antiqueGold],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  /// Subtle surface gradient
  var surfaceGradient: LinearGradient {
    LinearGradient(
      colors: [
        Color(light: OldMoneyColors.Light.ivory, dark: OldMoneyColors.Dark.charcoal),
        Color(light: OldMoneyColors.Light.cream, dark: OldMoneyColors.Dark.slate)
      ],
      startPoint: .top,
      endPoint: .bottom
    )
  }
}

// MARK: - Color Light/Dark Initializer

extension Color {
  /// Creates a color that adapts to light and dark mode
  init(light: Color, dark: Color) {
    self.init(uiColor: UIColor { traitCollection in
      switch traitCollection.userInterfaceStyle {
      case .dark:
        return UIColor(dark)
      default:
        return UIColor(light)
      }
    })
  }
}

// MARK: - Convenience Modifiers

extension View {
  /// Applies old money background color
  func oldMoneyBackground() -> some View {
    self.background(Color.oldMoney.background)
  }

  /// Applies old money surface color
  func oldMoneySurface() -> some View {
    self.background(Color.oldMoney.surface)
  }

  /// Applies old money text color
  func oldMoneyForeground() -> some View {
    self.foregroundStyle(Color.oldMoney.text)
  }

  /// Applies old money accent color
  func oldMoneyAccent() -> some View {
    self.foregroundStyle(Color.oldMoney.accent)
  }
}
