//
//  CelebrationView.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

/// Celebration animation styles
public enum CelebrationStyle {
  /// Refined: Scale pulse + soft glow (default)
  case refined

  /// Minimal: Check mark only
  case minimal

  /// Joyful: Refined + subtle shimmer
  case joyful
}

/// Celebration haptic feedback patterns
public enum CelebrationHaptic {
  /// Triple light taps
  case success

  /// Crescendo pattern (light → medium → heavy)
  case achievement

  /// No haptic feedback
  case none
}

/// Refined celebration animation for milestones
public struct CelebrationView: View {

  // MARK: - Configuration

  /// Celebration style
  private let style: CelebrationStyle

  /// Animation duration in seconds
  private let duration: TimeInterval

  /// Haptic feedback pattern
  private let haptic: CelebrationHaptic

  /// Callback when celebration completes
  private let onComplete: (() -> Void)?

  // MARK: - State

  /// Current animation phase (0.0 to 1.0)
  @State private var animationPhase: CGFloat = 0

  /// Whether celebration is visible
  @State private var isVisible: Bool = false

  /// Scale for pulse animation
  @State private var scale: CGFloat = 0.8

  /// Opacity for glow effect
  @State private var glowOpacity: Double = 0

  /// Environment values
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.accessibilityDifferentiateWithoutColor) private var highContrast

  // MARK: - Initialization

  /// Creates a celebration view
  /// - Parameters:
  ///   - style: Celebration style (default: .refined)
  ///   - duration: Animation duration in seconds (default: 2.0)
  ///   - haptic: Haptic feedback pattern (default: .success)
  ///   - onComplete: Callback when celebration completes
  public init(
    style: CelebrationStyle = .refined,
    duration: TimeInterval = 2.0,
    haptic: CelebrationHaptic = .success,
    onComplete: (() -> Void)? = nil
  ) {
    self.style = style
    self.duration = duration
    self.haptic = haptic
    self.onComplete = onComplete
  }

  // MARK: - Body

  public var body: some View {
    ZStack {
      if isVisible {
        celebrationContent
          .scaleEffect(scale)
          .opacity(isVisible ? 1.0 : 0.0)
          .transition(.opacity)
      }
    }
    .onAppear {
      startCelebration()
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Success")
    .accessibilityHidden(true) // Decorative animation
  }

  // MARK: - Views

  /// Main celebration content based on style
  @ViewBuilder
  private var celebrationContent: some View {
    switch style {
    case .refined:
      refinedCelebration
    case .minimal:
      minimalCelebration
    case .joyful:
      refinedCelebration // Same as refined for now
    }
  }

  /// Refined celebration: Pulse + glow
  private var refinedCelebration: some View {
    ZStack {
      // Glow effect
      if !reduceMotion {
        Circle()
          .fill(Color.oldMoney.accent.opacity(glowOpacity * glowMultiplier))
          .blur(radius: 20)
          .frame(width: 100, height: 100)
      }

      // Check mark icon
      Image(systemName: "checkmark.circle.fill")
        .font(.system(size: celebrationIconSize))
        .foregroundStyle(Color.oldMoney.accent)
    }
  }

  /// Minimal celebration: Check mark only
  private var minimalCelebration: some View {
    Image(systemName: "checkmark.circle.fill")
      .font(.system(size: celebrationIconSize))
      .foregroundStyle(Color.oldMoney.accent)
  }

  // MARK: - Computed Properties

  /// Icon size scaled for accessibility
  @ScaledMetric private var celebrationIconSize: CGFloat = 60

  /// Glow opacity multiplier for high contrast
  private var glowMultiplier: Double {
    highContrast ? 0.5 : 0.3
  }

  // MARK: - Actions

  /// Starts the celebration animation sequence
  private func startCelebration() {
    isVisible = true

    if reduceMotion {
      // Reduce Motion: Simple fade
      withAnimation(AnimationEngine.adaptiveCelebration()) {
        scale = 1.0
      }

      // Auto-dismiss
      DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        dismissCelebration()
      }
    } else {
      // Full animation sequence
      animateSequence()
    }

    // Trigger haptics
    triggerHaptics()
  }

  /// Full animation sequence: Fade in → Pulse → Glow → Fade out
  private func animateSequence() {
    // Phase 1: Fade in (200ms)
    withAnimation(.easeOut(duration: 0.2)) {
      scale = 1.0
    }

    // Phase 2: Pulse (600ms) - starts at 200ms
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      withAnimation(AnimationEngine.celebrationPulse) {
        scale = 1.05
      }

      // Return to normal after pulse
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
        withAnimation(AnimationEngine.celebrationPulse) {
          scale = 1.0
        }
      }
    }

    // Phase 3: Glow (800ms) - starts at 200ms
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      withAnimation(AnimationEngine.celebrationGlow) {
        glowOpacity = 1.0
      }

      // Fade glow
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        withAnimation(AnimationEngine.celebrationGlow) {
          glowOpacity = 0
        }
      }
    }

    // Phase 4: Fade out (400ms) - starts at 1.6s
    let fadeOutDelay = duration - 0.4
    DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDelay) {
      withAnimation(AnimationEngine.celebrationFade) {
        isVisible = false
      }

      // Call completion
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
        onComplete?()
      }
    }
  }

  /// Dismisses the celebration
  private func dismissCelebration() {
    withAnimation(AnimationEngine.celebrationFade) {
      isVisible = false
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
      onComplete?()
    }
  }

  /// Triggers haptic feedback based on pattern
  private func triggerHaptics() {
    guard !HapticEngine.shared.shouldSuppressHaptics else { return }

    switch haptic {
    case .success:
      // Triple light taps
      HapticEngine.shared.light()

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        HapticEngine.shared.light()
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        HapticEngine.shared.medium()
      }

    case .achievement:
      // Crescendo
      HapticEngine.shared.crescendo()

    case .none:
      break
    }
  }
}
