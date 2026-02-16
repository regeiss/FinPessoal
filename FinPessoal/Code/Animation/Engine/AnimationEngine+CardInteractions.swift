//
//  AnimationEngine+CardInteractions.swift
//  FinPessoal
//
//  Created by Claude Code on 15/02/26.
//

import SwiftUI

// MARK: - Card Interactions Animation Extensions

extension AnimationEngine {

  // MARK: - Swipe Animations

  /// Swipe reveal animation - smooth spring for action reveal
  /// Response: 0.3s, Damping: 0.8 (gentle bounce)
  public static let swipeReveal = Animation.spring(response: 0.3, dampingFraction: 0.8)

  /// Swipe bounce animation - bouncier spring for resistance feel
  /// Response: 0.25s, Damping: 0.6 (more bounce)
  public static let swipeBounce = Animation.spring(response: 0.25, dampingFraction: 0.6)

  /// Swipe reset animation - return to center after release
  /// Response: 0.35s, Damping: 0.75 (balanced)
  public static let swipeReset = Animation.spring(response: 0.35, dampingFraction: 0.75)

  // MARK: - Flip Animations

  /// Card flip animation - dramatic 3D rotation
  /// Response: 0.4s, Damping: 0.75 (smooth rotation)
  public static let cardFlip = Animation.spring(response: 0.4, dampingFraction: 0.75)

  // MARK: - Expand/Collapse Animations

  /// Section expand animation - smooth height change
  /// Duration: 0.3s ease in-out
  public static let sectionExpand = Animation.easeInOut(duration: 0.3)

  /// Chevron rotate animation - quick rotation
  /// Duration: 0.25s ease in-out
  public static let chevronRotate = Animation.easeInOut(duration: 0.25)

  // MARK: - Adaptive Animations (Respect AnimationSettings)

  /// Returns swipe animation respecting current animation mode
  /// - Full: Spring animation with resistance
  /// - Reduced: Simplified linear animation
  /// - Minimal: No animation (instant)
  @MainActor
  public static func adaptiveSwipe() -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return swipeReveal
    case .reduced:
      return .linear(duration: 0.2)
    case .minimal:
      return nil
    }
  }

  /// Returns flip animation respecting current animation mode
  /// - Full: Spring animation with 3D rotation
  /// - Reduced: Simplified linear animation (2D)
  /// - Minimal: No animation (instant swap)
  @MainActor
  public static func adaptiveFlip() -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return cardFlip
    case .reduced:
      return .linear(duration: 0.25)
    case .minimal:
      return nil
    }
  }

  /// Returns expand animation respecting current animation mode
  /// - Full: Smooth ease in-out
  /// - Reduced: Faster linear animation
  /// - Minimal: No animation (instant reveal)
  @MainActor
  public static func adaptiveExpand() -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return sectionExpand
    case .reduced:
      return .linear(duration: 0.15)
    case .minimal:
      return nil
    }
  }

  /// Returns bounce-back animation respecting current animation mode
  /// - Full: Bouncy spring
  /// - Reduced: Quick linear
  /// - Minimal: Instant
  @MainActor
  public static func adaptiveBounce() -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return swipeBounce
    case .reduced:
      return .linear(duration: 0.15)
    case .minimal:
      return nil
    }
  }

  /// Returns reset animation respecting current animation mode
  /// - Full: Smooth spring
  /// - Reduced: Quick linear
  /// - Minimal: Instant
  @MainActor
  public static func adaptiveReset() -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return swipeReset
    case .reduced:
      return .linear(duration: 0.2)
    case .minimal:
      return nil
    }
  }
}
