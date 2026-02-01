//
//  OldMoneyTheme.swift
//  FinPessoal
//
//  Created by Claude Code on 18/12/25.
//

import SwiftUI

/// Old Money theme configuration - typography, shadows, and polish details
struct OldMoneyTheme {

  // MARK: - Typography

  struct Typography {
    /// Headlines using system serif (New York)
    static func headline(_ size: CGFloat = 22) -> Font {
      .system(size: size, weight: .medium, design: .serif)
    }

    /// Large title for prominent displays
    static let largeTitle: Font = .system(size: 34, weight: .medium, design: .serif)

    /// Title for section headers
    static let title: Font = .system(size: 28, weight: .medium, design: .serif)

    /// Title 2 for card headers
    static let title2: Font = .system(size: 22, weight: .medium, design: .serif)

    /// Title 3 for smaller headers
    static let title3: Font = .system(size: 20, weight: .medium, design: .serif)

    /// Body text using SF Pro
    static let body: Font = .system(size: 17, weight: .regular, design: .default)

    /// Subheadline for secondary content
    static let subheadline: Font = .system(size: 15, weight: .regular, design: .default)

    /// Caption for hints and timestamps
    static let caption: Font = .system(size: 13, weight: .light, design: .default)

    /// Small caption for fine print
    static let caption2: Font = .system(size: 12, weight: .light, design: .default)

    /// Money amounts using SF Pro Rounded
    static func money(_ size: CGFloat = 20) -> Font {
      .system(size: size, weight: .medium, design: .rounded)
    }

    /// Large money display
    static let moneyLarge: Font = .system(size: 28, weight: .medium, design: .rounded)

    /// Medium money display
    static let moneyMedium: Font = .system(size: 20, weight: .medium, design: .rounded)

    /// Small money display
    static let moneySmall: Font = .system(size: 15, weight: .medium, design: .rounded)
  }

  // MARK: - Shadows

  struct Shadows {
    /// Subtle shadow for cards
    static let card = Shadow(
      color: Color(red: 61/255, green: 58/255, blue: 54/255).opacity(0.06),
      radius: 12,
      x: 0,
      y: 4
    )

    /// Light shadow for buttons
    static let button = Shadow(
      color: Color(red: 61/255, green: 58/255, blue: 54/255).opacity(0.05),
      radius: 8,
      x: 0,
      y: 2
    )

    /// Elevated shadow for modals/sheets
    static let elevated = Shadow(
      color: Color(red: 61/255, green: 58/255, blue: 54/255).opacity(0.08),
      radius: 16,
      x: 0,
      y: 6
    )

    /// No shadow
    static let none = Shadow(color: .clear, radius: 0, x: 0, y: 0)
  }

  /// Shadow configuration
  struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
  }

  // MARK: - Border Radius

  struct Radius {
    /// Small elements (buttons, chips)
    static let small: CGFloat = 8

    /// Medium elements (cards)
    static let medium: CGFloat = 12

    /// Large elements (sheets)
    static let large: CGFloat = 16

    /// Extra large (modals)
    static let extraLarge: CGFloat = 20

    /// Circular
    static let circular: CGFloat = 9999
  }

  // MARK: - Borders

  struct Borders {
    /// Standard border width
    static let width: CGFloat = 0.5

    /// Thicker border for emphasis
    static let thickWidth: CGFloat = 1.0

    /// Border color for light mode
    static var color: Color {
      Color.oldMoney.divider
    }
  }

  // MARK: - Spacing

  struct Spacing {
    /// Extra small spacing
    static let xs: CGFloat = 4

    /// Small spacing
    static let sm: CGFloat = 8

    /// Medium spacing
    static let md: CGFloat = 12

    /// Default spacing
    static let base: CGFloat = 16

    /// Large spacing
    static let lg: CGFloat = 24

    /// Extra large spacing
    static let xl: CGFloat = 32

    /// Extra extra large spacing
    static let xxl: CGFloat = 48
  }

  // MARK: - Animation

  struct Animation {
    /// Standard duration
    static let duration: Double = 0.25

    /// Fast duration
    static let fast: Double = 0.15

    /// Slow duration
    static let slow: Double = 0.35

    /// Standard animation
    static var standard: SwiftUI.Animation {
      .easeInOut(duration: duration)
    }

    /// Fast animation
    static var quick: SwiftUI.Animation {
      .easeInOut(duration: fast)
    }

    /// Slow animation
    static var gentle: SwiftUI.Animation {
      .easeInOut(duration: slow)
    }

    /// Spring animation (subtle, no bounce)
    static var spring: SwiftUI.Animation {
      .spring(response: 0.3, dampingFraction: 0.9)
    }
  }
}

// MARK: - View Modifiers

extension View {
  /// Applies old money card shadow
  func oldMoneyCardShadow() -> some View {
    let shadow = OldMoneyTheme.Shadows.card
    return self.shadow(
      color: shadow.color,
      radius: shadow.radius,
      x: shadow.x,
      y: shadow.y
    )
  }

  /// Applies old money button shadow
  func oldMoneyButtonShadow() -> some View {
    let shadow = OldMoneyTheme.Shadows.button
    return self.shadow(
      color: shadow.color,
      radius: shadow.radius,
      x: shadow.x,
      y: shadow.y
    )
  }

  /// Applies old money elevated shadow
  func oldMoneyElevatedShadow() -> some View {
    let shadow = OldMoneyTheme.Shadows.elevated
    return self.shadow(
      color: shadow.color,
      radius: shadow.radius,
      x: shadow.x,
      y: shadow.y
    )
  }

  /// Applies old money card style (surface background, rounded corners, shadow)
  func oldMoneyCard() -> some View {
    self
      .background(Color.oldMoney.surface)
      .clipShape(RoundedRectangle(cornerRadius: OldMoneyTheme.Radius.medium))
      .oldMoneyCardShadow()
  }

  /// Applies old money button style
  func oldMoneyButton() -> some View {
    self
      .background(Color.oldMoney.accent)
      .foregroundStyle(Color.oldMoney.background)
      .clipShape(RoundedRectangle(cornerRadius: OldMoneyTheme.Radius.small))
      .oldMoneyButtonShadow()
  }

  /// Applies old money secondary button style
  func oldMoneySecondaryButton() -> some View {
    self
      .background(Color.oldMoney.surface)
      .foregroundStyle(Color.oldMoney.accent)
      .clipShape(RoundedRectangle(cornerRadius: OldMoneyTheme.Radius.small))
      .overlay(
        RoundedRectangle(cornerRadius: OldMoneyTheme.Radius.small)
          .strokeBorder(Color.oldMoney.accent, lineWidth: OldMoneyTheme.Borders.width)
      )
  }
}

// MARK: - Font Modifiers

extension View {
  /// Applies headline typography
  func oldMoneyHeadline(_ size: CGFloat = 22) -> some View {
    self.font(OldMoneyTheme.Typography.headline(size))
  }

  /// Applies money typography
  func oldMoneyMoney(_ size: CGFloat = 20) -> some View {
    self.font(OldMoneyTheme.Typography.money(size))
  }
}

