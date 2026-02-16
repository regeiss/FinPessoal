//
//  SwipeGestureHandler.swift
//  FinPessoal
//
//  Created by Claude Code on 15/02/26.
//

import SwiftUI
import Combine

/// Manages swipe gesture state and physics for SwipeableRow
@MainActor
class SwipeGestureHandler: ObservableObject {

  // MARK: - Published State

  /// Current horizontal offset from swipe gesture
  @Published var offset: CGFloat = 0

  /// Whether the user is currently dragging
  @Published var isDragging: Bool = false

  /// Which side is currently revealed (if any)
  @Published var revealedSide: SwipeSide? = nil

  // MARK: - Private State

  /// Whether threshold haptic has been triggered for current swipe
  private var hasTriggeredHaptic = false

  // MARK: - Types

  /// Side of the swipe action reveal
  enum SwipeSide {
    case leading  // Swipe right (reveal leading actions)
    case trailing // Swipe left (reveal trailing actions)
  }

  // MARK: - Drag Handling

  /// Handles drag gesture changes with resistance curve
  /// - Parameters:
  ///   - value: The drag gesture value
  ///   - maxDistance: Maximum swipe distance allowed
  func handleDragChanged(_ value: DragGesture.Value, maxDistance: CGFloat) {
    isDragging = true

    // Get raw translation
    let translation = value.translation.width

    // Apply resistance curve (rubber band effect)
    // As we approach maxDistance, resistance increases
    let normalizedDistance = abs(translation) / maxDistance
    let resistance = min(normalizedDistance, 1.0)
    let dampenedOffset = translation * (1 - resistance * 0.3)

    // Clamp to max distance in both directions
    offset = min(maxDistance, max(-maxDistance, dampenedOffset))

    // Trigger haptic at threshold (50% of max distance)
    // Only trigger once per swipe gesture
    let threshold = maxDistance * 0.5
    if abs(offset) > threshold && !hasTriggeredHaptic {
      HapticEngine.shared.medium()
      hasTriggeredHaptic = true
    }
  }

  /// Handles drag gesture end, determining if actions should reveal
  /// - Parameters:
  ///   - threshold: Distance threshold to commit the swipe
  ///   - maxDistance: Maximum swipe distance allowed
  ///   - leadingActionsCount: Number of leading actions available
  ///   - trailingActionsCount: Number of trailing actions available
  func handleDragEnded(
    threshold: CGFloat,
    maxDistance: CGFloat,
    leadingActionsCount: Int,
    trailingActionsCount: Int
  ) {
    isDragging = false

    // Check if swipe passed the threshold
    let passedThreshold = abs(offset) > threshold

    // Determine if actions are available on swiped side
    let hasLeadingActions = leadingActionsCount > 0 && offset > 0
    let hasTrailingActions = trailingActionsCount > 0 && offset < 0

    if passedThreshold && (hasLeadingActions || hasTrailingActions) {
      // Commit swipe - reveal actions
      revealedSide = offset > 0 ? .leading : .trailing
      HapticEngine.shared.selection()

      // Snap to max distance to fully reveal actions
      offset = offset > 0 ? maxDistance : -maxDistance
    } else {
      // Bounce back to center
      offset = 0
      hasTriggeredHaptic = false
    }
  }

  /// Resets the gesture handler to initial state
  func reset() {
    offset = 0
    revealedSide = nil
    hasTriggeredHaptic = false
    isDragging = false
  }

  // MARK: - Query Methods

  /// Whether actions are currently revealed
  var isRevealed: Bool {
    revealedSide != nil
  }

  /// Calculate the progress of the swipe (0.0 to 1.0)
  /// - Parameter maxDistance: Maximum swipe distance
  /// - Returns: Swipe progress ratio
  func swipeProgress(maxDistance: CGFloat) -> CGFloat {
    guard maxDistance > 0 else { return 0 }
    return min(abs(offset) / maxDistance, 1.0)
  }

  /// Calculate opacity for action reveal (fades in from 30px to 60px)
  /// - Parameter maxDistance: Maximum swipe distance
  /// - Returns: Opacity value (0.0 to 1.0)
  func actionOpacity(maxDistance: CGFloat) -> CGFloat {
    let absOffset = abs(offset)

    // Start fading in at 30px
    guard absOffset > 30 else { return 0 }

    // Fully visible at 60px
    guard absOffset < 60 else { return 1.0 }

    // Linear interpolation between 30px and 60px
    return (absOffset - 30) / 30
  }
}
