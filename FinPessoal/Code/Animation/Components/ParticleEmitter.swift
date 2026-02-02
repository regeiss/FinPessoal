// FinPessoal/Code/Animation/Components/ParticleEmitter.swift
import SwiftUI

/// Particle emitter preset configurations
public enum ParticlePreset {
  case goldShimmer
  case celebration
  case warning
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
