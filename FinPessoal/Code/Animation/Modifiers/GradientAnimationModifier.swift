//
//  GradientAnimationModifier.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

/// Gradient animation style
public enum GradientAnimationStyle {
  /// Linear gradient
  case linear(UnitPoint, UnitPoint)

  /// Radial gradient
  case radial(center: UnitPoint)

  /// Angular gradient
  case angular(center: UnitPoint)
}

/// ViewModifier that applies animated gradient overlay
struct GradientAnimationModifier: ViewModifier {

  // MARK: - Configuration

  /// Gradient colors
  let colors: [Color]

  /// Animation duration
  let duration: TimeInterval

  /// Gradient style
  let style: GradientAnimationStyle

  // MARK: - State

  /// Current animation phase (0.0 to 1.0)
  @State private var animationPhase: CGFloat = 0

  // MARK: - Body

  func body(content: Content) -> some View {
    content
      .overlay(
        gradientView
          .opacity(AnimationSettings.shared.effectiveMode == .minimal ? 0 : 1)
      )
      .onAppear {
        startAnimation()
      }
  }

  // MARK: - Views

  /// Gradient view based on style
  @ViewBuilder
  private var gradientView: some View {
    switch style {
    case .linear(let start, let end):
      LinearGradient(
        colors: colors,
        startPoint: interpolatePoint(start, animationPhase),
        endPoint: interpolatePoint(end, 1 - animationPhase)
      )

    case .radial(let center):
      RadialGradient(
        colors: colors,
        center: center,
        startRadius: 0,
        endRadius: 200
      )

    case .angular(let center):
      AngularGradient(
        colors: colors,
        center: center,
        angle: .degrees(animationPhase * 360)
      )
    }
  }

  // MARK: - Methods

  /// Starts the gradient animation
  private func startAnimation() {
    guard AnimationSettings.shared.effectiveMode != .minimal else { return }

    withAnimation(AnimationEngine.adaptiveGradient()) {
      animationPhase = 1.0
    }
  }

  /// Interpolates point position based on animation phase
  private func interpolatePoint(_ point: UnitPoint, _ phase: CGFloat) -> UnitPoint {
    let offset = phase * 0.2 // Subtle 20% movement
    return UnitPoint(
      x: point.x + offset,
      y: point.y + offset
    )
  }
}

// MARK: - View Extension

public extension View {
  /// Applies animated gradient overlay to view
  /// - Parameters:
  ///   - colors: Gradient colors
  ///   - duration: Animation duration (default: 3.0s)
  ///   - style: Gradient style (default: linear)
  /// - Returns: View with gradient overlay
  func withGradientAnimation(
    colors: [Color],
    duration: TimeInterval = 3.0,
    style: GradientAnimationStyle = .linear(.topLeading, .bottomTrailing)
  ) -> some View {
    modifier(
      GradientAnimationModifier(
        colors: colors,
        duration: duration,
        style: style
      )
    )
  }
}
