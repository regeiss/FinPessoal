//
//  GradientAnimationView.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

/// Standalone animated gradient view
public struct GradientAnimationView: View {

  // MARK: - Configuration

  /// Gradient colors
  private let colors: [Color]

  /// Animation duration
  private let duration: TimeInterval

  /// Gradient style
  private let style: GradientAnimationStyle

  // MARK: - State

  /// Current animation phase
  @State private var animationPhase: CGFloat = 0

  // MARK: - Initialization

  /// Creates an animated gradient view
  /// - Parameters:
  ///   - colors: Gradient colors
  ///   - duration: Animation duration (default: 3.0s)
  ///   - style: Gradient style (default: linear)
  public init(
    colors: [Color],
    duration: TimeInterval = 3.0,
    style: GradientAnimationStyle = .linear(.topLeading, .bottomTrailing)
  ) {
    self.colors = colors
    self.duration = duration
    self.style = style
  }

  // MARK: - Body

  public var body: some View {
    gradientView
      .drawingGroup() // GPU acceleration
      .onAppear {
        startAnimation()
      }
  }

  // MARK: - Views

  @ViewBuilder
  private var gradientView: some View {
    switch style {
    case .linear(let start, let end):
      LinearGradient(
        colors: colors,
        startPoint: start,
        endPoint: end
      )

    case .radial(let center):
      RadialGradient(
        colors: colors,
        center: center,
        startRadius: 0,
        endRadius: 300
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

  private func startAnimation() {
    guard AnimationSettings.shared.effectiveMode != .minimal else { return }

    withAnimation(AnimationEngine.adaptiveGradient()) {
      animationPhase = 1.0
    }
  }
}
