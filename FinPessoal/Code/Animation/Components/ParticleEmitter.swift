// FinPessoal/Code/Animation/Components/ParticleEmitter.swift
import SwiftUI

/// Particle emitter preset configurations
public enum ParticlePreset {
  case goldShimmer
  case celebration
  case warning
  case confetti       // Vacation - multi-colour confetti
  case hearts         // Wedding - pink/rose hearts
  case stars          // Retirement - gold/bronze stars
  case sparkle        // House/Education - gold sparkles
  case coinsBurst     // Dashboard milestones - gold coin shower
}

/// Particle system for visual effects
public struct ParticleEmitter: View {
  public let preset: ParticlePreset
  @State private var particles: [Particle] = []
  @State private var isActive = false
  @MainActor private let settings = AnimationSettings.shared

  public init(preset: ParticlePreset) {
    self.preset = preset
  }

  public var body: some View {
    // Particles only shown in full mode
    guard settings.shouldShowParticles else {
      return AnyView(EmptyView())
    }

    return AnyView(
      TimelineView(.animation) { timeline in
        Canvas { context, size in
          let now = timeline.date.timeIntervalSinceReferenceDate

          for particle in particles {
            let opacity = particle.life
            var particleContext = context
            particleContext.opacity = opacity

            let rect = CGRect(
              x: particle.position.x - particle.size / 2,
              y: particle.position.y - particle.size / 2,
              width: particle.size,
              height: particle.size
            )

            particleContext.fill(
              Circle().path(in: rect),
              with: .color(particle.color)
            )
          }
        }
        .onAppear {
          startEmitting()
        }
      }
    )
  }

  private func startEmitting() {
    guard settings.shouldShowParticles else { return }

    // Generate particles based on preset
    let particleCount: Int
    let colors: [Color]

    switch preset {
    case .goldShimmer:
      particleCount = 20
      colors = [Color(red: 184/255, green: 150/255, blue: 92/255)]
    case .celebration:
      particleCount = 50
      colors = [
        Color(red: 184/255, green: 150/255, blue: 92/255),
        Color(red: 212/255, green: 186/255, blue: 138/255)
      ]
    case .warning:
      particleCount = 15
      colors = [Color(red: 232/255, green: 177/255, blue: 92/255)]
    case .confetti:
      particleCount = 60
      colors = [
        Color(red: 0.25, green: 0.55, blue: 0.95), // blue
        Color(red: 0.35, green: 0.85, blue: 0.90), // cyan
        Color(red: 0.95, green: 0.85, blue: 0.25)  // yellow
      ]
    case .hearts:
      particleCount = 40
      colors = [
        Color(red: 0.96, green: 0.47, blue: 0.67), // rose
        Color(red: 0.98, green: 0.75, blue: 0.82), // pink
        Color(red: 0.72, green: 0.59, blue: 0.36)  // gold
      ]
    case .stars:
      particleCount = 45
      colors = [
        Color(red: 0.72, green: 0.59, blue: 0.36), // gold
        Color(red: 0.80, green: 0.60, blue: 0.35), // bronze
        Color(red: 0.92, green: 0.82, blue: 0.60)  // light gold
      ]
    case .sparkle:
      particleCount = 35
      colors = [
        Color(red: 0.72, green: 0.59, blue: 0.36), // gold
        Color(red: 0.90, green: 0.90, blue: 0.95), // silver-white
        Color(red: 0.85, green: 0.75, blue: 0.95)  // lavender (education)
      ]
    case .coinsBurst:
      particleCount = 80
      colors = [
        Color(red: 0.72, green: 0.59, blue: 0.36), // gold
        Color(red: 0.84, green: 0.72, blue: 0.45), // light gold
        Color(red: 0.58, green: 0.47, blue: 0.25)  // dark gold
      ]
    }

    particles = (0..<particleCount).map { _ in
      Particle(
        position: CGPoint(
          x: CGFloat.random(in: -50...50),
          y: CGFloat.random(in: -50...50)
        ),
        velocity: CGPoint(
          x: CGFloat.random(in: -2...2),
          y: CGFloat.random(in: -3...(-1))
        ),
        life: 1.0,
        size: CGFloat.random(in: 2...6),
        color: colors.randomElement() ?? colors[0]
      )
    }
  }
}

/// Particle data structure
struct Particle {
  var position: CGPoint
  var velocity: CGPoint
  var life: Double
  var size: CGFloat
  var color: Color
}
