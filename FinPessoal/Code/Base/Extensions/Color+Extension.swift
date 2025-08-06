//
//  Color+Theme.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 05/08/25.
//

import SwiftUI

extension Color {
  // Cores personalizadas que se adaptam ao tema
  static let appBackground = Color("AppBackground")
  static let cardBackground = Color("CardBackground")
  static let primaryText = Color("PrimaryText")
  static let secondaryText = Color("SecondaryText")
  static let accent = Color("AccentColor")
  
  // Cores específicas para finanças
  static let income = Color.green
  static let expense = Color.red
  static let neutral = Color.blue
  
  // Cores adaptáveis para modo escuro/claro
  static var adaptiveBackground: Color {
    Color(UIColor.systemBackground)
  }
  
  static var adaptiveSecondaryBackground: Color {
    Color(UIColor.secondarySystemBackground)
  }
  
  static var adaptiveTertiaryBackground: Color {
    Color(UIColor.tertiarySystemBackground)
  }
  
  static var adaptiveLabel: Color {
    Color(UIColor.label)
  }
  
  static var adaptiveSecondaryLabel: Color {
    Color(UIColor.secondaryLabel)
  }
  
  static var adaptiveTertiaryLabel: Color {
    Color(UIColor.tertiaryLabel)
  }
}

// Extensão para facilitar o uso de temas em ViewModifiers
struct ThemedCardStyle: ViewModifier {
  @Environment(\.colorScheme) var colorScheme
  
  func body(content: Content) -> some View {
    content
      .background(Color.adaptiveSecondaryBackground)
      .cornerRadius(12)
      .shadow(
        color: colorScheme == .dark ? .clear : .black.opacity(0.1),
        radius: colorScheme == .dark ? 0 : 4,
        x: 0,
        y: colorScheme == .dark ? 0 : 2
      )
  }
}

extension View {
  func themedCard() -> some View {
    modifier(ThemedCardStyle())
  }
}

// Cores para status de orçamento que se adaptam ao tema
extension Color {
  static func budgetStatus(for percentage: Double, in colorScheme: ColorScheme) -> Color {
    if percentage >= 1.0 {
      return .red
    } else if percentage >= 0.8 {
      return .orange
    } else {
      return .green
    }
  }
  
  static func transactionAmount(for type: TransactionType, in colorScheme: ColorScheme) -> Color {
    switch type {
    case .income:
      return colorScheme == .dark ? .green.opacity(0.8) : .green
    case .expense:
      return colorScheme == .dark ? .red.opacity(0.8) : .red
    }
  }
}
