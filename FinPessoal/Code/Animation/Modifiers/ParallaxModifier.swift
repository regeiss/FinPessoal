//
//  ParallaxModifier.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

// MARK: - Parallax Modifier

/// ViewModifier that applies parallax effect during scroll
struct ParallaxModifier: ViewModifier {

  // MARK: - Configuration

  /// Speed multiplier (0.0-1.0, where 0.7 = 30% slower than scroll)
  let speed: CGFloat

  /// Axis of parallax effect
  let axis: Axis

  /// Whether parallax is enabled
  let enabled: Bool

  // MARK: - State

  /// Current scroll offset
  @State private var scrollOffset: CGFloat = 0

  /// Last update time for throttling
  @State private var lastUpdate: CFTimeInterval = 0

  /// Environment values
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // MARK: - Body

  func body(content: Content) -> some View {
    if enabled && !reduceMotion && AnimationSettings.shared.effectiveMode != .minimal {
      content
        .offset(
          x: axis == .horizontal ? scrollOffset * (1 - speed) : 0,
          y: axis == .vertical ? scrollOffset * (1 - speed) : 0
        )
        .background(
          GeometryReader { geometry in
            Color.clear.preference(
              key: ScrollOffsetPreferenceKey.self,
              value: geometry.frame(in: .named("scroll")).minY
            )
          }
        )
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
          updateParallax(value)
        }
    } else {
      content
    }
  }

  // MARK: - Methods

  /// Updates parallax offset with throttling for 60fps
  private func updateParallax(_ offset: CGFloat) {
    let currentTime = CACurrentMediaTime()

    // Throttle updates to max once per frame (16.67ms)
    guard currentTime - lastUpdate > 0.016 else { return }

    scrollOffset = offset
    lastUpdate = currentTime
  }
}

// MARK: - View Extension

public extension View {
  /// Applies parallax effect to view during scroll
  /// - Parameters:
  ///   - speed: Speed multiplier (0.0-1.0, default 0.7 = 30% slower)
  ///   - axis: Parallax axis (default: .vertical)
  ///   - enabled: Whether effect is enabled (default: true)
  /// - Returns: View with parallax effect
  func withParallax(
    speed: CGFloat = 0.7,
    axis: Axis = .vertical,
    enabled: Bool = true
  ) -> some View {
    modifier(
      ParallaxModifier(
        speed: speed,
        axis: axis,
        enabled: enabled
      )
    )
  }
}
