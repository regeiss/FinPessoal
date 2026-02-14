// FinPessoal/Code/Animation/Engine/AnimationEngine+Charts.swift
import SwiftUI

extension AnimationEngine {

  // MARK: - Chart Animation Constants

  /// Initial delay before chart reveal starts
  public static let chartInitialDelay: Double = 0.3

  /// Fade duration for chart data morphing
  public static let chartFadeDuration: Double = 0.15

  // MARK: - Chart Animations

  /// Chart reveal animation (300ms with stagger support)
  static func chartReveal(delay: Double = 0) -> Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return easeInOut.delay(delay)
    case .reduced:
      return .linear(duration: 0.15).delay(delay)
    case .minimal:
      return nil
    }
  }

  /// Chart data morph animation (smooth transition)
  static var chartMorph: Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return gentleSpring
    case .reduced:
      return .linear(duration: 0.15)
    case .minimal:
      return nil
    }
  }

  /// Chart selection animation (subtle scale)
  static var chartSelection: Animation? {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return snappySpring
    case .reduced:
      return .linear(duration: 0.15)
    case .minimal:
      return .linear(duration: 0.05)
    }
  }

  /// Selection scale factor (mode-aware)
  static var selectionScale: CGFloat {
    switch AnimationSettings.shared.effectiveMode {
    case .full:
      return 1.05 // 5% larger
    case .reduced:
      return 1.02 // 2% larger
    case .minimal:
      return 1.0 // No scale
    }
  }
}
