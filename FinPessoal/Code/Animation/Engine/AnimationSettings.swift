// FinPessoal/Code/Animation/Engine/AnimationSettings.swift
import SwiftUI
import Combine

/// Global animation settings managing animation mode and accessibility
@MainActor
public class AnimationSettings: ObservableObject {
  public static let shared = AnimationSettings()

  /// Current animation mode set by user
  @Published public var mode: AnimationMode = .full

  /// Whether to respect system reduce motion setting
  @Published public var respectReduceMotion: Bool = true

  /// System reduce motion setting (injected for testing)
  public var systemReduceMotionEnabled: Bool = false

  private init() {
    // Initialize with system setting
    systemReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
  }

  /// Effective mode considering user preference and system settings
  public var effectiveMode: AnimationMode {
    if respectReduceMotion && systemReduceMotionEnabled {
      return .minimal
    }
    return mode
  }

  /// Whether particles should be shown
  public var shouldShowParticles: Bool {
    effectiveMode == .full
  }

  /// Whether complex hero transitions should be used
  public var shouldUseHeroTransitions: Bool {
    effectiveMode != .minimal
  }

  /// Whether parallax effects should be applied
  public var shouldUseParallax: Bool {
    effectiveMode == .full
  }
}
