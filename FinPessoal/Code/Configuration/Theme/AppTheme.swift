//
//  AppTheme.swift
//  FinPessoal
//
//  Created by Claude on 30/09/25.
//

import SwiftUI

struct AppTheme {

  // MARK: - Dark Mode Colors (Inspired by Code Syntax Highlighting)

  struct DarkColors {
    // Background colors (dark theme base)
    static let primaryBackground = Color(red: 0.12, green: 0.12, blue: 0.12)  // #1E1E1E
    static let secondaryBackground = Color(red: 0.16, green: 0.16, blue: 0.16)  // #282828
    static let cardBackground = Color(red: 0.20, green: 0.20, blue: 0.20)  // #333333

    // Primary accent colors (inspired by syntax highlighting)
    static let syntaxGreen = Color(red: 0.40, green: 0.86, blue: 0.18)  // #66DC2E (keyword green)
    static let syntaxBlue = Color(red: 0.35, green: 0.77, blue: 1.0)  // #5AC4FF (method blue)
    static let syntaxYellow = Color(red: 1.0, green: 0.84, blue: 0.18)  // #FFD72E (string yellow)
    static let syntaxPurple = Color(red: 0.85, green: 0.44, blue: 1.0)  // #D870FF (type purple)

    // Financial colors
    static let incomeGreen = syntaxGreen
    static let expenseRed = Color(red: 1.0, green: 0.35, blue: 0.31)  // #FF5950
    static let transferBlue = syntaxBlue

    // Text colors
    static let primaryText = Color(red: 0.92, green: 0.92, blue: 0.92)  // #EBEBEB
    static let secondaryText = Color(red: 0.65, green: 0.65, blue: 0.65)  // #A6A6A6
    static let accentText = syntaxBlue

    // UI element colors
    static let border = Color(red: 0.30, green: 0.30, blue: 0.30)  // #4D4D4D
    static let separator = Color(red: 0.25, green: 0.25, blue: 0.25)  // #404040

    // Status colors
    static let success = syntaxGreen
    static let warning = syntaxYellow
    static let error = expenseRed
    static let info = syntaxBlue
  }

  // MARK: - Light Mode Colors (for comparison)

  struct LightColors {
    static let primaryBackground = Color.white
    static let secondaryBackground = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let cardBackground = Color.white

    static let syntaxGreen = Color(red: 0.20, green: 0.60, blue: 0.20)
    static let syntaxBlue = Color(red: 0.20, green: 0.40, blue: 0.80)
    static let syntaxYellow = Color(red: 0.80, green: 0.60, blue: 0.20)
    static let syntaxPurple = Color(red: 0.60, green: 0.20, blue: 0.80)

    static let incomeGreen = Color.green
    static let expenseRed = Color.red
    static let transferBlue = Color.blue

    static let primaryText = Color.black
    static let secondaryText = Color.gray
    static let accentText = Color.blue

    static let border = Color.gray.opacity(0.3)
    static let separator = Color.gray.opacity(0.2)

    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
  }

  // MARK: - Dynamic Colors (adapts to color scheme)

  static func primaryBackground(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark
      ? DarkColors.primaryBackground : LightColors.primaryBackground
  }

  static func secondaryBackground(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark
      ? DarkColors.secondaryBackground : LightColors.secondaryBackground
  }

  static func cardBackground(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark
      ? DarkColors.cardBackground : LightColors.cardBackground
  }

  static func primaryText(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? DarkColors.primaryText : LightColors.primaryText
  }

  static func secondaryText(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? DarkColors.secondaryText : LightColors.secondaryText
  }

  static func accentColor(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? DarkColors.syntaxBlue : LightColors.syntaxBlue
  }

  static func incomeColor(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? DarkColors.incomeGreen : LightColors.incomeGreen
  }

  static func expenseColor(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? DarkColors.expenseRed : LightColors.expenseRed
  }

  static func transferColor(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? DarkColors.transferBlue : LightColors.transferBlue
  }

  static func borderColor(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? DarkColors.border : LightColors.border
  }

  static func separatorColor(_ colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? DarkColors.separator : LightColors.separator
  }
}

// MARK: - View Extensions for Easy Access

extension View {
  func themedBackground(_ colorScheme: ColorScheme) -> some View {
    self.background(AppTheme.primaryBackground(colorScheme))
  }

  func themedCardBackground(_ colorScheme: ColorScheme) -> some View {
    self.background(AppTheme.cardBackground(colorScheme))
  }

  func themedPrimaryText(_ colorScheme: ColorScheme) -> some View {
    self.foregroundColor(AppTheme.primaryText(colorScheme))
  }

  func themedSecondaryText(_ colorScheme: ColorScheme) -> some View {
    self.foregroundColor(AppTheme.secondaryText(colorScheme))
  }

  func themedBorder(_ colorScheme: ColorScheme) -> some View {
    self.overlay(
      RoundedRectangle(cornerRadius: 8)
        .stroke(AppTheme.borderColor(colorScheme), lineWidth: 1)
    )
  }
}

// MARK: - Transaction Type Colors

extension TransactionType {
  func color(_ colorScheme: ColorScheme) -> Color {
    switch self {
    case .income:
      return AppTheme.incomeColor(colorScheme)
    case .expense:
      return AppTheme.expenseColor(colorScheme)
    case .transfer:
      return AppTheme.transferColor(colorScheme)
    }
  }

  func syntaxColor(_ colorScheme: ColorScheme) -> Color {
    switch self {
    case .income:
      return colorScheme == .dark
        ? AppTheme.DarkColors.syntaxGreen : AppTheme.LightColors.syntaxGreen
    case .expense:
      return colorScheme == .dark
        ? AppTheme.DarkColors.expenseRed : AppTheme.LightColors.expenseRed
    case .transfer:
      return colorScheme == .dark
        ? AppTheme.DarkColors.syntaxBlue : AppTheme.LightColors.syntaxBlue
    }
  }
}
