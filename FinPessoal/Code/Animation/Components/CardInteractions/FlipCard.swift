//
//  FlipCard.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

/// A card component with 3D flip transition between front and back views
public struct FlipCard<Front: View, Back: View>: View {

  // MARK: - Configuration

  /// Axis of rotation
  private let axis: FlipAxis

  /// Animation duration in seconds
  private let duration: TimeInterval

  /// Optional auto-flip back duration (nil = no auto-flip)
  private let autoFlipBack: TimeInterval?

  /// Front view builder
  private let front: Front

  /// Back view builder
  private let back: Back

  // MARK: - State

  /// Whether card is currently flipped to back
  @State private var isFlipped: Bool = false

  /// Current rotation angle in degrees
  @State private var rotationAngle: Double = 0

  /// Timer for auto-flip back
  @State private var autoFlipTimer: Task<Void, Never>?

  /// Environment values
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // MARK: - Initialization

  /// Creates a flip card with 3D rotation transition
  /// - Parameters:
  ///   - axis: Rotation axis (.vertical or .horizontal), default .vertical
  ///   - duration: Animation duration in seconds, default 0.4
  ///   - autoFlipBack: Optional duration to auto-flip back (nil = disabled)
  ///   - front: Front view builder
  ///   - back: Back view builder
  public init(
    axis: FlipAxis = .vertical,
    duration: TimeInterval = 0.4,
    autoFlipBack: TimeInterval? = nil,
    @ViewBuilder front: () -> Front,
    @ViewBuilder back: () -> Back
  ) {
    self.axis = axis
    self.duration = duration
    self.autoFlipBack = autoFlipBack
    self.front = front()
    self.back = back()
  }

  // MARK: - Body

  public var body: some View {
    ZStack {
      // Front view (visible when rotationAngle < 90)
      if rotationAngle < 90 {
        front
          .opacity(frontOpacity)
          .rotation3DEffect(
            .degrees(rotationAngle),
            axis: axisVector,
            perspective: 0.5
          )
      }

      // Back view (visible when rotationAngle >= 90)
      if rotationAngle >= 90 {
        back
          .opacity(backOpacity)
          .rotation3DEffect(
            .degrees(180 - rotationAngle),
            axis: axisVector,
            perspective: 0.5
          )
      }
    }
    .onTapGesture {
      flipCard()
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(isFlipped ? backAccessibilityLabel : frontAccessibilityLabel)
    .accessibilityHint("Double tap to flip card")
    .accessibilityAddTraits(.isButton)
    .accessibilityAction {
      flipCard()
    }
  }

  // MARK: - Computed Properties

  /// Rotation axis as 3D vector
  private var axisVector: (x: CGFloat, y: CGFloat, z: CGFloat) {
    switch axis {
    case .vertical:
      return (x: 0, y: 1, z: 0) // Y-axis rotation
    case .horizontal:
      return (x: 1, y: 0, z: 0) // X-axis rotation
    }
  }

  /// Front view opacity (fade out from 0° to 90°)
  private var frontOpacity: Double {
    guard rotationAngle > 0 else { return 1.0 }
    guard rotationAngle < 90 else { return 0.0 }
    return 1.0 - (rotationAngle / 90)
  }

  /// Back view opacity (fade in from 90° to 180°)
  private var backOpacity: Double {
    guard rotationAngle >= 90 else { return 0.0 }
    guard rotationAngle < 180 else { return 1.0 }
    return (rotationAngle - 90) / 90
  }

  /// Accessibility label for front side
  private var frontAccessibilityLabel: String {
    "Card front side"
  }

  /// Accessibility label for back side
  private var backAccessibilityLabel: String {
    "Card back side"
  }

  // MARK: - Actions

  /// Flips the card with animation
  private func flipCard() {
    // Cancel auto-flip timer if active
    autoFlipTimer?.cancel()
    autoFlipTimer = nil

    // Light haptic at flip start
    HapticEngine.shared.light()

    // Toggle flip state
    isFlipped.toggle()

    // Animate rotation
    let targetAngle: Double = isFlipped ? 180 : 0

    if reduceMotion {
      // Reduce Motion: Use crossfade instead of 3D rotation
      withAnimation(.linear(duration: 0.25)) {
        rotationAngle = targetAngle
      }
    } else {
      // Full animation: 3D rotation with spring
      withAnimation(AnimationEngine.adaptiveFlip()) {
        rotationAngle = targetAngle
      }
    }

    // Schedule auto-flip back if enabled and flipping to back
    if let autoFlipDuration = autoFlipBack, isFlipped {
      autoFlipTimer = Task {
        try? await Task.sleep(nanoseconds: UInt64(autoFlipDuration * 1_000_000_000))

        // Check if still flipped (user might have manually flipped back)
        guard isFlipped else { return }

        // Flip back automatically
        await MainActor.run {
          flipCard()
        }
      }
    }
  }
}

// MARK: - FlipAxis

/// Axis of rotation for flip animation
public enum FlipAxis {
  /// Y-axis rotation (default) - card flips horizontally
  case vertical

  /// X-axis rotation - card flips vertically
  case horizontal
}
