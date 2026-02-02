// FinPessoal/Code/Animation/Engine/AnimationEngine.swift
import SwiftUI

/// Centralized animation configuration and presets
public struct AnimationEngine {

  // MARK: - Spring Animations

  /// Gentle spring for subtle interactions (response: 0.6, damping: 0.8)
  public static let gentleSpring = Animation.spring(response: 0.6, dampingFraction: 0.8)

  /// Bouncy spring for playful interactions (response: 0.5, damping: 0.6)
  public static let bouncySpring = Animation.spring(response: 0.5, dampingFraction: 0.6)

  /// Snappy spring for quick feedback (response: 0.3, damping: 0.9)
  public static let snappySpring = Animation.spring(response: 0.3, dampingFraction: 0.9)

  /// Overdamped spring for smooth momentum (response: 0.8, damping: 1.0)
  public static let overdampedSpring = Animation.spring(response: 0.8, dampingFraction: 1.0)

  // MARK: - Timing Curves

  /// Standard ease in-out (0.3s)
  public static let easeInOut = Animation.easeInOut(duration: 0.3)

  /// Quick fade (0.2s)
  public static let quickFade = Animation.easeOut(duration: 0.2)

  /// Slow ease (0.5s)
  public static let slowEase = Animation.easeInOut(duration: 0.5)

  // MARK: - Mode-Aware Animations

  /// Returns appropriate animation based on current mode
  @MainActor
  public static func animation(for mode: AnimationMode, base: Animation) -> Animation? {
    switch mode {
    case .full:
      return base
    case .reduced:
      // Simplified version - shorter duration
      return .easeInOut(duration: 0.2)
    case .minimal:
      // No animation
      return nil
    }
  }

  /// Returns animation based on current global settings
  @MainActor
  public static func animation(base: Animation) -> Animation? {
    animation(for: AnimationSettings.shared.effectiveMode, base: base)
  }

  // MARK: - Stagger Delays

  /// Standard stagger delay for list items (50ms)
  public static let standardStagger: Double = 0.05

  /// Quick stagger for fast reveals (30ms)
  public static let quickStagger: Double = 0.03

  /// Slow stagger for dramatic effect (100ms)
  public static let slowStagger: Double = 0.1
}
