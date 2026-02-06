//
//  DepthModifier.swift
//  FinPessoal
//
//  Created by Claude Code on 2026-02-05.
//

import SwiftUI

// MARK: - Layered Background Modifier

extension View {
  /// Applies a layered background with subtle gradient
  /// - Parameters:
  ///   - cornerRadius: Corner radius for the background
  ///   - animated: Whether to animate the appearance
  /// - Returns: View with layered background applied
  func layeredBackground(cornerRadius: CGFloat = 16, animated: Bool = true) -> some View {
    self.modifier(LayeredBackgroundModifier(cornerRadius: cornerRadius, animated: animated))
  }

  /// Applies frosted glass effect
  /// - Parameter intensity: Blur intensity (0.0 to 1.0)
  /// - Returns: View with frosted glass effect
  func frostedGlass(intensity: Double = 1.0) -> some View {
    self.modifier(FrostedGlassModifier(intensity: intensity))
  }

  /// Applies inner shadow for recessed appearance
  /// - Parameters:
  ///   - cornerRadius: Corner radius for the shadow
  ///   - intensity: Shadow intensity (0.0 to 1.0)
  /// - Returns: View with inner shadow applied
  func innerShadow(cornerRadius: CGFloat = 16, intensity: Double = 1.0) -> some View {
    self.modifier(InnerShadowModifier(cornerRadius: cornerRadius, intensity: intensity))
  }
}

// MARK: - Layered Background

private struct LayeredBackgroundModifier: ViewModifier {
  let cornerRadius: CGFloat
  let animated: Bool

  @Environment(\.colorScheme) private var colorScheme

  func body(content: Content) -> some View {
    content
      .background(
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(
            LinearGradient(
              colors: gradientColors,
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
      )
  }

  private var gradientColors: [Color] {
    if colorScheme == .dark {
      return [
        OldMoneyColors.Dark.slate.opacity(0.95),
        OldMoneyColors.Dark.slate.opacity(0.85),
        OldMoneyColors.Dark.charcoal.opacity(0.9)
      ]
    } else {
      return [
        OldMoneyColors.Light.cream.opacity(0.98),
        OldMoneyColors.Light.cream.opacity(0.95),
        OldMoneyColors.Light.ivory.opacity(0.97)
      ]
    }
  }
}

// MARK: - Frosted Glass

private struct FrostedGlassModifier: ViewModifier {
  let intensity: Double

  @Environment(\.colorScheme) private var colorScheme

  func body(content: Content) -> some View {
    content
      .background(
        ZStack {
          // Base blur
          if #available(iOS 15.0, *) {
            Rectangle()
              .fill(.ultraThinMaterial)
          } else {
            Rectangle()
              .fill(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.8))
              .blur(radius: 10 * intensity)
          }
        }
      )
  }
}

// MARK: - Inner Shadow

private struct InnerShadowModifier: ViewModifier {
  let cornerRadius: CGFloat
  let intensity: Double

  @Environment(\.colorScheme) private var colorScheme

  func body(content: Content) -> some View {
    content
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(
            LinearGradient(
              colors: [
                Color.black.opacity(colorScheme == .dark ? 0.3 * intensity : 0.15 * intensity),
                Color.clear,
                Color.white.opacity(colorScheme == .dark ? 0.1 * intensity : 0.05 * intensity)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 2
          )
      )
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(
            LinearGradient(
              colors: [
                Color.black.opacity(colorScheme == .dark ? 0.2 * intensity : 0.1 * intensity),
                Color.clear
              ],
              startPoint: .top,
              endPoint: .center
            )
          )
          .blendMode(.multiply)
      )
  }
}
