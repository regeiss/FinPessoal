// FinPessoal/Code/Animation/Engine/AnimationMode.swift
import Foundation

/// Animation mode determining the complexity of animations shown to the user
@MainActor
public enum AnimationMode: String, Codable, CaseIterable {
  /// Full animations with particles, complex transitions, parallax
  case full

  /// Reduced animations - no particles, simplified transitions, smooth fades
  case reduced

  /// Minimal animations - instant transitions, fade-only effects
  case minimal

  /// Display name for UI
  var displayName: String {
    switch self {
    case .full:
      return "Full Experience"
    case .reduced:
      return "Reduced Motion"
    case .minimal:
      return "Minimal Motion"
    }
  }

  /// Description for accessibility
  var description: String {
    switch self {
    case .full:
      return "All animations enabled including particles and complex effects"
    case .reduced:
      return "Simplified animations without decorative effects"
    case .minimal:
      return "Minimal animations with instant transitions"
    }
  }
}
