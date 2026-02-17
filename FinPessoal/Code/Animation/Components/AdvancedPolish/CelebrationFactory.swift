//
//  CelebrationFactory.swift
//  FinPessoal
//
//  Created by Claude Code on 17/02/26.
//

import SwiftUI

/// Milestone threshold tiers for Dashboard savings celebrations
enum MilestoneTier: Equatable {
  case small   // $1k
  case medium  // $5k–$10k
  case large   // $25k
  case epic    // $50k–$100k

  /// Derives the tier from a savings amount that just crossed a milestone
  static func tier(for amount: Double) -> MilestoneTier {
    switch amount {
    case ..<5000:   return .small
    case ..<25000:  return .medium
    case ..<50000:  return .large
    default:        return .epic
    }
  }
}

/// Maps GoalCategory and MilestoneTier to CelebrationConfig
class CelebrationFactory {

  // MARK: - Goal Category Configs

  /// Returns the celebration config for a completed goal category
  static func config(for category: GoalCategory) -> CelebrationConfig {
    switch category {
    case .vacation:
      return CelebrationConfig(
        style: .joyful,
        haptic: .achievement,
        duration: 2.5,
        particlePreset: .confetti,
        accentColor: .blue,
        icon: "airplane",
        message: "Bon voyage! 🏖️"
      )
    case .house:
      return CelebrationConfig(
        style: .joyful,
        haptic: .achievement,
        duration: 2.5,
        particlePreset: .sparkle,
        accentColor: .green,
        icon: "house.fill",
        message: "Welcome home! 🏠"
      )
    case .wedding:
      return CelebrationConfig(
        style: .joyful,
        haptic: .achievement,
        duration: 3.0,
        particlePreset: .hearts,
        accentColor: Color(red: 0.96, green: 0.47, blue: 0.67), // rose
        icon: "heart.fill",
        message: "Congratulations! 💍"
      )
    case .retirement:
      return CelebrationConfig(
        style: .joyful,
        haptic: .achievement,
        duration: 2.5,
        particlePreset: .stars,
        accentColor: Color(red: 0.72, green: 0.59, blue: 0.36), // gold
        icon: "star.fill",
        message: "Enjoy your freedom! 🌟"
      )
    case .education:
      return CelebrationConfig(
        style: .joyful,
        haptic: .achievement,
        duration: 2.5,
        particlePreset: .sparkle,
        accentColor: .purple,
        icon: "graduationcap.fill",
        message: "Knowledge achieved! 🎓"
      )
    default:
      // Car, Investment, Emergency, Other — standard refined
      return CelebrationConfig(
        style: .refined,
        haptic: .achievement,
        duration: 2.0,
        particlePreset: nil,
        accentColor: Color.oldMoney.accent,
        icon: "checkmark.circle.fill",
        message: nil
      )
    }
  }

  // MARK: - Milestone Tier Configs

  /// Returns the celebration config for a savings milestone tier
  static func config(for tier: MilestoneTier) -> CelebrationConfig {
    switch tier {
    case .small:
      return CelebrationConfig(
        style: .refined,
        haptic: .success,
        duration: 1.5,
        particlePreset: .coinsBurst,
        accentColor: Color(red: 0.72, green: 0.59, blue: 0.36),
        icon: "dollarsign.circle.fill",
        message: "First milestone! ✨"
      )
    case .medium:
      return CelebrationConfig(
        style: .refined,
        haptic: .achievement,
        duration: 2.0,
        particlePreset: .coinsBurst,
        accentColor: Color(red: 0.72, green: 0.59, blue: 0.36),
        icon: "dollarsign.circle.fill",
        message: "Growing strong! 💪"
      )
    case .large:
      return CelebrationConfig(
        style: .joyful,
        haptic: .achievement,
        duration: 2.0,
        particlePreset: .coinsBurst,
        accentColor: Color(red: 0.72, green: 0.59, blue: 0.36),
        icon: "star.circle.fill",
        message: "Quarter century! 🌟"
      )
    case .epic:
      return CelebrationConfig(
        style: .joyful,
        haptic: .achievement,
        duration: 3.0,
        particlePreset: .coinsBurst,
        accentColor: Color(red: 0.72, green: 0.59, blue: 0.36),
        icon: "trophy.fill",
        message: "Incredible savings! 🏆"
      )
    }
  }
}
