//
//  AppColors.swift
//  FinPessoal
//
//  Created by Roberto Edgar Geiss on 14/10/25.
//

import SwiftUI

extension Color {
  // MARK: - Light Mode Color Palette

  /// Shark - Dark blue-gray for headers and primary text
  /// HEX: #20262D
  static let shark = Color(hex: "20262D")

  /// Leather - Medium brown for secondary elements
  /// HEX: #957652
  static let leather = Color(hex: "957652")

  /// Sorrel Brown - Light brown for tertiary elements
  /// HEX: #C6AB80
  static let sorrellBrown = Color(hex: "C6AB80")

  /// Tallow - Very light beige for backgrounds
  /// HEX: #A6A28B
  static let tallow = Color(hex: "A6A28B")

  /// Oslo Gray - Light gray for subtle backgrounds
  /// HEX: #8B8C90
  static let osloGray = Color(hex: "8B8C90")

  // MARK: - App Theme Colors (Semantic colors that adapt to light/dark mode)

  static var appBackground: Color {
    Color(uiColor: .systemBackground)
  }

  static var appSecondaryBackground: Color {
    Color(uiColor: .secondarySystemBackground)
  }

  static var appPrimaryText: Color {
    Color(uiColor: UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark
        ? .white
        : UIColor(red: 0.125, green: 0.149, blue: 0.176, alpha: 1.0) // Shark
    })
  }

  static var appSecondaryText: Color {
    Color(uiColor: UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark
        ? .lightGray
        : UIColor(red: 0.545, green: 0.549, blue: 0.565, alpha: 1.0) // Oslo Gray
    })
  }

  static var appAccent: Color {
    Color(uiColor: UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark
        ? UIColor(red: 0.40, green: 0.86, blue: 0.18, alpha: 1.0)
        : UIColor(red: 0.584, green: 0.463, blue: 0.322, alpha: 1.0) // Leather
    })
  }

  static var appCardBackground: Color {
    Color(uiColor: UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark
        ? UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        : UIColor(red: 0.776, green: 0.671, blue: 0.502, alpha: 0.15) // Sorrell Brown with opacity
    })
  }

  static var appDivider: Color {
    Color(uiColor: UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark
        ? UIColor(white: 0.3, alpha: 1.0)
        : UIColor(red: 0.651, green: 0.635, blue: 0.545, alpha: 0.3) // Tallow with opacity
    })
  }
}

// MARK: - Hex Color Extension

extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hex.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (1, 1, 1, 0)
    }

    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue:  Double(b) / 255,
      opacity: Double(a) / 255
    )
  }
}
