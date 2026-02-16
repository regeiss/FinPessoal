//
//  SwipeableRow.swift
//  FinPessoal
//
//  Created by Claude Code on 16/02/26.
//

import SwiftUI

/// A row component with physics-based swipe gestures revealing custom actions
public struct SwipeableRow<Content: View>: View {

  // MARK: - Configuration

  /// Leading actions (revealed on swipe right)
  private let leadingActions: [SwipeAction]

  /// Trailing actions (revealed on swipe left)
  private let trailingActions: [SwipeAction]

  /// Threshold ratio (0.0-1.0) to commit swipe, default 0.5 (50% of max distance)
  private let threshold: CGFloat

  /// Maximum swipe distance in points, default 120
  private let maxSwipeDistance: CGFloat

  /// Content view to display
  private let content: Content

  // MARK: - State

  /// Gesture handler managing swipe state
  @StateObject private var gestureHandler = SwipeGestureHandler()

  /// Current animation mode
  @Environment(\.colorScheme) private var colorScheme

  /// Accessibility reduce motion
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // MARK: - Initialization

  /// Creates a swipeable row with custom actions
  /// - Parameters:
  ///   - leadingActions: Actions revealed on swipe right
  ///   - trailingActions: Actions revealed on swipe left
  ///   - threshold: Swipe threshold ratio (0.0-1.0), default 0.5
  ///   - maxSwipeDistance: Maximum swipe distance in points, default 120
  ///   - content: Content view builder
  public init(
    leadingActions: [SwipeAction] = [],
    trailingActions: [SwipeAction] = [],
    threshold: CGFloat = 0.5,
    maxSwipeDistance: CGFloat = 120,
    @ViewBuilder content: () -> Content
  ) {
    self.leadingActions = leadingActions
    self.trailingActions = trailingActions
    self.threshold = max(0, min(1, threshold)) // Clamp to 0-1
    self.maxSwipeDistance = maxSwipeDistance
    self.content = content()
  }

  // MARK: - Body

  public var body: some View {
    ZStack(alignment: .center) {
      // Background: Action buttons (revealed behind content)
      actionsBackgroundView

      // Foreground: Swipeable content
      content
        .offset(x: gestureHandler.offset)
        .shadow(
          color: .black.opacity(shadowOpacity),
          radius: shadowRadius,
          x: 0,
          y: 2
        )
        .gesture(swipeGesture)
        .animation(swipeAnimation, value: gestureHandler.offset)
        .animation(swipeAnimation, value: gestureHandler.isDragging)
    }
    .accessibilityElement(children: .combine)
    .accessibilityActions {
      // Expose actions as VoiceOver custom actions
      accessibilityActionsView
    }
  }

  // MARK: - Views

  /// Background view showing action buttons
  @ViewBuilder
  private var actionsBackgroundView: some View {
    GeometryReader { geometry in
      HStack(spacing: 0) {
        // Leading actions (left side, revealed on swipe right)
        if gestureHandler.offset > 0 && !leadingActions.isEmpty {
          HStack(spacing: 0) {
            ForEach(leadingActions) { action in
              actionButton(action: action, geometry: geometry)
            }
          }
          .frame(width: abs(gestureHandler.offset))
          .opacity(gestureHandler.actionOpacity(maxDistance: maxSwipeDistance))
        }

        Spacer()

        // Trailing actions (right side, revealed on swipe left)
        if gestureHandler.offset < 0 && !trailingActions.isEmpty {
          HStack(spacing: 0) {
            ForEach(trailingActions) { action in
              actionButton(action: action, geometry: geometry)
            }
          }
          .frame(width: abs(gestureHandler.offset))
          .opacity(gestureHandler.actionOpacity(maxDistance: maxSwipeDistance))
        }
      }
    }
  }

  /// Individual action button
  @ViewBuilder
  private func actionButton(action: SwipeAction, geometry: GeometryProxy) -> some View {
    Button {
      Task {
        await executeAction(action)
      }
    } label: {
      VStack(spacing: 4) {
        Image(systemName: action.icon)
          .font(.title3)
          .fontWeight(.semibold)

        Text(action.title)
          .font(.caption2)
          .fontWeight(.medium)
      }
      .foregroundColor(.white)
      .frame(width: 60, height: geometry.size.height)
      .background(
        action.tint
          .overlay(.ultraThinMaterial.opacity(0.2))
      )
    }
    .buttonStyle(.plain)
  }

  /// VoiceOver accessibility actions
  @ViewBuilder
  private var accessibilityActionsView: some View {
    // Leading actions
    ForEach(leadingActions) { action in
      Button(action.title) {
        Task {
          await executeAction(action)
        }
      }
    }

    // Trailing actions
    ForEach(trailingActions) { action in
      Button(action.title) {
        Task {
          await executeAction(action)
        }
      }
    }
  }

  // MARK: - Gestures

  /// Drag gesture for swipe interaction
  private var swipeGesture: some Gesture {
    DragGesture(minimumDistance: 10)
      .onChanged { value in
        gestureHandler.handleDragChanged(value, maxDistance: maxSwipeDistance)
      }
      .onEnded { _ in
        let thresholdDistance = maxSwipeDistance * threshold
        gestureHandler.handleDragEnded(
          threshold: thresholdDistance,
          maxDistance: maxSwipeDistance,
          leadingActionsCount: leadingActions.count,
          trailingActionsCount: trailingActions.count
        )
      }
  }

  // MARK: - Animation

  /// Swipe animation respecting animation mode
  private var swipeAnimation: Animation? {
    if reduceMotion {
      return .linear(duration: 0.2)
    }

    if gestureHandler.isDragging {
      return AnimationEngine.adaptiveSwipe()
    } else if gestureHandler.isRevealed {
      return AnimationEngine.adaptiveReset()
    } else {
      return AnimationEngine.adaptiveBounce()
    }
  }

  // MARK: - Computed Properties

  /// Shadow opacity increases as content moves (depth cue)
  private var shadowOpacity: Double {
    let progress = gestureHandler.swipeProgress(maxDistance: maxSwipeDistance)
    return 0.05 + (progress * 0.15) // Range: 0.05 to 0.20
  }

  /// Shadow radius increases as content moves
  private var shadowRadius: CGFloat {
    let progress = gestureHandler.swipeProgress(maxDistance: maxSwipeDistance)
    return 2 + (progress * 6) // Range: 2 to 8
  }

  // MARK: - Actions

  /// Executes an action and resets the swipe
  private func executeAction(_ action: SwipeAction) async {
    // Execute the action
    await action.action()

    // Reset swipe state with animation
    withAnimation(AnimationEngine.adaptiveReset()) {
      gestureHandler.reset()
    }
  }
}
