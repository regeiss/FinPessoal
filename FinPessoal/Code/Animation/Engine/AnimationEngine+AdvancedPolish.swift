//
//  AnimationEngine+AdvancedPolish.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

// MARK: - Advanced Polish Animation Extensions

extension AnimationEngine {

  // MARK: - Hero Transitions

  /// Hero transition animation - smooth morphing between views
  /// Response: 0.4s, Damping: 0.8
  public static let heroTransition = Animation.spring(
    response: 0.4,
    dampingFraction: 0.8
  )

  // MARK: - Celebration Animations

  /// Celebration pulse animation - gentle scale bounce
  /// Response: 0.6s, Damping: 0.7
  public static let celebrationPulse = Animation.spring(
    response: 0.6,
    dampingFraction: 0.7
  )

  /// Celebration glow animation - soft fade in/out
  /// Duration: 0.8s ease in-out
  public static let celebrationGlow = Animation.easeInOut(duration: 0.8)

  /// Celebration fade animation - quick fade out
  /// Duration: 0.4s ease out
  public static let celebrationFade = Animation.easeOut(duration: 0.4)

  // MARK: - Gradient Animations

  /// Gradient shift animation - infinite loop
  /// Duration: 3.0s linear, repeats forever
  public static let gradientShift = Animation.linear(duration: 3.0)
    .repeatForever(autoreverses: false)

  // MARK: - Adaptive Animations (Respect AnimationSettings)

  /// Returns hero transition animation respecting current animation mode
  /// - Full: Spring animation with matched geometry (400ms)
  /// - Reduced: Simple scale transition (250ms linear)
  /// - Minimal: Instant crossfade (100ms)
  @MainActor
  public static func adaptiveHeroTransition() -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return heroTransition
    case .reduced:
      return .linear(duration: 0.25)
    case .minimal:
      return .linear(duration: 0.1)
    }
  }

  /// Returns celebration animation respecting current animation mode
  /// - Full: Complete pulse sequence (2000ms)
  /// - Reduced: Quick pulse (800ms)
  /// - Minimal: Simple fade (400ms)
  @MainActor
  public static func adaptiveCelebration() -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return celebrationPulse
    case .reduced:
      return .easeOut(duration: 0.4)
    case .minimal:
      return .linear(duration: 0.2)
    }
  }

  /// Returns gradient animation respecting current animation mode
  /// - Full: Smooth animation (3000ms loop)
  /// - Reduced: Slower animation (5000ms loop)
  /// - Minimal: No animation (nil)
  @MainActor
  public static func adaptiveGradient() -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return gradientShift
    case .reduced:
      return .linear(duration: 5.0).repeatForever(autoreverses: false)
    case .minimal:
      return nil
    }
  }
}
