//
//  CelebrationConfig.swift
//  FinPessoal
//
//  Created by Claude Code on 17/02/26.
//

import SwiftUI

/// Configuration for a themed celebration experience
struct CelebrationConfig {

  /// Base visual style
  let style: CelebrationStyle

  /// Haptic feedback pattern
  let haptic: CelebrationHaptic

  /// Auto-dismiss duration in seconds
  let duration: Double

  /// Optional particle overlay preset (nil = no particles)
  let particlePreset: ParticlePreset?

  /// Accent color for icon and glow
  let accentColor: Color

  /// SF Symbol name for celebration icon
  let icon: String

  /// Optional contextual message shown below icon
  let message: String?

  init(
    style: CelebrationStyle = .refined,
    haptic: CelebrationHaptic = .achievement,
    duration: Double = 2.0,
    particlePreset: ParticlePreset? = nil,
    accentColor: Color = Color.oldMoney.accent,
    icon: String = "checkmark.circle.fill",
    message: String? = nil
  ) {
    self.style = style
    self.haptic = haptic
    self.duration = duration
    self.particlePreset = particlePreset
    self.accentColor = accentColor
    self.icon = icon
    self.message = message
  }
}
